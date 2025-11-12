/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace (AI 검수 V2.1)
/// File          : lib/features/marketplace/services/ai_verification_service.dart
/// Purpose       : AI 검수 시작, 1차 분석, 화면 분기를 담당하는 핵심 서비스
///
/// [V2.1/V2.2 주요 변경 사항 (Job 25, 33, 34, 44)]
/// 1. startVerificationFlow (메인 함수):
///    - [개편안 1] 무료/유료/재사용 로직을 수행합니다. (Job 25)
///      - `isAiFreeTierUsed` (무료 티어) 확인.
///      - 데이터(설명/이미지) 변경 여부를 `aiReportSourceDescription`과 비교.
///      - 데이터가 동일하면 '보고서 재활성화', 다르면 '유료 재생성'을 안내 (TODO: PG연동).
///    - 1차 분석(`initialproductanalysis`) 호출 시, '카테고리명' 힌트를 전달하여
///      AI가 더 정확한 추천샷을 제안하도록 개선되었습니다. (Job 34)
///    - [Fix #3] AI의 이름 예측(prediction)을 무시하고, 사용자의 원본 `productName`을
///      신뢰하여 다음 화면으로 전달합니다. (데이터 오염 방지)
///
/// 2. 화면 분기 로직:
///    - 1차 분석 결과 `missingKeys`가 비어있으면(예: 신발), `AiEvidenceSuggestionScreen`으로
///      이동합니다. (작업 33에서 '빈 화면 스킵' 로직은 작업 34/35의 새 규칙 도입으로 대체됨)
/// ============================================================================
/// lib/features/marketplace/services/ai_verification_service.dart
library;

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_evidence_suggestion_screen.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // listEquals 사용
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AiVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-southeast2');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// AI 규칙을 Firestore에서 불러옵니다. 전용 규칙이 없으면 범용 규칙('generic_v2')을 찾습니다.
  Future<AiVerificationRule?> loadAiRule(String? categoryId) async {
    if (categoryId == null) {
      debugPrint('loadAiRule: categoryId == null -> returning null');
      return null;
    }

    DocumentSnapshot? snap;
    try {
      debugPrint('loadAiRule: fetching ai_verification_rules/$categoryId');
      snap = await _firestore
          .collection('ai_verification_rules')
          .doc(categoryId)
          .get();
      debugPrint('loadAiRule: fetched $categoryId, exists=${snap.exists}');
    } catch (e, st) {
      debugPrint('loadAiRule: error fetching rule for $categoryId: $e');
      debugPrint(st.toString());
      // Don't rethrow; we'll attempt fallback below.
      snap = null;
    }

    if (snap == null || !snap.exists) {
      try {
        debugPrint(
            'loadAiRule: trying fallback ai_verification_rules/generic_v2');
        snap = await _firestore
            .collection('ai_verification_rules')
            .doc('generic_v2')
            .get();
        debugPrint('loadAiRule: fetched generic_v2, exists=${snap.exists}');
      } catch (e, st) {
        debugPrint('loadAiRule: error fetching fallback generic_v2: $e');
        debugPrint(st.toString());
        snap = null;
      }
    }

    try {
      if (snap != null && snap.exists) {
        debugPrint('loadAiRule: returning rule from snapshot (id=${snap.id})');
        return AiVerificationRule.fromSnapshot(snap);
      } else {
        debugPrint(
            'loadAiRule: no rule found for $categoryId and generic_v2 fallback');
      }
    } catch (e, st) {
      debugPrint('loadAiRule: error parsing rule snapshot: $e');
      debugPrint(st.toString());
    }

    return null;
  }

  /// 카테고리 ID를 이용해 대/소분류 이름을 가져옵니다.
  Future<Map<String, String?>> getCategoryNames(
      String subCategoryId, String parentCategoryId,
      {String langCode = 'id'}) async {
    try {
      String fieldFor(String base) {
        switch (langCode) {
          case 'ko':
            return '${base}_ko';
          case 'en':
            return '${base}_en';
          default:
            return '${base}_id';
        }
      }

      final subDoc =
          await _firestore.collection('categories_v2').doc(subCategoryId).get();
      final parentDoc = await _firestore
          .collection('categories_v2')
          .doc(parentCategoryId)
          .get();
      return {
        'subCategoryName':
            subDoc.data()?[fieldFor('name')] ?? subDoc.data()?['name_ko'],
        'parentCategoryName':
            parentDoc.data()?[fieldFor('name')] ?? parentDoc.data()?['name_ko'],
      };
    } catch (e) {
      debugPrint("카테고리 이름을 가져오는 중 오류 발생: $e");
      return {};
    }
  }

  /// AI 검수 전체 흐름을 시작합니다. 규칙에 따라 화면 흐름을 분기합니다.
  Future<void> startVerificationFlow({
    required BuildContext context,
    required AiVerificationRule rule,
    required String productId,
    required String categoryId,
    required List<dynamic> initialImages, // String(URL) or XFile
    required String productName,
    String? productDescription,
    String? productPrice,
  }) async {
    // [V2.1] 먼저 1차 분석을 수행하여 누락된 추천 증거 목록을 확인합니다.
    // Flow split: 무료 티어 / 유료(재사용 or 재생성)

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    // [개편안 1] 이미지 URL 목록 확보
    final List<String> initialUrls = [];
    for (final img in initialImages) {
      if (img is String) initialUrls.add(img);
      if (img is XFile) initialUrls.add(await _uploadImage(img, user.uid));
    }

    // [개편안 1] 상품의 현재 상태(원본 스냅샷) 조회
    final productDoc =
        await _firestore.collection('products').doc(productId).get();
    if (!productDoc.exists) throw Exception("Product not found.");

    final productData = productDoc.data()!;
    final bool isFreeTierUsed = productData['isAiFreeTierUsed'] ?? false;
    final String? savedDesc = productData['aiReportSourceDescription'];
    final List<String> savedImages =
        List<String>.from(productData['aiReportSourceImages'] ?? []);
    final Map<String, dynamic>? savedReport =
        (productData['aiReport'] != null && productData['aiReport'] is Map)
            ? Map<String, dynamic>.from(productData['aiReport'])
            : null;

    // --- 유료/무료/재사용 분기 ---

    if (!isFreeTierUsed) {
      // [시나리오 1: 무료] 첫 검수이므로 무료 진행
      debugPrint("AI 검수: 무료 티어 사용. 1차 분석 시작.");
      await _proceedToAnalysis(context, rule, productId, categoryId,
          initialUrls, productName, productDescription, productPrice);
    } else {
      // [시나리오 2 & 3: 유료]

      // 데이터가 변경되었는지 확인
      bool isIdentical = (productDescription == savedDesc) &&
          listEquals(initialUrls, savedImages);

      if (isIdentical && savedReport != null) {
        // [시나리오 2: 유료-재사용] 데이터 변경 없음.
        // TODO: "유료 재활성화" 결제 팝업 표시
        debugPrint("AI 검수: 유료 재활성화. (데이터 동일)");
        // (결제 성공 시)
        await _firestore.collection('products').doc(productId).update({
          'isAiVerified': true,
          'aiVerificationStatus': 'verified', // 재활성화
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('marketplace.ai.reactivated'.tr())),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        // [시나리오 3: 유료-재생성] 데이터 변경됨.
        // TODO: "유료 신규 보고서" 결제 팝업 표시
        debugPrint("AI 검수: 유료 재생성. (데이터 변경됨)");
        // (결제 성공 시)
        await _proceedToAnalysis(context, rule, productId, categoryId,
            initialUrls, productName, productDescription, productPrice);
      }
    }
  }

  /// [개편안 1] 1차 분석 및 화면 이동 (공통 로직)
  Future<void> _proceedToAnalysis(
    BuildContext context,
    AiVerificationRule rule,
    String productId,
    String categoryId,
    List<String> initialUrls,
    String productName,
    String? productDescription,
    String? productPrice,
  ) async {
    try {
      // [Fix #2] 1차 분석의 품질 향상을 위해 카테고리 이름을 *먼저* 조회합니다.
      String? subName;
      String? parentName;
      try {
        final lang = context.locale.languageCode;
        final nameField =
            lang == 'ko' ? 'name_ko' : (lang == 'en' ? 'name_en' : 'name_id');
        final subDoc =
            await _firestore.collection('categories_v2').doc(categoryId).get();
        subName = subDoc.data()?[nameField] ?? subDoc.data()?['name_ko'];
        final pid = subDoc.data()?['parentId'];
        if (pid is String && pid.isNotEmpty) {
          final pDoc =
              await _firestore.collection('categories_v2').doc(pid).get();
          parentName = pDoc.data()?[nameField] ?? pDoc.data()?['name_ko'];
        }
      } catch (e) {
        debugPrint("카테고리 이름 조회 실패 (1차 분석): $e");
      }

      final initCallable = _functions.httpsCallable('initialproductanalysis');
      final initRes = await initCallable.call({
        'imageUrls': initialUrls,
        'ruleId': rule.id,
        'locale': context.locale.languageCode,
        'categoryName': parentName, // [Fix #2] 힌트 전달
        'subCategoryName': subName, // [Fix #2] 힌트 전달
      });
      final data = initRes.data ?? {};
      // [Fix #3] AI가 예측한 이름이 아닌, 사용자가 입력한 원본 제목을 항상 신뢰합니다.
      final String confirmedName = productName;
      final List<dynamic> missingRaw =
          (data['missing_evidence_list'] as List<dynamic>?) ?? const [];
      final missingKeys = missingRaw.whereType<String>().toList();

      // [Fix #2] '신발' 등 범용 카테고리일 때 빈 제안 화면이 뜨는 문제 해결
      // 부족한 증거가 없으면(missingKeys.isEmpty) 제안 화면을 건너뛰고 바로 리포트 생성
      if (missingKeys.isEmpty && context.mounted) {
        debugPrint("AI 검수: 부족한 증거 없음. 최종 보고서 생성으로 직행.");
        await _generateFinalReportDirectly(
            context,
            rule,
            productId,
            categoryId,
            initialUrls,
            confirmedName,
            productPrice,
            productDescription, <String>[]);
        return; // 흐름 종료
      }

      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AiEvidenceSuggestionScreen(
            productId: productId,
            categoryId: categoryId,
            ruleId: rule.id,
            rule: rule,
            initialImageUrls: initialUrls,
            confirmedProductName: confirmedName,
            userPrice: productPrice,
            userDescription: productDescription,
            categoryName: parentName,
            subCategoryName: subName,
            missingEvidenceKeys: missingKeys,
          ),
        ));
      }
    } catch (e) {
      debugPrint('1차 분석 실패 또는 V2.1 흐름 진입 오류: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'marketplace.error'.tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  /// [Fix #2] 제안 화면을 건너뛸 때 호출할 최종 보고서 생성 함수
  Future<void> _generateFinalReportDirectly(
    BuildContext context,
    AiVerificationRule rule,
    String productId,
    String categoryId,
    List<String> initialUrls,
    String confirmedProductName,
    String? productPrice,
    String? productDescription,
    List<String> skippedItems,
  ) async {
    // 1. 카테고리 이름 조회 (Suggestion Screen의 로직과 동일)
    String? subName;
    String? parentName;
    try {
      final lang = context.locale.languageCode;
      final nameField =
          lang == 'ko' ? 'name_ko' : (lang == 'en' ? 'name_en' : 'name_id');
      final subDoc =
          await _firestore.collection('categories_v2').doc(categoryId).get();
      subName = subDoc.data()?[nameField] ?? subDoc.data()?['name_ko'];
      final pid = subDoc.data()?['parentId'];
      if (pid is String && pid.isNotEmpty) {
        final pDoc =
            await _firestore.collection('categories_v2').doc(pid).get();
        parentName = pDoc.data()?[nameField] ?? pDoc.data()?['name_ko'];
      }
    } catch (_) {}

    // 2. 백엔드 호출
    final callable = _functions.httpsCallable('generatefinalreport');
    final result = await callable.call(<String, dynamic>{
      'imageUrls': {'initial': initialUrls, 'guided': <String, String>{}},
      'ruleId': rule.id,
      'confirmedProductName': confirmedProductName,
      'categoryName': parentName,
      'subCategoryName': subName,
      'userPrice': productPrice,
      'userDescription': productDescription,
      'skipped_items': skippedItems,
      'locale': context.locale.languageCode,
    });

    final reportRaw = (result.data as Map<dynamic, dynamic>?)?['report'];
    final report = (reportRaw != null && reportRaw is Map)
        ? Map<String, dynamic>.from(reportRaw)
        : null;
    if (report == null) {
      throw Exception('AI가 유효한 리포트를 생성하지 못했습니다.');
    }

    // 3. 최종 화면으로 이동 (AiEvidenceSuggestionScreen의 로직과 동일)
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AiFinalReportScreen(
          productId: productId,
          categoryId: categoryId,
          finalReport: report,
          rule: rule,
          initialImages: initialUrls,
          takenShots: <String, XFile>{},
          confirmedProductName: confirmedProductName,
          userPrice: productPrice,
          userDescription: productDescription,
        ),
      ));
    }
  }

  // 이미지 업로드 헬퍼 함수
  Future<String> _uploadImage(XFile image, String userId) async {
    final fileName = '${const Uuid().v4()}${p.extension(image.path)}';
    final ref = _storage.ref().child('product_images/$userId/$fileName');
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }
}

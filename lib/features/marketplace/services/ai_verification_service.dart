import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_evidence_suggestion_screen.dart';
// import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AiVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// AI 규칙을 Firestore에서 불러옵니다. 전용 규칙이 없으면 범용 규칙('generic_v2')을 찾습니다.
  Future<AiVerificationRule?> loadAiRule(String? categoryId) async {
    if (categoryId == null) return null;
    try {
      DocumentSnapshot snap = await _firestore
          .collection('ai_verification_rules')
          .doc(categoryId)
          .get();
      if (!snap.exists) {
        snap = await _firestore
            .collection('ai_verification_rules')
            .doc('generic_v2')
            .get();
      }
      if (snap.exists) {
        return AiVerificationRule.fromSnapshot(snap);
      }
    } catch (e) {
      debugPrint("AI 규칙 로딩 중 오류: $e");
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
    // [Blocker-B Fix] 보고서 권고안(7.3)에 따라 V1 레거시 경로(ai_evidence_collection)로의
    // fallback을 제거하고 V2.1(ai_evidence_suggestion) 흐름으로 일원화합니다.
    try {
      // Ensure URL list
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated.');
      final List<String> initialUrls = [];
      for (final img in initialImages) {
        if (img is String) initialUrls.add(img);
        if (img is XFile) initialUrls.add(await _uploadImage(img, user.uid));
      }

      final initCallable = _functions.httpsCallable('initialproductanalysis');
      final initRes = await initCallable.call({
        'imageUrls': initialUrls,
        'ruleId': rule.id,
        'locale': context.locale.languageCode,
      });
      final data = initRes.data ?? {};
      final String confirmedName =
          (data['prediction'] as String?)?.trim().isNotEmpty == true
              ? data['prediction']
              : productName;
      final List<dynamic> missingRaw =
          (data['missing_evidence_list'] as List<dynamic>?) ?? const [];
      final missingKeys = missingRaw.whereType<String>().toList();

      // V2.1 흐름: 1차 분석 성공 시, '부족 증거가 있든 없든' (missingKeys.isNotEmpty or not)
      // AiEvidenceSuggestionScreen으로 데이터를 넘깁니다.
      // 이 화면은 missingKeys가 비어있으면 '다음' 버튼만 표시하여
      // '최종 리포트 직행 경로(2.4)' 역할을 겸합니다.

      // 카테고리 ko 이름 조회
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
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

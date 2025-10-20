import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_evidence_collection_screen.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

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
      String subCategoryId, String parentCategoryId) async {
    try {
      final subDoc =
          await _firestore.collection('categories_v2').doc(subCategoryId).get();
      final parentDoc = await _firestore
          .collection('categories_v2')
          .doc(parentCategoryId)
          .get();
      return {
        'subCategoryName': subDoc.data()?['name_ko'],
        'parentCategoryName': parentDoc.data()?['name_ko'],
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
    // 1. 규칙에 추가 증거샷이 필요한 경우
    if (rule.requiredShots.isNotEmpty) {
      // TODO: initialproductanalysis를 먼저 호출하여 confirmedProductName을 받아야 함
      // 현재는 productName을 그대로 사용
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AiEvidenceCollectionScreen(
          categoryId: categoryId,
          productId: productId,
          rule: rule,
          initialImages: initialImages,
          confirmedProductName: productName,
        ),
      ));
    }
    // 2. 추가 증거샷이 필요 없는 경우 (범용 규칙)
    else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("User not authenticated.");

        // 이미지 업로드
        final List<String> imageUrls = [];
        for (final image in initialImages) {
          if (image is String) {
            imageUrls.add(image);
          } else if (image is XFile) {
            final url = await _uploadImage(image, user.uid);
            imageUrls.add(url);
          }
        }

        // [핵심 수정] categoryId를 사용하여 parentId를 조회합니다.
        final subCategoryDoc =
            await _firestore.collection('categories_v2').doc(categoryId).get();
        if (!subCategoryDoc.exists) {
          throw Exception("Category with ID $categoryId not found.");
        }
        final parentId = subCategoryDoc.data()?['parentId'] as String?;
        if (parentId == null || parentId.isEmpty) {
          throw Exception(
              "Parent category ID not found for category $categoryId.");
        }

        // 조회한 parentId를 사용하여 카테고리 이름들을 가져옵니다.
        final categoryNames = await getCategoryNames(categoryId, parentId);

        // 최종 리포트 생성 함수 호출
        final callable = _functions.httpsCallable('generatefinalreport');
        final result = await callable.call(<String, dynamic>{
          'imageUrls': {'initial': imageUrls, 'guided': {}},
          'ruleId': rule.id,
          'confirmedProductName': productName,
          'categoryName': categoryNames['parentCategoryName'],
          'subCategoryName': categoryNames['subCategoryName'],
          'userPrice': productPrice,
          'userDescription': productDescription,
        });

        final reportData = result.data['report'] as Map<String, dynamic>?;
        if (reportData == null) {
          throw Exception("AI가 유효한 리포트를 생성하지 못했습니다.");
        }

        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AiFinalReportScreen(
              productId: productId,
              categoryId: categoryId,
              finalReport: reportData,
              rule: rule,
              initialImages: initialImages,
              takenShots: const {},
              confirmedProductName: productName,
              userPrice: productPrice,
            ),
          ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
        }
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

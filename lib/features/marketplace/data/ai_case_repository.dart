// lib/features/marketplace/data/ai_case_repository.dart
/// ============================================================================
/// Bling DocHeader (V3.1 AI Case Repository, 2025-11-18)
/// Module        : Marketplace / Admin
/// File          : lib/features/marketplace/data/ai_case_repository.dart
/// Purpose       : AI 검수/인수 데이터('ai_cases') 및 증거 자료('ai_evidence') 관리.
///
/// [Key Features]
/// 1. Evidence Upload: 현장 사진을 'ai_evidence/{userId}/{date}/takeover' 경로에
///    안전하게 저장 (flutter_image_compress 적용).
/// 2. Backend Calls: 'verifyProductOnSite' 등 Cloud Functions 호출 래핑.
/// 3. Admin Actions: 관리자 직권 승인/반려 시 'ai_cases'와 'products'의 상태를
///    동시에 변경하는 트랜잭션(Batch Write) 로직 제공 ('resolveCaseByAdmin').
/// ============================================================================
library;

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // XFile 사용을 위해 필요
import 'package:uuid/uuid.dart';

/// [AiCaseRepository]
/// AI 검수/인수 프로세스('ai_cases')와 관련된 모든 데이터 접근을 전담하는 클래스입니다.
/// 역할:
/// 1. 증거 이미지(Evidences)를 Firebase Storage에 안전하게 업로드하고 기록.
/// 2. Cloud Functions를 호출하여 실제 AI 분석 및 ai_cases 문서 생성을 요청.
/// 3. 특정 상품의 AI 검수 이력(History) 조회.
class AiCaseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  AiCaseRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-southeast2'),
        _auth = auth ?? FirebaseAuth.instance;

  /// [1] 증거 이미지 업로드 (Multi-Image Upload)
  /// - 현장 인수 시 여러 장(8장 등)을 찍어도 모두 업로드하고 URL 리스트를 반환합니다.
  /// - 저장 경로: ai_evidence/{userId}/{date}/{uuid}.jpg
  Future<List<String>> uploadEvidenceImages({
    required List<XFile> images,
    required String folderName, // 예: 'registration' or 'takeover'
  }) async {
    if (images.isEmpty) return [];

    final user = _auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    final List<String> downloadUrls = [];
    final String dateStr =
        DateTime.now().toIso8601String().split('T').first; // YYYY-MM-DD

    try {
      // 병렬 업로드를 위해 Future.wait 사용 고려 가능하나, 순서 보장을 위해 루프 사용
      for (var image in images) {
        final String uuid = const Uuid().v4();
        final String extension = image.path.split('.').last;
        final String fileName = '$uuid.$extension';

        // 경로: ai_evidence/{uid}/{date}/{folder}/{fileName}
        final Reference ref = _storage
            .ref()
            .child('ai_evidence')
            .child(user.uid)
            .child(dateStr)
            .child(folderName)
            .child(fileName);

        final UploadTask task = ref.putFile(File(image.path));

        // 업로드 진행률 모니터링이 필요하면 task.snapshotEvents 사용 가능
        final TaskSnapshot snapshot = await task;
        final String url = await snapshot.ref.getDownloadURL();

        downloadUrls.add(url);
      }
      return downloadUrls;
    } catch (e) {
      throw Exception('증거 이미지 업로드 실패: $e');
    }
  }

  /// [2] AI 등록/검수 요청 (Cloud Function 호출)
  /// - 이미 업로드된 이미지 URL들을 받아 백엔드에 'enhancement' 케이스 생성을 요청합니다.
  /// - 반환값: 생성된 caseId와 리포트 데이터
  Future<Map<String, dynamic>> requestAiEnhancement({
    required String productId,
    required List<String> evidenceUrls,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('enhanceProductWithAi');

      final result = await callable.call({
        'productId': productId,
        'evidenceImageUrls': evidenceUrls,
        ...?additionalData, // 추가 메타데이터 병합
      });

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('AI 검수 요청 실패: $e');
    }
  }

  /// [3] 현장 인수 검증 요청 (Cloud Function 호출)
  /// - 현장 사진 URL들을 받아 백엔드에 'takeover' 케이스 생성을 요청합니다.
  /// - 기존에는 products를 덮어썼지만, 이제 index.js가 ai_cases 문서를 생성합니다.
  Future<Map<String, dynamic>> requestTakeoverVerification({
    required String productId,
    required List<String> newImageUrls,
  }) async {
    try {
      final HttpsCallable callable =
          _functions.httpsCallable('verifyProductOnSite');

      final result = await callable.call({
        'productId': productId,
        'newImageUrls': newImageUrls,
      });

      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      throw Exception('현장 인수 검증 요청 실패: $e');
    }
  }

  /// [4] 특정 상품의 AI 케이스 이력 조회
  /// - 최신순 정렬
  Stream<QuerySnapshot<Map<String, dynamic>>> getCaseHistoryStream(
      String productId) {
    return _firestore
        .collection('ai_cases')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// [5] 특정 케이스 상세 조회
  Future<DocumentSnapshot<Map<String, dynamic>>> getCaseDetail(String caseId) {
    return _firestore.collection('ai_cases').doc(caseId).get();
  }

  /// [Admin Action] 관리자 직권으로 케이스 및 상품 상태 변경 (Batch Transaction)
  Future<void> resolveCaseByAdmin({
    required String caseId,
    required String productId,
    required bool isApproved, // true=승인(Override), false=거절
    String? reason,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // 1. ai_cases 문서 업데이트
    final caseRef = _firestore.collection('ai_cases').doc(caseId);
    batch.update(caseRef, {
      'status': isApproved ? 'pass' : 'fail',
      'verdict': isApproved ? 'admin_override_pass' : 'admin_confirmed_fail',
      'adminComment': reason,
      'updatedAt': now,
    });

    // 2. products 문서 업데이트
    // 승인 시 -> sold (거래 완료) & verified
    // 거절 시 -> selling (판매중 복귀) & rejected (혹은 suspicious 유지)
    final productRef = _firestore.collection('products').doc(productId);

    if (isApproved) {
      batch.update(productRef, {
        'status': 'sold', // 거래 확정 처리
        'aiVerificationStatus': 'takeover_verified', // 최종 인증 완료
        'updatedAt': now,
      });
    } else {
      batch.update(productRef, {
        'status': 'selling', // 판매 중 상태로 복구 (예약 취소)
        // 'aiVerificationStatus': 'rejected', // 필요 시 상태 변경
        'rejectionReason': reason,
        'updatedAt': now,
      });
    }

    await batch.commit();
  }
}

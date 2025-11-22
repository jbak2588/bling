/// ============================================================================
/// (기존 헤더...)
///
/// 2025-10-31 (작업 35):
///   - '하이브리드 기획안' 6단계: 'jobs_screen'의 필터 탭과 연동.
///   - 'fetchJobs' 함수에 'String? jobType' 파라미터 추가.
///   - 'jobType' 파라미터가 null이 아닐 경우, 'where('jobType', isEqualTo: jobType)'
///     쿼리를 동적으로 추가하여 'regular'/'quick_gig' 필터링 구현.
/// ============================================================================
library;
// (파일 내용...)

// lib/features/jobs/data/job_repository.dart

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 'jobs' 컬렉션의 모든 구인글 목록을 실시간으로 가져옵니다.
  // V V V --- [수정] 사용자의 Province를 기준으로 1차 필터링하도록 변경 --- V V V
  Stream<List<JobModel>> fetchJobs(
      {Map<String, String?>? locationFilter,
      String? jobType,
      String? searchToken}) {
    Query<Map<String, dynamic>> query = _firestore.collection('jobs');

    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    // ✅ [작업 31] jobType 필터 추가
    if (jobType != null && jobType.isNotEmpty) {
      query = query.where('jobType', isEqualTo: jobType);
    }

    // ✅ [검색] searchIndex 기반 필터링 (simple token match)
    if (searchToken != null && searchToken.isNotEmpty) {
      query = query.where('searchIndex', arrayContains: searchToken);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        final fallbackSnapshot = await _firestore
            .collection('jobs')
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .get();
        return fallbackSnapshot.docs
            .map((doc) => JobModel.fromFirestore(doc))
            .toList();
      }
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  // V V V --- [추가] 새로운 구인글을 생성하는 함수 --- V V V
  Future<void> createJob(JobModel job) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception(tr('main.errors.loginRequired'));

    final newJobRef = _firestore.collection('jobs').doc();

    // 사용자의 productIds 배열에도 새 상품 ID 추가
    final userRef = _firestore.collection('users').doc(user.uid);

    final batch = _firestore.batch();
    batch.set(newJobRef, job.toJson());
    batch.update(userRef, {
      'jobIds': FieldValue.arrayUnion([newJobRef.id])
    }); // 'jobIds' 필드에 추가

    await batch.commit();
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  // V V V --- [추가] ID로 특정 구인글 하나의 정보를 가져오는 함수 --- V V V
  Future<JobModel?> fetchJob(String jobId) async {
    final doc = await _firestore.collection('jobs').doc(jobId).get();
    if (doc.exists) {
      return JobModel.fromFirestore(doc);
    }
    return null;
  }
}

// lib/features/jobs/data/job_repository.dart

import 'package:bling_app/core/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 'jobs' 컬렉션의 모든 구인글 목록을 실시간으로 가져옵니다.
  // V V V --- [수정] 사용자의 Province를 기준으로 1차 필터링하도록 변경 --- V V V
  Stream<List<JobModel>> fetchJobs(String? userProvince) {
    Query<Map<String, dynamic>> query = _firestore.collection('jobs');

    // 사용자의 위치 정보(Province)가 있을 경우, 해당 지역의 게시물만 가져오도록 쿼리 필터 추가
    if (userProvince != null && userProvince.isNotEmpty) {
      query = query.where('locationParts.prov', isEqualTo: userProvince);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .toList();
    });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^


  // V V V --- [추가] 새로운 구인글을 생성하는 함수 --- V V V
  Future<void> createJob(JobModel job) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("로그인이 필요합니다.");
    
    final newJobRef = _firestore.collection('jobs').doc();

    // 사용자의 productIds 배열에도 새 상품 ID 추가
    final userRef = _firestore.collection('users').doc(user.uid);

    final batch = _firestore.batch();
    batch.set(newJobRef, job.toJson());
    batch.update(userRef, {'jobIds': FieldValue.arrayUnion([newJobRef.id])}); // 'jobIds' 필드에 추가

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
// lib/features/jobs/data/job_repository.dart

import 'package:bling_app/core/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 'jobs' 컬렉션의 모든 구인글 목록을 실시간으로 가져옵니다.
  Stream<List<JobModel>> fetchJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc))
          .toList();
    });
  }
}
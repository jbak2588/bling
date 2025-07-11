// lib/features/jobs/data/job_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/job_model.dart';

/// Repository for managing job posts in the Jobs module.
///
/// This class was originally an in-memory placeholder. It now
/// uses Firestore so that job listings are shared across devices.
class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jobsCollection =>
      _firestore.collection('jobs');

  /// Creates a new job document and returns its ID.
  Future<String> createJob(JobModel job) async {
    final doc = await _jobsCollection.add(job.toJson());
    return doc.id;
  }

  /// Fetches all jobs ordered by creation date.
  Stream<List<JobModel>> readJobs() {
    return _jobsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(JobModel.fromFirestore).toList());
  }

  /// Fetches a single job by document ID.
  Future<JobModel> readJob(String id) async {
    final doc = await _jobsCollection.doc(id).get();
    return JobModel.fromFirestore(doc);
  }

  /// Updates an existing job document.
  Future<void> updateJob(JobModel job) async {
    await _jobsCollection.doc(job.id).update(job.toJson());
  }

  /// Deletes a job document by ID.
  Future<void> deleteJob(String id) async {
    await _jobsCollection.doc(id).delete();
  }
}

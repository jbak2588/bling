// lib/features/jobs/data/job_repository.dart

import '../../../core/models/job_model.dart';

/// Repository for managing local job listings.
/// All CRUD operations here operate on an in-memory list
/// rather than a remote database.
class JobRepository {
  final List<JobModel> _jobs = [];

  Future<void> createJob(JobModel job) async {
    _jobs.add(job);
  }

  Future<List<JobModel>> readJobs() async {
    return _jobs;
  }

  Future<JobModel?> readJob(String id) async {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateJob(JobModel job) async {
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index != -1) {
      _jobs[index] = job;
    }
  }

  Future<void> deleteJob(String id) async {
    _jobs.removeWhere((j) => j.id == id);
  }
}

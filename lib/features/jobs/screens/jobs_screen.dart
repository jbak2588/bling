// lib/features/jobs/screens/jobs_screen.dart

import 'package:bling_app/core/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/widgets/job_card.dart';
import 'package:flutter/material.dart';
// import 'create_job_screen.dart'; // TODO: 나중에 만들 구인글 작성 화면

class JobsScreen extends StatelessWidget {
  final UserModel? userModel;
  const JobsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final JobRepository jobRepository = JobRepository();

    return Scaffold(
      body: StreamBuilder<List<JobModel>>(
        stream: jobRepository.fetchJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // TODO: 다국어
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 등록된 구인글이 없습니다.')); // TODO: 다국어
          }

          final jobs = snapshot.data!;

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(job: job);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 구인글 작성 화면으로 이동하는 로직
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateJobScreen()));
        },
        tooltip: '새 구인글 등록', // TODO: 다국어
        child: const Icon(Icons.add),
      ),
    );
  }
}
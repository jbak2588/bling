// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore jobs 컬렉션 구조와 1:1 매칭, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 채팅 연동, 급여/근무기간/이미지 등 모든 주요 기능이 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 구직자/구인자 모두를 위한 UX 개선(지원/채팅/알림 등).
// =====================================================
// lib/features/jobs/screens/jobs_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore jobs 컬렉션 구조와 1:1 매칭, 채팅 연동, 신뢰 등급, 급여/근무기간/이미지 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 채팅 연동, 급여/근무기간/이미지 등 모든 주요 기능이 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 구직자/구인자 모두를 위한 UX 개선(지원/채팅/알림 등).
// =====================================================

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/widgets/job_card.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_job_screen.dart';

class JobsScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const JobsScreen({this.userModel, this.locationFilter, super.key});

  List<JobModel> _applyLocationFilter(List<JobModel> allJobs) {
    final filter = locationFilter;
    if (filter == null) return allJobs;

    String? key;
    if (filter['kel'] != null) {
      key = 'kel';
    } else if (filter['kec'] != null) {
      key = 'kec';
    } else if (filter['kab'] != null) {
      key = 'kab';
    } else if (filter['kota'] != null) {
      key = 'kota';
    } else if (filter['prov'] != null) {
      key = 'prov';
    }
    if (key == null) return allJobs;

    final value = filter[key]!.toLowerCase();
    return allJobs
        .where((job) =>
            (job.locationParts?[key] ?? '').toString().toLowerCase() == value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final JobRepository jobRepository = JobRepository();
    final userProvince = userModel?.locationParts?['prov'];

    if (userProvince == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('jobs.setLocationPrompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<JobModel>>(
        // [수정] Stream 타입을 JobModel 리스트로 변경
        stream:
          jobRepository.fetchJobs(locationFilter: locationFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allJobs = snapshot.data ?? [];
          // [수정] 2차 필터링 적용
          final filteredJobs = _applyLocationFilter(allJobs);

          if (filteredJobs.isEmpty) {
            return Center(child: Text('jobs.screen.empty'.tr()));
          }

          return ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index]; // [수정]
              return JobCard(job: job);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'jobs_fab', // HeroTag 추가
        onPressed: () {
          if (userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateJobScreen(userModel: userModel!),
            ));
          }
        },
        tooltip: 'jobs.screen.createTooltip'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

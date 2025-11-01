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
/// ============================================================================
///
/// 2025-10-31 (작업 35):
///   - '하이브리드 기획안' 6단계: 'jobs_screen'의 필터 탭과 연동.
///   - 'fetchJobs' 함수에 'String? jobType' 파라미터 추가.
///   - 'jobType' 파라미터가 null이 아닐 경우, 'where('jobType', isEqualTo: jobType)'
///     쿼리를 동적으로 추가하여 'regular'/'quick_gig' 필터링 구현.
/// ============================================================================
library;
// (파일 내용...)

import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/widgets/job_card.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// ✅ [작업 31] 1. 일자리 유형 선택 화면 import
import 'package:bling_app/features/jobs/constants/job_categories.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

class JobsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const JobsScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  // ✅ [작업 31] 6. 탭별 JobType 필터 값
  final List<String?> _tabFilters = [
    null, // 'all' (전체)
    JobType.quickGig.name, // 'quick_gig' (단순 일자리)
    JobType.regular.name, // 'regular' (정규직)
  ];

  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  List<JobModel> _applyLocationFilter(List<JobModel> allJobs) {
    final filter = widget.locationFilter;
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
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabFilters.length, vsync: this);

    // 전역 검색 시트에서 진입한 경우 자동 표시 + 포커스
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // 피드 내부 하단 검색 아이콘 → 검색칩 열기
    if (widget.searchNotifier != null) {
      _externalSearchListener = () {
        if (widget.searchNotifier!.value == AppSection.jobs) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.dispose();
    if (_externalSearchListener != null && widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final JobRepository jobRepository = JobRepository();
    final userProvince = widget.userModel?.locationParts?['prov'];

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
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.jobs'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: 'jobs.tabs.all'.tr()), // '전체'
              Tab(text: 'jobs.tabs.quickGig'.tr()), // '단순 일자리'
              Tab(text: 'jobs.tabs.regular'.tr()), // '정규/파트타임'
            ],
            // 탭 변경 시 화면을 다시 그리도록 리스너 추가
            onTap: (index) => setState(() {}),
          ),
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              // [수정] Stream 타입을 JobModel 리스트로 변경
              stream: jobRepository.fetchJobs(
                locationFilter: widget.locationFilter,
                // ✅ [작업 31] 6. 현재 탭의 jobType 필터 전달
                jobType: _tabFilters[_tabController.index],
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allJobs = snapshot.data ?? [];
                // [수정] 2차 필터링 적용 (위치)
                var filteredJobs = _applyLocationFilter(allJobs);
                // 키워드 필터 (제목/설명)
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  filteredJobs = filteredJobs
                      .where((j) => ('${j.title} ${j.description}')
                          .toLowerCase()
                          .contains(kw))
                      .toList();
                }

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
          ),
        ],
      ),
    );
  }
}

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

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/jobs/models/talent_model.dart'; // [추가]
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart'; // [추가]
import 'package:bling_app/features/jobs/widgets/job_card.dart';
import 'package:bling_app/features/jobs/widgets/talent_card.dart'; // [추가]
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
// ✅ [작업 31] 1. 일자리 유형 선택 화면 import
// import 'package:bling_app/features/jobs/constants/job_categories.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

class JobsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

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

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TalentRepository _talentRepo = TalentRepository(); // [추가]

  // [수정] 탭 구조 변경: [전체(Jobs+Talent)] -> [구인(Jobs)] -> [재능(Talent)]
  // 기존의 quick/regular 구분은 '구인' 탭 내부의 필터로 이동하거나, 일단 단순화하여 처리
  // 여기서는 3탭 구조를 유지하되 의미를 변경합니다.
  final List<String> _tabs = ['all', 'jobs', 'talents'];

  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapMode = false;

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

  // [리팩토링] 기존 StreamBuilder를 메서드로 분리
  Widget _buildJobFeed(JobRepository repo) {
    return StreamBuilder<List<JobModel>>(
      stream: repo.fetchJobs(
        locationFilter: widget.locationFilter,
        searchToken: _searchKeywordNotifier.value.isNotEmpty
            ? _searchKeywordNotifier.value.trim().split(' ').first
            : null,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allJobs = snapshot.data ?? [];
        var filteredJobs = _applyLocationFilter(allJobs);

        if (filteredJobs.isEmpty) {
          final isNational = context.watch<LocationProvider>().mode ==
              LocationSearchMode.national;
          if (!isNational) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('jobs.screen.empty'.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text('search.empty.checkSpelling'.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: Text('search.empty.expandToNational'.tr()),
                      onPressed: () => context
                          .read<LocationProvider>()
                          .setMode(LocationSearchMode.national),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('jobs.screen.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            return JobCard(job: job);
          },
        );
      },
    );
  }

  // [수정] 통합 대시보드: 전문가(가로) + 구인(세로)
  Widget _buildAllFeed(Map<String, String?>? locationFilter) {
    final JobRepository jobRepo = JobRepository();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 전문가/재능 섹션 (가로 스크롤)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('jobs.tabs.talents'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                GestureDetector(
                  onTap: () => _tabController.animateTo(2),
                  child: Text('common.viewAll'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 175, // [수정] 카드 높이를 늘려 오버플로우 여유 확보
            child: FutureBuilder<List<TalentModel>>(
              future: _talentRepo.fetchTalents(limit: 5),
              builder: (context, snapshot) {
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text('jobs.screen.empty'.tr(),
                            style: const TextStyle(color: Colors.grey))),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    // [수정] 너비를 85%로 늘려 시원하게 보이게 조정
                    final itemWidth = screenWidth * 0.80;
                    return Padding(
                      // [수정] 너무 붙지 않도록 최소한의 간격(8.0) 부여
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: itemWidth,
                        child: TalentCard(talent: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 32, thickness: 8, color: Color(0xFFF5F5F5)),

          // 2. [섹션] 구인/알바 (세로 리스트)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('jobs.selectType.regular.title'.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                GestureDetector(
                  onTap: () =>
                      _tabController.animateTo(1), // [수정] 구인 탭(1번)으로 이동
                  child: Text('common.viewAll'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          ),
          StreamBuilder<List<JobModel>>(
            stream: jobRepo.fetchJobs(locationFilter: locationFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('jobs.screen.empty'.tr())),
                );
              }

              final jobs = snapshot.data!.take(10).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jobs.length,
                itemBuilder: (context, index) => JobCard(job: jobs[index]),
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Ensure UI updates when the user swipes between tabs (so map updates too)
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    // 전역 검색 시트에서 진입한 경우 자동 표시 + 포커스
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // search UI is driven by `widget.searchNotifier` passed directly to the chip.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }

    // ✅ [버그 수정] 키워드가 변경될 때마다 setState를 호출하여 화면을 다시 그리도록 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipOpenNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    // ✅ [버그 수정] 리스너 제거를 먼저 수행한 다음 notifier를 폐기합니다.
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    super.dispose();
  }

  void _externalSearchListener() {
    if (widget.searchNotifier?.value == true) {
      if (!mounted) return;
      setState(() => _showSearchBar = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
      widget.searchNotifier?.value = false;
    }
  }

  // ✅ [버그 수정] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
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
          // [추가] 상단 바로가기 그리드 (미니 홈 스타일)
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //   child: Row(
          //     children: [
          //       _buildLauncherCard(
          //         context,
          //         icon: Icons.work_outline,
          //         color: Colors.blueAccent,
          //         title: 'jobs.selectType.regular.title'.tr(), // "일자리 찾기"
          //         onTap: () => _tabController.animateTo(1), // 구인 탭으로 이동
          //       ),
          //       const SizedBox(width: 12),
          //       _buildLauncherCard(
          //         context,
          //         icon: Icons.verified_user_outlined,
          //         color: const Color(0xFF00B14F),
          //         title: 'jobs.selectType.talent.title'.tr(), // "전문가 찾기"
          //         onTap: () => _tabController.animateTo(2), // 재능 탭으로 이동
          //       ),
          //     ],
          //   ),
          // ),

          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    Tab(text: 'jobs.tabs.all'.tr()), // 전체 (통합)
                    Tab(text: 'jobs.tabs.regular'.tr()), // 구인
                    Tab(text: 'jobs.tabs.talents'.tr()), // 재능
                  ],
                  onTap: (index) => setState(() {}),
                ),
              ),
              IconButton(
                icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
                tooltip:
                    _isMapMode ? 'common.closeMap'.tr() : 'common.viewMap'.tr(),
                onPressed: () => setState(() => _isMapMode = !_isMapMode),
              ),
            ],
          ),
          Expanded(
            child: _isMapMode
                ? _buildTabAwareMap(jobRepository)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 0: 통합 대시보드 (전문가/구인 통합)
                      _buildAllFeed(widget.locationFilter),

                      // Tab 1: 구인 피드 (기존 로직 유지)
                      _buildJobFeed(jobRepository),

                      // Tab 2: 재능 피드 (신규)
                      _buildTalentFeed(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // [추가] 런처 카드 위젯
  // Widget _buildLauncherCard(BuildContext context,
  //     {required IconData icon,
  //     required Color color,
  //     required String title,
  //     required VoidCallback onTap}) {
  //   return Expanded(
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(12),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         decoration: BoxDecoration(
  //           color: color.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: color.withValues(alpha: 0.2)),
  //         ),
  //         child: Column(
  //           children: [
  //             Icon(icon, size: 28, color: color),
  //             const SizedBox(height: 8),
  //             Text(title,
  //                 style: const TextStyle(
  //                     fontWeight: FontWeight.bold, fontSize: 14)),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // [추가] 재능 피드 빌더
  Widget _buildTalentFeed() {
    return FutureBuilder<List<TalentModel>>(
      future: _talentRepo.fetchTalents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('jobs.screen.empty'.tr()));
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              TalentCard(talent: snapshot.data![index]),
        );
      },
    );
  }

  // Build a tab-aware map view: show Jobs or Talents depending on active tab.
  Widget _buildTabAwareMap(JobRepository jobRepository) {
    final locationProvider = context.watch<LocationProvider>();

    // 초기 지도 중심 좌표 결정: LocationProvider 우선순위 사용
    final LatLng initialMapCenter = (() {
      try {
        if (locationProvider.mode == LocationSearchMode.nearby &&
            locationProvider.user?.geoPoint != null) {
          final gp = locationProvider.user!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
        if (locationProvider.user?.geoPoint != null) {
          final gp = locationProvider.user!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
        if (widget.userModel?.geoPoint != null) {
          final gp = widget.userModel!.geoPoint!;
          return LatLng(gp.latitude, gp.longitude);
        }
      } catch (_) {}
      return const LatLng(-6.200000, 106.816666);
    })();

    final initialCamera = CameraPosition(target: initialMapCenter, zoom: 14);

    if (_tabController.index == 2) {
      // Talents: build a stream from Firestore and show Talent markers
      final Stream<List<TalentModel>> talentStream = FirebaseFirestore.instance
          .collection('talents')
          .where('isVisible', isEqualTo: true)
          .snapshots()
          .map((s) => s.docs.map((d) => TalentModel.fromFirestore(d)).toList());

      return SharedMapBrowser<TalentModel>(
        dataStream: talentStream,
        initialCameraPosition: initialCamera,
        locationExtractor: (t) => t.geoPoint,
        idExtractor: (t) => t.id,
        cardBuilder: (context, talent) => TalentCard(talent: talent),
      );
    }

    // Default: Jobs (tabs 0 and 1)
    final Stream<List<JobModel>> jobStream = jobRepository.fetchJobs(
      locationFilter: null,
      jobType: null,
      searchToken: null,
    );

    return SharedMapBrowser<JobModel>(
      dataStream: jobStream,
      initialCameraPosition: initialCamera,
      locationExtractor: (job) => job.geoPoint,
      idExtractor: (job) => job.id,
      cardBuilder: (context, job) => JobCard(job: job),
    );
  }
}

// lib/features/clubs/screens/clubs_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 동호회 카드에는 각 동호회의 제목, 대표 이미지, 위치, 멤버 수 등 요약 정보가 표시됩니다.
//
// [구현 요약]
// - 동호회 이미지, 제목, 설명, 위치, 멤버 수를 표시합니다.
// - 탭 시 상세 동호회 화면으로 이동합니다.
//
// [차이점 및 부족한 부분]
// - 신뢰 등급, 비공개 여부, 관심사 등 추가 정보와 운영자 기능(관리/수정) 표시가 부족합니다.
//
// [개선 제안]
// - 카드에 신뢰 등급, 비공개, 관심사 태그 등 추가 정보 표시.
// - 운영자를 위한 빠른 관리/수정 액션 지원.
// - 동호회는 Firestore에 제목, 설명, 운영자, 위치, 관심사, 비공개 여부, 신뢰 등급, 멤버 관리 등의 필드로 구성됩니다.
// - 동호회 내 게시글은 `clubs/{clubId}/posts`에 저장되며, 이미지, 좋아요, 댓글을 지원합니다.
// - 매칭 및 추천 로직은 위치, 관심사, 연령대, 신뢰 등급을 우선적으로 고려합니다.
//
// [구현 요약]
// - 동호회 목록, 위치 필터, 상세 화면(탭: 게시판/멤버) 기능을 제공합니다.
// - 모델은 Firestore 구조와 거의 동일하게 위치, 관심사, 비공개, 신뢰 등급, 게시글 메타데이터를 포함합니다.
// - 위젯은 동호회 및 게시글 정보를 이미지, 운영자, 시간 등과 함께 표시합니다.
// - 위치 필터, 멤버 관리, 게시글 CRUD가 구현되어 있으며, 신뢰 등급과 비공개 설정이 UI에 반영됩니다.
//
// [차이점 및 부족한 부분]
// - 매칭/추천 로직은 더 스마트하게 확장될 수 있습니다.
// - 데이팅 프로필 및 1:1 채팅 연동은 동호회와 채팅 모듈 간의 깊은 연결이 필요할 수 있습니다.
// - 통계, 운영자 기능, 고급 비공개 설정 등은 코드에 충분히 구현되어 있지 않습니다.
//
// [개선 제안]
// - 위치, 관심사, 신뢰 등급을 가중치로 활용한 추천 기능 강화.
// - 동호회 활동 및 멤버 참여에 대한 통계 분석 기능 추가.
// - 운영자(방장)를 위한 멤버 관리(강퇴/승인) 및 게시글 관리 기능 강화.
// - 민감한 동호회를 위한 비공개 옵션 및 신뢰 등급 제한 확대.
// - 동호회 탐색 및 가입 UX/UI 개선.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) 기획서 6.1 '모임 제안' V2.0 UI로 전면 개편.
// 2. (Task 20) [버그 수정] 'IndexedStack'과 'AppBar(bottom: ...)'의 Ticker 충돌 해결.
// 3. 'DefaultTabController'를 사용하고, 'AppBar'의 'bottom' 속성을 제거함.
// 4. 'TabBar'를 'Scaffold'의 'body' 영역(Column)으로 이동하여 Ticker 충돌을 원천 차단함.
// 5. 'body'를 2개의 탭('모임 제안', '활동 중인 모임')으로 분리.
// 6. (Task 12) '활동 중인 모임' 탭 내부에 '내가 가입한 모임' (카로셀) + '모든 모임 탐색' (리스트)의 하이브리드 UI 적용.
// 7. (Task 15) 'FloatingActionButton' 제거 (main_navigation_screen의 중앙 FAB로 통합).
// =====================================================
// lib/features/clubs/screens/clubs_screen.dart

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart'; // [추가]
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:bling_app/features/clubs/widgets/club_proposal_card.dart'; // [추가]
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart';
// import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClubsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;
  final TabController? tabController; // 부모로부터 TabController 받을 수 있음(선택)
  final bool showInnerAppBar; // 내부 AppBar 노출 여부 (기본 표시)

  const ClubsScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    this.tabController,
    this.showInnerAppBar = true,
    super.key,
  });

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapMode = false;

  // 저장소 인스턴스 (탭별 StreamBuilder에서 재사용)
  final ClubRepository _repository = ClubRepository();

  @override
  void initState() {
    super.initState();

    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
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

  @override
  Widget build(BuildContext context) {
    // LocationProvider 우선값으로 초기 지도 중심 좌표 결정
    final locationProvider = context.watch<LocationProvider>();
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

    // Dual-mode:
    // - showInnerAppBar == true: self-contained (Scaffold + TabBar까지 내부 포함)
    // - showInnerAppBar == false: parent manages TabBar; requires external controller
    if (widget.showInnerAppBar) {
      return PopScope(
        canPop: !_isMapMode,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() => _isMapMode = false);
        },
        child: DefaultTabController(
          length: 2,
          child: Builder(
            builder: (ctx) {
              final controller =
                  widget.tabController ?? DefaultTabController.of(ctx);
              return Scaffold(
                // [수정] 중복 AppBar 제거
                body: _isMapMode
                    ? SharedMapBrowser<ClubModel>(
                        dataStream:
                            _repository.fetchClubs(locationFilter: null),
                        // [수정] 초기 위치: userModel 사용 (null 안전 처리)
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.userModel!.geoPoint!.latitude,
                            widget.userModel!.geoPoint!.longitude,
                          ),
                          zoom: 14,
                        ),
                        locationExtractor: (club) => club.geoPoint,
                        idExtractor: (club) => club.id,
                        cardBuilder: (context, club) =>
                            ClubCard(key: ValueKey(club.id), club: club),
                      )
                    : Column(
                        children: [
                          // ✅ 검색바가 활성화되면 탭보다 위에서 노출
                          if (_showSearchBar)
                            InlineSearchChip(
                              hintText: 'main.search.hint.clubs'.tr(),
                              openNotifier: _chipOpenNotifier,
                              onSubmitted: (kw) => _searchKeywordNotifier
                                  .value = kw.trim().toLowerCase(),
                              onClose: () {
                                setState(() => _showSearchBar = false);
                                _searchKeywordNotifier.value = '';
                              },
                            ),
                          // [수정] 탭바와 지도 버튼을 한 줄에 배치
                          Row(
                            children: [
                              Expanded(
                                child: TabBar(
                                  controller: controller,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Colors.grey[600],
                                  indicatorColor:
                                      Theme.of(context).primaryColor,
                                  tabs: [
                                    Tab(text: 'clubs.tabs.proposals'.tr()),
                                    Tab(text: 'clubs.tabs.activeClubs'.tr()),
                                  ],
                                ),
                              ),
                              // [추가] 지도/닫기 토글 버튼 (탭바 우측)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IconButton(
                                  icon: Icon(_isMapMode
                                      ? Icons.close
                                      : Icons.map_outlined),
                                  tooltip: _isMapMode
                                      ? 'common.closeMap'.tr()
                                      : 'common.viewMap'.tr(),
                                  onPressed: () =>
                                      setState(() => _isMapMode = !_isMapMode),
                                ),
                              ),
                            ],
                          ),
                          // 탭 컨텐츠
                          Expanded(
                            child: TabBarView(
                              controller: controller,
                              children: [
                                _buildProposalList(),
                                _buildActiveClubList(),
                              ],
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      );
    } else {
      final controller = widget.tabController;
      assert(
        controller != null,
        'When showInnerAppBar is false, a TabController must be provided.',
      );
      // 이 모드는 상위 위젯에서 TabBar를 관리하므로,
      // 여기서는 기존대로 탭 내용만 렌더링합니다.
      return PopScope(
        canPop: !_isMapMode,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() => _isMapMode = false);
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('main.tabs.clubs'.tr()),
            actions: [
              IconButton(
                icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
                tooltip:
                    _isMapMode ? 'common.closeMap'.tr() : 'common.viewMap'.tr(),
                onPressed: () => setState(() => _isMapMode = !_isMapMode),
              ),
            ],
          ),
          body: _isMapMode
              ? SharedMapBrowser<ClubModel>(
                  dataStream: _repository.fetchClubs(locationFilter: null),
                  initialCameraPosition: CameraPosition(
                    target: initialMapCenter,
                    zoom: 14,
                  ),
                  locationExtractor: (club) => club.geoPoint,
                  idExtractor: (club) => club.id,
                  cardBuilder: (context, club) =>
                      ClubCard(key: ValueKey(club.id), club: club),
                )
              : Column(
                  children: [
                    if (_showSearchBar)
                      InlineSearchChip(
                        hintText: 'main.search.hint.clubs'.tr(),
                        openNotifier: _chipOpenNotifier,
                        onSubmitted: (kw) => _searchKeywordNotifier.value =
                            kw.trim().toLowerCase(),
                        onClose: () {
                          setState(() => _showSearchBar = false);
                          _searchKeywordNotifier.value = '';
                        },
                      ),
                    Expanded(
                      child: TabBarView(
                        controller: controller,
                        children: [
                          _buildProposalList(),
                          _buildActiveClubList(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }

  // 모임 제안 목록 탭
  Widget _buildProposalList() {
    return StreamBuilder<List<ClubProposalModel>>(
      stream: _repository.getClubProposalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'clubs.screen.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()}),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    Text('clubs.proposal.empty'.tr(),
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
                            .setMode(LocationSearchMode.national)),
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
                  Text('clubs.proposal.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        var proposals = snapshot.data!;
        final kw = _searchKeywordNotifier.value;
        if (kw.isNotEmpty) {
          proposals = proposals
              .where(
                (c) =>
                    (("${c.title} ${c.description} ${c.mainCategory} ${c.interestTags.join(' ')}")
                        .toLowerCase()
                        .contains(kw)),
              )
              .toList();
        }

        if (proposals.isEmpty) {
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
                    Text('clubs.proposal.empty'.tr(),
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
                            .setMode(LocationSearchMode.national)),
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
                  Text('clubs.proposal.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: proposals.length,
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            return ClubProposalCard(
              key: ValueKey(proposal.id),
              proposal: proposal,
            );
          },
        );
      },
    );
  }

  // 활동 중인 모임 목록 탭
  Widget _buildActiveClubList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMyClubsCarousel(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'clubs.tabs.exploreClubs'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _buildAllActiveClubsList()),
      ],
    );
  }

  // 전체 클럽 목록 (스폰서 우선 정렬)
  Widget _buildAllActiveClubsList() {
    return StreamBuilder<List<ClubModel>>(
      stream: _repository.fetchClubs(locationFilter: widget.locationFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'clubs.screen.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()}),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                    Text('clubs.screen.empty'.tr(),
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
                            .setMode(LocationSearchMode.national)),
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
                  Text('clubs.screen.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        var clubs = snapshot.data!;
        final kw = _searchKeywordNotifier.value;
        if (kw.isNotEmpty) {
          clubs = clubs
              .where(
                (c) =>
                    (("${c.title} ${c.description} ${c.mainCategory} ${c.interestTags.join(' ')}")
                        .toLowerCase()
                        .contains(kw)),
              )
              .toList();
        }

        if (clubs.isEmpty) {
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
                    Text('clubs.screen.empty'.tr(),
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
                            .setMode(LocationSearchMode.national)),
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
                  Text('clubs.screen.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        final sponsoredClubs = clubs.where((c) => c.isSponsored).toList();
        final normalClubs = clubs.where((c) => !c.isSponsored).toList();
        final sortedClubs = sponsoredClubs + normalClubs;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: sortedClubs.length,
          itemBuilder: (context, index) {
            final club = sortedClubs[index];
            return ClubCard(key: ValueKey(club.id), club: club);
          },
        );
      },
    );
  }

  // 내가 가입한 모임 카로셀
  Widget _buildMyClubsCarousel() {
    if (widget.userModel == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<List<ClubModel>>(
      stream: _repository.getMyClubsStream(widget.userModel!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final myClubs = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'clubs.tabs.myClubs'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: myClubs.length,
                  itemBuilder: (context, index) {
                    final club = myClubs[index];
                    return _buildMyClubTile(club);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyClubTile(ClubModel club) {
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ClubDetailScreen(club: club),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage:
                  (club.imageUrl != null && club.imageUrl!.isNotEmpty)
                      ? NetworkImage(club.imageUrl!)
                      : null,
              child: (club.imageUrl == null || club.imageUrl!.isEmpty)
                  ? const Icon(Icons.groups)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              club.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

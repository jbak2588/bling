/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/find_friends_screen.dart
/// Purpose       : 관심사와 위치 기반으로 주변 사용자를 탐색하고 연결합니다.
/// User Impact   : 주민이 1~5km 내 이웃이나 데이팅 매치를 발견하도록 돕습니다.
/// Feature Links : lib/features/find_friends/screens/find_friend_detail_screen.dart; lib/features/find_friends/screens/findfriend_form_screen.dart; lib/features/find_friends/widgets/findfriend_card.dart
/// Data Model    : `users/{uid}`와 `/users/{uid}/findfriend_profile/main`을 읽고 관계는 `follows` 컬렉션을 사용합니다.
/// Privacy Note : 피드(목록/카드) 및 요약 UI에서는 `locationParts['street']` 또는 전체 `locationName`을 사용자 동의 없이 노출하지 마세요. 피드에는 행정구역을 약어(`kel.`, `kec.`, `kab.`, `prov.`)로 간략 표기하세요.
/// Location Scope: Province→Kabupaten/Kota→Kecamatan→Kelurahan로 필터링하며 LocationFilterScreen을 통한 선택적 RT/RW; 기본값은 사용자 `locationParts`입니다.
/// Trust Policy  : `isDatingProfile`이 true이고 TrustLevel 기준을 충족해야 하며 `blockedUsers`를 존중합니다.
/// Monetization  : 향후 프로필 노출 프리미엄 부스트 예정; TODO.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `profile_view`, `start_follow`, `start_chat`.
/// Analytics     : 필터 사용과 프로필 노출을 추적합니다.
/// I18N          : 키 `findFriend.prompt_title`, `findFriend.prompt_button` (assets/lang/*.json)
/// Dependencies  : easy_localization, lib/features/find_friends/data/find_friend_repository.dart, lib/features/location/screens/location_filter_screen.dart
/// Security/Auth : 인증된 접근이 필요하며 나이와 개인정보 설정을 적용합니다.
/// Edge Cases    : 프로필 미완성, 위치 필터 없음, 결과 없음.
/// 실제 구현 비교 : 나이 범위, 위치 기반 필터, 관심사, 친구 요청/팔로우 등 모든 기능이 정상 동작. UI/UX 완비.
/// 개선 제안     : KPI/통계/프리미엄 기능 실제 구현 필요. 필터 설명 및 에러 메시지 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012  Find Friend & Club & Jobs & etc 모듈.md; docs/Bling FindFriend DB 구조 설계 문서.md
/// ============================================================================
/// - `isDatingProfile` 관련 로직 제거 (Repository 쿼리에서 제거됨).
/// - FAB를 `FindFriendFormScreen` (폐기됨) 대신 `ProfileEditScreen`으로 연결.
/// - `ProfileEditScreen`에서 '리스트에 나를 노출' 토글을 관리.
///
library;

// [v2.1 리팩토링 이력: Job 6-45]
// - (Job 6, 9) 'FindFriendFormScreen' (데이팅 프로필) FAB를 'ProfileEditScreen'으로 변경.
// - (Job 32-34) UI 구조를 'Column'에서 'TabBar' + 'TabBarView'로 변경하여 '친구'와 '모임' 탭 통합.
// - (Job 35-36) 'autoFocusSearch' 및 '_showSearchBar' 관련 검색 로직 복원 (탭 추가 시 누락됨).
// - (Job 36, 37) '친구/모임' 탭의 StreamBuilder가 올바른 초기 필터(_currentLocationFilter)를 사용하도록 수정 (빈 리스트 문제 해결).
// - (Job 39, 45) '모임' 탭(_buildClubsList)이 'Active Clubs'와 'Proposals'를 모두 렌더링하도록 수정.
// - (Job 45) [임시 조치] 'Active Clubs'의 Firestore 인덱스 문제로, 'getClubsByLocationStream' 대신 'getClubsStream' (필터 없음)을 호출.
// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/my_bling/screens/profile_edit_screen.dart'; // [v2.1] ProfileEditScreen으로 대체
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

// [v2.1] '모임' 탭 구현을 위해 Club 관련 파일 import
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart'; // [v2.1] 모임 제안 모델
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:bling_app/features/clubs/widgets/club_proposal_card.dart'; // [v2.1] 모임 제안 카드
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart'; // [v2.1] ClubCard 탭을 위해 추가
import 'package:bling_app/features/clubs/screens/club_proposal_detail_screen.dart'; // [Added] Import

class FindFriendsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>?
      activeLocationFilter; // [v2.1] 이 파라미터는 존재하나, 초기 로드 시 사용하지 않음
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const FindFriendsScreen({
    super.key,
    this.userModel,
    this.activeLocationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

// [v2.1] TabBar 사용을 위해 SingleTickerProviderStateMixin 추가
class _FindFriendsScreenState extends State<FindFriendsScreen>
    with SingleTickerProviderStateMixin {
  final FindFriendRepository _repository = FindFriendRepository();
  late ClubRepository _clubRepository; // [v2.1] Club 리포지토리
  Stream<List<UserModel>>? _friendsStream;
  Stream<List<ClubModel>>? _clubsStream; // [v2.1] Club 스트림
  Stream<List<ClubProposalModel>>? _proposalsStream; // [v2.1] 모임 제안 스트림
  Map<String, String?>? _currentLocationFilter; // [작업 36] 내부 위치 필터 (초기값 null)

  // [작업 36] 검색칩 관련 State 변수 및 로직 복원
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  // _externalSearchListener removed: InlineSearchChip handles openNotifier externally

  late TabController _tabController; // [v2.1] TabBar 컨트롤러

  @override
  void initState() {
    super.initState();
    _clubRepository = ClubRepository(); // [v2.1] 초기화
    _tabController = TabController(length: 2, vsync: this); // [작업 43] 탭 2개로 복원

    // [작업 36] 검색 로직 복원 (탭 추가 직전 코드 기준)
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }
    // If an external search notifier is provided we register a listener
    // so we can render the chip and then open it. InlineSearchChip listens
    // to its own openNotifier, but if it's not mounted we must ensure it's
    // shown first and then trigger the local chip notifier.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }

    _searchKeywordNotifier.addListener(_onKeywordChanged);
    // [작업 36] 끝

    _loadData(); // [v2.1] _initLoad -> _loadData로 함수명 변경 (에러 수정)
  }

  // Test tab removed — debug logic cleaned up

  @override
  void didUpdateWidget(covariant FindFriendsScreen oldWidget) {
    // ignore: unnecessary_overrides
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeLocationFilter != widget.activeLocationFilter) {
      // [작업 36] 외부 필터가 '명시적'으로 변경될 때만 내부 필터 갱신 및 리로드
      _currentLocationFilter = widget.activeLocationFilter == null
          ? null
          : Map.from(widget.activeLocationFilter!);
      _loadData();
    }
  }

  // [v2.1] 초기 데이터 로드: friends, clubs, proposals
  void _loadData() {
    final userModel = widget.userModel;
    if (userModel == null) return;

    // [작업 37] '동네 친구' 탭의 하이퍼로컬 목적에 맞게,
    // 1순위: 사용자가 수동 설정한 필터 (_currentLocationFilter)
    // 2순위: 앱의 현재 활성 위치 (widget.activeLocationFilter)
    // 3순위: (둘 다 없으면) 빈 맵 (모두 노출)
    final locationFilter =
        _currentLocationFilter ?? widget.activeLocationFilter ?? {};

    // [v2.1] '친구' 탭 데이터 로드
    _friendsStream = _repository.getFindFriendListStream(
      locationFilter: locationFilter,
      currentUser: userModel,
    );

    // [작업 45] DevLog: 'Active Clubs'가 인덱스 문제로 로드되지 않아,
    // 임시로 'getClubsStream()' (위치 필터 없음)을 호출하여 'Test' 탭의 결과를 표시합니다.
    // TODO: Firestore 복합 인덱스 문제를 해결하고 'getClubsByLocationStream'으로 복원해야 함.
    if (kDebugMode) {
      print(
          "[DevLog Job 45] Calling getClubsStream() (no filter) for Active Clubs as a temporary fix.");
    }
    _clubsStream = _clubRepository.getClubsStream();

    // [v2.1] '모임 제안' 탭 데이터 로드 (이 스트림은 정상 작동하므로 유지)
    _proposalsStream = _clubRepository.getClubProposalsByLocationStream(
      locationFilter: locationFilter,
    );

    if (mounted) {
      setState(() {});
    }
  }

  // [작업 36] 키워드 변경 시 setState 호출 (리스트 필터링)
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  void _externalSearchListener() {
    if (widget.searchNotifier?.value == true) {
      if (!mounted) return;
      setState(() => _showSearchBar = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
      // reset external notifier to avoid repeated triggers
      widget.searchNotifier?.value = false;
    }
  }

  @override
  void dispose() {
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openLocationFilter() async {
    final userModel = widget.userModel;
    if (userModel == null) return;

    final newFilter = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(
              userModel: userModel)), // [v2.1] initialFilter 파라미터 제거 (에러 수정)
    );
    if (newFilter != null && mounted) {
      setState(() {
        _currentLocationFilter = newFilter;
        _loadData(); // [v2.1] 필터 변경 시 친구/모임 모두 리로드
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;
    if (userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // [v2.1] AppBar 제거 (main_navigation_screen.dart의 AppBar와 중복 충돌)
      body: Column(
        children: [
          // [작업 36] 검색 칩이 'autoFocusSearch' 등에 의해서만 노출되도록 조건부 렌더링
          if (_showSearchBar) _buildSearchChip(),
          // [v2.1] TabBar를 검색 칩 아래로 이동
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "findFriend.tabs.friends".tr()),
              Tab(text: "findFriend.tabs.groups".tr()),
            ],
          ),
          // [v2.1] TabBarView가 Column 안에서 확장되도록 Expanded로 감쌈
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(userModel), // [v2.1] 친구 리스트 뷰
                _buildClubsList(userModel), // [v2.1] 모임 리스트 뷰
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'find_friends_filter',
            onPressed: _openLocationFilter,
            tooltip: 'locationFilter.title'.tr(),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'find_friends_edit_profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ProfileEditScreen()), // [v2.1] userModel 파라미터 제거 (에러 수정)
              );
            },
            tooltip: "myBling.editProfile".tr(), // [v2.1] 툴팁 변경
            child: const Icon(Icons.edit_note_outlined),
          ),
        ],
      ),
    );
  }

  // [v2.1] '친구' 탭 UI
  Widget _buildFriendsList(UserModel userModel) {
    return StreamBuilder<List<UserModel>>(
      stream: _friendsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: _buildFirestoreErrorWidget(snapshot.error));
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
                    Text('findFriend.empty'.tr(),
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
                  Text('findFriend.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        // [작업 36] 검색 키워드 필터링 로직 (탭 추가 직전 코드 기준)
        var friends = snapshot.data!;
        final kw = _searchKeywordNotifier.value;
        if (kw.isNotEmpty) {
          friends = friends
              .where((u) =>
                  (('${u.nickname} ${u.bio ?? ''} ${(u.interests ?? const []).join(' ')}')
                      .toLowerCase()
                      .contains(kw)))
              .toList();
        }
        if (friends.isEmpty) {
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
                    Text('findFriend.empty'.tr(),
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
                  Text('findFriend.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }
        // [작업 36] 끝

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final user = friends[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FindFriendDetailScreen(
                        user: user, currentUserModel: userModel),
                  ),
                );
              },
              child: FindFriendCard(user: user),
            );
          },
        );
      },
    );
  }

  // [v2.1] '모임' 탭 UI (신규)
  Widget _buildClubsList(UserModel userModel) {
    final kw = _searchKeywordNotifier.value;

    // [v2.1] '정식 모임'과 '모임 제안'을 2개의 스트림으로 동시에 로드
    return StreamBuilder<List<ClubModel>>(
      stream: _clubsStream,
      builder: (context, clubsSnapshot) {
        return StreamBuilder<List<ClubProposalModel>>(
          stream: _proposalsStream, // [v2.1] 'unused_field' 경고 해결
          builder: (context, proposalsSnapshot) {
            if (clubsSnapshot.connectionState == ConnectionState.waiting ||
                proposalsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // [작업 40] 추적 코드: 스트림 에러 확인
            if (clubsSnapshot.hasError) {
              if (kDebugMode) {
                print(
                    '[Job 40 Debug] Groups Tab (Active) Error: ${clubsSnapshot.error}');
              }
            }
            if (proposalsSnapshot.hasError) {
              if (kDebugMode) {
                print(
                    '[Job 40 Debug] Groups Tab (Proposals) Error: ${proposalsSnapshot.error}');
              }
            }
            if (clubsSnapshot.hasError || proposalsSnapshot.hasError) {
              final err = clubsSnapshot.error ?? proposalsSnapshot.error;
              return Center(child: _buildFirestoreErrorWidget(err));
            }

            // [작업 36] 검색 키워드 필터링 로직 (탭 추가 직전 코드 기준)
            var clubs = clubsSnapshot.data ?? [];
            // [작업 36] 클라이언트 측 정렬 (Active Clubs)
            clubs.sort((a, b) {
              // isSponsored(true)가 먼저, 그 다음 최신순
              int sponsorCompare =
                  (b.isSponsored ? 1 : 0).compareTo(a.isSponsored ? 1 : 0);
              if (sponsorCompare != 0) return sponsorCompare;
              return b.createdAt.compareTo(a.createdAt);
            });
            if (kw.isNotEmpty) {
              clubs = clubs
                  .where((c) =>
                      (('${c.title} ${c.description} ${c.interestTags.join(' ')}')
                          .toLowerCase()
                          .contains(kw)))
                  .toList();
            }

            // [작업 40] 추적 코드: 데이터 개수 확인
            if (kDebugMode) {
              print(
                  '[Job 40 Debug] Groups Tab (Active) Count: ${clubs.length}');
            }
            if (kDebugMode) {
              print(
                  '[Job 40 Debug] Groups Tab (Proposals) Count: ${proposalsSnapshot.data?.length ?? 0}');
            }

            var proposals = proposalsSnapshot.data ?? [];
            // [작업 36] 클라이언트 측 정렬 (Proposals)
            proposals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            if (kw.isNotEmpty) {
              proposals = proposals
                  .where((p) =>
                      (('${p.title} ${p.description} ${p.interestTags.join(' ')}')
                          .toLowerCase()
                          .contains(kw)))
                  .toList();
            }

            if (clubs.isEmpty && proposals.isEmpty) {
              final isNational = context.watch<LocationProvider>().mode ==
                  LocationSearchMode.national;
              if (!isNational) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('clubs.empty'.tr(),
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
                      Text('clubs.empty'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              );
            }
            // [작업 36] 끝

            // [v2.1] '정식 모임'과 '모임 제안' 리스트를 하나의 ListView로 통합
            return ListView(
              children: [
                // --- 1. 정식 모임 섹션 ---
                if (clubs.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      'clubs.sections.active'.tr(), // I18N: "정식 모임"
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...clubs.map((club) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClubDetailScreen(club: club),
                          ),
                        );
                      },
                      child: ClubCard(club: club),
                    );
                  }),
                ],

                // --- 2. 모임 제안 섹션 ---
                if (proposals.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        16.0, clubs.isNotEmpty ? 24.0 : 16.0, 16.0, 8.0),
                    child: Text(
                      'clubs.sections.proposals'.tr(), // I18N: "모임 제안"
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...proposals.map((proposal) {
                    // [v2.1] 'unused_import' 경고 해결
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClubProposalDetailScreen(proposal: proposal),
                          ),
                        );
                      },
                      child: ClubProposalCard(proposal: proposal),
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // [작업 36] 검색 칩 빌더 로직 복원 (탭 추가 직전 코드 기준)
  Widget _buildSearchChip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: InlineSearchChip(
        hintText: 'main.search.hint.findFriends'.tr(),
        openNotifier: _chipOpenNotifier,
        onSubmitted: (kw) =>
            _searchKeywordNotifier.value = kw.trim().toLowerCase(),
        onClose: () {
          // [작업 36] autoFocusSearch가 아닐 때만 칩을 닫음 (기존 로직)
          if (!widget.autoFocusSearch) {
            setState(() => _showSearchBar = false);
          }
          _searchKeywordNotifier.value = '';
        },
      ),
    );
  }

  // Helper: render Firestore errors and make any index console URL clickable
  Widget _buildFirestoreErrorWidget(Object? error) {
    final msg = error?.toString() ?? 'Unknown error';

    // Find first URL in the error message (simple heuristic)
    final urlMatch = RegExp(r"https?:\/\/[^\s)']+").firstMatch(msg);
    final url = urlMatch?.group(0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Error: $msg'),
          const SizedBox(height: 8),
          if (url != null) ...[
            Text('It looks like this query requires a Firestore index.'),
            TextButton(
              onPressed: () async {
                try {
                  await launchUrlString(url);
                } catch (e) {
                  // ignore: avoid_print
                  print('Could not launch $url: $e');
                }
              },
              child: Text('Open index in console'),
            ),
          ],
        ],
      ),
    );
  }
}

/// ============================================================================
/// Find Friends — 변경 요약 (구분, 개선 내용, 기술적 구현 방안)
///
/// 구분,개선 내용,기술적 구현 방안
/// 1. 노출 기준 강화,프로필 완성도 검증 로직 추가,"`user_model.dart`: `isProfileReadyForMatching` getter 추가 — 사진(photoUrl), 자기소개(bio, 권장 최소 5자), 관심사(interests) 필수 검사.\n`find_friend_repository.dart`: 사용자 스트림/쿼리 호출 시 클라이언트 측 또는 서버측 필터로 `isProfileReadyForMatching` 조건 적용(쿼리에서 불가능한 경우 Stream.map()에서 필터링)."
/// 2. 탭 구조 개편,[탐색] / [내 친구] 2단 구조,`find_friends_screen.dart`: 기존 Clubs 탭 제거. Tab1 [탐색]은 이웃 프로필(프로필 노출 필터 적용) + (New) 동네 토크(Posts) 모드 포함. Tab2 [내 친구]는 `UserFriendList` 위젯으로 이관 (기존 `my_bling` 또는 `UserFriendList` 위치에서 재사용).
/// 3. 동네 토크 (Board),"목적 기반 간단 게시판 예: '오늘 운동하실 분?' 등. (New) `friend_post_model.dart`: 게시글 모델 정의(작성자, 내용, 태그, 작성시간, 위치 등). UI는 사진 중심이 아닌 텍스트+이모지 위주의 경량 카드 `FriendPostCard`로 구현 — 타임라인/참여 버튼/태그 표시.
/// 4. 멀티 채팅,게시글 기반 1:N 오픈 채팅,"`chat_service.dart`: 게시글(Post)에서 채팅방 생성 시 `isGroupChat: true` 설정. 그룹 참여는 기본적으로 승인제 — 방장(owner)이 참여 요청을 승인해야 입장 허용하도록 채팅 서비스와 권한 체크 추가(서버/클라이언트 양쪽에서 검증 필요)."
///
/// 주의사항:
/// - 이 파일은 UI 리팩토링 중심이며, 기존 Clubs/Proposal 로직은 제거되어 있습니다. 필요 시 별도 모듈로 분리해 재도입하세요.
/// - Firestore 인덱스, 권한, 채팅 승인 로직은 백엔드/클라우드 함수 또는 보안 규칙과 함께 테스트해야 합니다.
/// ============================================================================
library;

// lib/features/find_friends/screens/find_friends_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/find_friends/data/friend_post_repository.dart';
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:bling_app/features/find_friends/widgets/friend_post_card.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/find_friends/screens/create_friend_post_screen.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

class FindFriendsScreen extends StatefulWidget {
  final UserModel? userModel;
  // Provider 사용으로 locationFilter 파라미터 제거
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const FindFriendsScreen({
    super.key,
    this.userModel,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen>
    with SingleTickerProviderStateMixin {
  // 리포지토리
  final FindFriendRepository _userRepository = FindFriendRepository();
  final FriendPostRepository _postRepository = FriendPostRepository();

  // 상태 변수
  late TabController _mainTabController;

  // 탐색 탭 내부 모드 (0: Profiles, 1: Posts)
  int _exploreModeIndex = 0;

  // [복원] 검색 관련 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _loadData();

    // [복원] 검색 초기화 및 리스너 등록
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

  @override
  void didUpdateWidget(covariant FindFriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // LocationProvider로 필터 관리를 이전했으므로 didUpdateWidget에서 별도처리 없음
  }

  void _loadData() {
    // locationProvider로 대체됨
  }

  // [복원] 외부(앱바)에서 검색 아이콘 클릭 시 호출됨
  void _externalSearchListener() {
    if (widget.searchNotifier?.value == true) {
      if (!mounted) return;
      setState(() => _showSearchBar = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
      widget.searchNotifier?.value = false; // 리셋
    }
  }

  // [복원] 검색어 변경 시 화면 갱신
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  // [수정] 자체 LocationFilterScreen 호출 로직 제거 (MainNavigationScreen이 담당)

  @override
  void dispose() {
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;
    if (userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // [수정] 중복된 AppBar 및 필터 버튼 제거
      // MainNavigationScreen의 GrabAppBarShell 하위에서 렌더링되므로,
      // 여기서는 Body 내용만 구성합니다.

      body: Column(
        children: [
          // 1. 검색바 (활성화 시 표시)
          if (_showSearchBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: InlineSearchChip(
                hintText: _exploreModeIndex == 0
                    ? 'main.search.hint.findFriends'.tr() // "이웃 검색..."
                    : 'friendPost.searchHint'.tr(),
                openNotifier: _chipOpenNotifier,
                onSubmitted: (kw) =>
                    _searchKeywordNotifier.value = kw.trim().toLowerCase(),
                onClose: () {
                  if (!widget.autoFocusSearch) {
                    setState(() => _showSearchBar = false);
                  }
                  _searchKeywordNotifier.value = '';
                },
              ),
            ),

          // 2. 탭 바 (Body 상단으로 이동)
          // AppBar가 없으므로 Container로 감싸서 시각적 분리
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _mainTabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                    text: 'findFriend.tabs.explore'
                        .tr()), // localKey: findFriend.tabs.explore
                Tab(
                    text: 'findFriend.tabs.myFriends'
                        .tr()), // localKey: findFriend.tabs.myFriends
              ],
            ),
          ),

          // 3. 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // 탭 1: 둘러보기 (프로필 + 게시판)
                _buildExploreTab(userModel),

                // 탭 2: 내 친구 (간단 플레이스홀더 — 실제 리스트는 별도 위젯으로 대체 예정)
                const Center(child: Text("My Friends List (Coming Soon)")),
              ],
            ),
          ),
        ],
      ),

      // 플로팅 액션 버튼은 유지 (글쓰기 등)
      floatingActionButton:
          _exploreModeIndex == 1 && _mainTabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // [작업 9] 게시글 작성 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateFriendPostScreen(userModel: userModel),
                      ),
                    );
                  },
                  label: Text('friendPost.write'.tr()),
                  icon: const Icon(Icons.edit),
                )
              : null,
    );
  }

  Widget _buildExploreTab(UserModel currentUser) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final bool isNearbyMode =
        locationProvider.mode == LocationSearchMode.nearby;
    final Map<String, String?>? adminFilter =
        isNearbyMode ? null : locationProvider.adminFilter;
    final double radiusKm = locationProvider.radiusKm;

    return Column(
      children: [
        // 상단: 모드 전환
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                    value: 0,
                    label: Text('findFriend.segment.profile'.tr()),
                    icon: const Icon(Icons.people)),
                ButtonSegment(
                    value: 1,
                    label: Text('findFriend.segment.posts'.tr()),
                    icon: const Icon(Icons.forum)),
              ],
              selected: {_exploreModeIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _exploreModeIndex = newSelection.first;
                });
              },
              showSelectedIcon: false,
            ),
          ),
        ),

        // 콘텐츠 영역
        Expanded(
          child: _exploreModeIndex == 0
              ? _buildProfileList(
                  currentUser, adminFilter, isNearbyMode, radiusKm)
              : _buildPostList(
                  currentUser, adminFilter, isNearbyMode, radiusKm),
        ),
      ],
    );
  }

  // 1-A. 이웃 프로필 리스트 (LocationProvider 연동)
  // 거리 계산 헬퍼 (Haversine formula) - Marketplace와 동일
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Widget _buildProfileList(UserModel currentUser, Map<String, String?>? filter,
      bool isNearbyMode, double radiusKm) {
    return StreamBuilder<List<UserModel>>(
      stream: _userRepository.getFindFriendListStream(
        locationFilter: filter,
        currentUser: currentUser,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var users = snapshot.data ?? [];

        // 1. 프로필 완성도 필터 (기본)
        users = users.where((user) => user.isProfileReadyForMatching).toList();

        // 2. 거리 필터 (Nearby 모드일 때만)
        if (isNearbyMode && currentUser.geoPoint != null) {
          users = users.where((user) {
            if (user.geoPoint == null) return false;
            final dist = _calculateDistance(
              currentUser.geoPoint!.latitude,
              currentUser.geoPoint!.longitude,
              user.geoPoint!.latitude,
              user.geoPoint!.longitude,
            );
            return dist <= radiusKm;
          }).toList();

          // 거리순 정렬
          users.sort((a, b) {
            final distA = _calculateDistance(
                currentUser.geoPoint!.latitude,
                currentUser.geoPoint!.longitude,
                a.geoPoint!.latitude,
                a.geoPoint!.longitude);
            final distB = _calculateDistance(
                currentUser.geoPoint!.latitude,
                currentUser.geoPoint!.longitude,
                b.geoPoint!.latitude,
                b.geoPoint!.longitude);
            return distA.compareTo(distB);
          });
        }

        // 3. 키워드 검색
        final kw = _searchKeywordNotifier.value;
        if (kw.isNotEmpty) {
          users = users.where((u) {
            final text =
                '${u.nickname} ${u.bio ?? ''} ${(u.interests ?? []).join(' ')}'
                    .toLowerCase();
            return text.contains(kw);
          }).toList();
        }

        if (users.isEmpty) {
          return _buildEmptyView(kw.isNotEmpty
              ? 'findFriend.searchNoResults'.tr()
              : 'findFriend.noMatches'.tr());
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FindFriendDetailScreen(
                      user: user, currentUserModel: currentUser))),
              child: FindFriendCard(user: user, currentUser: currentUser),
            );
          },
        );
      },
    );
  }

  // 1-B. 동네 토크 리스트 (LocationProvider 연동)
  Widget _buildPostList(UserModel currentUser, Map<String, String?>? filter,
      bool isNearbyMode, double radiusKm) {
    return StreamBuilder<List<FriendPostModel>>(
      stream: _postRepository.getPostsStream(locationFilter: filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var posts = snapshot.data ?? [];

        if (isNearbyMode) {
          final myKel = currentUser.locationParts?['kel'];
          if (myKel != null) {
            posts =
                posts.where((p) => p.locationParts?['kel'] == myKel).toList();
          }
        }

        // 키워드 검색
        final kw = _searchKeywordNotifier.value;
        if (kw.isNotEmpty) {
          posts = posts.where((p) {
            final text = '${p.content} ${(p.tags).join(' ')}'.toLowerCase();
            return text.contains(kw);
          }).toList();
        }

        if (posts.isEmpty) {
          return _buildEmptyView(kw.isNotEmpty
              ? 'findFriend.searchNoResults'.tr()
              : 'friendPost.noPosts'.tr());
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return FriendPostCard(post: posts[index], currentUser: currentUser);
          },
        );
      },
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

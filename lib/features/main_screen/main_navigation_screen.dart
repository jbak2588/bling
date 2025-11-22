// 파일 경로: lib/features/main_screen/main_navigation_screen.dart
/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: 메인 네비게이션 구조, AppBar/Drawer/BottomNavigationBar, 위치 필터, 사용자 흐름, 반응형 정책 등
/// - 실제 코드 기능: MainNavigationScreen에서 AppBar, Drawer, BottomNavigationBar, 위치 필터, 사용자 정보, 알림 등 네비게이션 및 메인 화면 관리
/// - 비교: 기획의 네비게이션/레이아웃 구조가 실제 코드에서 State 관리와 위젯 조합으로 구현됨. 반응형/접근성/애니메이션 등은 일부 적용됨
/// Changelog     : 2025-10-30 (작업 13) 'getOrCreateBoardChatRoom' 함수 추가
///
/// 2025-10-30 (작업 13):
/// 2025-10-31 (작업 14, 21, 22, 23, 27):
///   - [Phase 4] '동네 게시판' 동적 탭 구현:
///     - `_checkKelurahanBoardStatus` 함수로 `boards.features.hasGroupChat` 플래그 확인.
///     - '동네' 탭(인덱스 1)을 항상 표시하되, 비활성 시 회색 아이콘 및 팝업(`_showBoardActivationPopup`) 표시.
///   - [버그 수정] `_buildPages()` 중복 호출 로직을 제거하여 하단 탭 인덱스 오류 완전 해결.
///   - [Phase 5] 전역 생성 시트(`_showGlobalCreateSheet`) 아이템 순서를 전략적 순서로 재배치.
///   - [Phase 6] 통합 검색 UI 리팩토링:
///     - `_isSearchActive` 상태를 중앙에서 관리.
///     - `_buildPersistentSearchBar` (신규) 위젯을 추가, 모든 화면 상단에 통일된 검색 UI 제공.
///     - 하단 검색 아이콘(`_onSearchRequested`)이 팝업 대신 이 공용 검색창을 활성화하도록 수정.
///     - `_submitSearch` 로직 추가 (keyword를 `TagSearchResultScreen`으로 전달).
/// ============================================================================
/// 2025-10-31 (작업 36):
///   - 'Jobs' 피처 이원화(regular/quick_gig)에 따른 FAB(+) 버튼 로직 수정.
///   - 'AppSection.jobs' 케이스 및 '_showGlobalCreateSheet'의 '일자리' 항목이
///     'CreateJobScreen' 대신 'SelectJobTypeScreen'을 호출하도록 변경.
/// ============================================================================
library;
// (파일 내용...)

// ===== 생성(등록) 화면: 각 Feature의 create 스크린들 =====
// [추가] 문맥 자동분기용: 인디프렌드/동네가게 생성 화면
// import 'package:bling_app/features/find_friends/screens/findfriend_form_screen.dart'; // [삭제됨]

import 'package:bling_app/features/location/providers/location_provider.dart'; // ✅ Provider Import
import 'package:bling_app/core/utils/localization_utils.dart';
// ✅ [신규] 검색 로직을 위해 모든 피드 스크린 import
import 'package:bling_app/features/local_news/screens/local_news_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_and_found_screen.dart';
import 'package:bling_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friends_screen.dart';
import 'package:bling_app/features/clubs/screens/clubs_screen.dart';
import 'package:bling_app/features/real_estate/screens/real_estate_screen.dart';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';

import 'package:bling_app/features/jobs/screens/select_job_type_screen.dart';
import 'package:bling_app/features/local_stores/screens/create_shop_screen.dart';
import 'package:bling_app/features/local_news/screens/create_local_news_screen.dart';
import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:bling_app/features/clubs/screens/create_club_screen.dart';
import 'package:bling_app/features/pom/screens/create_pom_screen.dart';
import 'package:bling_app/features/lost_and_found/screens/create_lost_item_screen.dart';
import 'package:bling_app/features/auction/screens/create_auction_screen.dart';
import 'package:bling_app/features/real_estate/screens/create_room_listing_screen.dart';

import 'package:bling_app/features/shared/grab_widgets.dart'; // GrabAppBarShell

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart'; // ✅ Provider Import
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/core/models/user_model.dart';

import 'package:bling_app/features/my_bling/screens/profile_edit_screen.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:bling_app/features/chat/screens/chat_list_screen.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'home_screen.dart';
import 'package:bling_app/features/boards/screens/kelurahan_board_screen.dart';
// ❌ [삭제] import 'package:bling_app/features/local_news/screens/tag_search_result_screen.dart';

import 'package:bling_app/features/admin/screens/admin_screen.dart'; // ✅ 관리자 화면 import
// [Fix]
import 'package:bling_app/features/categories/screens/category_admin_screen.dart'; // [Fix #52] 관리자 카테고리 화면
// [V3 NOTIFICATION] Task 80/81: 알림 서비스를 임포트합니다.
import 'package:bling_app/core/services/notification_service.dart';
// [V3 NOTIFICATION] Task 95/96: 알림 목록 화면을 임포트합니다.
import 'package:bling_app/features/notifications/screens/notification_list_screen.dart';

/// 현재 보고 있는 섹션을 타입 세이프하게 관리하기 위한 enum
enum AppSection {
  home,
  // ✅ [버그 수정] 동네 게시판 enum 추가
  board,
  localNews,
  jobs,
  lostAndFound,
  marketplace,
  localStores,
  findFriends,
  clubs,
  realEstate,
  auction,
  pom,
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _bottomNavIndex = 0;
  UserModel? _userModel;
  // Map<String, String?>? _activeLocationFilter; // Provider로 대체됨

  StreamSubscription? _userSubscription;
  StreamSubscription? _unreadChatsSubscription;
  StreamSubscription? _unreadNotificationsSubscription; // [Task 96]
  int _totalUnreadCount = 0;
  int _totalUnreadNotifications = 0; // [Task 96]
  // ✅ [게시판] 동네 게시판 활성화 상태
  bool _isKelurahanBoardActive = false;
  // 관리자 작업 로딩 상태
  bool _isAdminLoading = false;

  // ✅ [신규] 시나리오 2 (피드 내 검색 활성화)를 위한 Notifier
  final ValueNotifier<AppSection?> _searchActivationNotifier =
      ValueNotifier<AppSection?>(null);
  // [수정] 검색 트리거를 bool 타입으로 통일 (AppSection 제거)
  // 탭 내부에서 검색바를 열고 닫는 신호로만 사용
  final ValueNotifier<bool> _searchTrigger = ValueNotifier(false);

  // ✅ [스크롤 위치 보존] HomeScreen용 ScrollController 및 위치 저장 변수 추가
  final ScrollController _homeScrollController = ScrollController();
  double _savedHomeScrollOffset = 0.0;

  void goToSearchTab() {
    if (!mounted) return;

    setState(() {
      try {
        _currentHomePageContent = null; // 해당 변수가 있는 경우만
      } catch (_) {}
      //
      _bottomNavIndex = 3; // IndexedStack 방식
    });
  }

  Widget? _currentHomePageContent;

  // ✅ 번역된 문자열이 아닌 "키"를 상태로 보관
  String _appBarTitleKey = 'main.myTown';
  AppSection _currentSection = AppSection.home;

  @override
  void initState() {
    super.initState();
    // [V3 NOTIFICATION] Task 80/81: 앱 시작 시 FCM 알림 서비스를 초기화합니다.
    NotificationService.instance.init();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToUserData(user.uid);
        _listenToUnreadChats(user.uid);
        _listenToUnreadNotifications(user.uid); // [Task 96]
      } else {
        _userSubscription?.cancel();
        _unreadChatsSubscription?.cancel();
        _unreadNotificationsSubscription?.cancel(); // [Task 96]
        if (mounted) {
          setState(() {
            _userModel = null;
            _totalUnreadCount = 0;
            _totalUnreadNotifications = 0; // [Task 96]
            _isKelurahanBoardActive = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _unreadChatsSubscription?.cancel();
    _unreadNotificationsSubscription?.cancel(); // [Task 96]
    _homeScrollController.dispose();
    _searchActivationNotifier.dispose(); // ✅ Notifier 해제
    _searchTrigger.dispose();
    super.dispose();
  }

  void _listenToUserData(String uid) {
    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (mounted && doc.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(doc);
          // ✅ Provider에 사용자 정보 업데이트 (초기 위치 설정)
          context.read<LocationProvider>().setUser(_userModel);
        });
        // ✅ [게시판] 사용자 위치 로드 후 게시판 활성화 여부 확인
        _checkKelurahanBoardStatus();
      }
    });
  }

  // ✅ [게시판] Kelurahan 키 생성 헬퍼 (prov|kab|kec|kel)
  String? _getKelKey(Map<String, dynamic>? parts) {
    if (parts == null ||
        parts['prov'] == null ||
        parts['kab'] == null ||
        parts['kec'] == null ||
        parts['kel'] == null) {
      return null;
    }
    return "${parts['prov']}|${parts['kab']}|${parts['kec']}|${parts['kel']}";
  }

  // ✅ [게시판] Firestore boards/{kelKey}에서 활성화 플래그 확인
  Future<void> _checkKelurahanBoardStatus() async {
    // _userModel이 없으면 '동네' 탭 비활성화로 유지/변경
    if (_userModel == null) {
      if (_isKelurahanBoardActive) {
        if (!mounted) return;
        setState(() => _isKelurahanBoardActive = false);
      }
      return;
    }

    final kelKey = _getKelKey(_userModel?.locationParts);
    // kelKey가 없으면 비활성화로 유지/변경
    if (kelKey == null) {
      if (_isKelurahanBoardActive) {
        if (!mounted) return;
        setState(() => _isKelurahanBoardActive = false);
      }
      return;
    }
    try {
      final boardDoc = await FirebaseFirestore.instance
          .collection('boards')
          .doc(kelKey)
          .get();
      if (!mounted) return;
      if (boardDoc.exists) {
        final features =
            (boardDoc.data()?['features'] as Map<String, dynamic>?) ?? {};
        final bool isActive = features['hasGroupChat'] == true;
        if (isActive != _isKelurahanBoardActive) {
          setState(() => _isKelurahanBoardActive = isActive);
        }
      } else if (_isKelurahanBoardActive) {
        setState(() => _isKelurahanBoardActive = false);
      }
    } catch (e) {
      debugPrint('Error checking Kelurahan board status: $e');
      // 에러 발생 시에도 비활성화로 복원
      if (_isKelurahanBoardActive) {
        if (!mounted) return;
        setState(() => _isKelurahanBoardActive = false);
      }
    }
  }

  void _listenToUnreadChats(String myUid) {
    _unreadChatsSubscription?.cancel();
    final stream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .snapshots();
    _unreadChatsSubscription = stream.listen((snapshot) {
      if (mounted) {
        int count = 0;
        for (var doc in snapshot.docs) {
          count += (doc.data()['unreadCounts']?[myUid] ?? 0) as int;
        }
        setState(() => _totalUnreadCount = count);
      }
    });
  }

  /// [Task 96] 읽지 않은 알림 뱃지 카운트 리스너
  void _listenToUnreadNotifications(String myUid) {
    _unreadNotificationsSubscription?.cancel();
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('notifications')
        .where('isRead', isEqualTo: false) // 읽지 않은 것만 쿼리
        .limit(20) // 성능을 위해 최대 20개까지만 카운트
        .snapshots();

    _unreadNotificationsSubscription = stream.listen((snapshot) {
      if (mounted) {
        setState(() {
          _totalUnreadNotifications = snapshot.docs.length;
        });
      }
    });
  }

  // [UI 개선] 하단 탭 인덱스 처리 로직 변경
  // 0: 홈, 1: 동네생활, 2: 등록(+), 3: 채팅, 4: 마이
  void _onBottomNavTapped(int index) {
    // 1. 등록 버튼 (가운데)
    if (index == 2) {
      _onFloatingActionButtonTapped(); // 기존 등록 로직 재사용
      return;
    }

    // 2. 탭 이동
    setState(() {
      _bottomNavIndex = index;

      // 홈 탭 선택 시 초기화 로직
      if (index == 0) {
        _currentHomePageContent = null;
        _appBarTitleKey = 'main.myTown';
        _currentSection = AppSection.home;
      }
    });
  }

  // Note: _onSearchRequested removed; search handled via search activation notifier elsewhere.

  // _showGlobalSearchSheet removed; global search UI handled elsewhere.

  /// ✅ [신규] 전역 검색 시트 아이템
  // _searchSheetItem removed — global search sheet items handled in separate widget.

  /// ✅ [신규] AppSection 기반으로 피드 화면을 생성하고 이동
  void _buildFeedScreen(AppSection section, {bool autoFocus = false}) {
    final userModel = _userModel;
    // final activeLocationFilter = _activeLocationFilter; // 제거
    if (userModel == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('user.notLoggedIn'.tr())));
      return;
    }

    late Widget nextScreen;
    late String titleKey;
    // 동적 타이틀(카테고리 이름 등)을 위한 변수
    // String? dynamicTitle;

    switch (section) {
      case AppSection.localNews:
        titleKey = 'main.tabs.localNews';
        // [수정] 생성자 호출 시 타입 일치 확인
        nextScreen = LocalNewsScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.jobs:
        titleKey = 'main.tabs.jobs';
        nextScreen = JobsScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.lostAndFound:
        titleKey = 'main.tabs.lostAndFound';
        nextScreen = LostAndFoundScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.marketplace:
        titleKey = 'main.tabs.marketplace';
        nextScreen = MarketplaceScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
          // ✅ [추가] 카테고리 탭 변경 시 앱바 타이틀 업데이트 콜백
          onTitleChanged: (String newTitle) {
            setState(() {
              // _appBarTitleKey가 아닌 별도 변수를 쓰거나,
              // 단순화를 위해 _appBarTitleKey에 직접 텍스트를 넣고
              // tr() 호출 시 키가 없으면 텍스트 그대로 나오게 하는 방식을 활용할 수 있음.
              // 하지만 가장 안전한 방법은 화면 갱신을 유도하는 것입니다.
              // 여기서는 _getAppBarSubTitle 로직과 충돌하지 않게
              // 현재 화면 컨텐츠(_currentHomePageContent) 상태에서 타이틀을 관리하는 구조가 필요하나,
              // 기존 구조상 _appBarTitleKey를 덮어쓰는 것이 가장 빠릅니다.
              // (참고: .tr()은 키가 없으면 키 자체를 리턴하므로,
              //  newTitle이 번역된 문자열이라면 그대로 표시됩니다.)
              _appBarTitleKey = newTitle;
            });
          },
        );
        break;
      case AppSection.localStores:
        // ... (나머지 케이스 유지)
        titleKey = 'main.tabs.localStores';
        nextScreen = LocalStoresScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.findFriends:
        titleKey = 'main.tabs.findFriends';
        nextScreen = FindFriendsScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.clubs:
        titleKey = 'main.tabs.clubs';
        nextScreen = ClubsScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.realEstate:
        titleKey = 'main.tabs.realEstate';
        nextScreen = RealEstateScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.auction:
        titleKey = 'main.tabs.auction';
        nextScreen = AuctionScreen(
          userModel: userModel,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.pom:
        titleKey = 'main.tabs.pom';
        nextScreen = PomScreen(
          userModel: userModel,
          initialPoms: null,
          initialIndex: 0,
          autoFocusSearch: autoFocus,
          searchNotifier: _searchTrigger,
        );
        break;
      case AppSection.home:
      case AppSection.board:
        return;
    }

    _navigateToPage(nextScreen, titleKey);
  }

  Future<void> _onFloatingActionButtonTapped() async {
    // ✅ [핵심 수정] 기존의 _userModel 검사 대신,
    // Firebase의 현재 인증 상태를 직접 확인하는 로직으로 변경합니다.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 만약 이 순간에 로그인이 풀려있다면, 사용자에게 알리고 즉시 종료합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('main.errors.loginRequiredRetry'.tr())),
      );
      return;
    }

    if (_userModel == null) return; // _userModel이 로드될 때까지 기다리는 방어 코드
    // 안전하게 지역 변수로 복사하여 이후에 `userModel`를 사용합니다.
    final userModel = _userModel as UserModel;

    // 홈 루트(아이콘 그리드/탭 진입 전)에서는 전역 시트 노출
    if (_bottomNavIndex == 0 && _currentHomePageContent == null) {
      _showGlobalCreateSheet();
      return;
    }

    // 섹션 내부: enum 기준으로 안전 분기
    late Widget target;

    switch (_currentSection) {
      case AppSection.board:
        target = const CreateLocalNewsScreen();
        break;
      case AppSection.localNews:
        target = const CreateLocalNewsScreen();
        break;
      case AppSection.marketplace:
        target = const ProductRegistrationScreen();
        break;
      case AppSection.findFriends:
        target = const ProfileEditScreen(); // [v2.1] ProfileEditScreen으로 변경
        break;
      case AppSection.clubs:
        target = CreateClubScreen(userModel: userModel);
        break;
      case AppSection.jobs:
        // ✅ [작업 31] 일자리 생성 시, 유형 선택 화면으로 이동
        target = SelectJobTypeScreen(userModel: userModel);
        break;
      case AppSection.localStores:
        target = CreateShopScreen(userModel: userModel);
        break;
      case AppSection.auction:
        target = CreateAuctionScreen(userModel: userModel);
        break;
      case AppSection.pom:
        target = CreatePomScreen(userModel: userModel);
        break;
      case AppSection.lostAndFound:
        target = CreateLostItemScreen(userModel: userModel);
        break;
      case AppSection.realEstate:
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CreateRoomListingScreen(userModel: userModel),
          ),
        );
        if (!mounted) return;
        return;
      case AppSection.home:
        // 홈 루트로 오면 이미 위에서 전역 시트를 띄우므로 여기선 기본값 처리 없음
        return;
    }

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }

  /// 메인(홈 루트)에서만 사용되는 전역 생성 시트
  void _showGlobalCreateSheet() {
    if (_userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('main.errors.loginRequiredRetry'.tr())),
      );
      return;
    }
    final userModel = _userModel as UserModel;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              // ✅ [작업 19] 전략적 순서로 재배열
              // 1) 동네소식
              _sheetItem(
                  Icons.article_rounded, // 1. localNews
                  'main.tabs.localNews'.tr(),
                  'localNewsCreate.appBarTitle'.tr(),
                  builder: () => const CreateLocalNewsScreen()),
              // 2) 동네 일자리
              _sheetItem(
                  Icons.work_outline_rounded, // 2. jobs
                  'main.tabs.jobs'.tr(),
                  'jobs.form.title'.tr(),
                  builder: () =>
                      SelectJobTypeScreen(userModel: userModel)), // ✅ [작업 31]
              // 3) 분실물센터
              _sheetItem(
                  Icons.report_gmailerrorred_rounded, // 3. lostAndFound
                  'main.tabs.lostAndFound'.tr(),
                  'lostAndFound.form.title'.tr(),
                  builder: () => CreateLostItemScreen(userModel: userModel)),
              // 4) 중고거래
              _sheetItem(
                  Icons.store_mall_directory_rounded, // 4. marketplace
                  'main.tabs.marketplace'.tr(),
                  'marketplace.registration.title'.tr(),
                  builder: () => const ProductRegistrationScreen()),
              // 5) 동네업체
              _sheetItem(
                  Icons.storefront_rounded, // 5. localStores
                  'main.tabs.localStores'.tr(),
                  'localStores.create.title'.tr(),
                  builder: () => CreateShopScreen(userModel: userModel)),
              // 6) 모임
              _sheetItem(
                  Icons.groups_rounded, // 6. clubs
                  'main.tabs.clubs'.tr(),
                  'clubs.create.title'.tr(),
                  builder: () => CreateClubScreen(userModel: userModel)),
              // 7) 친구찾기
              _sheetItem(
                  Icons.sentiment_satisfied_alt_rounded, // 7. findFriends
                  'main.tabs.findFriends'.tr(),
                  'myBling.editProfile'.tr(), // [v2.1] 툴팁 변경
                  builder: () =>
                      const ProfileEditScreen()), // [v2.1] ProfileEditScreen으로 변경
              // 8) 부동산
              _sheetItem(
                  Icons.house_rounded, // 8. realEstate
                  'main.tabs.realEstate'.tr(),
                  'realEstate.form.title'.tr(),
                  builder: () => CreateRoomListingScreen(userModel: userModel)),
              // 9) 경매
              _sheetItem(
                  Icons.gavel_rounded, // 9. auction
                  'main.tabs.auction'.tr(),
                  'auctions.create.title'.tr(),
                  builder: () => CreateAuctionScreen(userModel: userModel)),
              // 10) 숏폼
              _sheetItem(
                  Icons.video_camera_back_rounded, // 10. pom
                  'main.tabs.pom'.tr(),
                  'pom.create.title'.tr(),
                  builder: () => CreatePomScreen(userModel: userModel)),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ✅ '동네' 탭 비활성 상태 안내 팝업 및 Local News 작성 유도
  void _showBoardActivationPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('boards.popup.inactiveTitle'.tr()),
        content: Text('boards.popup.inactiveBody'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateLocalNewsScreen(),
                ),
              );
            },
            child: Text('boards.popup.writePost'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _sheetItem(IconData icon, String title, String sub,
      {Widget Function()? builder, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.of(context).pop();
        if (onTap != null) {
          onTap();
          return;
        }
        if (builder != null) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => builder()));
        }
      },
    );
  }

  // [수정] 매개변수 이름을 명확하게 변경 (selectedIndex -> currentTab)
  PreferredSizeWidget _buildAppBar(int currentTab) {
    // ✅ locale 의존성만 생성(교체X, 리빌드O)
    final _ = context.locale;
    final photoUrl = _userModel?.photoUrl;
    // [로직] 검색 아이콘 표시 여부 결정
    // 숨김: 홈 루트(하위 컨텐츠가 없고 _bottomNavIndex == 0) 또는 채팅 탭(_bottomNavIndex == 3)
    final bool isHomeRoot =
        (_bottomNavIndex == 0 && _currentHomePageContent == null);
    final bool isChatTab = (_bottomNavIndex == 3);
    final showSearchIcon = !(isHomeRoot || isChatTab);
    return GrabAppBarShell(
      // ↓↓↓ 기존 leading 로직 그대로
      leading: (_bottomNavIndex == 0 && _currentHomePageContent != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentHomePageContent = null;
                  _appBarTitleKey = 'main.myTown'; // 키로 저장
                });
                // ✅ [스크롤 위치 보존] 다음 프레임에서 스크롤 위치 복원
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // 컨트롤러가 HomeScreen의 ScrollView에 연결된 후 실행
                  if (_homeScrollController.hasClients) {
                    _homeScrollController
                        .jumpTo(_savedHomeScrollOffset); // 저장된 위치로 즉시 이동
                  }
                });
              },
            )
          : Builder(
              builder: (context) => IconButton(
                // ✅ [스크롤 위치 보존] Drawer 열 때 스크롤 위치 저장 (선택 사항, 필요시)
                // onPressed: () {
                //   _savedHomeScrollOffset = _homeScrollController.hasClients ? _homeScrollController.offset : 0.0;
                //   Scaffold.of(context).openDrawer();
                // },
                icon: CircleAvatar(
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),

      // ↓↓↓ 기존 title 로직 (위치 필터 열기/타이틀 텍스트 구성 등)
      title: InkWell(
        onTap: () async {
          // ✅ [수정] 반환값 받을 필요 없이 Provider가 상태 관리
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => LocationFilterScreen(userModel: _userModel)),
          );
          // 화면 갱신 (Provider 구독은 하위 위젯들이 하므로 여기선 setState만 호출해주면 됨)
          if (mounted) {
            setState(() {
              // 홈 루트일 때만 상단 타이틀을 '내 동네' 키로 변경
              if (_currentHomePageContent == null) {
                _appBarTitleKey = 'main.myTown'; // 키 저장
              }
              // 섹션 화면이면 해당 섹션을 재생성하여 필터 반영
              if (_currentHomePageContent != null &&
                  _currentSection != AppSection.home &&
                  _currentSection != AppSection.board) {
                _buildFeedScreen(_currentSection);
              }
            });
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ 항상 build 시점에 번역되도록 .tr() 호출
            // 👇 [수정] 메인 타이틀도 Flexible로 감싸서 공간을 유연하게 차지하도록 변경
            Flexible(
              child: Text(
                _appBarTitleKey.tr(),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis, // 글자가 길면 ...으로 표시
                maxLines: 1, // 한 줄만 표시
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              // ✅ [수정] LocationProvider의 displayTitle 사용
              child: Consumer<LocationProvider>(
                builder: (context, provider, _) {
                  return Text(
                    provider.displayTitle, // "역삼동" or "내 주변 5km"
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),

      centerTitle: true, // 기존과 동일하게 가운데 정렬
      // ↓↓↓ 기존 actions 그대로
      actions: [
        // [추가] 검색 아이콘 (각 탭의 InlineSearchChip을 열기 위함)
        if (showSearchIcon)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87, size: 24),
            tooltip: '검색',
            onPressed: () {
              // 검색 트리거 신호 발송 (true/false 토글)
              _searchTrigger.value = !_searchTrigger.value;
            },
          ),
        // [Task 96] 알림 아이콘 버튼 수정
        // Debug: resolve tooltip text and log to help diagnose missing localization key
        Builder(builder: (context) {
          final notifTooltip =
              safeTr(context, 'notifications.title', fallback: '');
          debugPrint(
              'MainNavigationScreen - notifications.title -> $notifTooltip, locale: ${context.locale}');
          return IconButton(
            tooltip: notifTooltip,
            icon: _totalUnreadNotifications > 0
                ? Badge(
                    label: Text('$_totalUnreadNotifications'),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications_none),
            onPressed: () {
              // Task 95에서 생성한 알림 목록 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const NotificationListScreen()),
              );
            },
          );
        }),
      ],

      // 선택 옵션: 액션 버튼을 흰색 동글칩으로 감쌀지 여부 (원하면 true 유지)
      pillActions: true,
    );
  }

  // AppBar subtitle is now provided by LocationProvider.displayTitle

  /// [Fix] AI 검수 횟수 초기화 확인 다이얼로그 (누락된 함수 호출)
  void _confirmResetAiCounts() async {
    Navigator.of(context).pop(); // Drawer 닫기

    final bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('admin.reset.confirmTitle'.tr()),
        content: Text('admin.reset.confirmContent'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('admin.reset.execute'.tr(),
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetAiCancelCounts();
    }
  }

  /// [Fix] AI 검수 횟수 초기화 함수 호출
  Future<void> _resetAiCancelCounts() async {
    // [Fix] 20여개 문서이므로 Cloud Function 대신 Client-side Batch Write 실행
    setState(() => _isAdminLoading = true);
    try {
      final db = FirebaseFirestore.instance;
      final productsRef = db.collection('products');

      // 1. 대상 문서 조회
      final snapshot =
          await productsRef.where('aiCancelCount', isGreaterThan: 0).get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('admin.reset.noTargets'.tr())),
        );
        if (mounted) setState(() => _isAdminLoading = false);
        return;
      }

      // 2. 배치(Batch) 작업 생성
      final batch = db.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'aiCancelCount': 0});
      }

      // 3. 배치 커밋
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('admin.reset.success'
                .tr(namedArgs: {'count': snapshot.docs.length.toString()}))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'admin.reset.fail'.tr(namedArgs: {'error': e.toString()}))),
      );
    } finally {
      if (mounted) setState(() => _isAdminLoading = false);
    }
  }

  void _navigateToPage(Widget page, String titleKey) {
    // ✅ [스크롤 위치 보존] 네비게이션 전에 현재 스크롤 위치 저장
    // 상세 화면으로 이동하는 경우에만 저장 (setState 호출 전에)
    if (_homeScrollController.hasClients) {
      // HomeScreen이 화면에 있을 때만 offset 접근
      _savedHomeScrollOffset = _homeScrollController.offset;
    }
    setState(() {
      _currentHomePageContent = page;
      _appBarTitleKey = titleKey; // 키 그대로 저장
      _currentSection = _sectionFromTitleKey(titleKey);
    });
  }

  /// i18n 키를 enum으로 매핑 (기존 데이터/문서의 키를 바꾸지 않고 안전하게 분기)
  AppSection _sectionFromTitleKey(String key) {
    switch (key) {
      case 'main.tabs.localNews':
        return AppSection.localNews;
      case 'main.bottomNav.board':
        return AppSection.board;
      case 'main.tabs.marketplace':
        return AppSection.marketplace;
      case 'main.tabs.findFriends':
        return AppSection.findFriends;
      case 'main.tabs.clubs':
        return AppSection.clubs;
      case 'main.tabs.jobs':
        return AppSection.jobs;
      case 'main.tabs.localStores':
        return AppSection.localStores;
      case 'main.tabs.auction':
        return AppSection.auction;
      case 'main.tabs.pom':
        return AppSection.pom;
      case 'main.tabs.lostAndFound':
        return AppSection.lostAndFound;
      case 'main.tabs.realEstate':
        return AppSection.realEstate;
      default:
        return AppSection.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    // [UI 개선] 하단 탭 구성에 맞춰 페이지 리스트 재정의
    final List<Widget> pages = [
      // 0. 홈
      _currentHomePageContent ??
          HomeScreen(
            controller: _homeScrollController,
            userModel: _userModel,
            activeLocationFilter:
                Provider.of<LocationProvider>(context).adminFilter,
            searchNotifier: _searchTrigger,
            // [수정] 홈 화면 아이콘 클릭 시 이동할 때도 searchTrigger를 전달할 수 있도록 구조 변경 가능하나,
            // 현재는 홈에서 직접 feature 스크린을 띄우므로, 여기서 searchTrigger를 넘겨줘야 함.
            // 하지만 HomeScreen 내부 구현상 별도 처리가 필요하므로 아래 HomeScreen 패치 참조.
            onIconTap: _navigateToPage,
          ),
      // 1. 동네생활 (게시판) - 활성 상태 체크
      if (_isKelurahanBoardActive && _userModel != null)
        KelurahanBoardScreen(userModel: _userModel as UserModel),
      // 2. (등록 버튼 자리 - 페이지 없음, 더미)
      const SizedBox.shrink(),
      // 3. 채팅
      const ChatListScreen(),
      // 4. 마이
      (_userModel != null)
          ? MyBlingScreen(
              userModel: _userModel as UserModel, onIconTap: _navigateToPage)
          : const Center(child: CircularProgressIndicator()),
    ];

    // IndexedStack용 인덱스 보정 (게시판 비활성 시 인덱스 밀림 처리)
    int effectiveIndex;
    final hasBoardTab = _isKelurahanBoardActive && _userModel != null;

    // _bottomNavIndex: 0(홈), 1(동네), 2(등록), 3(채팅), 4(마이)
    // pages: [Home, Board(opt), Dummy, Chat, My]
    if (hasBoardTab) {
      // Board가 있으면 인덱스 그대로 매핑 (단, 2는 등록버튼이므로 제외)
      effectiveIndex = _bottomNavIndex;
    } else {
      // Board가 없으면:
      // 0(홈) -> 0
      // 1(동네 - 비활성) -> (처리 안함/팝업)
      // 3(채팅) -> pages[2]
      // 4(마이) -> pages[3]
      if (_bottomNavIndex == 0) {
        effectiveIndex = 0;
      } else if (_bottomNavIndex >= 3) {
        effectiveIndex = _bottomNavIndex - 1;
      } else {
        effectiveIndex = 0;
      }
    }

    return Scaffold(
      // [수정] _selectedIndex(없는 변수) 대신 기존 _bottomNavIndex 전달
      appBar: _buildAppBar(_bottomNavIndex),
      drawer: _buildAppDrawer(_userModel),
      body: IndexedStack(
        index: effectiveIndex,
        children: pages,
      ),
      // [UI 개선] BottomNavigationBar로 교체 (균형 잡힌 배치 + 텍스트 라벨)
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // 클릭 효과(물결) 색상 조정
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            final hasBoardTab = _isKelurahanBoardActive && _userModel != null;
            if (index == 1 && !hasBoardTab) {
              _showBoardActivationPopup();
              return;
            }
            _onBottomNavTapped(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,

          // ✅ [UI 개선] 비활성 아이콘도 회색 대신 브랜드 컬러(연하게) 적용
          unselectedItemColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.6),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: 'main.bottomNav.home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.holiday_village_outlined),
              activeIcon: const Icon(Icons.holiday_village),
              label: 'main.bottomNav.board'.tr(),
            ),
            // [중앙] 등록 버튼 (FAB 대체)
            BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .primaryColor
                          .withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _totalUnreadCount > 0,
                label: Text('$_totalUnreadCount'),
                child: const Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Badge(
                isLabelVisible: _totalUnreadCount > 0,
                label: Text('$_totalUnreadCount'),
                child: const Icon(Icons.chat_bubble),
              ),
              label: 'main.bottomNav.chat'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'main.bottomNav.myBling'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  // _buildBottomNavItem removed — navigation now handled by BottomNavigationBar

  Widget _buildAppDrawer(UserModel? userModel) {
    return Drawer(
      child: userModel == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF6A1B9A)),
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: (userModel.photoUrl != null &&
                                userModel.photoUrl!.startsWith('http'))
                            ? NetworkImage(userModel.photoUrl!)
                            : null,
                        child: (userModel.photoUrl == null ||
                                !userModel.photoUrl!.startsWith('http'))
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8.0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(userModel.nickname,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.white)),
                                TrustLevelBadge(
                                    // [v2.1] 런타임 예외 수정: _userModel이 null일 때를 대비
                                    // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
                                    trustLevelLabel:
                                        _userModel?.trustLevelLabel ?? 'normal',
                                    showText: true),
                                Text('(${userModel.trustScore})',
                                    style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(userModel.email,
                                style: GoogleFonts.inter(
                                    color: Colors.white70, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.military_tech, color: Colors.brown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('drawer.trustDashboard.title'.tr(),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) =>
                                TrustScoreBreakdownModal(key: UniqueKey())),
                        child: Text(
                            'drawer.trustDashboard.breakdownButton'.tr(),
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                _buildTrustInfoTile(
                    icon: Icons.location_city,
                    titleKey: 'drawer.trustDashboard.kelurahanAuth',
                    isCompleted: userModel.locationParts?['kel'] != null),
                _buildTrustInfoTile(
                    icon: Icons.home_work_outlined,
                    titleKey: 'drawer.trustDashboard.rtRwAuth',
                    isCompleted: userModel.locationParts?['rt'] != null),
                _buildTrustInfoTile(
                    icon: Icons.phone_android,
                    titleKey: 'drawer.trustDashboard.phoneAuth',
                    isCompleted: userModel.phoneNumber != null &&
                        userModel.phoneNumber!.isNotEmpty),
                _buildTrustInfoTile(
                    icon: Icons.verified_user,
                    titleKey: 'drawer.trustDashboard.profileComplete',
                    isCompleted: userModel.profileCompleted),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('drawer.editProfile'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ProfileEditScreen()));
                  },
                ),

                // ✅ [신규] userModel의 isAdmin 플래그를 확인하여 관리자 메뉴를 표시합니다.
                if (userModel.isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('관리자 페이지'),
                    onTap: () {
                      Navigator.of(context).pop(); // Drawer를 닫고
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AdminScreen())); // 관리자 페이지로 이동
                    },
                  ),

                  // [Fix #52] 신규 카테고리 관리자 화면 연결
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('ADMIN: Category Manager (V2)'),
                    onTap: () {
                      Navigator.of(context).pop(); // Drawer를 닫고
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const CategoryAdminScreen(),
                      ));
                    },
                  ),

                  // 'Upload AI Rules' (V2) removed: uploader is deprecated in favor of Firestore atomic deploy

                  // [Fix] 누락된 'AI Cancel Count 초기화' 메뉴 추가
                  if (_isAdminLoading)
                    const ListTile(
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('Initializing AI Counts...'),
                    )
                  else
                    ListTile(
                      leading: Icon(
                        Icons.history_toggle_off,
                        color: _isAdminLoading ? Colors.grey : Colors.orange,
                      ),
                      title: const Text('ADMIN: Reset AI Cancel Counts'),
                      enabled: !_isAdminLoading, // 다른 관리자 작업 중 비활성화
                      onTap:
                          _confirmResetAiCounts, // [Fix] _resetAiCancelCounts -> _confirmResetAiCounts
                    ),
                ],
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text('drawer.logout'.tr()),
                  onTap: () async {
                    if (mounted) Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildTrustInfoTile(
      {required IconData icon,
      required String titleKey,
      required bool isCompleted}) {
    return ListTile(
      leading: Icon(icon, color: isCompleted ? Colors.teal : Colors.grey),
      title: Text(titleKey.tr(), style: GoogleFonts.inter(fontSize: 15)),
      trailing: Icon(isCompleted ? Icons.check_circle : Icons.cancel,
          color: isCompleted ? Colors.green : Colors.grey, size: 22),
    );
  }
}

class SearchScreen extends StatelessWidget {
  // ✅ [작업 49] 임시 검색 결과 표시용
  final String? tempSearchQuery;
  const SearchScreen({super.key, this.tempSearchQuery});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GrabAppBarShell(
          title: Text(tempSearchQuery ?? 'main.bottomNav.search'.tr())),
      body: Center(
          child: Text(tempSearchQuery != null
              ? "'$tempSearchQuery' ${'search.sheet.comingSoon'.tr()}"
              : 'main.search.placeholder'.tr())),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class TrustScoreBreakdownModal extends StatelessWidget {
  const TrustScoreBreakdownModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('drawer.trustDashboard.breakdownModalTitle'.tr(),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _breakdownRow('drawer.trustDashboard.kelurahanAuth',
                'drawer.trustDashboard.breakdown.kelurahanAuth'),
            _breakdownRow('drawer.trustDashboard.rtRwAuth',
                'drawer.trustDashboard.breakdown.rtRwAuth'),
            _breakdownRow('drawer.trustDashboard.phoneAuth',
                'drawer.trustDashboard.breakdown.phoneAuth'),
            _breakdownRow('drawer.trustDashboard.profileComplete',
                'drawer.trustDashboard.breakdown.profileComplete'),
            const Divider(),
            _breakdownRow('drawer.trustDashboard.feedThanks',
                'drawer.trustDashboard.breakdown.feedThanks'),
            _breakdownRow('drawer.trustDashboard.marketThanks',
                'drawer.trustDashboard.breakdown.marketThanks'),
            _breakdownRow('drawer.trustDashboard.reports',
                'drawer.trustDashboard.breakdown.reports'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('drawer.trustDashboard.breakdownClose'.tr()),
        ),
      ],
    );
  }

  Widget _breakdownRow(String labelKey, String valueKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(labelKey.tr(), style: GoogleFonts.inter())),
          Text(valueKey.tr(),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

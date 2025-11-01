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
import 'package:bling_app/features/find_friends/screens/findfriend_form_screen.dart';
import 'package:bling_app/features/jobs/screens/select_job_type_screen.dart';
import 'package:bling_app/features/local_stores/screens/create_shop_screen.dart';

import 'package:bling_app/features/local_news/screens/create_local_news_screen.dart';
// import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:bling_app/features/clubs/screens/create_club_screen.dart';
import 'package:bling_app/features/pom/screens/create_short_screen.dart';
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

import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/my_bling/screens/profile_edit_screen.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:bling_app/features/chat/screens/chat_list_screen.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'home_screen.dart';
import 'package:bling_app/features/boards/screens/kelurahan_board_screen.dart';
import 'package:bling_app/features/local_news/screens/tag_search_result_screen.dart';

import 'package:bling_app/features/admin/screens/admin_screen.dart'; // ✅ 관리자 화면 import
import 'package:bling_app/core/utils/ai_rule_uploader.dart';

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
  Map<String, String?>? _activeLocationFilter;
  String _currentAddress = "Loading...";
  bool _isLocationLoading = true;
  StreamSubscription? _userSubscription;
  StreamSubscription? _unreadChatsSubscription;
  int _totalUnreadCount = 0;
  // ✅ [게시판] 동네 게시판 활성화 상태
  bool _isKelurahanBoardActive = false;

  // ✅ [검색] 검색창 UI 상태
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  // ✅ [검색] 홈 화면 인라인 검색칩 제어용
  final ValueNotifier<bool> _homeSearchOpen = ValueNotifier<bool>(false);

  // ✅ [스크롤 위치 보존] HomeScreen용 ScrollController 및 위치 저장 변수 추가
  final ScrollController _homeScrollController = ScrollController();
  double _savedHomeScrollOffset = 0.0;

  void goToSearchTab() {
    if (!mounted) return;

    setState(() {
      try {
        _currentHomePageContent = null; // 해당 변수가 있는 경우만
      } catch (_) {}
      // ✅ 검색 아이콘은 항상 index 3 (FAB를 중심으로 좌우 아이콘 고정)
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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToUserData(user.uid);
        _listenToUnreadChats(user.uid);
      } else {
        _userSubscription?.cancel();
        _unreadChatsSubscription?.cancel();
        if (mounted) {
          setState(() {
            _userModel = null;
            _currentAddress = 'main.appBar.locationNotSet'.tr();
            _isLocationLoading = false;
            _totalUnreadCount = 0;
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
    // ✅ [스크롤 위치 보존] ScrollController 해제
    _homeScrollController.dispose();
    // ✅ [검색] 검색 리소스 해제
    _searchController.dispose();
    _searchFocusNode.dispose();
    _homeSearchOpen.dispose();
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
          // [수정] _currentAddress를 locationName 대신 locationParts['kab']으로 초기화 시도
          _currentAddress = _userModel!.locationParts?['kab'] ??
              _userModel!.locationName ??
              'main.appBar.locationNotSet'.tr();
          _isLocationLoading = false;
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

    final kelKey = _getKelKey(_userModel!.locationParts);
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

  void _onBottomNavItemTapped(int index) {
    if (index == 2) {
      _onFloatingActionButtonTapped();
      return;
    }
    // 검색 아이콘(index 3)은 태그 입력 다이얼로그로 처리
    if (index == 3) {
      // 홈이 보이는 상태라면 인라인 칩을 열고, 그 외에는 상단 검색바 활성화
      final hasBoardTab = _isKelurahanBoardActive && _userModel != null;
      final effectiveIndex = hasBoardTab
          ? (_bottomNavIndex >= 3 ? _bottomNavIndex - 1 : _bottomNavIndex)
          : (_bottomNavIndex >= 3 ? _bottomNavIndex - 2 : _bottomNavIndex);
      final isHomeVisible =
          (effectiveIndex == 0) && _currentHomePageContent == null;
      if (isHomeVisible) {
        _homeSearchOpen.value = true;
      } else {
        _onSearchRequested();
      }
      return;
    }
    if (index == 0 && _currentHomePageContent != null) {
      setState(() {
        _currentHomePageContent = null;
        _appBarTitleKey = 'main.myTown'; // 홈으로 돌아올 때 키 초기화
        _currentSection = AppSection.home; // 섹션도 홈으로 복원
      });
    }
    setState(() {
      _bottomNavIndex = index;
    });
  }

  /// ✅ [검색] 'showDialog' 대신 상단 고정 검색바 활성화
  Future<void> _onSearchRequested() async {
    if (!mounted) return;
    setState(() {
      _isSearchActive = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  // ✅ [검색] 제출 처리: keyword로 결과 화면 이동
  void _submitSearch(String query) {
    final keyword = query.trim();
    if (keyword.isEmpty) return;
    setState(() {
      _isSearchActive = false;
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagSearchResultScreen(keyword: keyword),
      ),
    );
  }

  // ✅ [검색] 홈 인라인 칩 제출 처리
  void _onInlineSearchSubmit(String keyword) {
    FocusScope.of(context).unfocus();
    _homeSearchOpen.value = false;
    if (keyword.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TagSearchResultScreen(keyword: keyword.trim()),
      ),
    );
  }

  Future<void> _onFloatingActionButtonTapped() async {
    // ✅ [핵심 수정] 기존의 _userModel 검사 대신,
    // Firebase의 현재 인증 상태를 직접 확인하는 로직으로 변경합니다.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 만약 이 순간에 로그인이 풀려있다면, 사용자에게 알리고 즉시 종료합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다. 다시 시도해주세요.')),
      );
      return;
    }

    if (_userModel == null) return; // _userModel이 로드될 때까지 기다리는 방어 코드

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
        target = FindFriendFormScreen(userModel: _userModel!);
        break;
      case AppSection.clubs:
        target = CreateClubScreen(userModel: _userModel!);
        break;
      case AppSection.jobs:
        // ✅ [작업 31] 일자리 생성 시, 유형 선택 화면으로 이동
        target = SelectJobTypeScreen(userModel: _userModel!);
        break;
      case AppSection.localStores:
        target = CreateShopScreen(userModel: _userModel!);
        break;
      case AppSection.auction:
        target = CreateAuctionScreen(userModel: _userModel!);
        break;
      case AppSection.pom:
        target = CreateShortScreen(userModel: _userModel!);
        break;
      case AppSection.lostAndFound:
        target = CreateLostItemScreen(userModel: _userModel!);
        break;
      case AppSection.realEstate:
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CreateRoomListingScreen(userModel: _userModel!),
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
                  () => const CreateLocalNewsScreen()),
              // 2) 동네 일자리
              _sheetItem(
                  Icons.work_outline_rounded, // 2. jobs
                  'main.tabs.jobs'.tr(),
                  'jobs.form.title'.tr(),
                  () =>
                      SelectJobTypeScreen(userModel: _userModel!)), // ✅ [작업 31]
              // 3) 분실물센터
              _sheetItem(
                  Icons.report_gmailerrorred_rounded, // 3. lostAndFound
                  'main.tabs.lostAndFound'.tr(),
                  'lostAndFound.form.title'.tr(),
                  () => CreateLostItemScreen(userModel: _userModel!)),
              // 4) 중고거래
              _sheetItem(
                  Icons.store_mall_directory_rounded, // 4. marketplace
                  'main.tabs.marketplace'.tr(),
                  'marketplace.registration.title'.tr(),
                  () => const ProductRegistrationScreen()),
              // 5) 동네업체
              _sheetItem(
                  Icons.storefront_rounded, // 5. localStores
                  'main.tabs.localStores'.tr(),
                  'localStores.create.title'.tr(),
                  () => CreateShopScreen(userModel: _userModel!)),
              // 6) 모임
              _sheetItem(
                  Icons.groups_rounded, // 6. clubs
                  'main.tabs.clubs'.tr(),
                  'clubs.create.title'.tr(),
                  () => CreateClubScreen(userModel: _userModel!)),
              // 7) 친구찾기
              _sheetItem(
                  Icons.sentiment_satisfied_alt_rounded, // 7. findFriends
                  'main.tabs.findFriends'.tr(),
                  'findfriend.form.title'.tr(),
                  () => FindFriendFormScreen(userModel: _userModel!)),
              // 8) 부동산
              _sheetItem(
                  Icons.house_rounded, // 8. realEstate
                  'main.tabs.realEstate'.tr(),
                  'realEstate.form.title'.tr(),
                  () => CreateRoomListingScreen(userModel: _userModel!)),
              // 9) 경매
              _sheetItem(
                  Icons.gavel_rounded, // 9. auction
                  'main.tabs.auction'.tr(),
                  'auctions.create.title'.tr(),
                  () => CreateAuctionScreen(userModel: _userModel!)),
              // 10) 숏폼
              _sheetItem(
                  Icons.video_camera_back_rounded, // 10. pom
                  'main.tabs.pom'.tr(),
                  'pom.create.title'.tr(),
                  () => CreateShortScreen(userModel: _userModel!)),
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

  Widget _sheetItem(
      IconData icon, String title, String sub, Widget Function() builder) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => builder()));
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // ✅ locale 의존성만 생성(교체X, 리빌드O)
    final _ = context.locale;
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
                  backgroundImage: (_userModel?.photoUrl != null &&
                          _userModel!.photoUrl!.isNotEmpty)
                      ? NetworkImage(_userModel!.photoUrl!)
                      : null,
                  child: (_userModel?.photoUrl == null ||
                          _userModel!.photoUrl!.isEmpty)
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
          final result = await Navigator.of(context).push<Map<String, String?>>(
            MaterialPageRoute(
                builder: (_) => LocationFilterScreen(userModel: _userModel)),
          );

          if (result != null && mounted) {
            final processedFilter = <String, String?>{};
            // ✅ 타이틀은 키만 유지하고, 화면에서 .tr()로 번역합니다.
            String newTitleKey = 'main.myTown';

            if (result['kel'] != null && result['kel']!.isNotEmpty) {
              processedFilter['kel'] = result['kel'];
              newTitleKey = 'main.myTown';
            } else if (result['kec'] != null && result['kec']!.isNotEmpty) {
              processedFilter['kec'] = result['kec'];
              newTitleKey = 'main.myTown';
            } else if (result['kota'] != null && result['kota']!.isNotEmpty) {
              processedFilter['kota'] = result['kota'];
              newTitleKey = 'main.myTown';
            } else if (result['kab'] != null && result['kab']!.isNotEmpty) {
              processedFilter['kab'] = result['kab'];
              newTitleKey = 'main.myTown';
            } else if (result['prov'] != null && result['prov']!.isNotEmpty) {
              processedFilter['prov'] = result['prov'];
              newTitleKey = 'main.myTown';
            }

            setState(() {
              _activeLocationFilter =
                  processedFilter.isNotEmpty ? processedFilter : null;
              _appBarTitleKey = newTitleKey; // 키 저장
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
              child: Text(
                _getAppBarSubTitle(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),

      centerTitle: true, // 기존과 동일하게 가운데 정렬
      // ↓↓↓ 기존 actions 그대로
      actions: [
        _LanguageMenu(),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],

      // 선택 옵션: 액션 버튼을 흰색 동글칩으로 감쌀지 여부 (원하면 true 유지)
      pillActions: true,
    );
  }

  // --- AppBar 부제목 표시 로직 ---
  String _getAppBarSubTitle() {
    if (_isLocationLoading) {
      return 'main.appBar.locationLoading'.tr();
    }
    // 1. 사용자가 설정한 필터가 있으면, 그 값을 최우선으로 표시
    if (_activeLocationFilter != null &&
        _activeLocationFilter!.values.first != null) {
      return StringExtension(_activeLocationFilter!.values.first!).capitalize();
    }
    // 2. 필터가 없으면, 사용자의 기본 위치 정보에서 'kab' 값을 가져와 표시
    final userKabupaten = _userModel?.locationParts?['kab'];
    if (userKabupaten != null && userKabupaten.isNotEmpty) {
      return StringExtension(userKabupaten).capitalize();
    }
    // 3. 'kab' 값도 없으면, 기존의 전체 주소(_currentAddress)를 축약해서 표시
    return AddressFormatter.toSingkatan(_currentAddress);
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
    final List<Widget> pages = [
      _currentHomePageContent ??
          HomeScreen(
            // ✅ [스크롤 위치 보존] ScrollController 전달
            controller: _homeScrollController,
            userModel: _userModel,
            activeLocationFilter: _activeLocationFilter,
            // onIconTap 콜백은 이미 스크롤 위치 저장을 처리함 (_navigateToPage 내부)
            onIconTap: _navigateToPage,
            onSearchChipTap: () => _homeSearchOpen.value = true,
            openSearchNotifier: _homeSearchOpen,
            onSearchSubmit: _onInlineSearchSubmit,
          ),
      if (_isKelurahanBoardActive && _userModel != null)
        KelurahanBoardScreen(userModel: _userModel!),
      const SearchScreen(),
      const ChatListScreen(),
      const MyBlingScreen(),
    ];

    // ✅ BottomAppBar 인덱스(0, [1], 3, 4, 5)를 실제 pages 인덱스에 매핑
    // - '동네' 탭 활성: pages = [Home(0), Board(1), Search(2), Chat(3), My(4)]
    //   => nav index >=3 는 -1, 그 외는 그대로
    // - '동네' 탭 비활성: pages = [Home(0), Search(1), Chat(2), My(3)]
    //   => nav index >=3 는 -2, 그 외(0)는 그대로
    int effectiveIndex;
    final hasBoardTab = _isKelurahanBoardActive && _userModel != null;
    if (hasBoardTab) {
      effectiveIndex = (_bottomNavIndex >= 3)
          ? _bottomNavIndex - 1
          : _bottomNavIndex; // 0 또는 1
    } else {
      effectiveIndex =
          (_bottomNavIndex >= 3) ? _bottomNavIndex - 2 : _bottomNavIndex; // 0
    }

    // ✅ [검색] 상단 고정 검색바 (홈 화면에서는 숨김)
    final bool isHomeVisible =
        (effectiveIndex == 0) && _currentHomePageContent == null;
    final Widget persistentSearchBar = (_isSearchActive && !isHomeVisible)
        ? Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            color:
                Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'main.search.chipPlaceholder'.tr(), // '이웃, 소식, 장터...'
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    });
                  },
                  tooltip: 'common.cancel'.tr(),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildAppDrawer(_userModel),
      body: Column(
        children: [
          persistentSearchBar,
          Expanded(
            child: IndexedStack(
              index: effectiveIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(icon: Icons.home, index: 0),
            // ✅ '동네' 탭은 항상 표시. 비활성 상태면 흐리게 처리하고 탭 시 안내 팝업 노출
            _buildBottomNavItem(icon: Icons.holiday_village_outlined, index: 1),
            const SizedBox(width: 40),
            _buildBottomNavItem(icon: Icons.search, index: 3),
            _buildBottomNavItem(
                icon: Icons.chat_bubble_outline,
                index: 4,
                badgeCount: _totalUnreadCount),
            _buildBottomNavItem(icon: Icons.person_outline, index: 5),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_main_fab',
        onPressed: _onFloatingActionButtonTapped,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavItem(
      {required IconData icon, required int index, int badgeCount = 0}) {
    String tooltipKey = '';
    if (index == 0) {
      tooltipKey = 'main.bottomNav.home';
    } else if (index == 1) {
      // ✅ 항상 '동네' 탭으로 표시
      tooltipKey = 'main.bottomNav.board';
    } else if (index == 3) {
      tooltipKey = 'main.bottomNav.search';
    } else if (index == 4) {
      tooltipKey = 'main.bottomNav.chat';
    } else if (index == 5) {
      tooltipKey = 'main.bottomNav.myBling';
    }
    final hasBoardTab = _isKelurahanBoardActive && _userModel != null;
    final bool isBoardDisabled = (index == 1 && !hasBoardTab);
    final isSelected = _bottomNavIndex == index && !isBoardDisabled;
    Widget iconWidget = Icon(
      icon,
      color: isBoardDisabled
          ? Colors.grey.shade400
          : (isSelected ? Theme.of(context).primaryColor : Colors.grey),
    );
    iconWidget = badgeCount > 0
        ? Badge(label: Text('$badgeCount'), child: iconWidget)
        : iconWidget;
    return IconButton(
      tooltip: tooltipKey.isNotEmpty ? tooltipKey.tr() : '',
      icon: iconWidget,
      onPressed: () {
        if (isBoardDisabled) {
          _showBoardActivationPopup();
          return;
        }
        // 하단 검색 아이콘도 태그 입력으로 통일
        if (index == 3) {
          _onSearchRequested();
          return;
        }
        _onBottomNavItemTapped(index);
      },
    );
  }

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
                                    trustLevel: userModel.trustLevel,
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

                  // ▼▼▼▼▼ 여기에 아래 코드를 추가하세요 ▼▼▼▼▼
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: const Text('AI 검수 규칙 업로드 (초기화)'),
                    onTap: () async {
                      Navigator.pop(context); // Drawer를 먼저 닫습니다.

                      // Uploader 실행
                      final uploader = AiRuleUploader();
                      await uploader.uploadInitialRules();

                      // 작업 완료 후 사용자에게 피드백 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('AI 검수 규칙 초기 데이터 업로드를 시도했습니다.')),
                        );
                      }
                    },
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

class _LanguageMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final code = context.locale.languageCode; // 'id' | 'ko' | 'en'
    final short = (code == 'id')
        ? 'ID'
        : (code == 'ko')
            ? 'KO'
            : 'EN';

    return PopupMenuButton<Locale>(
      tooltip: 'Change Language',
      onSelected: (loc) {
        // 팝업 닫힘(라우트 pop) 이후 프레임에 로케일 변경
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final el = EasyLocalization.of(context);
          if (el != null) el.setLocale(loc);
        });
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: Locale('id'),
          child: Text('Bahasa Indonesia'),
        ),
        PopupMenuItem(
          value: Locale('ko'),
          child: Text('한국어'),
        ),
        PopupMenuItem(
          value: Locale('en'),
          child: Text('English'),
        ),
      ],
      // 아이콘 + 현재 코드(ID/KO/EN)
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 6),
            Text(
              short,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GrabAppBarShell(title: Text('main.bottomNav.search'.tr())),
      body: Center(child: Text('main.search.placeholder'.tr())),
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

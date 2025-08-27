// 파일 경로: lib/features/main_screen/main_navigation_screen.dart
/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: 메인 네비게이션 구조, AppBar/Drawer/BottomNavigationBar, 위치 필터, 사용자 흐름, 반응형 정책 등
/// - 실제 코드 기능: MainNavigationScreen에서 AppBar, Drawer, BottomNavigationBar, 위치 필터, 사용자 정보, 알림 등 네비게이션 및 메인 화면 관리
/// - 비교: 기획의 네비게이션/레이아웃 구조가 실제 코드에서 State 관리와 위젯 조합으로 구현됨. 반응형/접근성/애니메이션 등은 일부 적용됨
library;

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
import 'package:bling_app/features/local_news/screens/create_local_news_screen.dart';
import 'home_screen.dart';

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

  static const int kSearchTabIndex = 1; // 예: 0=Home, 1=Search, 2=Chat, 3=Profile

 void goToSearchTab() {
  if (!mounted) return;

  // 홈에서 서브뷰를 띄웠다면 정리(프로젝트에 있다면 유지)
  setState(() {
    try {
      _currentHomePageContent = null; // 해당 변수가 있는 경우만
    } catch (_) {}

    _bottomNavIndex = kSearchTabIndex; // IndexedStack 방식
  });

}

  Widget? _currentHomePageContent;
  String _appBarTitle = 'main.myTown'.tr();

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
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _unreadChatsSubscription?.cancel();
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
      }
    });
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
    if (index == 0 && _currentHomePageContent != null) {
      setState(() {
        _currentHomePageContent = null;
        _appBarTitle = 'main.myTown'.tr(); // 홈으로 돌아올 때 접두사 초기화
      });
    }
    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _onFloatingActionButtonTapped() {
    if (_userModel == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateLocalNewsScreen()));
  }

  PreferredSizeWidget _buildAppBar() {
    return GrabAppBarShell(
      // ↓↓↓ 기존 leading 로직 그대로
      leading: (_bottomNavIndex == 0 && _currentHomePageContent != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentHomePageContent = null;
                  _appBarTitle = 'main.myTown'.tr(); // 통합된 변수 사용
                });
              },
            )
          : Builder(
              builder: (context) => IconButton(
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

      // ↓↓↓ 기존 title 로직 그대로 (위치 필터 열기/타이틀 텍스트 구성 등)
      title: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<Map<String, String?>>(
            MaterialPageRoute(
                builder: (_) => LocationFilterScreen(userModel: _userModel)),
          );

          if (result != null && mounted) {
            final processedFilter = <String, String?>{};
            String newTitle = 'main.myTown'.tr(); // 기본값

            if (result['kel'] != null && result['kel']!.isNotEmpty) {
              processedFilter['kel'] = result['kel'];
              newTitle = "Kel.";
            } else if (result['kec'] != null && result['kec']!.isNotEmpty) {
              processedFilter['kec'] = result['kec'];
              newTitle = "Kec.";
            } else if (result['kota'] != null && result['kota']!.isNotEmpty) {
              processedFilter['kota'] = result['kota'];
              newTitle = "Kota";
            } else if (result['kab'] != null && result['kab']!.isNotEmpty) {
              processedFilter['kab'] = result['kab'];
              newTitle = "Kab.";
            } else if (result['prov'] != null && result['prov']!.isNotEmpty) {
              processedFilter['prov'] = result['prov'];
              newTitle = "Prov.";
            }

            setState(() {
              _activeLocationFilter =
                  processedFilter.isNotEmpty ? processedFilter : null;
              _appBarTitle = newTitle; // 통합된 변수 사용
            });
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_appBarTitle,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16)),
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

  // V V V --- [수정] AppBar 부제목 표시 로직을 '대원칙'에 맞게 변경 --- V V V
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
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  void _navigateToPage(Widget page, String titleKey) {
    setState(() {
      _currentHomePageContent = page;
      _appBarTitle = titleKey.tr(); // [수정] 통합된 변수 사용
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _currentHomePageContent ??
          HomeScreen(
            userModel: _userModel,
            activeLocationFilter: _activeLocationFilter,
            onIconTap: (page, titleKey) => _navigateToPage(page, titleKey),
            onSearchChipTap: goToSearchTab, // ✅ 추가
          ),
      const SearchScreen(),
      const ChatListScreen(),
      const MyBlingScreen(),
    ];

    int effectiveIndex =
        _bottomNavIndex > 2 ? _bottomNavIndex - 1 : _bottomNavIndex;

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildAppDrawer(_userModel),
      body: IndexedStack(
        index: effectiveIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(icon: Icons.home, index: 0),
            _buildBottomNavItem(icon: Icons.search, index: 1),
            const SizedBox(width: 40),
            _buildBottomNavItem(
                icon: Icons.chat_bubble_outline,
                index: 3,
                badgeCount: _totalUnreadCount),
            _buildBottomNavItem(icon: Icons.person_outline, index: 4),
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
    final Map<int, String> tooltipKeys = {
      0: 'main.bottomNav.home',
      1: 'main.bottomNav.search',
      3: 'main.bottomNav.chat',
      4: 'main.bottomNav.myBling'
    };
    final isSelected = _bottomNavIndex == index;
    Widget iconWidget = Icon(icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey);
    if (badgeCount > 0) {
      iconWidget = Badge(label: Text('$badgeCount'), child: iconWidget);
    }
    return IconButton(
      tooltip: tooltipKeys[index]?.tr() ?? '',
      icon: iconWidget,
      onPressed: () => _onBottomNavItemTapped(index),
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
      onSelected: (loc) => context.setLocale(loc),
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
      // icon 대신 child를 써서 "아이콘 + 현재 코드"를 함께 보여줍니다.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 6),
            Text(
              short, // ID/KO/EN
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

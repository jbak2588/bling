// lib/features/main_screen/home_screen.dart

import 'dart:async';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/chat/screens/chat_list_screen.dart';
import 'package:bling_app/features/clubs/screens/clubs_screen.dart';
import 'package:bling_app/features/main_feed/screens/main_feed_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friends_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:bling_app/features/local_news/screens/create_local_news_screen.dart';
import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/user_model.dart';
import '../../../core/utils/address_formatter.dart';
import '../auth/screens/profile_edit_screen.dart';
import '../local_news/screens/local_news_screen.dart';
// import '../location/screens/location_setting_screen.dart';
import '../location/screens/location_filter_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';
import '../admin/screens/data_fix_screen.dart';

// 검색 화면을 위한 임시 Placeholder
// git 테스트

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('main.bottomNav.search'.tr())),
      body: Center(child: Text('main.search.placeholder'.tr())),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _bottomNavIndex = 0;

  UserModel? _userModel;
  Map<String, String?>? _activeLocationFilter;
  String _currentAddress = "Loading...";
  bool _isLocationLoading = true;
  StreamSubscription? _userSubscription;
  StreamSubscription? _unreadChatsSubscription;
  int _totalUnreadCount = 0;

  final List<Map<String, dynamic>> _topTabs = [
    {'icon': Icons.new_releases_outlined, 'key': 'main.tabs.newFeed'},
    {'icon': Icons.newspaper_outlined, 'key': 'main.tabs.localNews'},
    {'icon': Icons.storefront_outlined, 'key': 'main.tabs.marketplace'},
    {'icon': Icons.favorite_border_outlined, 'key': 'main.tabs.findFriends'},
    {'icon': Icons.groups_outlined, 'key': 'main.tabs.clubs'},
    {'icon': Icons.work_outline, 'key': 'main.tabs.jobs'},
    {
      'icon': Icons.store_mall_directory_outlined,
      'key': 'main.tabs.localStores'
    },
    {'icon': Icons.gavel_outlined, 'key': 'main.tabs.auction'},
    {'icon': Icons.star_outline, 'key': 'main.tabs.pom'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _topTabs.length, vsync: this);

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
    _tabController.dispose();
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
        .listen((userDoc) {
      if (mounted && userDoc.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(userDoc);
          _currentAddress =
              _userModel!.locationName ?? 'main.appBar.locationNotSet'.tr();
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

    if (index == 0) {
      _tabController.animateTo(0);
    }

    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _onFloatingActionButtonTapped() {
    final currentTabIndex = _tabController.index;
    switch (currentTabIndex) {
      case 0:
      case 1:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateLocalNewsScreen()));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ProductRegistrationScreen()));
        break;
      default:
        debugPrint('\x1B[33m${currentTabIndex + 1}번 탭의 등록 기능이 호출되었습니다.\x1B[0m');
    }
  }

  // ✅ [추가] AppBar 타이틀을 동적으로 생성하는 함수
  String getAppBarTitle() {
    if (_isLocationLoading) {
      return 'main.appBar.locationLoading'.tr();
    }
    if (_activeLocationFilter != null) {
      // 필터 값 중 가장 구체적인 지역 이름만 찾아 반환
      return (_activeLocationFilter!['kel'] ??
              _activeLocationFilter!['kec'] ??
              _activeLocationFilter!['kab'] ??
              _activeLocationFilter!['kota'] ??
              _activeLocationFilter!['prov'] ??
              'Filter Applied')
          .capitalize();
    }
    // 필터가 없으면 기존 주소 반환
    return AddressFormatter.toSingkatan(_currentAddress);
  }

  // SliverAppBar로 변경하여 스크롤 최적화 적용
  SliverAppBar _buildHomeSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: CircleAvatar(
            backgroundImage: (_userModel?.photoUrl != null)
                ? NetworkImage(_userModel!.photoUrl!)
                : null,
            child: (_userModel?.photoUrl == null)
                ? const Icon(Icons.person)
                : null,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      title: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<Map<String, String?>>(
            MaterialPageRoute(
                builder: (_) => LocationFilterScreen(userModel: _userModel)),
          );
          if (result != null && mounted) {
            setState(() => _activeLocationFilter = result);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('main.myTown'.tr(),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                // _isLocationLoading
                //     ? 'main.appBar.locationLoading'.tr()
                //     : AddressFormatter.toSingkatan(_currentAddress),
                getAppBarTitle(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Change Language',
          icon: const Icon(Icons.language),
          onPressed: () {
            final currentLang = context.locale.languageCode;
            context.setLocale(Locale(currentLang == 'id'
                ? 'ko'
                : (currentLang == 'ko' ? 'en' : 'id')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF00A66C),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelColor: const Color(0xFF616161),
        indicatorColor: const Color(0xFF00A66C),
        indicatorWeight: 3.0,
        tabs: _topTabs
            .map((tab) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tab['icon']),
                      const SizedBox(width: 8),
                      Text(tab['key'].toString().tr()),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHomePage() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildHomeSliverAppBar(),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          MainFeedScreen(userModel: _userModel),
          LocalNewsScreen(
              userModel: _userModel, locationFilter: _activeLocationFilter),
          MarketplaceScreen(
              userModel: _userModel, locationFilter: _activeLocationFilter),
          FindFriendsScreen(userModel: _userModel),
          ClubsScreen(userModel: _userModel),
          JobsScreen(userModel: _userModel),
          LocalStoresScreen(userModel: _userModel),
          AuctionScreen(userModel: _userModel),
          PomScreen(userModel: _userModel),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      const SearchScreen(),
      const ChatListScreen(),
      const MyBlingScreen(),
    ];

    int effectiveIndex =
        _bottomNavIndex > 2 ? _bottomNavIndex - 1 : _bottomNavIndex;

    return Scaffold(
      appBar: null,
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
                // ✅ [수정] 오버플로우 방지를 위해 Row와 Expanded 구조로 변경
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
                        // 남은 공간을 모두 차지하도록 설정
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
                            Text(
                              userModel.email,
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 14),
                              overflow: TextOverflow.ellipsis, // 긴 이메일은 ... 처리
                            ),
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
                            builder: (_) => const TrustScoreBreakdownModal()),
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
                  leading: const Icon(Icons.build_circle_outlined,
                      color: Colors.red),
                  title: Text('drawer.runDataFix'.tr(),
                      style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const DataFixScreen()));
                  },
                ),
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

// ✅ [추가] capitalize 유틸리티 함수
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

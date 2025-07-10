
// lib/features/main_screen/home_screen.dart

import 'dart:async';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/chat/screens/chat_list_screen.dart';
import 'package:bling_app/features/clubs/screens/clubs_screen.dart';
import 'package:bling_app/features/feed/screens/feed_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friends_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:bling_app/features/post/screens/create_post_screen.dart';
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
import '../feed/screens/local_feed_screen.dart';
import '../location/screens/location_setting_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';

import '../admin/screens/data_fix_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _bottomNavIndex = 0;

  // ✅ [수정] UserModel과 관련 상태를 관리합니다.
  UserModel? _userModel;
  String _currentAddress = "";
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

    // ✅ [수정] 로그인 상태 변경 시 사용자 데이터 스트림을 설정/해제합니다.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToUserData(user.uid); // 로그인 시 사용자 데이터 스트림 시작
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
    _userSubscription?.cancel(); // ✅ [추가] 스트림 구독 취소
    _unreadChatsSubscription?.cancel();
    super.dispose();
  }

  // ✅ [수정] 사용자 정보를 실시간 스트림으로 구독하는 함수
  void _listenToUserData(String uid) {
    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((userDoc) {
      if (mounted) {
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          setState(() {
            _userModel = userModel;
            _currentAddress =
                userModel.locationName ?? 'main.appBar.locationNotSet'.tr();
            _isLocationLoading = false;
          });
        } else {
          setState(() {
            _userModel = null;
            _currentAddress = 'main.appBar.locationNotSet'.tr();
            _isLocationLoading = false;
          });
        }
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
          _currentAddress = 'main.appBar.locationError'.tr();
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
      int count = 0;
      for (var doc in snapshot.docs) {
        count += (doc.data()['unreadCounts']?[myUid] ?? 0) as int;
      }
      if (mounted) {
        setState(() {
          _totalUnreadCount = count;
        });
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
      setState(() {
        _bottomNavIndex = 0;
      });
      return;
    }

    setState(() {
      _bottomNavIndex = index;
    });

    if (index == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ChatListScreen()));
    } else if (index == 4) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const MyBlingScreen()));
    }
  }

  void _onFloatingActionButtonTapped() {
    final currentTabIndex = _tabController.index;
    switch (currentTabIndex) {
      case 0:
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ProductRegistrationScreen()));
        break;
      default:
        debugPrint('\x1B[33m${currentTabIndex + 1}번 탭의 등록 기능이 호출되었습니다.\x1B[0m');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ [수정] 각 탭 화면에 상태(_userModel)를 전달합니다.
    final List<Widget> topTabScreens = [
      FeedScreen(userModel: _userModel),
      LocalFeedScreen(userModel: _userModel),
      MarketplaceScreen(userModel: _userModel),
      FindFriendsScreen(userModel: _userModel),
      ClubsScreen(userModel: _userModel),
      JobsScreen(userModel: _userModel),
      LocalStoresScreen(userModel: _userModel),
      AuctionScreen(userModel: _userModel),
      PomScreen(userModel: _userModel),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: (_userModel?.photoUrl != null)
                    ? NetworkImage(_userModel!.photoUrl!)
                    : null,
                child: (_userModel?.photoUrl == null)
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Town',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            _buildAppBarTitle(),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Change Language',
            icon: const Icon(Icons.language),
            onPressed: () {
              final currentLang = context.locale.languageCode;
              if (currentLang == 'id') {
                context.setLocale(const Locale('ko'));
              } else if (currentLang == 'ko') {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('id'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {/* 알림 화면으로 이동 */},
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
          tabs: _topTabs.map((tab) {
            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tab['icon']),
                  const SizedBox(width: 8),
                  Text(tab['key'].toString().tr()),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      drawer: _buildAppDrawer(_userModel), // ✅ [수정] Drawer에도 _userModel 전달
      body: TabBarView(
        controller: _tabController,
        children: topTabScreens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(
                icon: Icons.home, index: 0, labelKey: 'main.bottomNav.home'),
            _buildBottomNavItem(
                icon: Icons.search,
                index: 1,
                labelKey: 'main.bottomNav.search'),
            const SizedBox(width: 40),
            _buildBottomNavItem(
                icon: Icons.chat_bubble_outline,
                index: 3,
                labelKey: 'main.bottomNav.chat',
                badgeCount: _totalUnreadCount),
            _buildBottomNavItem(
                icon: Icons.person_outline,
                index: 4,
                labelKey: 'main.bottomNav.myBling'),
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

  Widget _buildAppBarTitle() {
    return InkWell(

      onTap: () async {
        // 위치 설정 화면으로 이동. 돌아오면 StreamBuilder가 자동으로 UI를 갱신합니다.
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LocationSettingScreen()),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              _isLocationLoading
                  ? 'main.appBar.locationLoading'.tr()
                  : AddressFormatter.toSingkatan(_currentAddress),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
      {required IconData icon,
      required int index,
      required String labelKey,
      int badgeCount = 0}) {
    final isSelected = _bottomNavIndex == index;
    Widget iconWidget = Icon(icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey);

    if (badgeCount > 0) {
      iconWidget = Badge(label: Text('$badgeCount'), child: iconWidget);
    }

    return IconButton(
      tooltip: labelKey.tr(),
      icon: iconWidget,
      onPressed: () => _onBottomNavItemTapped(index),
    );
  }

  // ✅ [수정 없음] 기존 Drawer 코드를 그대로 사용합니다.
  Widget _buildAppDrawer(UserModel? userModel) {
    return Drawer(
      child: userModel == null
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 또는 로그아웃
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF6A1B9A)),
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            userModel.nickname,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          TrustLevelBadge(
                              trustLevel: userModel.trustLevel, showText: true),
                          const SizedBox(width: 6),
                          Text(
                            '(${userModel.trustScore})',
                            style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userModel.email,
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
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
                        child: Text(
                          'drawer.trustDashboard.title'.tr(),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const TrustScoreBreakdownModal(),
                          );
                        },
                        child: Text(
                          'drawer.trustDashboard.breakdownButton'.tr(),
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrustInfoTile(
                  icon: Icons.location_city,
                  titleKey: 'drawer.trustDashboard.kelurahanAuth',
                  isCompleted: userModel.locationParts?['kel'] != null,
                ),
                _buildTrustInfoTile(
                  icon: Icons.home_work_outlined,
                  titleKey: 'drawer.trustDashboard.rtRwAuth',
                  isCompleted: userModel.locationParts?['rt'] != null,
                ),
                _buildTrustInfoTile(
                  icon: Icons.phone_android,
                  titleKey: 'drawer.trustDashboard.phoneAuth',
                  isCompleted: userModel.phoneNumber != null &&
                      userModel.phoneNumber!.isNotEmpty,
                ),
                _buildTrustInfoTile(
                  icon: Icons.verified_user,
                  titleKey: 'drawer.trustDashboard.profileComplete',
                  isCompleted: userModel.profileCompleted == true,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('drawer.editProfile'.tr()),
                  onTap: () {
                    Navigator.of(context).pop(); // Drawer 닫기
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfileEditScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.build_circle_outlined,
                      color: Colors.red),
                  title: const Text('데이터 보정 실행',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context); // Drawer 닫기
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DataFixScreen()),
                    );
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

  Widget _buildTrustInfoTile({
    required IconData icon,
    required String titleKey,
    required bool isCompleted,
  }) {
    return ListTile(
      leading: Icon(icon, color: isCompleted ? Colors.teal : Colors.grey),
      title: Text(titleKey.tr(), style: GoogleFonts.inter(fontSize: 15)),
      trailing: Icon(
        isCompleted ? Icons.check_circle : Icons.cancel,
        color: isCompleted ? Colors.green : Colors.grey,
        size: 22,
      ),
    );
  }
}

// --- TrustScoreBreakdownModal Widget ---
class TrustScoreBreakdownModal extends StatelessWidget {
  const TrustScoreBreakdownModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('drawer.trustDashboard.breakdownModalTitle'.tr(),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        // 내용이 길어질 수 있으므로 스크롤 추가
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


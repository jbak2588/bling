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
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/user_model.dart';
import '../../../core/utils/address_formatter.dart';
// import '../admin/screens/data_uploader_screen.dart';
// import '../auth/screens/profile_edit_screen.dart';
import '../feed/screens/local_feed_screen.dart';
import '../location/screens/location_setting_screen.dart';
import '../marketplace/screens/marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _bottomNavIndex = 0;
  String _currentAddress = "";
  bool _isLocationLoading = true;
  StreamSubscription? _unreadChatsSubscription;
  int _totalUnreadCount = 0;

  // 상단 탭 메뉴 정의 (클래스 멤버로 유지)
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
    _fetchUserData();
    // _listenToUnreadChats();
   // ▼▼▼▼▼ 로그인 상태가 변경될 때마다 채팅 리스너를 재설정 ▼▼▼▼▼
   FirebaseAuth.instance.authStateChanges().listen((User? user) {
     if (user != null) {
       _listenToUnreadChats(user.uid);
     } else {
       _unreadChatsSubscription?.cancel();
       if(mounted) setState(() => _totalUnreadCount = 0);
     }
   });

  }

  @override
  void dispose() {
    _tabController.dispose();
    _unreadChatsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLocationLoading = false);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _currentAddress = userDoc.data()?['locationName'] ??
              'main.appBar.locationNotSet'.tr();
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'main.appBar.locationError'.tr();
          _isLocationLoading = false;
        });
      }
    }
  }

  // void _listenToUnreadChats() {  
  //   final myUid = FirebaseAuth.instance.currentUser?.uid;
  //   if (myUid == null) return;

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
  
    // Home(0) 탭을 누르면 항상 첫 탭으로 이동
    if (index == 0) {
      // TabBarView 첫 번째 탭으로 이동
      _tabController.animateTo(0);
      // 필요하다면 아래처럼 네비게이터 스택도 정리
      // Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() {
        _bottomNavIndex = 0;
      });
      return;
    }

    setState(() {
      _bottomNavIndex = index;
    });

    if (index == 1) {/* 검색 화면 로직 */}
    else if (index == 3) {
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
      case 0: // New Feed
      case 1: // Local Stories
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        );
        break;
      case 2: // Marketplace
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProductRegistrationScreen()),
        );
        break;
      default:
        // 기타 탭에서는 등록 기능이 없거나, 필요시 추가 구현
        debugPrint('\x1B[33m${currentTabIndex + 1}번 탭의 등록 기능이 호출되었습니다.\x1B[0m');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ▼▼▼▼▼ 화면 리스트를 build 메소드 안에서 지역 변수로 생성 ▼▼▼▼▼
    final List<Widget> topTabScreens = [
      const FeedScreen(),
      const LocalFeedScreen(),
      MarketplaceScreen(currentAddress: _currentAddress),
      const FindFriendsScreen(),
      const ClubsScreen(),
      const JobsScreen(),
      const LocalStoresScreen(),
      const AuctionScreen(),
      const PomScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: user != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (user == null ||
                      !snapshot.hasData ||
                      snapshot.data?.data() == null) {
                    return const CircleAvatar(child: Icon(Icons.person));
                  }
                  final userModel = UserModel.fromFirestore(
                      snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
                  return CircleAvatar(
                    backgroundImage: userModel.photoUrl != null
                        ? NetworkImage(userModel.photoUrl!)
                        : null,
                    child: userModel.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  );
                },
              ),
            ),
          ),
        ),
        title: _buildAppBarTitle(),
        centerTitle: true,
        actions: [
                   // ▼▼▼▼▼ 언어 변경 아이콘 추가 ▼▼▼▼▼
         IconButton(
           tooltip: 'Change Language', // 추후 다국어 키 추가 필요
           icon: const Icon(Icons.language),
           onPressed: () {
             // 현재 로케일 확인 후 순서대로 변경
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
          // 선택된 탭 스타일
          labelColor: const Color(0xFF00A66C), // Primary 컬러
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600), // Semi-Bold
          // 선택되지 않은 탭 스타일
          unselectedLabelColor: const Color(0xFF616161), // TextSecondary 컬러
          // 하단 인디케이터 스타일
          indicatorColor: const Color(0xFF00A66C),
          indicatorWeight: 3.0,
          tabs: _topTabs.map((tab) {
            // ▼▼▼▼▼ 아이콘과 텍스트를 함께 표시하는 구조로 변경 ▼▼▼▼▼
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
      drawer: _buildAppDrawer(user),
      body: TabBarView(
        controller: _tabController,
        children: topTabScreens, // build 메소드 내에서 생성된 리스트 사용
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
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LocationSettingScreen()),
        );
        _fetchUserData();
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
      iconWidget = Badge(
        label: Text('$badgeCount'),
        child: iconWidget,
      );
    }

    return IconButton(
      tooltip: labelKey.tr(),
      icon: iconWidget,
      onPressed: () => _onBottomNavItemTapped(index),
    );
  }

  Widget _buildAppDrawer(User? user) {
    // if (user == null) return const Drawer();
    // return Drawer(
    //   child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    //     stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //       final userModel = UserModel.fromFirestore(snapshot.data!);

    return Drawer(
     child: ListView(
       padding: EdgeInsets.zero,
       children: [
         // user가 null이면 UserAccountsDrawerHeader를 그리지 않습니다.
         if (user != null)
           StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
             stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
             builder: (context, snapshot) {
               if (!snapshot.hasData || snapshot.data?.data() == null) {
                 return UserAccountsDrawerHeader(accountName: Text("..."), accountEmail: Text("..."));
               }
               final userModel = UserModel.fromFirestore(snapshot.data!);
               return UserAccountsDrawerHeader(
                 accountName: Text(userModel.nickname, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                 accountEmail: Text(userModel.email, style: GoogleFonts.inter()),
                 currentAccountPicture: CircleAvatar(
                   backgroundImage: (userModel.photoUrl != null && userModel.photoUrl!.startsWith('http')) ? NetworkImage(userModel.photoUrl!) : null,
                   child: (userModel.photoUrl == null || !userModel.photoUrl!.startsWith('http')) ? const Icon(Icons.person, size: 40) : null,
                 ),
               );
             },
           ),
         ListTile(leading: const Icon(Icons.edit_outlined), title: Text('drawer.editProfile'.tr()), onTap: () { /* ... */ }),
         ListTile(leading: const Icon(Icons.bookmark_border), title: Text('drawer.bookmarks'.tr()), onTap: () => Navigator.pop(context)),
         const Divider(),
         ListTile(
           leading: const Icon(Icons.cloud_upload_outlined),
           title: Text('drawer.uploadSampleData'.tr()),
           onTap: () { /* ... */ },
         ),
         const Divider(),
         ListTile(
           leading: const Icon(Icons.logout),
           title: Text('drawer.logout'.tr()),
           onTap: () async {
             // 로그아웃 전에 모든 리스너가 정리될 시간을 주기 위해 pop을 먼저 호출할 수 있습니다.
             if(mounted) Navigator.pop(context); 
             await FirebaseAuth.instance.signOut();
           },
         ),
       ],
     ),
   );
 }
}

// 파일 경로: lib/features/main_screen/main_navigation_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// [유지] 모든 필요한 import 구문을 유지합니다.
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/auth/screens/profile_edit_screen.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';

import 'package:bling_app/features/chat/screens/chat_list_screen.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'package:bling_app/features/local_news/screens/create_local_news_screen.dart';
import 'home_screen.dart'; // [신규] '가구' 역할을 할 HomeScreen import


// [수정] MainNavigationScreen은 더 이상 child를 받지 않습니다.
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

   Widget? _currentHomePageContent;

  @override
  void initState() {
  super.initState();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      // 사용자가 로그인 상태일 때: 사용자 데이터를 불러옵니다.
      _listenToUserData(user.uid);
      _listenToUnreadChats(user.uid);
    } else {
      // 사용자가 로그아웃 상태일 때: 모든 사용자 관련 상태를 초기화합니다.
      _userSubscription?.cancel();
      _unreadChatsSubscription?.cancel();
      if (mounted) {
        setState(() {
          _userModel = null; // [수정] userModel을 null로 설정
          _currentAddress = 'main.appBar.locationNotSet'.tr();
          _isLocationLoading = false;
          // _totalUnreadCount = 0; // 필요하다면 이 부분도 초기화
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
    _userSubscription = FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((doc) {
      if (mounted && doc.exists) {
        setState(() {
          _userModel = UserModel.fromFirestore(doc);
          _currentAddress = _userModel!.locationName ?? 'main.appBar.locationNotSet'.tr();
          _isLocationLoading = false;
        });
      }
    });
  }

  void _listenToUnreadChats(String myUid) {
    _unreadChatsSubscription?.cancel();
    final stream = FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: myUid).snapshots();
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
    // [수정] 홈 탭(index 0)으로 돌아올 때, 아이콘 그리드 화면으로 돌아가도록 _currentHomePageContent를 null로 설정
    if (index == 0 && _currentHomePageContent != null) {
      setState(() {
        _currentHomePageContent = null;
      });
    }
    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _onFloatingActionButtonTapped() {
    if (_userModel == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateLocalNewsScreen()));
  }

 AppBar _buildAppBar() {
    return AppBar(
      // [신규] 뒤로가기 버튼 로직 추가: 홈 탭에서 다른 화면을 보고 있을 때만 뒤로가기 버튼 표시
      leading: (_bottomNavIndex == 0 && _currentHomePageContent != null)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentHomePageContent = null; // 아이콘 그리드 화면으로 복귀
                });
              },
            )
          : Builder(
              builder: (context) => IconButton(
                icon: CircleAvatar(
                  backgroundImage: (_userModel?.photoUrl != null && _userModel!.photoUrl!.isNotEmpty) ? NetworkImage(_userModel!.photoUrl!) : null,
                  child: (_userModel?.photoUrl == null || _userModel!.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
      title: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<Map<String, String?>>(
            MaterialPageRoute(builder: (_) => LocationFilterScreen(userModel: _userModel)),
          );
          if (result != null && mounted) {
            setState(() => _activeLocationFilter = result);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('main.myTown'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _getAppBarTitle(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            context.setLocale(Locale(currentLang == 'id' ? 'ko' : (currentLang == 'ko' ? 'en' : 'id')));
          },
        ),
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
      ],
    );
  }

  String _getAppBarTitle() {
    if (_isLocationLoading) {
      return 'main.appBar.locationLoading'.tr();
    }
    if (_activeLocationFilter != null) {
      return StringExtension((_activeLocationFilter!['kel'] ?? _activeLocationFilter!['kec'] ?? _activeLocationFilter!['kab'] ?? _activeLocationFilter!['kota'] ?? _activeLocationFilter!['prov'] ?? 'Filter Applied')).capitalize();
    }
    return AddressFormatter.toSingkatan(_currentAddress);
  }

   void _navigateToPage(Widget page) {
    setState(() {
      _currentHomePageContent = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    // [신규] 하단 네비게이션바가 관리할 '방(pages)' 목록을 정의합니다.
    final List<Widget> pages = [
      // 0번 방: _currentHomePageContent가 있으면 해당 화면을, 없으면 HomeScreen(아이콘 그리드)을 보여줍니다.
      _currentHomePageContent ?? HomeScreen(
        userModel: _userModel, 
        activeLocationFilter: _activeLocationFilter, 
        onIconTap: _navigateToPage, // [신규] '방'을 바꿔달라는 요청 함수를 '가구'에게 전달
      ),
      const SearchScreen(),
      const ChatListScreen(),
      const MyBlingScreen(),
    ];
    // BottomAppBar의 실제 버튼 인덱스(0,1,3,4)를 pages 리스트의 인덱스(0,1,2,3)로 변환합니다.
    int effectiveIndex = _bottomNavIndex > 2 ? _bottomNavIndex - 1 : _bottomNavIndex;

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildAppDrawer(_userModel),
      // [수정] body를 IndexedStack으로 변경하여, _bottomNavIndex에 따라 '방'을 교체하도록 합니다.
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
            _buildBottomNavItem(icon: Icons.chat_bubble_outline, index: 3, badgeCount: _totalUnreadCount),
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

  Widget _buildBottomNavItem({required IconData icon, required int index, int badgeCount = 0}) {
    final Map<int, String> tooltipKeys = {0: 'main.bottomNav.home', 1: 'main.bottomNav.search', 3: 'main.bottomNav.chat', 4: 'main.bottomNav.myBling'};
    final isSelected = _bottomNavIndex == index;
    Widget iconWidget = Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey);
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: (userModel.photoUrl != null && userModel.photoUrl!.startsWith('http')) ? NetworkImage(userModel.photoUrl!) : null,
                        child: (userModel.photoUrl == null || !userModel.photoUrl!.startsWith('http')) ? const Icon(Icons.person, size: 30) : null,
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
                                Text(userModel.nickname, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
                                TrustLevelBadge(trustLevel: userModel.trustLevel, showText: true),
                                Text('(${userModel.trustScore})', style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(userModel.email, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.military_tech, color: Colors.brown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('drawer.trustDashboard.title'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => showDialog(context: context, builder: (_) => TrustScoreBreakdownModal(key: UniqueKey())),
                        child: Text('drawer.trustDashboard.breakdownButton'.tr(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                _buildTrustInfoTile(icon: Icons.location_city, titleKey: 'drawer.trustDashboard.kelurahanAuth', isCompleted: userModel.locationParts?['kel'] != null),
                _buildTrustInfoTile(icon: Icons.home_work_outlined, titleKey: 'drawer.trustDashboard.rtRwAuth', isCompleted: userModel.locationParts?['rt'] != null),
                _buildTrustInfoTile(icon: Icons.phone_android, titleKey: 'drawer.trustDashboard.phoneAuth', isCompleted: userModel.phoneNumber != null && userModel.phoneNumber!.isNotEmpty),
                _buildTrustInfoTile(icon: Icons.verified_user, titleKey: 'drawer.trustDashboard.profileComplete', isCompleted: userModel.profileCompleted),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('drawer.editProfile'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                  },
                ),
                const Divider(),
                // if (userModel.role == 'admin')
                //   ListTile(
                //     leading: const Icon(Icons.build_circle_outlined, color: Colors.red),
                //     title: Text('drawer.runDataFix'.tr(), style: const TextStyle(color: Colors.red)),
                //     onTap: () {
                //       Navigator.pop(context);
                //       Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DataFixScreen()));
                //     },
                //   ),
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

    Widget _buildTrustInfoTile({required IconData icon, required String titleKey, required bool isCompleted}) {
    return ListTile(
      leading: Icon(icon, color: isCompleted ? Colors.teal : Colors.grey),
      title: Text(titleKey.tr(), style: GoogleFonts.inter(fontSize: 15)),
      trailing: Icon(isCompleted ? Icons.check_circle : Icons.cancel, color: isCompleted ? Colors.green : Colors.grey, size: 22),
    );
  }
}

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
      title: Text('drawer.trustDashboard.breakdownModalTitle'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _breakdownRow('drawer.trustDashboard.kelurahanAuth', 'drawer.trustDashboard.breakdown.kelurahanAuth'),
            _breakdownRow('drawer.trustDashboard.rtRwAuth', 'drawer.trustDashboard.breakdown.rtRwAuth'),
            _breakdownRow('drawer.trustDashboard.phoneAuth', 'drawer.trustDashboard.breakdown.phoneAuth'),
            _breakdownRow('drawer.trustDashboard.profileComplete', 'drawer.trustDashboard.breakdown.profileComplete'),
            const Divider(),
            _breakdownRow('drawer.trustDashboard.feedThanks', 'drawer.trustDashboard.breakdown.feedThanks'),
            _breakdownRow('drawer.trustDashboard.marketThanks', 'drawer.trustDashboard.breakdown.marketThanks'),
            _breakdownRow('drawer.trustDashboard.reports', 'drawer.trustDashboard.breakdown.reports'),
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
          Text(valueKey.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
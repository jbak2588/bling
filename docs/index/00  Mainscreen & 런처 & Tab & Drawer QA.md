# 1_14. UIUX_Guide 1

---

## ✅ UI/UX Guide 개요

Bling은 Keluharan(Kel.) 기반 지역 슈퍼앱으로,  
지역 기반의 뉴스 피드 구조와 Gojek 런처 UX를  
하나로 통합해 **일관된 사용자 흐름과 직관적 인터페이스**를 목표로 합니다.

---

## ✅ 메인 레이아웃 구성

- **상단 AppBar**
    
    - 좌측: 사용자 프로필 아이콘 (Drawer 열기)
        
    - 중앙: "My Town" ( GEO 드롭다운 : Kabupaten(Kab.) → Kecamatan(Kec.) → Keluharan(Kel.) → 옵션 : RT/RW 리트스 정렬)
        
    - 우측: 언어 변경 아이콘 (기본 id.json, en.json, ko.json...)
        
- **상단 슬라이드 탭**
    
    - Main Feed | Local News | Marketplace | Find Friend | Club | Jobs | Local Shops | Auction | POM | Find & Lost | Find a room(sewa kamar) |
        
- **메인 Feed**
    
    - 최신 글 + 인기 글 우선 노출
        
- **왼쪽 Drawer**
    
    - Profile, Chat, Bookmark, Community, Jobs, Settings, Logout
        
- **하단 BottomNavigationBar**
    
    - Home | Search | (+) 글쓰기 | Chat | Notifications | My Page
        

---

## ✅ 주요 컴포넌트 규칙

- **FeedCard**: 제목, 이미지, 카테고리 Badge
    
- **Comment Bubble**: 닉네임 + TrustLevel 뱃지
    
- **Chat Bubble**: 좌/우 정렬
    
- **FloatingActionButton**: (+) 글쓰기 전용 강조
    

---

## ✅ 반응형 & 접근성

- Mobile: 1 Column
    
- Tablet: 2 Column
    
- 최소 터치 영역: 48dp 이상
    
- 명도 대비: WCAG AA 이상 준수
    

---

## ✅ 마이크로 인터랙션

- 좋아요: Heart Beat Animation
    
- 댓글 입력: Smooth Slide Up
    
- Chat 알림: Badge + Vibration
    

---

## ✅ 사용자 흐름 시나리오

1️⃣ 신규 유저 → Keluharan 인증 → 기본 프로필 작성  
2️⃣ Local Feed 진입 → 관심사 선택 → Find Friend 추천  
3️⃣ 관심사 기반 이웃 연결 → 채팅 → Club 참여 → Marketplace 확장

---

## ✅ Flutter 적용 가이드

- AppBar, Drawer: `Scaffold.drawer` + `AppBar.leading`
    
- 슬라이드 탭: `TabBar` + `TabBarView`
    
- Feed: `ListView` + `StreamBuilder`
    
- BottomNav: `BottomNavigationBar` + `FloatingActionButton`
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[1_01. Design_Guide]]
    

---

## ✅ 결론

Bling UI/UX Guide는  
Keluharan 기반 사용자 흐름**, **슬라이드 런처 UX**,  
**신뢰도 기반 개인화**를 하나로 묶어  
인도네시아 로컬 슈퍼앱의 UX 표준을 만듭니다.


# 2_04. Bling_MainScreen_Structure


---

## ✅ 핵심 목표

Bling 메인화면은 Nextdoor의 Keluhara(Kel.) 기반 커뮤니티 구조,  
Gojek 런처 스타일, X(Twitter) 프로필/드로어 흐름을 하나로 합친  
**인도네시아형 슈퍼앱 홈 설계안**입니다.

---

## ✅ 1️⃣ AppBar 구조

- **왼쪽:** 사용자 프로필 이미지 (`CircleAvatar`) → 클릭 시 왼쪽 Drawer 열림
    
- **중앙:** `My Town (Karawaci ▼)` → GEO 드롭다운 (Kabupaten → Kecamatan → Kelurahan → RT/RW )
    - 첫 화면 위치 기준은  항상 사용자 위치 기준 Kabupaten 임. (검색 지역을 확장하려는 경우 Province → Kabupaten → Kecamatan → Kelurahan → RT/RW)
    - 
    - 줄임말 표기: Kelurahan → Kel., Kecamatan → Kec., Kabupaten → Kab., Province → Prov.
        
- **오른쪽:** 언어 변경 아이콘 (지구본)
    

---

## ✅ 2️⃣ 상단 슬라이드 탭

`Main Feed`|`Local Story` | `Marketplace` | `Find Friend` | `Club` | `Jobs` | `Local Shops` | `Auction` | `POM`

---

## ✅ 3️⃣ 메인 Feed 구성

- 동네 이야기 (최신 5)
    
- 신상품/중고상품 (최신 5)
    
- 친구찾기 (최신 5)
    
- 동호회/클럽 (최신 5)
    
- 일자리 (최신 5)
    
- 경매 (최신 5)
    
- POM 쇼츠 (최신 5)  및 나머지 Feed들


---

## ✅ 4️⃣ 왼쪽 Drawer 메뉴

- 상단: 프로필 이미지, 닉네임, 이웃 수, TrustLevel 뱃지
    
- 메뉴:
    
    - Profile
        
    - Chat
        
    - Community
        
    - Bookmark(wishList)
        
    - 내가 등록한 게시물 모아 보기(My page로 연결)
        
    - 이웃 요청
        
    - 친구 요청


- 맨 아래:
    
    - 고객센터
        
    - 개인정보보호
        
    - 로그아웃







---

## ✅ 5️⃣ 하단 BottomNavigationBar

- Home
    
- Search
    
- (+) 글쓰기 (Local Feed 작성) + 각 상단 탭 INDEX OR KEY 밸류로 각 CREATE() 호출
    
- Chat / Messages / Inbox
    
- Notifications
    
- My Page (친구찾기 페이지 설정 / 프로필 / 내가 쓴 글 페이지)
    

---

## ✅ 기술 가이드 (Flutter)

- Drawer: `Scaffold.drawer`
    
- AppBar: `leading`, `title`, `actions`
    
- 슬라이드 탭: `TabBar` + `TabBarView`
    
- Feed: `ListView` + Firestore `StreamBuilder`
    
- GEO 드롭다운: `PopupMenuButton` 또는 `ModalBottomSheet`
    
- 하단바: `BottomNavigationBar` + `FloatingActionButton`
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[6_03. Bling_Local_Feed_Policy & To-Do 목록]]
    
- [[7_04. Bling_Marketplace_Policy]]
    
- [[2_02. Project_FolderTree]]

- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
- 
    

---

## ✅ 결론

Bling 메인화면은 ** Keluhara(Kel.)  기반 신뢰 구조**, **런처 UX**, **개인 프로필**까지  
하나의 홈 화면에서 유기적으로 연결하여,  
인도네시아 지역 슈퍼앱의 **중심 허브** 역할을 합니다.

##  주소 화면 표시 원칙 : Kel. Kec. 까지만




# 2_05. home_screen.dart

```dart
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

```


# 2_11. Bling_프로젝트_연계_종합점검

---

## ✅ 프로젝트 통합 점검 개요

Bling은 Keluhara(Kel.)  기반 신뢰 구조, Nextdoor 스타일 커뮤니티,  
Gojek 런처 UX, 다국어 시스템, AI 검수까지 모두 하나로 연결하는  
**하이브리드 지역 슈퍼앱**입니다.  
이를 위해 모듈별 구현 상태와 연계 흐름을 통합 점검합니다.

---

## ✅ 핵심 연계 항목

|항목| 설명                             |
| ----------- | ----------------------------- |
|Local Fee  Keluhara(Kel.) 피드, 댓글/대댓글 연계 연계 |
|Marketplace| 상품 등록, 카테고리, Wishl             |
|Find Friend| Matching, Fol                  |
|Club| 그룹 생성,                         |
|Jobs| 구인 등록,                         |
|Local Shops| 상점 프로필, 리뷰, Marketp    연계      |
|Auction| 경매 등록, 입                       |
|POM| 쇼츠 업로드,                        |

---

## ✅ 사용자(User) 필드 표준 연계

- 모든 모듈은 `users/{uid}` 컬렉션과 연결되어야 함
    
- TrustLevel &  Keluhara(Kel.)   위치 필수
    
- 활동 히스토리: `posts`, `comments`, `wishlist`, `clubs`, `jobs`, `shops`, `auctions`, `shorts`
    

---

## ✅ Firestore 핵심 컬렉션

|컬렉션|설명|
|---|---|
|`posts`|Local Feed|
|`products`|Marketplace|
|`shorts`|POM 쇼츠|
|`auctions`|Auction 경매|
|`jobs`|구인구직|
|`shops`|Local Shops|
|`clubs`|Club 소모임|
|`chats`|공통 채팅|
|`notifications`|알림|
|`users`|사용자 프로필|

---

## ✅ TrustLevel & 인증

-  Keluhara(Kel.)  인증 필수 → 모든 모듈에 적용
    
- TrustLevel 조건 → 권한 제한 (Auction, Club, POM)
    

---

## ✅ 다국어(i18n)

- `en.json`, `id.json` → ISO 639-1 표준
    
- `feature.component.property` 키명 규칙
    
- 모든 UI 문구는 Obsidian 기준으로 정리 → `localization/i18n/` 폴더 관리
    

---

## ✅ DevOps 연계

- GitHub Repo → `.md` 정책, 데이터 모델, 버전 관리
    
- GPT → 구조 설계 가이드
    
- Copilot → Dart 코드 자동완성
    
- Gemini → 코드 Diff 검증
    
- Obsidian → 핵심 문서 Vault 연동
    

---

## ✅ TODO 점검

-  User 컬렉션 필드 표준화 (`trustLevel`, `location`)
    
-  모듈별 Firestore 구조 스키마 통일
    
-  AI 검수 로직 연계
    
-  Wishlist 연계 → `users/{uid}/wishlist`
    
-   Keluharan(Kel.)  DropDown → GEO 연동
    
-  다국어 JSON Key 최신화
    
-  AppBar, Drawer, BottomNav 통일
    
-  DevOps → CI/CD 흐름 반영
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[6_03. Bling_Local_Feed_Policy & To-Do 목록]]
    
- [[7_04. Bling_Marketplace_Policy]]
    
- [[8_05_0. Find_Friend_Policy & To-Do 목록]]
    
- [[8_06_0. Bling_Club_Policy & To-Do 목록]]
    
- [[8_07_0. Bling_Jobs_Policy & To-Do 목록]]
    
- [[8_08_0. Bling_LocalShops_Policy & To-Do 목록]]
    
- [[8_09_0. Bling_Auction_Policy & To-Do 목록]]
    
- [[8_10. Bling_POM_Policy & To-Do 목록]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---

## ✅ 결론

Bling은 모든 모듈을  Keluhara(Kel.)  기반 TrustLevel과  
Firestore 통합 컬렉션으로 연결해  
**단일 신뢰 구조 + 다국어 + AI 검수 + 슈퍼앱 런처 UX**를 실현합니다.


# 2_19. Repo_README 1

---

## ✅ Bling Repo 개요

이 저장소는 **Bling 슈퍼앱 프로젝트**의 모든 코드, 설계, 정책 문서를 관리하는  
 Keluharan(Kel.)  기반 Nextdoor + Gojek 하이브리드 로컬 슈퍼앱**의 메인 Repo입니다.

---

## ✅ 핵심 컨셉

- Kelurahan(Kec.)  기반 TrustLevel 시스템
    
- Local Feed, Marketplace, Find Friend, Club, Jobs 등 지역 모듈
    
- AI 검수, 다국어(Localization) 통합
    
- Gojek 스타일 런처 UX → 상단 슬라이드 탭 구성
      
- 모든 주소 표기는 인도네시아 공공 행정 표준 Singkatan(약어)을 사용합니다.
    
- Kecamatan → Kec.
    
- Kelurahan → Kel.
    
- Kabupaten → Kab.
    
- Provinsi → Prov.

---

## ✅ 폴더 구조 요약

```plaintext
lib
├── core
│   ├── constants/
│   ├── models/
├── features/
│   ├── feed/
│   ├── marketplace/
│   ├── find_friends/
│   ├── clubs/
│   ├── jobs/
│   ├── pom/
│   ├── auction/
│   ├── chat/
│   ├── auth/
│   ├── community/
│   ├── location/
│   ├── main_screen/
│   ├── my_bling/
│   ├── admin/
│   ├── categories/
│   ├── shared/
assets/
├── icons/
├── lang/
├── sounds/
```


---

## ✅ Firestore 핵심 컬렉션

|컬렉션|설명|
|---|---|
|`posts`|Local Feed|
|`products`|Marketplace|
|`shorts`|POM (쇼츠)|
|`auctions`|Auction 경매|
|`jobs`|구인구직|
|`shops`|Local Shops|
|`clubs`|Club 모임|
|`users`|사용자 정보|
|`chats`|공통 채팅|
|`notifications`|알림|

---

## ✅ 주요 정책 문서

-     
- 📄 Bling_Project_FolderTree.md
     
- 📄[[1_99. 📌 Bling 인도네시아 주소 표기 & DropDown 정책]].md
-



---

## ✅ DevOps & AI 협업 흐름

|도구|역할|
|---|---|
|**GitHub**|정책/코드 버전 관리|
|**Obsidian**|`.md` 정책 문서 관리|
|**GPT**|설계/정책 구조화|
|**Copilot**|Flutter/Dart 코드 자동화|
|**Gemini**|코드 Diff & 대안 검증|

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_02. Project_FolderTree]]
    
- [[4_21. User_Field_Standard]]
    

---

## ✅ 결론

**Bling-Repo**는  Keluharan(Kel.)  기반 지역 커뮤니티 신뢰 구조와  
슈퍼앱 런처 UX, 다국어, AI 검수를 하나로 통합한  
**인도네시아형 로컬 슈퍼앱 프로젝트**의 표준 저장소입니다.

---

### ✅ 구성 핵심

- Repo 목적 + 폴더 구조 + Firestore 컬렉션 표준
    
- 핵심 `.md` 정책 연결 목록
    
- GPT + Copilot + Gemini 연계 DevOps 흐름까지 포함
    

---





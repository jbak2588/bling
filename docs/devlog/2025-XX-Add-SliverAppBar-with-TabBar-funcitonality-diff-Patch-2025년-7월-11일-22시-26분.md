diff --git a/lib/features/main_screen/home_screen.dart b/lib/features/main_screen/home_screen.dart
index 4d823f9096f0d2689b840ae364630670be161307..f238c0929ce8a62bc4c030fb5035fb19f99c9ed6 100644
--- a/lib/features/main_screen/home_screen.dart
+++ b/lib/features/main_screen/home_screen.dart
@@ -149,52 +149,56 @@ class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
         Navigator.of(context)
             .push(MaterialPageRoute(builder: (_) => const CreateLocalNewsScreen()));
         break;
       case 2:
         Navigator.of(context).push(MaterialPageRoute(
             builder: (_) => const ProductRegistrationScreen()));
         break;
       default:
         debugPrint('\x1B[33m${currentTabIndex + 1}번 탭의 등록 기능이 호출되었습니다.\x1B[0m');
     }
   }
 
-  AppBar _buildHomeAppBar() {
-    return AppBar(
+  // SliverAppBar로 변경하여 스크롤 최적화 적용
+  SliverAppBar _buildHomeSliverAppBar() {
+    return SliverAppBar(
+      floating: true,
+      snap: true,
+      pinned: true,
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
         onTap: () => Navigator.of(context).push(
             MaterialPageRoute(builder: (_) => const LocationSettingScreen())),
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text('My Town',
                 style: GoogleFonts.inter(
                     fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(width: 8),
             Flexible(
@@ -231,77 +235,86 @@ class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
 
-  @override
-  Widget build(BuildContext context) {
-    final List<Widget> pages = [
-      TabBarView(
+  Widget _buildHomePage() {
+    return NestedScrollView(
+      headerSliverBuilder: (context, innerBoxIsScrolled) => [
+            _buildHomeSliverAppBar(),
+          ],
+      body: TabBarView(
         controller: _tabController,
         children: [
           MainFeedScreen(userModel: _userModel),
           LocalNewsScreen(userModel: _userModel),
           MarketplaceScreen(userModel: _userModel),
           FindFriendsScreen(userModel: _userModel),
           ClubsScreen(userModel: _userModel),
           JobsScreen(userModel: _userModel),
           LocalStoresScreen(userModel: _userModel),
           AuctionScreen(userModel: _userModel),
           PomScreen(userModel: _userModel),
         ],
       ),
-      SearchScreen(),
-      ChatListScreen(),
-      MyBlingScreen(),
+    );
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    final List<Widget> pages = [
+      _buildHomePage(),
+      const SearchScreen(),
+      const ChatListScreen(),
+      const MyBlingScreen(),
     ];
 
     int effectiveIndex =
         _bottomNavIndex > 2 ? _bottomNavIndex - 1 : _bottomNavIndex;
 
     return Scaffold(
-      appBar: effectiveIndex == 0 ? _buildHomeAppBar() : null,
+      appBar: null,
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

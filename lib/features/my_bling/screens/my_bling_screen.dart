// lib/features/my_bling/screens/my_bling_screen.dart
/*
 * DocHeader
 * [기획 요약]
 * - 마이블링 화면은 친구, 게시물, 상품, 찜, 프로필 편집, 신뢰등급, 설정 등 다양한 개인화 기능을 제공합니다.
 * - KPI, 신뢰등급, 사용자 경험, 통계 등 다양한 정보를 유저에게 제공합니다.
 *
 * [실제 구현 비교]
 * - 탭별로 친구/게시물/상품/찜 목록, 프로필 편집, 신뢰등급 뱃지, 통계(게시물/팔로워/이웃/친구 수) 등 구현됨.
 * - Firestore 연동, 실시간 통계, 다국어 지원, UI/UX 개선 적용.
 *
 * [v2.1 REFACTORING]
 * - '친구 요청' 및 '보낸 요청' 메뉴 삭제 (기능 폐기)
 */

// import 'package:bling_app/features/my_bling/screens/blocked_users_screen.dart';
import 'package:bling_app/features/my_bling/screens/profile_edit_screen.dart';
import 'package:bling_app/features/my_bling/screens/settings_screen.dart';
import 'package:bling_app/features/my_bling/widgets/user_bookmark_list.dart';
import 'package:bling_app/features/my_bling/widgets/user_friend_list.dart';
import 'package:bling_app/features/my_bling/widgets/user_post_list.dart';
import 'package:bling_app/features/my_bling/widgets/user_product_list.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

// [v2.1] 삭제된 파일 임포트 제거
// import 'friend_requests_screen.dart';
// import 'sent_friend_requests_screen.dart';

class MyBlingScreen extends StatefulWidget {
  final UserModel userModel;
  final Function(Widget, String) onIconTap;

  const MyBlingScreen({
    super.key,
    required this.userModel,
    required this.onIconTap,
  });

  @override
  State<MyBlingScreen> createState() => _MyBlingScreenState();
}

class _MyBlingScreenState extends State<MyBlingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userModel;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('myBling.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (user.photoUrl != null &&
                                  user.photoUrl!.isNotEmpty)
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child:
                              (user.photoUrl == null || user.photoUrl!.isEmpty)
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nickname,
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              TrustLevelBadge(
                                  // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
                                  trustLevelLabel: user.trustLevelLabel),
                              if (user.bio != null && user.bio!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(user.bio!,
                                    style: GoogleFonts.inter(
                                        color: Colors.grey[700])),
                              ],
                              if (user.locationName != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    // Constrain the location text to avoid Row overflow
                                    Expanded(
                                      child: Text(
                                        user.locationName!,
                                        style: GoogleFonts.inter(
                                            color: Colors.grey[600]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            _getPostsCount(user.uid), 'myBling.posts'),
                        _buildStatColumn(
                            _getFollowersCount(user.uid), 'myBling.followers'),
                        _buildStatColumn(
                            _getNeighborsCount(user.uid), 'myBling.neighbors'),
                        _buildStatColumn(
                            _getFriendsCount(user.uid), 'myBling.friends'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: Text('myBling.editProfile'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildProfileTabs(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            const UserFriendList(),
            const UserPostList(),
            const UserProductList(),
            const UserBookmarkList(),
          ],
        ),
      ),
      // [작업 10] my_bling_screen의 구문 오류 지점이 이 ListView였을 가능성이 높음.
      // settings_screen.dart로 이동됨.
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // V V V --- [수정] 설정 페이지로 이동 --- V V V
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()));
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        },
        child: const Icon(Icons.settings_outlined),
      ),
      */
    );
  }

  // [작업 10] 구문 오류 복원
  SliverPersistentHeader _buildProfileTabs() {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'myBling.tabs.friends'.tr()),
            Tab(text: 'myBling.tabs.posts'.tr()),
            Tab(text: 'myBling.tabs.products'.tr()),
            Tab(text: 'myBling.tabs.bookmarks'.tr()),
          ],
        ),
      ),
      pinned: true,
    );
  }

  // [작업 10] 구문 오류 복원
  Widget _buildStatColumn(Future<int> future, String labelKey) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count',
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(labelKey.tr(),
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
          ],
        );
      },
    );
  }

  // [작업 10] 구문 오류 복원
  Future<int> _getPostsCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  // [작업 10] 구문 오류 복원
  Future<int> _getFollowersCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('toUserId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  // [작업 10] 구문 오류 복원
  Future<int> _getNeighborsCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('fromUserId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  // [작업 10] 구문 오류 복원
  Future<int> _getFriendsCount(String uid) async {
    // This is a simplified logic. A real implementation might need to check both follow collections.
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final user = UserModel.fromFirestore(userDoc);
      return user.friends?.length ?? 0;
    }
    return 0;
  }
}

// [작업 10] 구문 오류 복원
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

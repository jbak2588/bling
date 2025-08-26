// lib/features/my_bling/screens/my_bling_screen.dart
/**
 * DocHeader
 * [기획 요약]
 * - 마이블링 화면은 친구, 게시물, 상품, 찜, 프로필 편집, 신뢰등급, 설정 등 다양한 개인화 기능을 제공합니다.
 * - KPI, 신뢰등급, 사용자 경험, 통계 등 다양한 정보를 유저에게 제공합니다.
 *
 * [실제 구현 비교]
 * - 탭별로 친구/게시물/상품/찜 목록, 프로필 편집, 신뢰등급 뱃지, 통계(게시물/팔로워/이웃/친구 수) 등 구현됨.
 * - Firestore 연동, 실시간 통계, 다국어 지원, UI/UX 개선 적용.
 *
 * [차이점 및 개선 제안]
 * 1. 신뢰점수, 채팅 블록, 통계 등은 기본 제공되나, KPI/Analytics(활동 내역, 피드백, 반응 등) 시각화 및 상세 통계 제공 필요.
 * 2. 사용자 경험 개선을 위해 활동 히스토리, 신뢰등급 변화 추이, 추천 친구/상품/게시물, 프리미엄 기능(뱃지, 테마 등) 도입 검토.
 * 3. 광고/추천/프리미엄 기능 연계, 사용자별 맞춤형 통계/알림/피드백 시스템 강화 필요.
 * 4. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화, 불필요한 rebuild 최소화 등 코드 안정성/성능 개선.
 * 5. 통계 정보(게시물/팔로워/이웃/친구 수 등) 외에 활동 내역, 신뢰등급 변화, KPI 기반 추천/분석 기능 추가 권장.
 */
/// [기획의도 요약]
/// - 마이페이지에서 친구, 포스트, 상품, 북마크 관리, 프로필 편집, 신뢰등급 뱃지, 설정 등 다양한 개인화 기능을 제공한다.
/// - KPI, 신뢰등급, 사용자 경험, 수익화 등 다양한 정책을 반영한다.
/// [실제 구현 기능]
/// - MyBlingScreen에서 탭별로 친구/포스트/상품/북마크 관리, 프로필 편집, 신뢰등급 뱃지, 설정 등 구현.
/// - 각 기능별 위젯 분리, Firestore 연동, 다국어 지원, UI/UX 개선.
/// [기획의도와 실제 기능의 차이점]
/// - 기획의도보다 좋아진 점: 탭 구조 및 위젯 분리로 사용자 경험이 향상됨. 신뢰등급 뱃지, 프로필 편집 등 세부 기능 강화.
/// - 기획의도에 못 미친 점: 수익화(광고, 추천 등) 기능은 코드상에서 미구현. KPI/Analytics 연동, 사용자 경험(애니메이션, 피드백 등) 추가 개선 필요.
/// [UI/UX 기능개선 제안]
/// - 마이페이지 내 활동 히스토리, 신뢰등급 변화 시각화, 친구/포스트/상품 추천 기능 추가
/// - 프로필 편집 시 실시간 미리보기, 애니메이션 효과, 접근성 강화
/// [수익화 제안]
/// - 마이페이지 내 광고, 추천 상품/친구/포스트 노출, 프리미엄 기능(뱃지, 테마 등) 연계
/// [코드 안정성 및 실행 속도 개선 제안]
/// - Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 처리 최적화
/// - 탭/위젯 상태 관리 개선, 불필요한 rebuild 최소화
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/find_friends/models/friend_request_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';

import '../../../core/models/user_model.dart';
import '../widgets/user_post_list.dart';
import '../widgets/user_product_list.dart';
import '../widgets/user_bookmark_list.dart';
import '../widgets/user_friend_list.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'profile_edit_screen.dart';
import 'friend_requests_screen.dart';
import 'sent_friend_requests_screen.dart';
import 'settings_screen.dart'; // [추가] 방금 만든 설정 화면 import

class MyBlingScreen extends StatefulWidget {
  const MyBlingScreen({super.key});

  @override
  State<MyBlingScreen> createState() => _MyBlingScreenState();
}

class _MyBlingScreenState extends State<MyBlingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) {
      return Scaffold(
          body: Center(child: Text('main.errors.loginRequired'.tr())));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('myBling.title'.tr()),
        actions: [
          StreamBuilder<List<FriendRequestModel>>(
              stream: FindFriendRepository().getReceivedRequests(myUid),
              builder: (context, snapshot) {
                final requestCount = snapshot.data?.length ?? 0;
                return IconButton(
                  icon: Badge(
                    isLabelVisible: requestCount > 0,
                    label: Text('$requestCount'),
                    child: const Icon(Icons.people_alt_outlined),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const FriendRequestsScreen(),
                    ));
                  },
                  tooltip: 'myBling.friendRequests'.tr(),
                );
              }),
 
          IconButton(
            icon: const Icon(Icons.outbox_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SentFriendRequestsScreen(),
              ));
            },
            tooltip: 'myBling.sentFriendRequests'.tr(),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
            },
            tooltip: 'myBling.editProfile'.tr(),
          ),
          // V V V --- [수정] 설정 아이콘의 onPressed 이벤트를 수정합니다 --- V V V
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 설정 화면으로 이동하도록 Navigator.push를 사용합니다.
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ));
            },
            tooltip: 'myBling.settings'.tr(),
          ),
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(myUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('main.errors.userNotFound'.tr()));
          }

          final user = UserModel.fromFirestore(snapshot.data!);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(context, user),
                ),
              ];
            },
            body: _buildProfileTabs(user),
          );
        },
      ),
    );
  }

  /// 프로필 상단 헤더 UI 위젯
  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.startsWith('http'))
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: (user.photoUrl == null ||
                        !user.photoUrl!.startsWith('http'))
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                          'myBling.stats.posts', _getPostsCount(user.uid)),
                      _buildStatColumn('myBling.stats.followers',
                          _getFollowersCount(user.uid)),
                      const VerticalDivider(width: 20, thickness: 1),
                      _buildStatColumn('myBling.stats.neighbors',
                          _getNeighborsCount(user.uid)),
                      _buildStatColumn(
                          'myBling.stats.friends', _getFriendsCount(user.uid)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.nickname,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    TrustLevelBadge(trustLevel: user.trustLevel),
                    const SizedBox(width: 4),
                    Text(
                      '(${user.trustScore})',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                  ),
                const SizedBox(height: 6),
                if (user.locationName != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        user.locationName!,
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 프로필 하단 탭 UI 위젯
  Widget _buildProfileTabs(UserModel user) {
    final isPublic = user.privacySettings?['isProfilePublic'] ?? true;
    if (!isPublic) {
      return const Center(child: Text('This profile is private.'));
    }
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00A66C),
          unselectedLabelColor: const Color(0xFF616161),
          indicatorColor: const Color(0xFF00A66C),
          tabs: [
            Tab(text: 'myBling.tabs.posts'.tr()),
            Tab(text: 'myBling.tabs.products'.tr()),
            Tab(text: 'myBling.tabs.bookmarks'.tr()),
            Tab(text: 'myBling.tabs.friends'.tr()),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              UserPostList(),
              UserProductList(),
              UserBookmarkList(),
              UserFriendList(),
            ],
          ),
        ),
      ],
    );
  }

  /// 프로필 통계 정보 표시 위젯
  Widget _buildStatColumn(String labelKey, Future<int> countFuture) {
    return FutureBuilder<int>(
      future: countFuture,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
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

  Future<int> _getPostsCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  Future<int> _getFollowersCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('toUserId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  Future<int> _getNeighborsCount(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('fromUserId', isEqualTo: uid)
        .get();
    return snapshot.size;
  }

  Future<int> _getFriendsCount(String uid) async {
    // This is a simplified logic. A real implementation might need to check both follow collections.
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final user = UserModel.fromFirestore(userDoc);
      return user.friends?.length ?? 0;
    }
    return 0;
  }
}
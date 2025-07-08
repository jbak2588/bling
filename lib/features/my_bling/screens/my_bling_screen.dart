// lib/features/my_bling/screens/my_bling_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/user_model.dart';
import '../widgets/user_post_list.dart';
import '../widgets/user_product_list.dart';
import '../widgets/user_bookmark_list.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {/* 프로필 수정 화면으로 이동 */},
            tooltip: 'myBling.editProfile'.tr(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {/* 설정 화면으로 이동 */},
            tooltip: 'myBling.settings'.tr(),
          ),
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
                          'myBling.stats.posts', '12'), // TODO: 실제 데이터 연동
                      _buildStatColumn('myBling.stats.followers', '128'),
                      const VerticalDivider(width: 20, thickness: 1),
                      _buildStatColumn('myBling.stats.neighbors', '34'),
                      _buildStatColumn('myBling.stats.friends', '5'),
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
    // TODO: 추후 user.privacySettings 값에 따라 공개 여부 결정 로직 추가
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
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Center(child: Text('내가 쓴 게시물이 표시될 영역')),
              // ▼▼▼▼▼ '내 게시물' 탭에 새로운 위젯 적용 ▼▼▼▼▼
              UserPostList(),
              // Center(child: Text('내 판매상품이 표시될 영역')),
              // ▼▼▼▼▼ '내 판매상품' 탭에 새로운 위젯 적용 ▼▼▼▼▼
              UserProductList(),
              UserBookmarkList(),
            ],
          ),
        ),
      ],
    );
  }

  /// 프로필 통계 정보 표시 위젯
  Widget _buildStatColumn(String labelKey, String count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count,
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(labelKey.tr(),
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// lib/features/user_profile/screens/user_profile_screen.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2, // 활동내역, 받은감사 등 탭 추가 가능
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text('profileView.title'.tr()),
                floating: true,
                pinned: true,
                snap: true,
                expandedHeight: 240,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildUserProfileHeader(),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    tabs: [
                      Tab(text: 'profileView.tabs.posts'.tr()),
                      Tab(text: 'profileView.tabs.interests'.tr()),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildUserPostsList(),
              _buildUserInterests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0).copyWith(top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.nickname,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    TrustLevelBadge(
                        trustLevel: user.trustLevel, showText: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.locationName ?? 'postCard.locationNotSet'.tr(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserPostsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('profileView.noPosts'.tr()));
        }
        final postDocs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: postDocs.length,
          itemBuilder: (context, index) {
            final post = PostModel.fromFirestore(postDocs[index]);
            return PostCard(post: post);
          },
        );
      },
    );
  }

  Widget _buildUserInterests() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        final interests = user.interests ?? [];

        if (interests.isEmpty) {
          return Center(child: Text('profileView.noInterests'.tr()));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: interests.map((interestKey) {
              return Chip(
                avatar: const Icon(Icons.check_circle_outline, size: 16),
                label: Text("interests.items.$interestKey".tr()),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// TabBar를 SliverPersistentHeader로 사용하기 위한 헬퍼 클래스
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

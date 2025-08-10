// lib/features/clubs/widgets/club_post_list.dart

import 'package:bling_app/core/models/club_model.dart'; // [추가]
import 'package:bling_app/core/models/club_post_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/create_club_post_screen.dart';
import 'club_post_card.dart';

class ClubPostList extends StatelessWidget {
  final ClubModel club; // [수정] clubId와 ownerId 대신 club 객체 전체를 받습니다.
  const ClubPostList({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    final ClubRepository repository = ClubRepository();

    return Scaffold(
      body: StreamBuilder<List<ClubPostModel>>(
        stream: repository.getClubPostsStream(club.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('clubs.postList.empty'.tr()));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              // [수정] 각 게시글 카드에 club 객체를 전달합니다.
              return ClubPostCard(post: post, club: club);
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: repository.isCurrentUserMember(club.id),
        builder: (context, snapshot) {
          final isMember = snapshot.data ?? false;
          if (isMember) {
            return FloatingActionButton(
              heroTag: 'club_post_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => CreateClubPostScreen(clubId: club.id)),
                );
              },
              tooltip: 'clubs.postList.writeTooltip'.tr(),
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

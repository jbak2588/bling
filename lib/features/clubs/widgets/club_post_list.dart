// lib/features/clubs/widgets/club_post_list.dart

import 'package:bling_app/core/models/club_post_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:flutter/material.dart';
import '../screens/create_club_post_screen.dart';
import 'club_post_card.dart';

class ClubPostList extends StatelessWidget {
  final String clubId;
  final String ownerId; // [추가] 방장 ID를 받습니다.
  const ClubPostList({super.key, required this.clubId, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final ClubRepository repository = ClubRepository();
    
    return Scaffold(
      body: StreamBuilder<List<ClubPostModel>>(
        stream: repository.getClubPostsStream(clubId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 게시글이 없습니다. 첫 글을 작성해보세요!'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              // [수정] 각 게시글 카드에 방장 ID를 전달합니다.
              return ClubPostCard(post: post, clubOwnerId: ownerId);
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: repository.isCurrentUserMember(clubId),
        builder: (context, snapshot) {
          final isMember = snapshot.data ?? false;
          if (isMember) {
            return FloatingActionButton(
              heroTag: 'club_post_fab',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CreateClubPostScreen(clubId: clubId)),
                );
              },
              tooltip: '글쓰기',
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
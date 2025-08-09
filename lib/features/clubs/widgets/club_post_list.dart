// lib/features/clubs/widgets/club_post_list.dart

import 'package:bling_app/core/models/club_model.dart'; // [추가]
import 'package:bling_app/core/models/club_post_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:flutter/material.dart';
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
            return const Center(child: Text('아직 게시글이 없습니다. 첫 글을 작성해보세요!'));
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
                  MaterialPageRoute(builder: (_) => CreateClubPostScreen(clubId: club.id)),
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
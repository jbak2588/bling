// lib/features/my_bling/widgets/user_post_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../local_news/widgets/post_card.dart';

/// MyBling 화면의 '내 게시물' 탭에 표시될 위젯입니다.
/// 사용자의 postIds를 기반으로 게시물을 가져옵니다.
class UserPostList extends StatelessWidget {
  const UserPostList({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) {
      return const Center(child: Text("로그인이 필요합니다."));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // 1. 현재 사용자의 문서를 실시간으로 관찰합니다.
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("사용자 정보를 찾을 수 없습니다."));
        }

        final user = UserModel.fromFirestore(userSnapshot.data!);
        final postIds = user.postIds;

        if (postIds == null || postIds.isEmpty) {
          return const Center(child: Text("작성한 게시물이 없습니다."));
        }

        // 2. 가져온 postIds 목록을 사용하여 'posts' 컬렉션에서 여러 문서를 한번에 쿼리합니다.
        return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('posts')
              .where(FieldPath.documentId, whereIn: postIds)
              .get(),
          builder: (context, postsSnapshot) {
            if (postsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (postsSnapshot.hasError) {
              return Center(
                  child:
                      Text("게시물을 불러오는 중 오류가 발생했습니다: ${postsSnapshot.error}"));
            }
            if (!postsSnapshot.hasData || postsSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("게시물을 찾을 수 없습니다."));
            }

            final posts = postsSnapshot.data!.docs
                .map((doc) => PostModel.fromFirestore(doc))
                .toList();

            // createdAt 기준으로 최신순 정렬
            posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            );
          },
        );
      },
    );
  }
}

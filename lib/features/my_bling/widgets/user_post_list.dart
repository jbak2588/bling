// lib/features/my_bling/widgets/user_post_list.dart
/// DocHeader
/// [기획 요약]
/// - 내 게시물 탭은 사용자가 작성한 게시물 목록, 통계, 활동 내역을 제공합니다.
/// - KPI, 활동 통계, 추천/분석 기능 등 사용자 경험 강화가 목표입니다.
///
/// [실제 구현 비교]
/// - 게시물 목록, 최신순 정렬, Firestore 연동, 실시간 통계, UI/UX 개선 적용됨.
///
/// [차이점 및 개선 제안]
/// 1. KPI/Analytics 기반 활동 통계, 추천/분석 기능, 프리미엄 기능(뱃지, 광고 등) 도입 검토.
/// 2. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화 등 코드 안정성/성능 개선.
/// 3. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 게시물 기능 연계 강화 필요.
/// 4. 활동 내역, KPI 기반 추천/분석 기능 추가 권장.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';

import '../../local_news/models/post_model.dart';
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
      return Center(child: Text(t.main.errors.loginRequired));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // 1. 현재 사용자의 문서를 실시간으로 관찰합니다.
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: Text(t.main.errors.userNotFound));
        }

        final user = UserModel.fromFirestore(userSnapshot.data!);
        final postIds = user.postIds;

        if (postIds == null || postIds.isEmpty) {
          return Center(child: Text(t.myBling.posts.empty));
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
                  child: Text(t.myBling.posts.loadErrorWithMsg
                      .replaceAll('{msg}', postsSnapshot.error.toString())));
            }
            if (!postsSnapshot.hasData || postsSnapshot.data!.docs.isEmpty) {
              return Center(child: Text(t.myBling.posts.noInfo));
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

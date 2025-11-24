// lib/features/my_bling/widgets/user_bookmark_list.dart
/// DocHeader
/// [기획 요약]
/// - 관심목록(찜) 탭은 사용자가 찜한 게시물/상품 목록, 통계, 활동 내역을 제공합니다.
/// - KPI, 활동 통계, 추천/분석 기능 등 사용자 경험 강화가 목표입니다.
///
/// [실제 구현 비교]
/// - 찜한 게시물/상품 목록, 최신순 정렬, Firestore 연동, 실시간 통계, UI/UX 개선 적용됨.
///
/// [차이점 및 개선 제안]
/// 1. KPI/Analytics 기반 활동 통계, 추천/분석 기능, 프리미엄 기능(뱃지, 광고 등) 도입 검토.
/// 2. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화 등 코드 안정성/성능 개선.
/// 3. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 찜 기능 연계 강화 필요.
/// 4. 활동 내역, KPI 기반 추천/분석 기능 추가 권장.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// easy_localization compatibility removed; using Slang `t[...]`

import '../../local_news/models/post_model.dart';
import '../../marketplace/models/product_model.dart';
import '../../../core/models/user_model.dart';

import '../../local_news/widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart';

/// MyBling 화면의 '관심목록' 탭에 표시될 위젯입니다.
class UserBookmarkList extends StatelessWidget {
  const UserBookmarkList({super.key});

  // 여러 컬렉션에서 데이터를 비동기적으로 가져오는 함수
  Future<List<dynamic>> _fetchBookmarkedItems(
      List<String> postIds, List<String> productIds) async {
    final List<Future> futures = [];

    // 찜한 게시물 가져오기
    if (postIds.isNotEmpty) {
      futures.add(FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: postIds)
          .get());
    }

    // 찜한 상품 가져오기
    if (productIds.isNotEmpty) {
      futures.add(FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get());
    }

    // 모든 요청이 끝날 때까지 기다림
    final results = await Future.wait(futures);
    final List<dynamic> items = [];

    for (var result in results) {
      for (var doc in result.docs) {
        // 데이터 종류에 따라 적절한 모델로 변환하여 리스트에 추가
        if (doc.reference.parent.id == 'posts') {
          items.add(PostModel.fromFirestore(doc));
        } else if (doc.reference.parent.id == 'products') {
          items.add(ProductModel.fromFirestore(doc));
        }
      }
    }

    // 최신순으로 정렬
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) {
      return Center(child: Text(t.main.errors.loginRequired));
    }

    // 1. 사용자 정보를 먼저 가져옴
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: Text(t.main.errors.userNotFound));
        }

        final user = UserModel.fromFirestore(userSnapshot.data!);
        final postIds = user.bookmarkedPostIds ?? [];
        final productIds = user.bookmarkedProductIds ?? [];

        if (postIds.isEmpty && productIds.isEmpty) {
          return Center(child: Text(t.myBling.bookmarks.empty));
        }

        // 2. 찜한 ID 목록을 기반으로 실제 데이터들을 가져옴
        return FutureBuilder<List<dynamic>>(
          future: _fetchBookmarkedItems(postIds, productIds),
          builder: (context, itemsSnapshot) {
            if (itemsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (itemsSnapshot.hasError ||
                !itemsSnapshot.hasData ||
                itemsSnapshot.data!.isEmpty) {
              return Center(child: Text(t.myBling.bookmarks.loadError));
            }

            final items = itemsSnapshot.data!;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                // 3. 아이템 타입에 따라 다른 카드 위젯을 보여줌
                if (item is PostModel) {
                  return PostCard(post: item);
                } else if (item is ProductModel) {
                  return ProductCard(product: item);
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}

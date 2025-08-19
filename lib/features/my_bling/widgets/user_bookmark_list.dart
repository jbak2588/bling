// lib/features/my_bling/widgets/user_bookmark_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../local_news/models/post_model.dart';
import '../../marketplace/models/product_model.dart';
import '../../../core/models/user_model.dart';

import '../../local_news/widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart';


/// MyBling 화면의 '관심목록' 탭에 표시될 위젯입니다.
class UserBookmarkList extends StatelessWidget {
  const UserBookmarkList({super.key});

  // 여러 컬렉션에서 데이터를 비동기적으로 가져오는 함수
  Future<List<dynamic>> _fetchBookmarkedItems(List<String> postIds, List<String> productIds) async {
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

    if (myUid == null) return const Center(child: Text("로그인이 필요합니다."));

    // 1. 사용자 정보를 먼저 가져옴
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("사용자 정보를 찾을 수 없습니다."));
        }
        
        final user = UserModel.fromFirestore(userSnapshot.data!);
        final postIds = user.bookmarkedPostIds ?? [];
        final productIds = user.bookmarkedProductIds ?? [];

        if (postIds.isEmpty && productIds.isEmpty) {
          return const Center(child: Text("찜한 항목이 없습니다."));
        }
        
        // 2. 찜한 ID 목록을 기반으로 실제 데이터들을 가져옴
        return FutureBuilder<List<dynamic>>(
          future: _fetchBookmarkedItems(postIds, productIds),
          builder: (context, itemsSnapshot) {
            if (itemsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (itemsSnapshot.hasError || !itemsSnapshot.hasData || itemsSnapshot.data!.isEmpty) {
              return const Center(child: Text("관심 목록을 불러올 수 없습니다."));
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
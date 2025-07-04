// lib/features/feed/screens/feed_screen.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] Firestore 관련 타입 사용을 위해 import

// 새로운 모델과 리포지토리를 import 합니다.
import '../../../core/models/feed_item_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/product_model.dart';
import '../data/feed_repository.dart';
import '../widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart'; // [수정] 이제 실제로 사용됩니다.

/// 'New Feed' 탭에 표시될 통합 피드 화면입니다.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedRepository _feedRepository = FeedRepository();
  late Future<List<FeedItemModel>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _feedRepository.fetchUnifiedFeed();
  }

  // 새로고침 기능
  Future<void> _handleRefresh() async {
    setState(() {
      _feedFuture = _feedRepository.fetchUnifiedFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedItemModel>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('새로운 소식이 없습니다.'));
        }

        final feedItems = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              final item = feedItems[index];

              switch (item.type) {
                case FeedItemType.post:
                  final post = PostModel.fromFirestore(item.originalDoc
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return PostCard(post: post);
                case FeedItemType.product:
                  // [수정] 임시 Text 위젯 대신, ProductCard를 사용하여 상품을 표시합니다.
                  final product = ProductModel.fromFirestore(item.originalDoc
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return ProductCard(product: product);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }
}

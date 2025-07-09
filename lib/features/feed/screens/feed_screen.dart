// lib/features/feed/screens/feed_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import

import '../../../core/models/feed_item_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/product_model.dart';
import '../data/feed_repository.dart';
import '../widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart';

/// 'New Feed' 탭에 표시될 통합 피드 화면입니다.
class FeedScreen extends StatefulWidget {
  final UserModel? userModel;
  const FeedScreen({this.userModel, super.key});

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
          // ✅ [다국어 수정] 'feed.error' 키를 사용하여 에러 메시지를 표시합니다.
          return Center(
              child: Text('feed.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // ✅ [다국어 수정] 'feed.empty' 키를 사용하여 안내 메시지를 표시합니다.
          return Center(child: Text('feed.empty'.tr()));
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

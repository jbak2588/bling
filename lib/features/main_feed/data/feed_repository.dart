// lib/features/main_feed/data/feed_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/feed_item_model.dart';

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FeedItemModel>> fetchUnifiedFeed() async {
    final postsFuture = _fetchLatestPosts();
    final productsFuture = _fetchLatestProducts();

    final results = await Future.wait([postsFuture, productsFuture]);

    final List<FeedItemModel> feedItems = [];
    for (var list in results) {
      feedItems.addAll(list);
    }

    feedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return feedItems;
  }

  Future<List<FeedItemModel>> _fetchLatestPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      // ✅ [핵심 수정] mediaUrl 데이터를 안전하게 처리합니다.
      dynamic mediaUrlData = data['mediaUrl'];
      String? firstImageUrl;
      if (mediaUrlData is List && mediaUrlData.isNotEmpty) {
        firstImageUrl = mediaUrlData.first as String?;
      } else if (mediaUrlData is String) {
        firstImageUrl = mediaUrlData;
      }

      return FeedItemModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        type: FeedItemType.post,
        title: data['title'] ?? data['body'] ?? '',
        content: data['body'],
        imageUrl: firstImageUrl, // ✅ 안전하게 처리된 URL을 사용합니다.
        createdAt: data['createdAt'] ?? Timestamp.now(),
        originalDoc: doc,
      );
    }).toList();
  }

  Future<List<FeedItemModel>> _fetchLatestProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final imageUrls = data['imageUrls'] as List<dynamic>?;
      return FeedItemModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        type: FeedItemType.product,
        title: data['title'] ?? '',
        content: data['description'],
        imageUrl: (imageUrls != null && imageUrls.isNotEmpty)
            ? imageUrls.first
            : null,
        createdAt: data['createdAt'] ?? Timestamp.now(),
        originalDoc: doc,
      );
    }).toList();
  }
}

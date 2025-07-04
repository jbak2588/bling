// lib/features/feed/data/feed_repository.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/feed_item_model.dart';

/// 통합 피드 데이터를 가져오는 로직을 전문적으로 처리하는 클래스입니다.
class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 여러 컬렉션에서 데이터를 가져와 하나의 리스트로 합치는 함수
  Future<List<FeedItemModel>> fetchUnifiedFeed() async {
    // 1. 각 컬렉션에서 최신 5개의 데이터를 가져오는 작업을 동시에 실행합니다.
    final postsFuture = _fetchLatestPosts();
    final productsFuture = _fetchLatestProducts();
    // TODO: 나중에 Club, Job 등 다른 컬렉션 Future도 여기에 추가

    // 2. 모든 작업이 끝날 때까지 기다립니다.
    final results = await Future.wait([postsFuture, productsFuture]);

    // 3. 각 결과를 하나의 리스트로 합칩니다.
    final List<FeedItemModel> feedItems = [];
    for (var list in results) {
      feedItems.addAll(list);
    }

    // 4. 최종적으로 합쳐진 리스트를 'createdAt' 기준으로 최신순 정렬합니다.
    feedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return feedItems;
  }

  // 'posts' 컬렉션에서 최신 5개를 가져오는 내부 함수
  Future<List<FeedItemModel>> _fetchLatestPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FeedItemModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        type: FeedItemType.post,
        title: data['title'] ?? data['body'] ?? '',
        content: data['body'],
        imageUrl: data['mediaUrl'],
        createdAt: data['createdAt'] ?? Timestamp.now(),
        originalDoc: doc,
      );
    }).toList();
  }

  // 'products' 컬렉션에서 최신 5개를 가져오는 내부 함수
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

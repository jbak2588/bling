// 파일 경로: lib/features/main_feed/data/feed_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/models/feed_item_model.dart';

// 모든 관련 모델 파일들을 정확히 import 합니다.
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:flutter/foundation.dart';

class FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FeedItemModel>> fetchUnifiedFeed() async {
    final results = await Future.wait([
      _fetchLatestPosts(),
      _fetchLatestProducts(),
      _fetchLatestJobs(),
      _fetchLatestAuctions(),
      _fetchLatestClubPosts(),
      _fetchLatestLostItems(),
      _fetchLatestShorts(),
      _fetchLatestRoomListings(),
      _fetchLatestShops(),
    ]);

    final List<FeedItemModel> feedItems = [];
    for (var list in results) {
      feedItems.addAll(list);
    }

    feedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return feedItems;
  }

  // [수정 완료] 각 모델의 '실제' 필드 이름을 사용하여 FeedItemModel로 변환합니다.
  
  Future<List<FeedItemModel>> _fetchLatestPosts({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final post = PostModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: post.userId,
          type: FeedItemType.post,
          title: post.title ?? '',
          content: post.body,
          imageUrl: post.mediaUrl?.isNotEmpty == true ? post.mediaUrl!.first : null,
          createdAt: post.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching posts: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestProducts({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('products').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final product = ProductModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: product.userId,
          type: FeedItemType.product,
          title: product.title,
          content: product.description,
          imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
          createdAt: product.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching products: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestJobs({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('jobs').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final job = JobModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: job.userId,
          type: FeedItemType.job,
          title: job.title,
          content: job.description,
          imageUrl: null, // JobModel에 imageUrl 필드가 없습니다.
          createdAt: job.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching jobs: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestAuctions({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('auctions').orderBy('startAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final auction = AuctionModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: auction.ownerId,
          type: FeedItemType.auction,
          title: auction.title,
          content: auction.description,
          imageUrl: auction.images.isNotEmpty ? auction.images.first : null,
          createdAt: auction.startAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching auctions: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestClubPosts({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collectionGroup('posts').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final post = ClubPostModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: post.userId,
          type: FeedItemType.club,
          title: post.body, // ClubPostModel에는 title이 없고 body를 title로 사용합니다.
          content: post.body,
          imageUrl: post.imageUrls?.isNotEmpty == true ? post.imageUrls!.first : null,
          createdAt: post.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching club posts: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestLostItems({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('lostItems').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final item = LostItemModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: item.userId,
          type: FeedItemType.lostAndFound,
          title: item.itemDescription,
          content: item.locationDescription,
          imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : null,
          createdAt: item.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching lost items: $e'); return []; }
  }

  // [수정] 디버깅을 위해 이 함수에서만 일시적으로 try-catch를 제거합니다.
Future<List<FeedItemModel>> _fetchLatestShorts({int limit = 5}) async {
    try {
      // [수정] timestamp -> createdAt 로 정렬 필드를 정확히 수정합니다.
      final snapshot = await _firestore.collection('shorts').orderBy('createdAt', descending: true).limit(limit).get();
      
      return snapshot.docs.map((doc) {
        final short = ShortModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: short.userId,
          type: FeedItemType.pom,
          title: short.title,
          content: null,
          imageUrl: short.thumbnailUrl,
          // [수정] short.timestamp -> short.createdAt 로 필드 이름을 정확히 수정합니다.
          createdAt: short.createdAt, 
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { 
      debugPrint('Error fetching shorts: $e'); 
      return []; 
    }
  }

  
  Future<List<FeedItemModel>> _fetchLatestRoomListings({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('roomListings').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final room = RoomListingModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: room.userId,
          type: FeedItemType.realEstate,
          title: room.title,
          content: room.description,
          imageUrl: room.imageUrls.isNotEmpty ? room.imageUrls.first : null,
          createdAt: room.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching room listings: $e'); return []; }
  }

  Future<List<FeedItemModel>> _fetchLatestShops({int limit = 5}) async {
    try {
      final snapshot = await _firestore.collection('shops').orderBy('createdAt', descending: true).limit(limit).get();
      return snapshot.docs.map((doc) {
        final shop = ShopModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: shop.ownerId,
          type: FeedItemType.localStores,
          title: shop.name,
          content: shop.description,
          imageUrl: shop.imageUrls.isNotEmpty ? shop.imageUrls.first : null,
          createdAt: shop.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) { debugPrint('Error fetching shops: $e'); return []; }
  }
}
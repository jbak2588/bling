// 파일 경로: lib/features/main_feed/data/feed_repository.dart
//
// DocHeader
// [기획 요약]
// - 각 피드(게시글, 상품, 구인, 경매, 클럽, 분실물, 숏폼, 부동산, 상점)를 Firestore에서 5개씩 가져와 통합합니다.
// * - createdAt 기준으로 모든 피드를 혼합 정렬하여 최신순으로 제공합니다.
// * - 향후 인기순, 추천순, 광고 삽입 등 다양한 정렬/추천 로직이 추가될 예정입니다.
// *
// * [실제 구현 비교]
// * - fetchUnifiedFeed()에서 각 피드별 5개씩 가져와 createdAt 기준으로 통합 정렬합니다.
// * - 인기순, 추천순, 광고 삽입 등은 아직 미구현 상태입니다.
// *
// * [차이점 및 개선 제안]
// * 1. 한 피드당 5개씩 가져오는 방식은 빠른 로딩에는 유리하나, 최신성/다양성/사용자 선호 반영에 한계가 있습니다.
// * 2. createdAt 기준 혼합 정렬은 기본적이나, 인기순(조회수, 좋아요 등), 추천순(사용자 행동 기반), 광고 삽입(노출 빈도/타겟팅) 등 추가 로직이 필요합니다.
// * 3. 추후 페이징/무한스크롤, 피드 유형별 동적 배치, 광고/추천 피드 삽입, 사용자 맞춤형 피드 추천 알고리즘 도입을 적극 검토해야 합니다.
// * 4. 광고 삽입 시 FeedItemModel에 광고 타입 추가 및 노출 위치/빈도 제어 로직 설계 필요.
// * 5. 인기/추천/광고 로직은 KPI(조회수, 클릭률, 사용자 반응 등) 기반으로 설계/튜닝 권장.
// */


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
  
  Future<List<FeedItemModel>> _fetchLatestPosts({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final post = PostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestProducts({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('products')
          .where('aiVerificationStatus', whereIn: ['approved', 'none'])
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final product = ProductModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestJobs({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final job = JobModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestAuctions({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('auctions')
          .orderBy('startAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final auction = AuctionModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestClubPosts({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collectionGroup('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final post = ClubPostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestLostItems({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('lostItems')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final item = LostItemModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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
Future<List<FeedItemModel>> _fetchLatestShorts({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('shorts')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final short = ShortModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  
  Future<List<FeedItemModel>> _fetchLatestRoomListings({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('roomListings')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final room = RoomListingModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  Future<List<FeedItemModel>> _fetchLatestShops({int limit = 5, DocumentSnapshot? startAfter}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('shops')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter as DocumentSnapshot<Map<String, dynamic>>);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final shop = ShopModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  // NEW: 피처 타입별 최신 목록 로딩(기본 20개). 가로 캐러셀에서 사용.
  Future<List<FeedItemModel>> fetchByType(
    FeedItemType type, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    switch (type) {
      case FeedItemType.post:
        return _fetchLatestPosts(limit: limit, startAfter: startAfter);
      case FeedItemType.product:
        return _fetchLatestProducts(limit: limit, startAfter: startAfter);
      case FeedItemType.job:
        return _fetchLatestJobs(limit: limit, startAfter: startAfter);
      case FeedItemType.auction:
        return _fetchLatestAuctions(limit: limit, startAfter: startAfter);
      case FeedItemType.lostAndFound:
        return _fetchLatestLostItems(limit: limit, startAfter: startAfter);
      case FeedItemType.pom:
        return _fetchLatestShorts(limit: limit, startAfter: startAfter);
      case FeedItemType.realEstate:
        return _fetchLatestRoomListings(limit: limit, startAfter: startAfter);
      case FeedItemType.localStores:
        return _fetchLatestShops(limit: limit, startAfter: startAfter);
      default:
        return [];
    }
  }
}
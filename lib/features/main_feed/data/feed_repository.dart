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
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:flutter/foundation.dart';
import 'package:bling_app/core/models/user_model.dart';

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
      _fetchLatestPoms(),
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

  // ▼▼▼▼▼ [개편] 2단계: HomeScreen의 Post 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestPosts({int limit = 20}) async {
    // 기존 비공개(_fetchLatestPosts) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestPosts(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 3단계: HomeScreen의 Product 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestProducts({int limit = 20}) async {
    // 기존 비공개(_fetchLatestProducts) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestProducts(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 4단계: HomeScreen의 Club 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestClubPosts({int limit = 20}) async {
    // 기존 비공개(_fetchLatestClubPosts) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestClubPosts(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 5단계: HomeScreen의 FindFriend 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestFindFriends({int limit = 20}) async {
    // 비공개(_fetchLatestFindFriends) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestFindFriends(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 6단계: HomeScreen의 Job 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestJobs({int limit = 20}) async {
    // 비공개(_fetchLatestJobs) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestJobs(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 7단계: HomeScreen의 LocalStore 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestShops({int limit = 20}) async {
    // 비공개(_fetchLatestShops) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestShops(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 8단계: HomeScreen의 Auction 캐러셀이 호출할 공개(public) 메소드 추가 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestAuctions({int limit = 20}) async {
    // 비공개(_fetchLatestAuctions) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestAuctions(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 9단계: HomeScreen의 POM 캐러셀이 호출할 공개(public) 메소드 ▼▼▼▼▼
  //
  Future<List<FeedItemModel>> fetchLatestPoms({int limit = 20}) async {
    // 비공개(_fetchLatestPoms) 메소드를 호출하여 결과를 반환합니다.
    return _fetchLatestPoms(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 10단계: HomeScreen의 Lost&Found 캐러셀이 호출할 공개 메소드 추가 ▼▼▼▼▼
  Future<List<FeedItemModel>> fetchLatestLostItems({int limit = 20}) async {
    return _fetchLatestLostItems(limit: limit);
  }

  // ▼▼▼▼▼ [개편] 11단계: HomeScreen의 RealEstate 캐러셀이 호출할 공개 메소드 추가 ▼▼▼▼▼
  Future<List<FeedItemModel>> fetchLatestRoomListings({int limit = 20}) async {
    return _fetchLatestRoomListings(limit: limit);
  }

  // [수정 완료] 각 모델의 '실제' 필드 이름을 사용하여 FeedItemModel로 변환합니다.

  Future<List<FeedItemModel>> _fetchLatestPosts({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) {
        final post = PostModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: post.userId,
          type: FeedItemType.post,
          title: post.title ?? '',
          content: post.body,
          imageUrl:
              post.mediaUrl?.isNotEmpty == true ? post.mediaUrl!.first : null,
          createdAt: post.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestProducts({int limit = 5}) async {
    try {
      // ✅ [수정 시작]
      final snapshot = await _firestore
          .collection('products')
          // ✅ [핵심 수정] 'approved'(승인됨)와 'none'(일반 상품) 상태의 상품만 허용합니다.
          .where('aiVerificationStatus', whereIn: ['approved', 'none'])
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      // ✅ [수정 끝]
      return snapshot.docs.map((doc) {
        final product = ProductModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: product.userId,
          type: FeedItemType.product,
          title: product.title,
          content: product.description,
          imageUrl:
              product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
          createdAt: product.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestJobs({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
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
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestAuctions({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('auctions')
          .orderBy('startAt', descending: true)
          .limit(limit)
          .get();
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
    } catch (e) {
      debugPrint('Error fetching auctions: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestClubPosts({int limit = 5}) async {
    try {
      // ✅ [최종 수정] Copilot 제안 적용: 'parentType' 필드를 사용하여 서버 측에서 필터링 및 limit 적용
      // 중요: Firestore의 모든 /clubs/{clubId}/posts/{postId} 문서에
      // 'parentType': 'club' 필드가 추가되어 있어야 합니다!
      final snapshot = await _firestore
          .collectionGroup('posts')
          .where('parentType', isEqualTo: 'club') // 서버 측 필터링
          .orderBy('createdAt', descending: true)
          .limit(limit) // 서버 측 Limit 적용
          .get();

      return snapshot.docs.map((doc) {
        final post = ClubPostModel.fromFirestore(doc);
        return FeedItemModel(
          id: doc.id,
          userId: post.userId,
          type: FeedItemType.club,
          title: post.body, // ClubPostModel에는 title이 없고 body를 title로 사용합니다.
          content: post.body,
          imageUrl:
              post.imageUrls?.isNotEmpty == true ? post.imageUrls!.first : null,
          createdAt: post.createdAt,
          originalDoc: doc,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching club posts: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestLostItems({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('lost_and_found')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
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
    } catch (e) {
      debugPrint('Error fetching lost items: $e');
      return [];
    }
  }

  // [수정] 디버깅을 위해 이 함수에서만 일시적으로 try-catch를 제거합니다.
  Future<List<FeedItemModel>> _fetchLatestPoms({int limit = 5}) async {
    try {
      // [수정] timestamp -> createdAt 로 정렬 필드를 정확히 수정합니다.
      final snapshot = await _firestore
          .collection('pom')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final short = PomModel.fromFirestore(doc);
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
      final snapshot = await _firestore
          .collection('room_listings')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
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
    } catch (e) {
      debugPrint('Error fetching room listings: $e');
      return [];
    }
  }

  Future<List<FeedItemModel>> _fetchLatestShops({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
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
    } catch (e) {
      debugPrint('Error fetching shops: $e');
      return [];
    }
  }
}

// ▼▼▼▼▼ [개편] 5단계: Find Friend 데이터 로드 함수 추가 ▼▼▼▼▼
// 가장 최근 가입한 사용자 목록을 가져옵니다. (UserModel 사용)
Future<List<FeedItemModel>> _fetchLatestFindFriends({int limit = 20}) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true) // 최신 가입 순서
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final user = UserModel.fromFirestore(doc);
      return FeedItemModel(
        id: doc.id,
        userId: user.uid, // UserModel의 uid 필드 사용
        type: FeedItemType.findFriends,
        title: user.nickname, // title로 nickname 사용
        imageUrl: user.photoUrl,
        createdAt: user.createdAt, // UserModel의 createdAt 사용
        originalDoc: doc,
      );
    }).toList();
  } catch (e) {
    debugPrint('Error fetching latest users (for FindFriends): $e');
    return [];
  }
}

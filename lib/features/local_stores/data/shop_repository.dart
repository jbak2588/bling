// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) 'incrementShopView': 상세 페이지 조회수(KPI) 1 증가 함수 추가.
// 2. (Task 1) 'addReview': 리뷰 추가 시, Firestore Transaction을 사용해 'averageRating' 및 'reviewCount'를 원자적으로 재계산/업데이트하는 로직 추가.
// 3. (Task 3) 'deleteReview': [버그 수정] 기존 평점 재계산 로직이 누락되었던 문제 해결. Transaction을 사용해 리뷰 삭제 시 평점/개수를 정확히 차감하여 재계산/업데이트.
// =====================================================

// lib/features/local_stores/data/shop_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shop_model.dart';
import '../models/shop_review_model.dart';

/// Handles CRUD operations for shops and reviews in the Local Shops module.
class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shopsCollection =>
      _firestore.collection('shops');

  Future<String> createShop(ShopModel shop) async {
    final doc = await _shopsCollection.add(shop.toJson());
    return doc.id;
  }

  Future<void> updateShop(ShopModel shop) async {
    await _shopsCollection.doc(shop.id).update(shop.toJson());
  }

  Future<void> deleteShop(String shopId) async {
    await _shopsCollection.doc(shopId).delete();
  }

  Future<ShopModel> fetchShop(String shopId) async {
    final doc = await _shopsCollection.doc(shopId).get();
    return ShopModel.fromFirestore(doc);
  }

  /// [추가] 상점 조회수를 1 증가시킵니다. (KPI)
  Future<void> incrementShopView(String shopId) async {
    // (개선) Cloud Function에서 처리하는 것이 좋으나, 클라이언트에서도 구현 가능
    await _shopsCollection.doc(shopId).update({
      'viewsCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchShops(
      {Map<String, String?>? locationFilter}) {
    Query<Map<String, dynamic>> query = _shopsCollection;

    final String? kab = locationFilter?['kab'];
    if (kab != null && kab.isNotEmpty) {
      query = query.where('locationParts.kab', isEqualTo: kab);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty && kab != null && kab != 'Tangerang') {
        return await _shopsCollection
            .where('locationParts.kab', isEqualTo: 'Tangerang')
            .orderBy('createdAt', descending: true)
            .get();
      }
      return snapshot;
    });
  }

  // V V V --- [추가] 특정 상점 정보를 실시간으로 가져오는 Stream 함수 --- V V V
  Stream<ShopModel> getShopStream(String shopId) {
    return _shopsCollection
        .doc(shopId)
        .snapshots()
        .map((snapshot) => ShopModel.fromFirestore(snapshot));
  }

  // [수정] 리뷰 추가 시 평균 별점 업데이트 로직
  Future<String> addReview(String shopId, ShopReviewModel review) async {
    // 트랜잭션으로 리뷰 추가 + 상점 별점 업데이트
    final reviewCol = _shopsCollection.doc(shopId).collection('reviews');
    final shopDoc = _shopsCollection.doc(shopId);

    final newReviewRef = reviewCol.doc();

    await _firestore.runTransaction((transaction) async {
      final shopSnapshot = await transaction.get(shopDoc);
      if (!shopSnapshot.exists) {
        throw Exception("Shop does not exist!");
      }

      final currentReviewCount = shopSnapshot.data()!['reviewCount'] ?? 0;
      final currentAverageRating =
          (shopSnapshot.data()!['averageRating'] ?? 0.0).toDouble();

      final newReviewCount = currentReviewCount + 1;
      final newAverageRating =
          ((currentAverageRating * currentReviewCount) + review.rating) /
              newReviewCount;

      transaction.set(newReviewRef, review.toJson());
      transaction.update(shopDoc, {
        'reviewCount': newReviewCount,
        'averageRating': newAverageRating,
      });
    });

    return newReviewRef.id;
  }

  Future<void> updateReview(String shopId, ShopReviewModel review) async {
    await _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .doc(review.id)
        .update(review.toJson());
  }

  Future<void> deleteReview(String shopId, String reviewId) async {
    // [수정] 리뷰 삭제 시 트랜잭션을 사용하여 평균 별점 및 리뷰 수 재계산
    final shopDoc = _shopsCollection.doc(shopId);
    final reviewDoc = shopDoc.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      final shopSnapshot = await transaction.get(shopDoc);
      final reviewSnapshot = await transaction.get(reviewDoc);

      if (!shopSnapshot.exists) {
        throw Exception("Shop does not exist!");
      }
      if (!reviewSnapshot.exists) {
        throw Exception("Review does not exist!");
      }

      final currentReviewCount = (shopSnapshot.data()!['reviewCount'] ?? 0);
      final currentAverageRating =
          (shopSnapshot.data()!['averageRating'] ?? 0.0).toDouble();
      final deletedRating = (reviewSnapshot.data()!['rating'] ?? 0).toDouble();

      final newReviewCount = currentReviewCount - 1;
      final double newAverageRating;

      if (newReviewCount > 0) {
        newAverageRating =
            ((currentAverageRating * currentReviewCount) - deletedRating) /
                newReviewCount;
      } else {
        newAverageRating = 0.0; // 리뷰가 없으면 0점으로 리셋
      }

      transaction.delete(reviewDoc);
      transaction.update(shopDoc, {
        'reviewCount': newReviewCount,
        'averageRating': newAverageRating,
      });
    });
  }

  Stream<List<ShopReviewModel>> fetchReviews(String shopId) {
    return _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ShopReviewModel.fromFirestore).toList());
  }
}

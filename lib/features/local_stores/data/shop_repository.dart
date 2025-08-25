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

  Future<String> addReview(String shopId, ShopReviewModel review) async {
    final doc = await _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .add(review.toJson());
    return doc.id;
  }

  Future<void> updateReview(String shopId, ShopReviewModel review) async {
    await _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .doc(review.id)
        .update(review.toJson());
  }

  Future<void> deleteReview(String shopId, String reviewId) async {
    await _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .doc(reviewId)
        .delete();
  }

  Stream<List<ShopReviewModel>> fetchReviews(String shopId) {
    return _shopsCollection
        .doc(shopId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(ShopReviewModel.fromFirestore)
            .toList());
  }
}


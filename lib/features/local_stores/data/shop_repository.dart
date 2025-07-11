// lib/features/local_stores/data/shop_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/shop_model.dart';
import '../../../core/models/shop_review_model.dart';

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

  Stream<List<ShopModel>> fetchShops() {
    return _shopsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ShopModel.fromFirestore).toList());
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


// lib/core/models/shop_review_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Review model stored under `shops/{shopId}/reviews`.
class ShopReviewModel {
  final String id;
  final String shopId;
  final String userId;
  final int rating;
  final String comment;
  final Timestamp createdAt;

  ShopReviewModel({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ShopReviewModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShopReviewModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      userId: data['userId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}


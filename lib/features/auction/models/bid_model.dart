// lib/core/models/bid_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for bids stored under `auctions/{auctionId}/bids`.
class BidModel {
  final String id;
  final String userId;
  final int bidAmount;
  final Timestamp bidTime;

  BidModel({
    required this.id,
    required this.userId,
    required this.bidAmount,
    required this.bidTime,
  });

  factory BidModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BidModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bidAmount: data['bidAmount'] ?? 0,
      bidTime: data['bidTime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bidAmount': bidAmount,
      'bidTime': bidTime,
    };
  }

  /// Compatibility: present a short label for UIs that expect `.title`.
  String get title => userId;
}

// lib/core/models/friend_request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a friend request between two users.
class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status; // pending, accepted, rejected
  final Timestamp createdAt;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FriendRequestModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

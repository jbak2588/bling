// lib/core/models/follow_model.dart
//
// Model representing a follow relationship in the Find Friend feature.
// This allows one user to follow another.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages follow relationships for the Find Friend feature.
class FollowModel {
  /// UID of the user who initiated the follow.
  final String fromUserId;

  /// UID of the user being followed.
  final String toUserId;

  /// Time at which the follow was created.
  final Timestamp createdAt;

  FollowModel({
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
  });

  /// Create a [FollowModel] from a Firestore document.
  factory FollowModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FollowModel(
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Convert this model to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': createdAt,
    };
  }
}

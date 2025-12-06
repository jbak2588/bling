// lib/core/models/club_member_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user who has joined a specific club. Stored under
/// `clubs/{clubId}/members` subcollection.
class ClubMemberModel {
  final String id;
  final String userId;
  final Timestamp joinedAt;

  ClubMemberModel({
    required this.id,
    required this.userId,
    required this.joinedAt,
  });

  factory ClubMemberModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubMemberModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      joinedAt: data['joinedAt'] ?? Timestamp.now(),
    );
  }

  /// Compatibility getter: use userId as a short title/label.
  String get title => userId;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'joinedAt': joinedAt,
    };
  }
}

// lib/core/models/short_comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment model stored under `shorts/{shortId}/comments` in the POM hub.
class ShortCommentModel {
  final String id;
  final String userId;
  final String body;
  final Timestamp createdAt;

  ShortCommentModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
  });

  factory ShortCommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShortCommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      body: data['body'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'body': body,
      'createdAt': createdAt,
    };
  }
}


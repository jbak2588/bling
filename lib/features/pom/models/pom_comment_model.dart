// ===================== DocHeader =====================
// [기획 요약]
// - '뽐' (Pom) 댓글 데이터 모델.
// - Firestore 경로: pom/{pomId}/comments
// [V2 - 2025-11-03]
// - 'shorts_comment_model'에서 'pom_comment_model'로 리네이밍.
// =====================================================
// lib/features/pom/models/pom_comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment model stored under `pom/{pomId}/comments` in the POM hub.
class PomCommentModel {
  final String id;
  final String userId;
  final String body;
  final Timestamp createdAt;

  PomCommentModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
  });

  factory PomCommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PomCommentModel(
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

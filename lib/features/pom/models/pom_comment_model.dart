// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 댓글 데이터 모델. Firestore shorts/{shortId}/comments 컬렉션 구조와 1:1 매칭, 본문/작성자/작성일 등 필드 지원.
// [V2 - 2025-11-03 개선]
// - 'Shorts'에서 'Pom'으로 리네이밍. (pom/{pomId}/comments)
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

// lib/core/models/club_post_model.dart
// ===================== DocHeader =====================
// [Planning Summary]
// - Club posts are stored under `clubs/{clubId}/posts` in Firestore, with fields for author, body, images, likes, comments, and timestamps.
//
// [Implementation Summary]
// - Dart model matches Firestore structure: id, clubId, userId, body, imageUrls, createdAt, likesCount, commentsCount.
// - Used for post creation, display, and interaction in club boards.
//
// [Differences & Gaps]
// - Moderation, analytics, and advanced post controls are not directly implemented in this model.
//
// [Improvement Suggestions]
// - Add fields for moderation status, analytics, and post visibility options.
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// 동호회 전용 게시판의 게시글 정보를 담는 데이터 모델입니다.
/// Firestore의 `clubs/{clubId}/posts` 하위 컬렉션 문서 구조와 대응됩니다.
class ClubPostModel {
  final String id;
  final String clubId; // 이 게시물이 속한 동호회의 ID
  final String userId; // 작성자 ID
  final String body;
  final List<String>? imageUrls;
  final Timestamp createdAt;
  final int likesCount;
  final int commentsCount;

  ClubPostModel({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.body,
    this.imageUrls,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory ClubPostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubPostModel(
      id: doc.id,
      clubId: data['clubId'] ?? '',
      userId: data['userId'] ?? '',
      body: data['body'] ?? '',
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
      'userId': userId,
      'body': body,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }
}
// lib/core/models/club_comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 동호회 게시글의 댓글 정보를 담는 데이터 모델입니다.
/// Firestore의 `clubs/{clubId}/posts/{postId}/comments` 하위 컬렉션 문서 구조와 대응됩니다.
class ClubCommentModel {
  final String id;
  final String userId; // 댓글 작성자 ID
  final String body; // 댓글 내용
  final Timestamp createdAt;
  final int likesCount;

  ClubCommentModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.likesCount = 0,
  });

  factory ClubCommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubCommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      body: data['body'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'body': body,
      'createdAt': createdAt,
      'likesCount': likesCount,
    };
  }

  /// Compatibility getter: expose comment body as `title`.
  String get title => body;
}

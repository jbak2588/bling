// lib/core/models/comment_model.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  // [삭제] userName 필드 제거
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool isSecret;
  final String? parentCommentId;

  CommentModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isSecret = false,
    this.parentCommentId,
  });

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      // [삭제] userName 로직 제거
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] ?? 0,
      isSecret: data['isSecret'] ?? false,
      parentCommentId: data['parentCommentId'],
    );
  }

  /// Compatibility getter: use comment content as `title` for lists.
  String get title => content;
}

// lib/core/models/reply_model.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  final String id;
  final String userId;
  // [삭제] userName 필드 제거
  final String content;
  final DateTime createdAt;

  ReplyModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory ReplyModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReplyModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      // [삭제] userName 로직 제거
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

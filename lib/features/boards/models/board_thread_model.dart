// lib/features/boards/models/board_thread_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 동네 게시판 스레드 모델
class BoardThreadModel {
  final String id;
  final String type; // "sticky" | "normal"
  final String title;
  final Timestamp lastActivityAt;
  final List<String> tags;
  final String createdBy; // userId
  final Timestamp createdAt;

  BoardThreadModel({
    required this.id,
    this.type = 'normal',
    required this.title,
    required this.lastActivityAt,
    this.tags = const [],
    required this.createdBy,
    required this.createdAt,
  });

  factory BoardThreadModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BoardThreadModel(
      id: doc.id,
      type: data['type'] ?? 'normal',
      title: data['title'] ?? '',
      lastActivityAt: data['lastActivityAt'] ?? Timestamp.now(),
      tags: (data['tags'] is List) ? List<String>.from(data['tags']) : [],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'lastActivityAt': lastActivityAt,
      'tags': tags,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}

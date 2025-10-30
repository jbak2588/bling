// lib/features/boards/models/board_thread_model.dart
/// ============================================================================
/// Bling DocHeader
/// Module        : Boards (동네 게시판)
/// File          : lib/features/boards/models/board_thread_model.dart
/// Purpose       : 'boards/{kel_key}/threads/{thread_id}' 문서의 데이터 모델.
///                 (향후 동네 게시판의 주제별 스레드용)
///
/// Related Docs  : '하이브리드 방식 로컬 뉴스 게시글 개선 방안.md' (4. 동네 게시판)
///
/// 2025-10-30 (작업 8):
///   - '하이브리드 기획안' 4)를 기반으로 BoardThreadModel 신규 생성.
/// ============================================================================
library;
// (파일 내용...)

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

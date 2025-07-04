// lib/core/models/feed_item_model.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';

// 피드 아이템의 종류를 구분하기 위한 enum
enum FeedItemType { post, product, unknown }

/// 통합 피드에 표시될 모든 아이템을 위한 표준 데이터 모델입니다.
class FeedItemModel {
  final String id; // 문서 ID
  final String userId; // 작성자 ID
  final FeedItemType type; // 아이템 종류 (post, product 등)
  final String title; // 제목 또는 상품명
  final String? content; // 내용 또는 설명
  final String? imageUrl; // 대표 이미지 URL
  final Timestamp createdAt; // 생성 시간 (정렬 기준)

  // 원본 데이터를 저장하여, 상세 보기 시 활용
  final DocumentSnapshot originalDoc;

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.originalDoc,
  });
}

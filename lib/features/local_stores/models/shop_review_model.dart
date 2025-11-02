// ===================== DocHeader =====================
// [기획 요약]
// - 상점 리뷰 데이터 모델. Firestore shops/{shopId}/reviews 컬렉션 구조와 1:1 매칭, 평점/코멘트/작성자/작성일 등 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 평점/코멘트/작성자/작성일 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(리뷰 부스트, 신고/차단 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// lib/core/models/shop_review_model.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 상점 리뷰 데이터 모델. Firestore shops/{shopId}/reviews 컬렉션 구조와 1:1 매칭, 평점/코멘트/작성자/작성일 등 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 평점/코멘트/작성자/작성일 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(리뷰 부스트, 신고/차단 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// - (Task 1) 기획서 검토 완료.
// - 현재 모델(ID, shopId, userId, rating, comment, createdAt)이 기획서의 리뷰 요구사항을 충족하므로 변경 사항 없음.
// =====================================================
// lib/features/local_stores/models/shop_review_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Review model stored under `shops/{shopId}/reviews`.
class ShopReviewModel {
  final String id;
  final String shopId;
  final String userId;
  final int rating;
  final String comment;
  final Timestamp createdAt;

  ShopReviewModel({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ShopReviewModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShopReviewModel(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      userId: data['userId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}

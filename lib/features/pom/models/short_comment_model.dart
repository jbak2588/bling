// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 댓글 데이터 모델. Firestore shorts/{shortId}/comments 컬렉션 구조와 1:1 매칭, 본문/작성자/작성일 등 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 본문/작성자/작성일 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(댓글 부스트, 신고/차단 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// lib/core/models/short_comment_model.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 댓글 데이터 모델. Firestore shorts/{shortId}/comments 컬렉션 구조와 1:1 매칭, 본문/작성자/작성일 등 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 본문/작성자/작성일 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(댓글 부스트, 신고/차단 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment model stored under `shorts/{shortId}/comments` in the POM hub.
class ShortCommentModel {
  final String id;
  final String userId;
  final String body;
  final Timestamp createdAt;

  ShortCommentModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
  });

  factory ShortCommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShortCommentModel(
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


// lib/core/models/short_model.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 데이터 모델. Firestore shorts 컬렉션 구조와 1:1 매칭, AI 인증, 신뢰 등급, 태그, 좋아요/댓글/조회수 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, AI 인증, 신뢰 등급, 태그, 좋아요/댓글/조회수 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트, AI 인증 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a short video uploaded to the POM (Piece of Moment)
/// short-video hub.
class ShortModel {
  final String id;
  final String userId;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String? location;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? tags;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final bool trustLevelVerified;
  final bool isAiVerified;
  final Timestamp createdAt;

  ShortModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    this.location,
    this.locationParts,
    this.geoPoint,
    this.tags,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.trustLevelVerified = false,
    this.isAiVerified = false,
    required this.createdAt,
  });

  factory ShortModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShortModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      description: data['description'] ?? '',
      location: data['location'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      likesCount: data['likesCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      isAiVerified: data['isAiVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'location': location,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'tags': tags,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
      'trustLevelVerified': trustLevelVerified,
      'isAiVerified': isAiVerified,
      'createdAt': createdAt,
    };
  }
}

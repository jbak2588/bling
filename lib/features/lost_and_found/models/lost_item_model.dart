// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 데이터 모델. Firestore lost_and_found 컬렉션 구조와 1:1 매칭, 위치/이미지/현상금 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 위치/이미지/현상금 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// lib/core/models/lost_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 분실/습득물 정보를 담는 데이터 모델입니다.
/// Firestore의 `lost_and_found` 컬렉션 문서 구조와 대응됩니다.
class LostItemModel {
  final String id;
  final String userId; // 등록자 ID
  final String type; // 'lost' 또는 'found'
  final String itemDescription; // 물건 설명
  final String locationDescription; // 분실/습득 장소 설명
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final bool isHunted; // 현상금(Hunted) 여부
  final num? bountyAmount; // ✅ [수정] int? -> num? (정수/실수 모두 허용)
  final List<String> tags; // ✅ [추가] 태그 목록

  // ✅ [작업 41] '해결 완료' 기능 추가
  final bool isResolved;
  final Timestamp? resolvedAt;

  // ✅ [작업 42] 댓글 및 조회수 기능 추가
  final int viewsCount;
  final int commentsCount;

  LostItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemDescription,
    required this.locationDescription,
    this.locationParts,
    this.geoPoint,
    required this.imageUrls,
    required this.createdAt,
    this.isHunted = false,
    this.bountyAmount,
    this.tags = const [], // ✅ 생성자 추가

    // ✅ [작업 41]
    this.isResolved = false,
    this.resolvedAt,

    // ✅ [작업 42]
    this.viewsCount = 0,
    this.commentsCount = 0,
  });

  factory LostItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LostItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'lost',
      itemDescription: data['itemDescription'] ?? '',
      locationDescription: data['locationDescription'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isHunted: data['isHunted'] ?? false,
      bountyAmount: data['bountyAmount'],
      // ✅ Firestore 데이터로부터 tags 필드를 읽어옵니다.
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],

      // ✅ [작업 41]
      isResolved: data['isResolved'] ?? false,
      resolvedAt: data['resolvedAt'] as Timestamp?,

      // ✅ [작업 42]
      viewsCount: data['viewsCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'itemDescription': itemDescription,
      'locationDescription': locationDescription,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'bountyAmount': bountyAmount,
      'tags': tags, // ✅ Firestore에 저장

      // ✅ [작업 41]
      'isResolved': isResolved,
      'resolvedAt': resolvedAt,

      // ✅ [작업 42]
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,

      // [수정] 'isHunted' 필드도 저장되도록 추가합니다.
      'isHunted': isHunted,
    };
  }
}

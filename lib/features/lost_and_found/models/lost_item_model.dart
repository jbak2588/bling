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
  final int? bountyAmount; // 현상금 금액

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
  });
  

  factory LostItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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
      'isHunted': isHunted,
      'bountyAmount': bountyAmount,
    };
  }
}
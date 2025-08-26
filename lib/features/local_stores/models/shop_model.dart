// lib/core/models/shop_model.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 상점 데이터 모델. Firestore shops 컬렉션 구조와 1:1 매칭, 위치/신뢰 등급/이미지/연락처/영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 위치/신뢰 등급/이미지/연락처/영업시간 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// 지역 상점 정보를 담는 데이터 모델입니다.
/// Firestore의 `shops` 컬렉션 문서 구조와 1:1로 대응됩니다.
class ShopModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? products; // 간단한 대표 상품/서비스 이름 목록
  final String contactNumber;
  final String openHours;
  final bool trustLevelVerified;
  final Timestamp createdAt;
  final int viewsCount;
  final int likesCount;
  
  // V V V --- [수정] 단일 이미지(String)에서 이미지 목록(List<String>)으로 변경 --- V V V
  final List<String> imageUrls; // 상점 대표 이미지

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.products,
    required this.contactNumber,
    required this.openHours,
    this.trustLevelVerified = false,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    // [수정] 생성자 필드 변경
    required this.imageUrls,
  });

  factory ShopModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      locationName: data['locationName'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      products:
          data['products'] != null ? List<String>.from(data['products']) : [],
      contactNumber: data['contactNumber'] ?? '',
      openHours: data['openHours'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      // [수정] Firestore에서 이미지 목록 불러오기
      imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'products': products,
      'contactNumber': contactNumber,
      'openHours': openHours,
      'trustLevelVerified': trustLevelVerified,
      'createdAt': createdAt,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      // [수정] Firestore에 이미지 목록 저장
      'imageUrls': imageUrls,
    };
  }
}
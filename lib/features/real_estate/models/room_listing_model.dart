// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 데이터 모델. Firestore room_listings 컬렉션 구조와 1:1 매칭, 위치/이미지/가격/편의시설 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 위치/이미지/가격/편의시설 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// lib/core/models/room_listing_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 지역 부동산(월세/하숙) 매물 정보를 담는 데이터 모델입니다.
/// Firestore의 `room_listings` 컬렉션 문서 구조와 대응됩니다.
/// 
class RoomListingModel {
  final String id;
  final String userId; // 게시자 ID
  final String title;
  final String description;
  final String type; // 'kos', 'kontrakan', 'sewa' (하숙, 월세 등)
  
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  final int price;
  final String priceUnit; // 'monthly', 'yearly' (월세/연세)
  
  final List<String> imageUrls;
  final List<String> amenities; // 'wifi', 'ac', 'parking' 등 편의시설 목록
  
  final Timestamp createdAt;
  final bool isAvailable;

  RoomListingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.price,
    required this.priceUnit,
    required this.imageUrls,
    required this.amenities,
    required this.createdAt,
    this.isAvailable = true,
  });

  factory RoomListingModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RoomListingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'kos',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null ? Map<String, dynamic>.from(data['locationParts']) : null,
      geoPoint: data['geoPoint'],
      price: data['price'] ?? 0,
      priceUnit: data['priceUnit'] ?? 'monthly',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'price': price,
      'priceUnit': priceUnit,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'createdAt': createdAt,
      'isAvailable': isAvailable,
    };
  }
}
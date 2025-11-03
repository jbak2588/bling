// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 데이터 모델. Firestore room_listings 컬렉션 구조와 1:1 매칭, 위치/이미지/가격/편의시설 등 다양한 필드 지원.
// 지역 부동산(월세/하숙) 매물 정보를 담는 데이터 모델입니다.
// Firestore의 `room_listings` 컬렉션 문서 구조와 대응됩니다.
//
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 위치/이미지/가격/편의시설 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 21, 23) '직방' 모델 도입 (Gap 1, 4, 5).
// 2. [Gap 1] 핵심 정보 필드 추가: 'area'(면적), 'roomCount'(방 수), 'bathroomCount'(욕실 수), 'moveInDate'(입주 가능일).
// 3. [Gap 4] 매물/게시자 유형 필드 추가: 'listingType'(임대/매매), 'publisherType'(직거래/중개인).
// 4. [Gap 5] 수익화/KPI 필드 추가: 'isSponsored'(광고), 'isVerified'(인증), 'viewCount'(조회수).
// =====================================================
// lib/core/models/room_listing_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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

  // [추가] 기획서 7.1.2 및 '직방' 핵심 필드
  final String listingType; // 'rent' (임대), 'sale' (매매)
  final String publisherType; // 'individual' (직거래), 'agent' (중개인)
  final double area; // 면적 (m²)
  final int roomCount; // 방 수
  final int bathroomCount; // 욕실 수
  final Timestamp? moveInDate; // 입주 가능일

  // [추가] 기획서 7.1.5 (수익화 및 KPI)
  final bool isSponsored; // 광고(상단 고정) 여부
  final bool isVerified; // 인증 매물 여부 (중개사/집주인 인증)
  final int viewCount; // 조회수

  // [추가] Task 38: '직방' 및 'rumah123' 상세 필터용 필드
  // (Kos, Apartemen, Kontrakan)
  final String? furnishedStatus; // 'furnished', 'semi_furnished', 'unfurnished'
  final String? rentPeriod; // 'daily', 'monthly', 'yearly'
  final int? maintenanceFee; // 관리비
  // (Kontrakan, Ruko, Kantor)
  final int? deposit; // 보증금
  // (Apartemen, Ruko, Kantor)
  final String? floorInfo; // 층수 (예: "Lantai 5", "Middle")

  // ✅ tags 필드를 추가합니다.
  final List<String> tags;

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
    this.listingType = 'rent',
    this.publisherType = 'individual',
    this.area = 0.0,
    this.roomCount = 1,
    this.bathroomCount = 1,
    this.moveInDate,
    this.isSponsored = false,
    this.isVerified = false,
    this.viewCount = 0,
    // [추가] Task 38
    this.furnishedStatus,
    this.rentPeriod,
    this.maintenanceFee,
    this.deposit,
    this.floorInfo,
    this.tags = const [], // ✅ 생성자에 추가
  });

  factory RoomListingModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RoomListingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'kos',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      price: data['price'] ?? 0,
      priceUnit: data['priceUnit'] ?? 'monthly',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isAvailable: data['isAvailable'] ?? true,
      // [추가]
      listingType: data['listingType'] ?? 'rent',
      publisherType: data['publisherType'] ?? 'individual',
      area: (data['area'] ?? 0.0).toDouble(),
      roomCount: data['roomCount'] ?? 1,
      bathroomCount: data['bathroomCount'] ?? 1,
      moveInDate: data['moveInDate'],
      isSponsored: data['isSponsored'] ?? false,
      isVerified: data['isVerified'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      // [추가] Task 38: '직방' 및 'rumah123' 상세 필터용 필드
      furnishedStatus: data['furnishedStatus'],
      rentPeriod: data['rentPeriod'],
      maintenanceFee: data['maintenanceFee'],
      deposit: data['deposit'],
      floorInfo: data['floorInfo'],
      // ✅ Firestore 데이터로부터 tags 필드를 읽어옵니다.
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
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

      // [추가]
      'listingType': listingType,
      'publisherType': publisherType,
      'area': area,
      'roomCount': roomCount,
      'bathroomCount': bathroomCount,
      'moveInDate': moveInDate,
      'isSponsored': isSponsored,
      'isVerified': isVerified,
      'viewCount': viewCount,
      // [추가] Task 38
      'furnishedStatus': furnishedStatus,
      'rentPeriod': rentPeriod,
      'maintenanceFee': maintenanceFee,
      'deposit': deposit,
      'floorInfo': floorInfo,

      'tags': tags, // ✅ JSON 변환 시 tags 필드를 포함합니다.
    };
  }
}

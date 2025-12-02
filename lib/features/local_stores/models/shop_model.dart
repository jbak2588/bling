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
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) 기획서(백서 9.1) 요구사항 반영을 위해 모델 확장.
// 2. 'category': 업종 분류 (food, cafe 등) 필드 추가.
// 3. 'products': 대표 상품/서비스 (List<String>) 필드 추가.
// 4. 'averageRating', 'reviewCount': 리뷰/평점 시스템 연동 필드 추가.
// 5. 'isSponsored', 'adExpiryDate': 광고(수익화) 모델 연동 필드 추가.
// =====================================================

import 'package:bling_app/core/models/bling_location.dart';
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
  final BlingLocation? shopLocation; // physical location of the store
  final String? shopAddress;
  final String category; // [추가] 업종 카테고리
  final List<String>? products; // 간단한 대표 상품/서비스 이름 목록
  final List<String> tags; // 사용자 정의 태그/검색 보조 태그
  final String contactNumber;
  final String openHours;
  final bool trustLevelVerified;
  final Timestamp createdAt;
  final int viewsCount;
  final int likesCount;
  final double averageRating; // [추가] 평균 별점
  final int reviewCount; // [추가] 리뷰 개수
  final bool isSponsored; // [추가] 유료 광고 여부
  final Timestamp? adExpiryDate; // [추가] 광고 만료일

  // V V V --- [수정] 단일 이미지(String)에서 이미지 목록(List<String>)으로 변경 --- V V V
  final List<String> imageUrls; // 상점 대표 이미지

  // [추가] 검색용 역색인
  final List<String> searchIndex;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.shopLocation,
    this.shopAddress,
    required this.category,
    this.products,
    required this.contactNumber,
    required this.openHours,
    this.trustLevelVerified = false,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isSponsored = false,
    this.adExpiryDate,
    // [수정] 생성자 필드 변경
    required this.imageUrls,
    this.searchIndex = const [],
    this.tags = const [],
  });

  factory ShopModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final shopLocMap = data['shopLocation'];
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      locationName: data['locationName'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      shopLocation: (shopLocMap is Map<String, dynamic>)
          ? BlingLocation.fromJson(Map<String, dynamic>.from(shopLocMap))
          : _fallbackShopLocationFromLegacy(data),
      shopAddress: data['shopAddress'] ??
          data['address'] ??
          data['fullAddress'] ??
          data['locationDescription'],
      category: data['category'] ?? 'etc', // [추가]
      geoPoint: data['geoPoint'],
      products:
          data['products'] != null ? List<String>.from(data['products']) : [],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      contactNumber: data['contactNumber'] ?? '',
      openHours: data['openHours'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isSponsored: data['isSponsored'] ?? false,
      adExpiryDate: data['adExpiryDate'],
      // [수정] Firestore에서 이미지 목록 불러오기
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
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
      'shopLocation': shopLocation?.toJson(),
      'shopAddress':
          shopAddress ?? shopLocation?.shortLabel ?? shopLocation?.mainAddress,
      'category': category, // [추가]
      'products': products,
      'contactNumber': contactNumber,
      'openHours': openHours,
      'trustLevelVerified': trustLevelVerified,
      'createdAt': createdAt,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isSponsored': isSponsored,
      'adExpiryDate': adExpiryDate,
      // [수정] Firestore에 이미지 목록 저장
      'imageUrls': imageUrls,
      'tags': tags,
      'searchIndex': searchIndex,
    };
  }

  static BlingLocation? _fallbackShopLocationFromLegacy(
      Map<String, dynamic> data) {
    final gp = data['shopGeoPoint'] ?? data['geoPoint'];
    final desc = data['shopAddress'] ?? data['address'] ?? data['fullAddress'];
    if (gp is GeoPoint && desc is String && desc.isNotEmpty) {
      return BlingLocation(
        geoPoint: gp,
        mainAddress: desc,
        shortLabel: desc,
      );
    }
    return null;
  }
}

/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/models/product_model.dart
/// Purpose       : AI 검증과 상태 추적을 포함한 상품 Firestore 스키마입니다.
/// User Impact   : 구조화된 정보를 통해 안전한 동네 거래를 지원합니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/marketplace/screens/product_registration_screen.dart
/// Data Model    : Firestore `products/{productId}` 문서; 필드 `price`, `imageUrls`, `locationParts`, `status`, `isAiVerified`, `likesCount`, `chatsCount`, `viewsCount`.
/// Location Scope: Kabupaten→Kecamatan→Kelurahan을 저장하며 RT/RW는 선택 사항; 없으면 `locationName`을 사용합니다.
/// Trust Policy  : `isAiVerified` 상품이 우선 노출되며 판매자는 TrustLevel 정책을 따릅니다.
/// Monetization  : AI 검증 상품은 서비스 수수료를 지불하며 프로모션 배치 가능성이 있습니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_product`, `start_chat`, 총거래액(Gross Merchandise Volume, GMV).
/// Analytics     : `viewsCount`, `chatsCount`, `likesCount` 증가를 추적합니다.
/// I18N          : 카테고리 이름은 assets/lang 제품 키를 통해 제공합니다.
/// Dependencies  : cloud_firestore
/// Security/Auth : 게시물 소유자만 수정할 수 있으며 입력 검증으로 사기를 방지합니다.
/// Edge Cases    : 필수 이미지나 위치 누락, `status` 불일치.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011  Marketplace 모듈.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 상품 정보(제목, 설명, 이미지, 가격, 카테고리, 위치, 신뢰등급, AI 검수 등) 포함
///   - Firestore와 1:1 대응, KPI/Analytics 필드(viewsCount, chatsCount, likesCount 등)
///
/// 2. 실제 코드 분석
///   - 위치 정보(locationParts), 신뢰등급, AI 검수 등 품질·운영 기능 반영
///   - KPI/Analytics, 광고/프로모션, 다국어(i18n) 등 실제 서비스 운영에 필요한 기능 반영
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·신뢰등급·AI 검수 등 품질·운영 기능 강화
///   - 기획에 못 미친 점: 채팅, 댓글, 찜, Opt-in/Opt-out 등 일부 상호작용 기능 미구현, AI 검수·활동 히스토리·광고 슬롯 등 추가 구현 필요
///
/// 4. 개선 제안
///   - 데이터 모델 확장(활동 히스토리, KPI/Analytics 필드 추가), Firestore 쿼리 최적화, 에러 핸들링 강화
library;
// 아래부터 실제 코드

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String userId;
  final String title; 
  final String description;
  final List<String> imageUrls;
  final String categoryId;
  final int price;
  final bool negotiable;

  // ✅ [통합] 신규 모델의 정교한 위치 정보 필드를 사용합니다.
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  // ✅ [통합] 구버전 모델의 상태 관리 필드를 가져옵니다.
  final String status; // 'selling', 'reserved', 'sold'
  final bool isAiVerified;
  final String condition; // 'new' or 'used'
  // ✅ [추가] 거래 희망 장소 필드를 추가합니다.
  final String? transactionPlace;

  // 카운트 필드
  final int likesCount;
  final int chatsCount;
  final int viewsCount;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.categoryId,
    required this.price,
    required this.negotiable,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.status = 'selling',
    this.isAiVerified = false,
    this.condition = 'used',
      // ✅ [추가] 생성자에 transactionPlace를 추가합니다.
    this.transactionPlace,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      categoryId: data['categoryId'] ?? '',
      price: data['price'] ?? 0,
      negotiable: data['negotiable'] ?? false,
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      status: data['status'] ?? 'selling',
      isAiVerified: data['isAiVerified'] ?? false,
      condition: data['condition'] ?? 'used',
      // ✅ [추가] Firestore에서 transactionPlace 필드를 가져옵니다.
      transactionPlace: data['transactionPlace'],
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'price': price,
      'negotiable': negotiable,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'status': status,
      'isAiVerified': isAiVerified,
      'condition': condition,
       // ✅ [추가] toJson 맵에 transactionPlace를 추가합니다.
      'transactionPlace': transactionPlace,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

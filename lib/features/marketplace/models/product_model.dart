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
/// ============================================================================///
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
///   - 거래 희망 장소 미니맵화
/// ============================================================================///
/// 2025년 8월 30일 : 공용위젯인 테그 위젯, 검색화 도입 및 이미지 갤러리 위젯 작업 진행
/// [V2.2 개편안 (Job 24-41) 주요 변경 사항]
/// 1. AI 인수 (V2.2):
///    - `buyerId`: 'AI 안심 예약'을 실행한 구매자의 UID를 저장합니다.
/// 2. 신뢰 정책 (개편안 1):
///    - `aiCancelCount`: AI 검수를 취소한 횟수 (1회 제한).
///    - `isAiFreeTierUsed`: 첫 무료 검수 기회 사용 여부.
///    - `aiReportSourceDescription`: AI 보고서 생성 당시의 원본 '설명' 스냅샷.
///    - `aiReportSourceImages`: AI 보고서 생성 당시의 원본 '이미지 URL' 스냅샷.
///    (위 4개 필드는 '유료 재검수' 및 '보고서 재사용' 로직에 사용됩니다.)
///
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
  // ✅ [추가] 태그 필드를 추가합니다.
  final List<String> tags;
  // ✅ [통합] 신규 모델의 정교한 위치 정보 필드를 사용합니다.
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  // ✅ [통합] 구버전 모델의 상태 관리 필드를 가져옵니다.
  final String status; // 'selling', 'reserved', 'sold'
  final String condition; // 'new' or 'used'
  final String? buyerId; // [AI 인수] 'reserved', 'sold' 상태일 때 구매자 ID
  // ✅ [추가] 거래 희망 장소 필드를 추가합니다.
  final String? transactionPlace;

  // [개편안 1] AI 검수 취소/재사용을 위한 신규 필드
  final int aiCancelCount; // AI 검수 취소 횟수
  final bool isAiFreeTierUsed; // 첫 무료 AI 검수 기회 사용 여부
  final String? aiReportSourceDescription; // AI 보고서 생성 당시의 설명
  final List<String>? aiReportSourceImages; // AI 보고서 생성 당시의 이미지 URL 목록

  final bool isAiVerified;
  final String
      aiVerificationStatus; // 'pending', 'approved', 'rejected', 'none'
  final Map<String, dynamic>? aiReport;
  // [추가] AI 검수 완료 상품을 위한 필드 (새 키 호환)
  final Map<String, dynamic>? aiVerificationData;
  final String? rejectionReason;

  // 카운트 필드
  final int likesCount;
  final int chatsCount;
  final int viewsCount;

  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? userUpdatedAt; // [Fix] '끌어올리기' 정렬 기준
  final bool isNew; // <-- 신품 여부 구분을 위한 필드 추가

  ProductModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.categoryId,
    required this.price,
    required this.negotiable,
    this.tags = const [],
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.status = 'selling',
    this.condition = 'used',
    this.buyerId,
    this.aiCancelCount = 0,
    this.isAiFreeTierUsed = false,
    this.aiReportSourceDescription,
    this.aiReportSourceImages,
    this.transactionPlace,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.userUpdatedAt, // [Fix]
    this.isAiVerified = false,
    this.aiVerificationStatus = 'none',
    this.aiReport,
    // [추가] 새 필드 추가
    this.aiVerificationData,
    this.rejectionReason,
    this.isNew = false,
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
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      status: data['status'] ?? 'selling',
      buyerId: data['buyerId'], // [AI 인수] buyerId 로드
      condition: data['condition'] ?? 'used',
      transactionPlace: data['transactionPlace'],

      // [개편안 1] 신규 필드 로드
      aiCancelCount: data['aiCancelCount'] ?? 0,
      isAiFreeTierUsed: data['isAiFreeTierUsed'] ?? false,
      aiReportSourceDescription: data['aiReportSourceDescription'],
      aiReportSourceImages: data['aiReportSourceImages'] != null
          ? List<String>.from(data['aiReportSourceImages'])
          : null,
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      // [Fix] userUpdatedAt이 없으면 createdAt으로 대체 (오래된 데이터 호환)
      userUpdatedAt:
          data['userUpdatedAt'] ?? data['createdAt'] ?? Timestamp.now(),
      // ✅ [핵심 수정] AI 관련 필드들을 안전하게 불러옵니다.
      isAiVerified: data['isAiVerified'] ?? false,
      aiVerificationStatus: data['aiVerificationStatus'] ?? 'none',
      aiReport: data['aiReport'] != null
          ? Map<String, dynamic>.from(data['aiReport'])
          : null,
      // [추가] 새 키(aiVerificationData)도 함께 로드, 없으면 aiReport로 폴백
      aiVerificationData: data['aiVerificationData'] != null
          ? Map<String, dynamic>.from(data['aiVerificationData'])
          : (data['aiReport'] != null
              ? Map<String, dynamic>.from(data['aiReport'])
              : null),
      rejectionReason: data['rejectionReason'],
      isNew: data['isNew'] ?? false,
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
      'tags': tags,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'status': status,
      'condition': condition,
      'buyerId': buyerId, // [AI 인수] buyerId 저장
      'aiCancelCount': aiCancelCount,
      'isAiFreeTierUsed': isAiFreeTierUsed,
      'aiReportSourceDescription': aiReportSourceDescription,
      'aiReportSourceImages': aiReportSourceImages,

      'transactionPlace': transactionPlace,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userUpdatedAt': userUpdatedAt, // [Fix]
      'isAiVerified': isAiVerified,
      'aiVerificationStatus': aiVerificationStatus,
      'aiReport': aiReport,
      // [추가] 새 필드 저장
      'aiVerificationData': aiVerificationData,
      'rejectionReason': rejectionReason,
      'isNew': isNew,
    };
  }

  ProductModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? imageUrls,
    String? categoryId,
    int? price,
    bool? negotiable,
    List<String>? tags,
    String? locationName,
    Map<String, dynamic>? locationParts,
    GeoPoint? geoPoint,
    String? status,
    String? condition,
    String? buyerId,
    int? aiCancelCount,
    bool? isAiFreeTierUsed,
    String? aiReportSourceDescription,
    List<String>? aiReportSourceImages,
    String? transactionPlace,
    int? likesCount,
    int? chatsCount,
    int? viewsCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? userUpdatedAt,
    bool? isAiVerified,
    String? aiVerificationStatus,
    Map<String, dynamic>? aiReport,
    // [추가]
    Map<String, dynamic>? aiVerificationData,
    String? rejectionReason,
  }) {
    return ProductModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      negotiable: negotiable ?? this.negotiable,
      tags: tags ?? this.tags,
      locationName: locationName ?? this.locationName,
      locationParts: locationParts ?? this.locationParts,
      geoPoint: geoPoint ?? this.geoPoint,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      buyerId: buyerId ?? this.buyerId,
      aiCancelCount: aiCancelCount ?? this.aiCancelCount,
      isAiFreeTierUsed: isAiFreeTierUsed ?? this.isAiFreeTierUsed,
      aiReportSourceDescription:
          aiReportSourceDescription ?? this.aiReportSourceDescription,
      aiReportSourceImages: aiReportSourceImages ?? this.aiReportSourceImages,
      transactionPlace: transactionPlace ?? this.transactionPlace,
      likesCount: likesCount ?? this.likesCount,
      chatsCount: chatsCount ?? this.chatsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userUpdatedAt: userUpdatedAt ?? this.userUpdatedAt, // [Fix]
      isAiVerified: isAiVerified ?? this.isAiVerified,
      aiVerificationStatus: aiVerificationStatus ?? this.aiVerificationStatus,
      aiReport: aiReport ?? this.aiReport,
      // [추가]
      aiVerificationData: aiVerificationData ?? this.aiVerificationData,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isNew: isNew,
    );
  }
}

// lib/features/jobs/models/talent_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================================
/// [Future Feature Plan: Talent Review System]
/// 재능 마켓의 신뢰도를 위한 후기 시스템 구현 계획 (TODO)
///
/// 1. 데이터 모델 (New Model): 'TalentReviewModel'
///    - id (String): 리뷰 ID
///    - talentId (String): 대상 재능 ID
///    - reviewerId (String): 작성자 ID (구매자)
///    - sellerId (String): 판매자 ID (판매자 평판 집계용)
///    - rating (double): 별점 (1.0 ~ 5.0)
///    - content (String): 후기 내용
// ignore: unintended_html_in_doc_comment
///    - images (List<String>): 후기 사진
///    - createdAt (Timestamp): 작성일
///
/// 2. Firestore 구조 (Sub-collection 권장)
///    - Path: /talents/{talentId}/reviews/{reviewId}
///    - 이유: 개별 재능에 종속된 데이터이며, 리뷰 수가 많아질 수 있음.
///
/// 3. 집계 로직 (Aggregation) - Cloud Functions 또는 트랜잭션 사용
///    - 리뷰 작성 시 -> 해당 'talents' 문서의 'rating'(평점 평균)과 'reviewsCount'(총 개수) 업데이트.
///    - 동시에 'users/{sellerId}'의 'talentStats' (판매자 전체 평점)도 업데이트 권장.
///
/// 4. UI/UX 흐름
///    - 채팅방에서 '거래 완료' 버튼 클릭 -> '후기 작성' 팝업 노출.
///    - TalentDetailScreen 하단에 '후기 목록(Review List)' 섹션 추가.
/// ============================================================================

/// 재능 마켓(Talent Market)의 게시글 데이터 모델
/// Firestore 컬렉션: 'talents'
class TalentModel {
  final String id;
  final String userId;
  final String title; // 예: "고등 수학 과외 해드립니다"
  final String description; // 상세 설명
  final String category; // 예: 'talent_tutoring', 'talent_design'
  final int price; // 가격
  final String
      priceUnit; // 단위: 'hourly'(시급), 'project'(건당), 'fixed'(고정), 'negotiable'(협의)
  final List<String> portfolioUrls; // 포트폴리오 이미지 리스트 (최대 10장 권장)

  // 위치 정보 (UserModel에서 상속받아 저장)
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  // 평판 관리
  final int reviewsCount;
  final double rating;

  // 상태 관리
  final bool isVisible; // 판매 중지/재개
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TalentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.priceUnit,
    required this.portfolioUrls,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.reviewsCount = 0,
    this.rating = 0.0,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서로부터 객체 생성 (Factory)
  factory TalentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TalentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'talent_other',
      price: data['price'] ?? 0,
      priceUnit: data['priceUnit'] ?? 'negotiable',
      portfolioUrls: data['portfolioUrls'] != null
          ? List<String>.from(data['portfolioUrls'])
          : [],
      locationName: data['locationName'],
      locationParts: data['locationParts'],
      geoPoint: data['geoPoint'],
      reviewsCount: data['reviewsCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      isVisible: data['isVisible'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Firestore 저장용 맵 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'priceUnit': priceUnit,
      'portfolioUrls': portfolioUrls,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'reviewsCount': reviewsCount,
      'rating': rating,
      'isVisible': isVisible,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 객체 복사 및 수정 (CopyWith)
  TalentModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    int? price,
    String? priceUnit,
    List<String>? portfolioUrls,
    String? locationName,
    Map<String, dynamic>? locationParts,
    GeoPoint? geoPoint,
    int? reviewsCount,
    double? rating,
    bool? isVisible,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TalentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      locationName: locationName ?? this.locationName,
      locationParts: locationParts ?? this.locationParts,
      geoPoint: geoPoint ?? this.geoPoint,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      rating: rating ?? this.rating,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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

import 'package:bling_app/core/models/bling_location.dart';
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
  final BlingLocation? lostLocation; // where item was lost
  final BlingLocation? foundLocation; // where item was found
  final List<String> imageUrls;
  final Timestamp createdAt;
  final bool isHunted; // 현상금(Hunted) 여부
  final num? bountyAmount; // ✅ [수정] int? -> num? (정수/실수 모두 허용)
  final List<String> tags; // ✅ [추가] 태그 목록

  // ✅ [작업 41] '해결 완료' 기능 추가
  final bool isResolved;
  final Timestamp? resolvedAt;

  // ✅ [작업 3] 해결 기여자 및 후기 필드 추가
  final String? resolverId; // 물건을 찾아주거나 돌려준 고마운 이웃의 ID
  final String? reviewText; // 미담 후기

  // ✅ [작업 42] 댓글 및 조회수 기능 추가
  final int viewsCount;
  final int commentsCount;

  // [추가] 검색용 역색인
  final List<String> searchIndex;

  LostItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemDescription,
    required this.locationDescription,
    this.locationParts,
    this.geoPoint,
    this.lostLocation,
    this.foundLocation,
    required this.imageUrls,
    required this.createdAt,
    this.isHunted = false,
    this.bountyAmount,
    this.tags = const [], // ✅ 생성자 추가

    // ✅ [작업 41]
    this.isResolved = false,
    this.resolvedAt,

    // ✅ [작업 3]
    this.resolverId,
    this.reviewText,

    // ✅ [작업 42]
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.searchIndex = const [],
  });

  // Compatibility getters: some UI code expects `.title` or `.body`.
  // Provide these as aliases to `itemDescription` to avoid NoSuchMethodError
  // when older call sites still reference those properties.
  String get title => itemDescription;
  String get body => itemDescription;

  factory LostItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final lostLocationMap = data['lostLocation'];
    final foundLocationMap = data['foundLocation'];
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
      lostLocation: (lostLocationMap is Map<String, dynamic>)
          ? BlingLocation.fromJson(lostLocationMap)
          : _fallbackLostLocationFromLegacy(data),
      foundLocation: (foundLocationMap is Map<String, dynamic>)
          ? BlingLocation.fromJson(foundLocationMap)
          : _fallbackFoundLocationFromLegacy(data),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isHunted: data['isHunted'] ?? false,
      bountyAmount: data['bountyAmount'],
      // ✅ Firestore 데이터로부터 tags 필드를 읽어옵니다.
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],

      // ✅ [작업 41]
      isResolved: data['isResolved'] ?? false,
      resolvedAt: data['resolvedAt'] as Timestamp?,
      // ✅ [작업 3]
      resolverId: data['resolverId'],
      reviewText: data['reviewText'],

      // ✅ [작업 42]
      viewsCount: data['viewsCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
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
      'lostLocation': lostLocation?.toJson(),
      'foundLocation': foundLocation?.toJson(),
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'bountyAmount': bountyAmount,
      'tags': tags, // ✅ Firestore에 저장

      // Legacy compatibility
      'lostPlace': locationDescription.isNotEmpty
          ? locationDescription
          : lostLocation?.shortLabel ?? lostLocation?.mainAddress,
      'foundPlace': foundLocation?.shortLabel ?? foundLocation?.mainAddress,

      // ✅ [작업 41]
      'isResolved': isResolved,
      'resolvedAt': resolvedAt,
      // ✅ [작업 3]
      'resolverId': resolverId,
      'reviewText': reviewText,

      // ✅ [작업 42]
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,

      // [수정] 'isHunted' 필드도 저장되도록 추가합니다.
      'isHunted': isHunted,
      'searchIndex': searchIndex,
    };
  }

  static BlingLocation? _fallbackLostLocationFromLegacy(
      Map<String, dynamic> data) {
    final geo = data['geoPoint'];
    final lostPlace = data['lostPlace'] ?? data['locationDescription'];
    if (geo is GeoPoint && lostPlace is String && lostPlace.isNotEmpty) {
      return BlingLocation(
        geoPoint: geo,
        mainAddress: lostPlace,
        shortLabel: lostPlace,
      );
    }
    return null;
  }

  static BlingLocation? _fallbackFoundLocationFromLegacy(
      Map<String, dynamic> data) {
    final foundPlace = data['foundPlace'];
    final foundGeo = data['foundGeoPoint'] ?? data['geoPoint'];
    if (foundGeo is GeoPoint && foundPlace is String && foundPlace.isNotEmpty) {
      return BlingLocation(
        geoPoint: foundGeo,
        mainAddress: foundPlace,
        shortLabel: foundPlace,
      );
    }
    return null;
  }
}

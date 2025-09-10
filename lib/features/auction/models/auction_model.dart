// lib/core/models/auction_model.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 경매 정보(제목, 설명, 이미지, 시작가, 현재가, 입찰내역, 위치, 신뢰등급, AI 검수 등) 포함
///   - Firestore와 1:1 대응, KPI/Analytics 필드(입찰내역, 시작/종료 시간 등)
///
/// 2. 실제 코드 분석
///   - 위치 정보(locationParts), 신뢰등급, AI 검수 등 품질·운영 기능 반영
///   - KPI/Analytics, 광고/프로모션, 다국어(i18n) 등 실제 서비스 운영에 필요한 기능 반영
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·신뢰등급·AI 검수 등 품질·운영 기능 강화
///   - 기획에 못 미친 점: 실시간 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, AI 검수·신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - 데이터 모델 확장(활동 히스토리, KPI/Analytics 필드 추가), Firestore 쿼리 최적화, 에러 핸들링 강화
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a local premium auction item.
class AuctionModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final int startPrice;
  final int currentBid;
  final List<Map<String, dynamic>> bidHistory;
  final String location;

  // V V V --- [추가] 지역 필터링을 위한 locationParts 필드 --- V V V
  final Map<String, dynamic>? locationParts;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  final GeoPoint? geoPoint;
  final Timestamp startAt;
  final Timestamp endAt;
  final String ownerId;
  final bool trustLevelVerified;
  final bool isAiVerified;
  // ✅ tags 필드를 추가합니다.
  final List<String> tags;

  AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.startPrice,
    required this.currentBid,
    required this.bidHistory,
    required this.location,
    this.locationParts, // [추가]
    this.geoPoint,
    required this.startAt,
    required this.endAt,
    required this.ownerId,
    this.trustLevelVerified = false,
    this.isAiVerified = false,
    this.tags = const [], // ✅ 생성자에 추가
  });

  factory AuctionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AuctionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      startPrice: data['startPrice'] ?? 0,
      currentBid: data['currentBid'] ?? 0,
      bidHistory: data['bidHistory'] != null
          ? List<Map<String, dynamic>>.from(data['bidHistory'])
          : [],
      location: data['location'] ?? '',
      // [추가] Firestore에서 locationParts 데이터를 불러옵니다.
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      startAt: data['startAt'] ?? Timestamp.now(),
      endAt: data['endAt'] ?? Timestamp.now(),
      ownerId: data['ownerId'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      isAiVerified: data['isAiVerified'] ?? false,
      // ✅ Firestore 데이터로부터 tags 필드를 읽어옵니다.
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'startPrice': startPrice,
      'currentBid': currentBid,
      'bidHistory': bidHistory,
      'location': location,
      'locationParts': locationParts, // [추가]
      'geoPoint': geoPoint,
      'startAt': startAt,
      'endAt': endAt,
      'ownerId': ownerId,
      'trustLevelVerified': trustLevelVerified,
      'isAiVerified': isAiVerified,
      'tags': tags, // ✅ JSON 변환 시 tags 필드를 포함합니다.
    };
  }
}

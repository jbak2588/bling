// lib/core/models/post_model.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 위치 기반 동네 소통 피드, 주소 표기는 Singkatan(Kel., Kec., Kab.) 사용
///   - 카테고리, 태그, 미디어, 신뢰등급 등 다양한 정보 포함
///
/// 2. 실제 코드 분석
///   - Firestore 'posts' 컬렉션과 1:1 대응, 위치 정보(locationName, locationParts, geoPoint), 카테고리, 태그, 미디어, 신뢰등급 등 포함
///   - 카테고리·위치·신뢰등급 기반 다양한 기능 확장 가능
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·카테고리·신뢰등급 등 다양한 확장성 확보
///   - 기획에 못 미친 점: AI 태그 추천, Marketplace 연동 등 일부 기능 미구현
///
/// 4. 개선 제안
///   - 데이터 모델 확장(활동 히스토리, KPI/Analytics 필드 추가), Firestore 쿼리 최적화, 에러 핸들링 강화
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 앱의 모든 게시물(Feed)에 대한 표준 데이터 모델 클래스입니다.
/// Firestore의 'posts' 컬렉션 문서 구조와 1:1로 대응됩니다.
class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String body;
  // ❌ [태그 시스템] category 필드 제거
  // final String category;
  // ✅ [태그 시스템] tags 필드 추가 (필수)
  final List<String> tags; // 태그 ID 목록 (최소 1개 이상)

  // final List<String> tags; // 해시태그 목록 -> 기존 tags 필드는 다른 용도였던 것으로 보이므로 주석 처리 또는 제거
  // ✅ [수정] mediaUrl의 타입을 List<String>? 로 변경하여 여러 이미지를 지원합니다.
  final List<String>? mediaUrl;
  final String? mediaType;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final Timestamp createdAt;
  final Timestamp? updatedAt; // ✅ [추가] 수정 시간을 위해 nullable로 추가
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final int thanksCount;

  // ✅ [태그 시스템] 가이드형 추가 필드 (옵션)
  final Timestamp? eventTime; // 특정 이벤트 시간 (예: 정전 시작 시간)
  final String? eventLocation; // 특정 이벤트 장소 (예: 특정 거리명)

  // [추가] 검색용 역색인
  final List<String> searchIndex;

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    required this.body,
    // ❌ [태그 시스템] category 제거
    // required this.category,
    // ✅ [태그 시스템] tags 추가
    required this.tags,
    this.mediaUrl, // ✅ 수정
    this.mediaType,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.createdAt,
    this.updatedAt, // ✅ 추가
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.thanksCount = 0,
    // ✅ 가이드형 필드 추가
    this.eventTime,
    this.eventLocation,
    this.searchIndex = const [],
  });

  /// Firestore 문서로부터 PostModel 객체를 생성합니다.
  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // ✅ [핵심 수정] mediaUrl 필드를 안전하게 처리하는 로직
    dynamic mediaUrlData = data['mediaUrl'];
    List<String>? mediaUrls;
    if (mediaUrlData is List) {
      mediaUrls = List<String>.from(mediaUrlData);
    } else if (mediaUrlData is String) {
      mediaUrls = [mediaUrlData]; // 단일 String이면 List로 감싸줍니다.
    }

    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'],
      body: data['body'] ?? '',
      // ❌ [태그 시스템] category 로드 제거
      // category: data['category'] ?? 'etc',
      // ✅ [태그 시스템] tags 로드 (null 이거나 List가 아니면 빈 리스트 반환)
      tags: (data['tags'] is List) ? List<String>.from(data['tags']) : [],
      mediaUrl: mediaUrls, // ✅ 수정된 변수를 사용
      mediaType: data['mediaType'],
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'], // ✅ 추가
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      thanksCount: data['thanksCount'] ?? 0,
      // ✅ 가이드형 필드 로드
      eventTime: data['eventTime'] as Timestamp?,
      eventLocation: data['eventLocation'] as String?,
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
    );
  }

  /// PostModel 객체를 Firestore에 저장하기 위한 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      // ❌ [태그 시스템] category 저장 제거
      // 'category': category,
      // ✅ [태그 시스템] tags 저장
      'tags': tags,
      'mediaUrl': mediaUrl, // ✅ 수정
      'mediaType': mediaType,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'createdAt': createdAt, // 최초 생성 시에는 FieldValue.serverTimestamp() 사용 권장
      'updatedAt': updatedAt, // ✅ 추가
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'thanksCount': thanksCount,
      // ✅ 가이드형 필드 저장 (null이 아닐 경우)
      if (eventTime != null) 'eventTime': eventTime,
      if (eventLocation != null) 'eventLocation': eventLocation,
      'searchIndex': searchIndex,
    };
  }
}

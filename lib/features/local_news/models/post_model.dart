// lib/core/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 앱의 모든 게시물(Feed)에 대한 표준 데이터 모델 클래스입니다.
/// Firestore의 'posts' 컬렉션 문서 구조와 1:1로 대응됩니다.
class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String body;
  final String category;
  final List<String> tags;
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

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    required this.body,
    required this.category,
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
      category: data['category'] ?? 'etc',
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
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
    );
  }

  /// PostModel 객체를 Firestore에 저장하기 위한 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'category': category,
      'tags': tags,
      'mediaUrl': mediaUrl, // ✅ 수정
      'mediaType': mediaType,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'createdAt': createdAt,
      'updatedAt': updatedAt, // ✅ 추가
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'thanksCount': thanksCount,
    };
  }
}

// lib/core/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 앱의 모든 게시물(Feed)에 대한 표준 데이터 모델 클래스입니다.
/// Firestore의 'posts' 컬렉션 문서 구조와 1:1로 대응됩니다.
class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String body;
  final String category; // 'daily_question', 'help_share' 등 고정 카테고리
  final List<String> tags; // '#강아지', '#무료나눔' 등 자유 태그
  final String? mediaUrl;
  final String? mediaType; // 'image' or 'video'
  final String? locationName; // 'Kel. Panunggangan, Kec. Cibodas' 등 전체 주소
  final Map<String, dynamic>? locationParts; // { 'kab': 'Kab. Tangerang', ... }
  final GeoPoint? geoPoint;
  final Timestamp createdAt;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    required this.body,
    required this.category,
    required this.tags,
    this.mediaUrl,
    this.mediaType,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
  });

  /// Firestore 문서로부터 PostModel 객체를 생성합니다.
  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'],
      body: data['body'] ?? '',
      category: data['category'] ?? 'etc',
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      mediaUrl: data['mediaUrl'],
      mediaType: data['mediaType'],
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
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
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
    };
  }
}

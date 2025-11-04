// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 데이터 모델. Firestore shorts 컬렉션 구조와 1:1 매칭, AI 인증, 신뢰 등급, 태그, 좋아요/댓글/조회수 등 다양한 필드 지원.
// [V2 - 2025-11-03 개선]
// - 기획서(백서)의 '뽐' 컨셉에 맞춰 'Shorts'에서 'Pom'으로 리네이밍.
// - 'videoUrl' 중심에서 사진(image)과 비디오(video)를 모두 지원하는 '멀티 콘텐츠' 모델로 변경.
// - mediaType (enum), mediaUrls (List<String>) 추가.
// =====================================================
// - '뽐' (Pom) 콘텐츠의 데이터 모델. Firestore 'pom' 컬렉션과 매칭.
// [V2 - 2025-11-03]
// - 'shorts'에서 'pom'으로 리네이밍.
// - 'videoUrl'(단일 비디오)에서 'mediaType'(enum), 'mediaUrls'(List<String>) (사진/비디오 멀티콘텐츠)로 변경.
// - 'videoUrl' 하위 호환성 지원 (데이터 마이그레이션용).
// [V3 - 2025-11-04]
// - 'searchIndex' (List<String>) 필드를 toJson에 추가하여 서버사이드 검색 지원.
// =====================================================

// lib/features/pom/models/pom_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum to define the media type of the Pom content.
enum PomMediaType {
  image,
  video,
}

/// Helper to convert String to PomMediaType and vice-versa for Firestore.
PomMediaType _mediaTypeFromString(String? type) {
  switch (type) {
    case 'video':
      return PomMediaType.video;
    case 'image':
    default:
      return PomMediaType.image;
  }
}

String _mediaTypeToString(PomMediaType type) {
  return type.toString().split('.').last;
}

/// Model representing a "Pom" (Piece of Moment) content,
/// which can be an image album or a short video.
class PomModel {
  final String id;
  final String userId;
  final String title;

  // --- [V2 개선] ---
  final PomMediaType mediaType; // 'image' or 'video'
  final List<String> mediaUrls; // List of image URLs or a single video URL
  final String thumbnailUrl; // First image or video thumbnail
  // --- [V2 개선 끝] ---

  final String description;
  final String? location;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? tags;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final bool trustLevelVerified;
  final bool isAiVerified;
  final Timestamp createdAt;

  PomModel({
    required this.id,
    required this.userId,
    required this.title,

    // --- [V2 개선] ---
    required this.mediaType,
    required this.mediaUrls,
    required this.thumbnailUrl,
    // --- [V2 개선 끝] ---

    required this.description,
    this.location,
    this.locationParts,
    this.geoPoint,
    this.tags,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.trustLevelVerified = false,
    this.isAiVerified = false,
    required this.createdAt,
  });

  factory PomModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // --- [V2 개선] ---
    // Handle new multi-content data (V2). Legacy 'videoUrl' fallback removed.
    final mediaType = _mediaTypeFromString(data['mediaType']);
    List<String> mediaUrls = [];
    String thumbnailUrl = data['thumbnailUrl'] ?? '';

    if (data['mediaUrls'] != null) {
      // New V2 format
      mediaUrls = List<String>.from(data['mediaUrls']);
    }

    if (thumbnailUrl.isEmpty &&
        mediaType == PomMediaType.image &&
        mediaUrls.isNotEmpty) {
      thumbnailUrl = mediaUrls.first;
    }
    // --- [V2 개선 끝] ---

    return PomModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',

      // --- [V2 개선] ---
      mediaType: mediaType,
      mediaUrls: mediaUrls,
      thumbnailUrl: thumbnailUrl,
      // --- [V2 개선 끝] ---

      description: data['description'] ?? '',
      location: data['location'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      likesCount: data['likesCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      isAiVerified: data['isAiVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,

      // --- [V2 개선] ---
      'mediaType': _mediaTypeToString(mediaType),
      'mediaUrls': mediaUrls,
      'thumbnailUrl': thumbnailUrl,
      // --- [V2 개선 끝] ---

      'description': description,
      'location': location,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'tags': tags,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
      'trustLevelVerified': trustLevelVerified,
      'isAiVerified': isAiVerified,
      'createdAt': createdAt,
    };
  }
}

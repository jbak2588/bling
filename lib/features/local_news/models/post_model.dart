// lib/features/local_news/models/post_model.dart
/// PostModel for local news feed (refactored)
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// PostModel represents a post in the local news feed.
/// Refactor notes:
/// - Removed legacy fields: `searchIndex`, `eventTime`, `eventLocation` (String), `eventLocationGeo`.
/// - Standardized event fields to: `eventDate` (DateTime?) and `eventAddress` (String?).
class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String body;
  final String category;
  final List<String> tags;
  final List<String>? mediaUrl;
  final String? mediaType;

  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  final Timestamp createdAt;
  final Timestamp? updatedAt;

  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final int thanksCount;

  // Event-related standardized fields
  final DateTime? eventDate; // 행사 날짜/시간
  final String? eventAddress; // 행사 장소명 (예: 마을회관)

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    required this.body,
    required this.category,
    this.tags = const [],
    this.mediaUrl,
    this.mediaType,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.thanksCount = 0,
    this.eventDate,
    this.eventAddress,
  });

  /// Create PostModel from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // mediaUrl: support List<String> or single String
    dynamic mediaUrlData = data['mediaUrl'];
    List<String>? mediaUrls;
    if (mediaUrlData is List) {
      mediaUrls = List<String>.from(mediaUrlData.map((e) => e.toString()));
    } else if (mediaUrlData is String) {
      mediaUrls = [mediaUrlData];
    }

    // Parse eventDate: Timestamp | String | DateTime
    DateTime? parsedEventDate;
    final rawEvent = data['eventDate'];
    if (rawEvent is Timestamp) {
      parsedEventDate = rawEvent.toDate();
    } else if (rawEvent is DateTime) {
      parsedEventDate = rawEvent;
    } else if (rawEvent is String) {
      try {
        parsedEventDate = DateTime.parse(rawEvent);
      } catch (_) {
        parsedEventDate = null;
      }
    }

    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] as String?,
      body: data['body'] ?? '',
      category: data['category'] ?? 'daily_life',
      tags: (data['tags'] is List) ? List<String>.from(data['tags']) : [],
      mediaUrl: mediaUrls,
      mediaType: data['mediaType'] as String?,
      locationName: data['locationName'] as String?,
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'] as Map)
          : null,
      geoPoint: data['geoPoint'] as GeoPoint?,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp?,
      likesCount: (data['likesCount'] is int)
          ? data['likesCount'] as int
          : (data['likesCount'] is num
              ? (data['likesCount'] as num).toInt()
              : 0),
      commentsCount: (data['commentsCount'] is int)
          ? data['commentsCount'] as int
          : (data['commentsCount'] is num
              ? (data['commentsCount'] as num).toInt()
              : 0),
      viewsCount: (data['viewsCount'] is int)
          ? data['viewsCount'] as int
          : (data['viewsCount'] is num
              ? (data['viewsCount'] as num).toInt()
              : 0),
      thanksCount: (data['thanksCount'] is int)
          ? data['thanksCount'] as int
          : (data['thanksCount'] is num
              ? (data['thanksCount'] as num).toInt()
              : 0),
      eventDate: parsedEventDate,
      eventAddress: data['eventAddress'] as String?,
    );
  }

  /// Convert to Map for Firestore (toJson / toMap)
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
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
      if (updatedAt != null) 'updatedAt': updatedAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'viewsCount': viewsCount,
      'thanksCount': thanksCount,
    };

    if (eventDate != null) {
      map['eventDate'] = Timestamp.fromDate(eventDate!);
    }
    if (eventAddress != null && eventAddress!.isNotEmpty) {
      map['eventAddress'] = eventAddress;
    }

    return map;
  }

  /// copyWith helper
  PostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? category,
    List<String>? tags,
    List<String>? mediaUrl,
    String? mediaType,
    String? locationName,
    Map<String, dynamic>? locationParts,
    GeoPoint? geoPoint,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    int? thanksCount,
    DateTime? eventDate,
    String? eventAddress,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      tags: tags ?? List<String>.from(this.tags),
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      locationName: locationName ?? this.locationName,
      locationParts: locationParts ?? this.locationParts,
      geoPoint: geoPoint ?? this.geoPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      thanksCount: thanksCount ?? this.thanksCount,
      eventDate: eventDate ?? this.eventDate,
      eventAddress: eventAddress ?? this.eventAddress,
    );
  }
}

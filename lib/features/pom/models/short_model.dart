// lib/core/models/short_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a short video uploaded to the POM (Piece of Moment)
/// short-video hub.
class ShortModel {
  final String id;
  final String userId;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String? location;
  final GeoPoint? geoPoint;
  final List<String>? tags;
  final int likesCount;
  final int viewsCount;
  final int commentsCount;
  final bool trustLevelVerified;
  final bool isAiVerified;
  final Timestamp createdAt;


  ShortModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    this.location,
    this.geoPoint,
    this.tags,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.trustLevelVerified = false,
    this.isAiVerified = false,
    required this.createdAt,
  });

  factory ShortModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShortModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      description: data['description'] ?? '',
      location: data['location'],
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
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'location': location,
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


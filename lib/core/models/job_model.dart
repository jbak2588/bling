// lib/core/models/job_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 지역 구인구직 게시글 정보를 담는 데이터 모델입니다.
/// Firestore의 `jobs` 컬렉션 문서 구조와 1:1로 대응됩니다.
class JobModel {
  final String id;
  final String userId; // 작성자 ID
  final String title;
  final String description;
  final String category; // 직종/업종
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final Timestamp createdAt;
  final String trustLevelRequired; // 요구되는 최소 신뢰 등급
  final int viewsCount;
  final int likesCount;
  final bool isPaidListing; // 유료 공고 여부

  JobModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.createdAt,
    this.trustLevelRequired = 'normal',
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isPaidListing = false,
  });

  factory JobModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'etc',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null ? Map<String, dynamic>.from(data['locationParts']) : null,
      geoPoint: data['geoPoint'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      isPaidListing: data['isPaidListing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'createdAt': createdAt,
      'trustLevelRequired': trustLevelRequired,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'isPaidListing': isPaidListing,
    };
  }
}
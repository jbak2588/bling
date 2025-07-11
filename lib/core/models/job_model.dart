// lib/core/models/job_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Job listing data model mapped to the Firestore `jobs` collection.
class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? location;
  final GeoPoint? geoPoint;
  final Timestamp createdAt;
  final String userId;
  final String trustLevelRequired;
  final int viewsCount;
  final int likesCount;
  final bool isPaidListing;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.location,
    this.geoPoint,
    required this.createdAt,
    required this.userId,
    required this.trustLevelRequired,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isPaidListing = false,
  });

  factory JobModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'],
      geoPoint: data['geoPoint'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      isPaidListing: data['isPaidListing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'geoPoint': geoPoint,
      'createdAt': createdAt,
      'userId': userId,
      'trustLevelRequired': trustLevelRequired,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'isPaidListing': isPaidListing,
    };
  }
}

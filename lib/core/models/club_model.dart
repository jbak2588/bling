// lib/core/models/club_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a local community club where neighbors gather around
/// common interests. Each document in the `clubs` collection maps
/// to one instance of this model.
class ClubModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String location;
  final List<String> interests;
  final int membersCount;
  final bool isPrivate;
  final String trustLevelRequired;
  final Timestamp createdAt;

  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.location,
    required this.interests,
    this.membersCount = 0,
    this.isPrivate = false,
    this.trustLevelRequired = 'normal',
    required this.createdAt,
  });

  factory ClubModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      interests:
          data['interests'] != null ? List<String>.from(data['interests']) : [],
      membersCount: data['membersCount'] ?? 0,
      isPrivate: data['isPrivate'] ?? false,
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'location': location,
      'interests': interests,
      'membersCount': membersCount,
      'isPrivate': isPrivate,
      'trustLevelRequired': trustLevelRequired,
      'createdAt': createdAt,
    };
  }
}

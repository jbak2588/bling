// lib/core/models/lost_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for lost and found posts with optional bounty.
class LostItemModel {
  final String id;
  final String type;
  final String title;
  final Timestamp date;
  final String locationDescription;
  final String description;
  final String? photoUrl;
  final String contactInfo;
  final int? reward;
  final Timestamp expiresAt;
  final Timestamp createdAt;
  final String userId;

  LostItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.locationDescription,
    required this.description,
    this.photoUrl,
    required this.contactInfo,
    this.reward,
    required this.expiresAt,
    required this.createdAt,
    required this.userId,
  });

  factory LostItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LostItemModel(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      locationDescription: data['locationDescription'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      contactInfo: data['contactInfo'] ?? '',
      reward: data['reward'],
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'date': date,
      'locationDescription': locationDescription,
      'description': description,
      'photoUrl': photoUrl,
      'contactInfo': contactInfo,
      'reward': reward,
      'expiresAt': expiresAt,
      'createdAt': createdAt,
      'userId': userId,
    };
  }
}

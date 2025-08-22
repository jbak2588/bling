// lib/core/models/club_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String location;
  final Map<String, dynamic>? locationParts;
  final String mainCategory;
  final List<String> interestTags;
  final int membersCount;
  final bool isPrivate;
  final String trustLevelRequired;
  final Timestamp createdAt;
  final List<String>? kickedMembers;
  final List<String>? pendingMembers;

  // V V V --- [추가] 동호회 대표 이미지 URL 필드 --- V V V
  final String? imageUrl;


  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.location,
    this.locationParts,
    required this.mainCategory,
    required this.interestTags,
    this.membersCount = 0,
    this.isPrivate = false,
    this.trustLevelRequired = 'normal',
    required this.createdAt,
    this.kickedMembers,
    this.pendingMembers,
    this.imageUrl, // [추가] 생성자에 추가
  });

  factory ClubModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      mainCategory: data['mainCategory'] ?? '',
      interestTags: data['interestTags'] != null
          ? List<String>.from(data['interestTags'])
          : [],
      membersCount: data['membersCount'] ?? 0,
      isPrivate: data['isPrivate'] ?? false,
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      kickedMembers: data['kickedMembers'] != null
          ? List<String>.from(data['kickedMembers'])
          : [],
      pendingMembers: data['pendingMembers'] != null
          ? List<String>.from(data['pendingMembers'])
          : [],
      imageUrl: data['imageUrl'], // [추가] Firestore에서 이미지 URL 불러오기
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'location': location,
      'locationParts': locationParts,
      'mainCategory': mainCategory,
      'interestTags': interestTags,
      'membersCount': membersCount,
      'isPrivate': isPrivate,
      'trustLevelRequired': trustLevelRequired,
      'createdAt': createdAt,
      'kickedMembers': kickedMembers,
      'pendingMembers': pendingMembers,
      'imageUrl': imageUrl, // [추가] Firestore에 이미지 URL 저장
    };
  }
}

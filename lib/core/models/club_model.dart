// lib/core/models/club_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String location;
  final String mainCategory;
  final List<String> interestTags;
  final int membersCount;
  final bool isPrivate;
  final String trustLevelRequired;
  final Timestamp createdAt;

  // V V V --- [추가] 강퇴자 및 가입 대기자 목록 필드 --- V V V
  final List<String>? kickedMembers;
  final List<String>? pendingMembers;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  ClubModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.location,
    required this.mainCategory,
    required this.interestTags,
    this.membersCount = 0,
    this.isPrivate = false,
    this.trustLevelRequired = 'normal',
    required this.createdAt,
    // [추가] 생성자에 새로운 필드 추가
    this.kickedMembers,
    this.pendingMembers,
  });

  factory ClubModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      mainCategory: data['mainCategory'] ?? '',
      interestTags: data['interestTags'] != null ? List<String>.from(data['interestTags']) : [],
      membersCount: data['membersCount'] ?? 0,
      isPrivate: data['isPrivate'] ?? false,
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      // [추가] Firestore에서 새로운 필드를 불러오는 로직
      kickedMembers: data['kickedMembers'] != null ? List<String>.from(data['kickedMembers']) : [],
      pendingMembers: data['pendingMembers'] != null ? List<String>.from(data['pendingMembers']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'location': location,
      'mainCategory': mainCategory,
      'interestTags': interestTags,
      'membersCount': membersCount,
      'isPrivate': isPrivate,
      'trustLevelRequired': trustLevelRequired,
      'createdAt': createdAt,
      // [추가] Firestore에 새로운 필드를 저장하는 로직
      'kickedMembers': kickedMembers,
      'pendingMembers': pendingMembers,
    };
  }
}
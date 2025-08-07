// lib/core/models/club_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String location;
  
  // V V V --- [수정] 관심사 필드를 두 개로 분리합니다 --- V V V
  final String mainCategory; // 대표 관심사 (예: 'category_sports')
  final List<String> interestTags; // 세부 관심사 태그 목록 (예: ['soccer', 'hiking'])
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

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
    required this.mainCategory, // [수정] 생성자에 추가
    required this.interestTags, // [수정] 생성자에 추가 (이전 interests -> interestTags)
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
      // [수정] 새로운 필드에 맞게 데이터를 불러옵니다.
      mainCategory: data['mainCategory'] ?? '', 
      interestTags: data['interestTags'] != null ? List<String>.from(data['interestTags']) : [],
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
      // [수정] 새로운 필드에 맞게 데이터를 저장합니다.
      'mainCategory': mainCategory,
      'interestTags': interestTags,
      'membersCount': membersCount,
      'isPrivate': isPrivate,
      'trustLevelRequired': trustLevelRequired,
      'createdAt': createdAt,
    };
  }
}
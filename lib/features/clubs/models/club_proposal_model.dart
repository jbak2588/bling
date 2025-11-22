// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) 기획서 6.1 '모임 제안' 기능 구현을 위해 신규 생성.
// 2. '/club_proposals' 컬렉션의 데이터 모델.
// 3. 'targetMemberCount': 모임 제안자가 설정하는 목표 인원.
// 4. 'currentMemberCount', 'memberIds': 현재 참여 인원 및 ID 목록.
// 5. 이 모델은 목표 인원 도달 시 'ClubModel'로 자동 전환됩니다.
// =====================================================
// lib/features/clubs/models/club_proposal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 기획서 6.1의 '모임 제안' (/group_proposals)을 위한 데이터 모델입니다.
/// 목표 인원 도달 시 이 정보는 'ClubModel'로 변환됩니다.
class ClubProposalModel {
  final String id;
  final String title;
  final String description;
  final String ownerId; // 제안자
  final String location;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final String mainCategory;
  final List<String> interestTags;
  final String imageUrl;
  final Timestamp createdAt;

  final int targetMemberCount; // [핵심] 목표 인원
  final int currentMemberCount; // [핵심] 현재 참여 인원
  final List<String> memberIds; // [핵심] 현재 참여자 ID 목록
  // 검색용 역색인
  final List<String> searchIndex;

  ClubProposalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.location,
    this.locationParts,
    this.geoPoint,
    required this.mainCategory,
    required this.interestTags,
    required this.imageUrl,
    required this.createdAt,
    required this.targetMemberCount,
    this.currentMemberCount = 1, // 제안자 1명 포함 시작
    required this.memberIds,
    this.searchIndex = const [],
  });

  factory ClubProposalModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClubProposalModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      mainCategory: data['mainCategory'] ?? 'etc',
      interestTags: data['interestTags'] != null
          ? List<String>.from(data['interestTags'])
          : [],
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      targetMemberCount: data['targetMemberCount'] ?? 5, // 기본 목표 5명
      currentMemberCount: data['currentMemberCount'] ?? 1,
      memberIds: data['memberIds'] != null
          ? List<String>.from(data['memberIds'])
          : [data['ownerId']], // 최소한 제안자는 포함
      searchIndex: data['searchIndex'] != null
          ? List<String>.from(data['searchIndex'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'location': location,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'mainCategory': mainCategory,
      'interestTags': interestTags,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'targetMemberCount': targetMemberCount,
      'currentMemberCount': currentMemberCount,
      'memberIds': memberIds,
      'searchIndex': searchIndex,
    };
  }
}

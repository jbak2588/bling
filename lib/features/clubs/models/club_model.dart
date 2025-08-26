// lib/core/models/club_model.dart
<<<<<<< HEAD
     // ===================== DocHeader =====================
=======
      // ===================== DocHeader =====================
>>>>>>> 039b98320b865c27dc8be3d24e8ba31540ea21af
      // [기획 요약]
      // - Firestore 동호회 모델은 제목, 설명, 운영자, 위치, 관심사, 비공개 여부, 신뢰 등급, 멤버 관리, 생성일 등의 필드를 포함합니다.
      // - 위치, 관심사, 연령, 신뢰 등급을 활용한 고급 매칭 및 추천을 지원합니다.
      //
      // [구현 요약]
      // - Dart 모델은 Firestore 구조와 동일하게 id, title, description, ownerId, location, locationParts, mainCategory, interestTags, membersCount, isPrivate, trustLevelRequired, createdAt, kickedMembers, pendingMembers, imageUrl을 포함합니다.
      // - 동호회 생성, 표시, 멤버 관리에 사용됩니다.
      //
      // [차이점 및 부족한 부분]
      // - 매칭 로직과 통계 기능은 모델에 직접 구현되어 있지 않습니다.
      // - 운영자 기능과 고급 비공개 설정이 부족합니다.
      //
      // [개선 제안]
      // - 통계, 운영자 상태, 고급 비공개 옵션 필드 추가.
      // - 더 세분화된 신뢰 등급 및 멤버 역할 지원 고려.
      // =====================================================
<<<<<<< HEAD
      
=======

>>>>>>> 039b98320b865c27dc8be3d24e8ba31540ea21af
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

// lib/features/find_friends/models/friend_post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// Class         : FriendPostModel
/// Purpose       : "오늘 커피 마실 분?" 등 가벼운 만남/대화 제안을 위한 게시글 모델
/// User Impact   : 외모 중심의 매칭에서 벗어나 공통 관심사/활동 기반의 연결 제공
/// ============================================================================
class FriendPostModel {
  final String id;
  final String authorId;
  final String authorNickname;
  final String? authorPhotoUrl;
  final String content; // "오늘 저녁 7시 센트럴파크 러닝하실 분?"
  final List<String> tags; // ["#운동", "#러닝", "#초보환영"]
  final Timestamp createdAt;
  final Timestamp expiresAt; // 게시글 자동 만료 시간 (예: 24시간 후)

  // 위치 정보 (작성 당시 위치 기준)
  final String? locationName;
  final Map<String, dynamic>? locationParts;

  // 채팅 설정
  final bool isMultiChat; // true: 그룹 채팅(여러 명), false: 1:1 채팅
  final int maxParticipants; // 최대 참여 인원 (멀티 채팅인 경우)
  final List<String> currentParticipantIds; // 현재 참여 확정된 인원
  // [New] 승인 대기 중인 유저 ID 목록
  final List<String> waitingParticipantIds;

  FriendPostModel({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    this.authorPhotoUrl,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.expiresAt,
    this.locationName,
    this.locationParts,
    this.isMultiChat = false,
    this.maxParticipants = 2,
    this.currentParticipantIds = const [],
    this.waitingParticipantIds = const [],
  });

  factory FriendPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendPostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorNickname: data['authorNickname'] ?? 'Unknown',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
      locationName: data['locationName'],
      locationParts: data['locationParts'],
      isMultiChat: data['isMultiChat'] ?? false,
      maxParticipants: data['maxParticipants'] ?? 2,
      currentParticipantIds:
          List<String>.from(data['currentParticipantIds'] ?? []),
      // [New] Firestore에서 로드
      waitingParticipantIds:
          List<String>.from(data['waitingParticipantIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'authorNickname': authorNickname,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'tags': tags,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'locationName': locationName,
      'locationParts': locationParts,
      'isMultiChat': isMultiChat,
      'maxParticipants': maxParticipants,
      'currentParticipantIds': currentParticipantIds,
      // [New] Firestore에 저장
      'waitingParticipantIds': waitingParticipantIds,
    };
  }
}

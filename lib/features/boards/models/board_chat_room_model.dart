// lib/features/boards/models/board_chat_room_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// 동네 게시판 그룹 채팅방 모델
class BoardChatRoomModel {
  final String id; // kel_key와 동일
  final String roomType; // "kelurahan"
  final int memberCount;
  final Timestamp lastMessageAt;
  final ChatModeration moderation;
  final List<String> pinnedPosts;

  BoardChatRoomModel({
    required this.id,
    this.roomType = 'kelurahan',
    this.memberCount = 0,
    required this.lastMessageAt,
    required this.moderation,
    this.pinnedPosts = const [],
  });

  factory BoardChatRoomModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BoardChatRoomModel(
      id: doc.id,
      roomType: data['roomType'] ?? 'kelurahan',
      memberCount: data['memberCount'] ?? 0,
      lastMessageAt: data['lastMessageAt'] ?? Timestamp.now(),
      moderation: ChatModeration.fromMap(data['moderation'] ?? {}),
      pinnedPosts: (data['pinnedPosts'] is List)
          ? List<String>.from(data['pinnedPosts'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomType': roomType,
      'memberCount': memberCount,
      'lastMessageAt': lastMessageAt,
      'moderation': moderation.toMap(),
      'pinnedPosts': pinnedPosts,
    };
  }
}

/// 채팅방 운영 설정 (moderation 필드)
class ChatModeration {
  final int slowModeSec;
  final bool badWords;

  ChatModeration({
    this.slowModeSec = 0,
    this.badWords = true,
  });

  factory ChatModeration.fromMap(Map<String, dynamic> map) {
    return ChatModeration(
      slowModeSec: map['slowModeSec'] ?? 0,
      badWords: map['badWords'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slowModeSec': slowModeSec,
      'badWords': badWords,
    };
  }
}

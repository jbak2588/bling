// lib/core/models/chat_room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final Map<String, int> unreadCounts;

  // V V V --- [수정] 채팅 유형을 구분하기 위한 필드 추가 --- V V V
  final bool isGroupChat;
  final String? groupName;
  final String? groupImage;
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  // [수정] 상품 정보는 nullable로 변경
  final String? productId;
  final String? productTitle;
  final String? productImage;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCounts,
    this.isGroupChat = false, // 기본값은 1:1 채팅
    this.groupName,
    this.groupImage,
    this.productId,
    this.productTitle,
    this.productImage,
  });

  factory ChatRoomModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastTimestamp: data['lastTimestamp'] ?? Timestamp.now(),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      isGroupChat: data['isGroupChat'] ?? false,
      groupName: data['groupName'],
      groupImage: data['groupImage'],
      productId: data['productId'],
      productTitle: data['productTitle'],
      productImage: data['productImage'],
    );
  }
}
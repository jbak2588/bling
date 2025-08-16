// lib/core/models/chat_room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final Map<String, int> unreadCounts;

  // --- 채팅 유형을 구분하기 위한 필드들 ---
  final bool isGroupChat;
  final String? groupName;
  final String? groupImage;

  final String? productId;
  final String? productTitle;
  final String? productImage;

  final String? jobId;
  final String? jobTitle;

// V V V --- [추가] 지역 상점 관련 필드 --- V V V
  final String? shopId;
  final String? shopName;
  final String? shopImage;

  final String? lostItemId;
  final String? contextType;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCounts,
    this.isGroupChat = false,
    this.groupName,
    this.groupImage,
    this.productId,
    this.productTitle,
    this.productImage,
    this.jobId,
    this.jobTitle,
    this.shopId, // [추가]
    this.shopName, // [추가]
    this.shopImage, // [추가]

    this.lostItemId,
    this.contextType, // [추가]
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
      jobId: data['jobId'],
      jobTitle: data['jobTitle'],
      shopId: data['shopId'],
      shopName: data['shopName'],
      shopImage: data['shopImage'],
      lostItemId: data['lostItemId'],
      contextType: data['contextType'], // [추가]
    );
  }
}

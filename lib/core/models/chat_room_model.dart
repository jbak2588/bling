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
  final String? jobImage;

// V V V --- [추가] 지역 상점 관련 필드 --- V V V
  final String? shopId;
  final String? shopName;
  final String? shopImage;

  final String? lostItemId;
  final String? contextType;

  // V V V --- [추가] 부동산 매물 관련 필드 --- V V V
  final String? roomId;
  final String? roomTitle;
  final String? roomImage;

  // [추가] 재능 마켓 관련 필드
  final String? talentId;
  final String? talentTitle;
  final String? talentImage;

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
    this.jobImage,
    this.shopId, // [추가]
    this.shopName, // [추가]
    this.shopImage, // [추가]

    this.lostItemId,
    this.contextType, // [추가]

    this.roomId, // [추가]
    this.roomTitle, // [추가]
    this.roomImage, // [추가]
    this.talentId, // [추가]
    this.talentTitle, // [추가]
    this.talentImage, // [추가]
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
      jobImage: data['jobImage'],
      shopId: data['shopId'],
      shopName: data['shopName'],
      shopImage: data['shopImage'],
      lostItemId: data['lostItemId'],
      contextType: data['contextType'], // [추가]
      // [추가] Firestore에서 부동산 정보 불러오기
      roomId: data['roomId'],
      roomTitle: data['roomTitle'],
      roomImage: data['roomImage'],
      // [추가] Firestore에서 재능 마켓 관련 정보 불러오기
      talentId: data['talentId'],
      talentTitle: data['talentTitle'],
      talentImage: data['talentImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
      'unreadCounts': unreadCounts,
      'isGroupChat': isGroupChat,
      'groupName': groupName,
      'groupImage': groupImage,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobImage': jobImage,
      'shopId': shopId,
      'shopName': shopName,
      'shopImage': shopImage,
      'lostItemId': lostItemId,
      'contextType': contextType,
      'roomId': roomId,
      'roomTitle': roomTitle,
      'roomImage': roomImage,
      'talentId': talentId,
      'talentTitle': talentTitle,
      'talentImage': talentImage,
    };
  }
}

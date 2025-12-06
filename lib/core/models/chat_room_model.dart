// lib/core/models/chat_room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final Map<String, int> unreadCounts;

  final bool isGroupChat;
  final String? groupName;
  final String? groupImage;

  final String? productId;
  final String? productTitle;
  final String? productImage;

  final String? jobId;
  final String? jobTitle;
  final String? jobImage;

  final String? shopId;
  final String? shopName;
  final String? shopImage;

  final String? lostItemId;
  final String? contextType;

  final String? roomId;
  final String? roomTitle;
  final String? roomImage;

  final String? talentId;
  final String? talentTitle;
  final String? talentImage;

  // [추가됨] 클럽(동호회) 관련 필드
  final String? clubId;
  final String? clubTitle;
  final String? clubImage;

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
    this.shopId,
    this.shopName,
    this.shopImage,
    this.lostItemId,
    this.contextType,
    this.roomId,
    this.roomTitle,
    this.roomImage,
    this.talentId,
    this.talentTitle,
    this.talentImage,
    this.clubId,
    this.clubTitle,
    this.clubImage,
  });

  /// Compatibility getter: provide a single `title` field for UIs that
  /// expect `.title` on various item-like models. Falls back through
  /// groupName, roomTitle, productTitle, jobTitle, shopName, talentTitle,
  /// clubTitle, or empty string.
  String get title {
    return groupName ??
        roomTitle ??
        productTitle ??
        jobTitle ??
        shopName ??
        talentTitle ??
        clubTitle ??
        '';
  }

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
      contextType: data['contextType'],
      roomId: data['roomId'],
      roomTitle: data['roomTitle'],
      roomImage: data['roomImage'],
      talentId: data['talentId'],
      talentTitle: data['talentTitle'],
      talentImage: data['talentImage'],
      // [중요] 필드 매핑 확인
      clubId: data['clubId'],
      clubTitle: data['clubTitle'],
      clubImage: data['clubImage'],
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
      'clubId': clubId,
      'clubTitle': clubTitle,
      'clubImage': clubImage,
    };
  }
}

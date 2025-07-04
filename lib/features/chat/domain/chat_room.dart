// lib/features/chat/domain/chat_room.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id; // 채팅방 문서 ID
  final List<String> participants; // 참여자들의 UID 리스트
  final String productTitle; // 관련 상품 제목
  final String productImage; // 관련 상품 이미지 URL
  final String lastMessage; // 마지막 메시지 내용
  final Timestamp lastTimestamp; // 마지막 메시지 시간
  
  // 누가 메시지를 읽지 않았는지 표시 (예: {'uid1': true, 'uid2': false})
  // final Map<String, bool> unreadBy; 
   final Map<String, int> unreadCounts; 

  ChatRoom({
    required this.id,
    required this.participants,
    required this.productTitle,
    required this.productImage,
    required this.lastMessage,
    required this.lastTimestamp,
    // required this.unreadBy,
    required this.unreadCounts,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      productTitle: data['productTitle'] ?? '',
      productImage: data['productImage'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastTimestamp: data['lastTimestamp'] ?? Timestamp.now(),
      // unreadBy: Map<String, bool>.from(data['unreadBy'] ?? {}),
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }
}
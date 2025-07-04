// lib/features/chat/domain/chat_message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  // 'isRead' -> 'readBy'로 변경. 여러 참여자의 읽음 상태를 기록할 수 있음.
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      // Firestore에서 List<String> 타입으로 데이터를 가져옴
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }
}

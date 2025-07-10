// lib/core/models/chat_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final List<String> readBy;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: (data['text'] ?? '').toString(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }
}

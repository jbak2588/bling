// lib/core/models/chat_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final Timestamp timestamp;
  final List<String> readBy;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
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
      // [v2.1] '?? null' 경고 수정
      imageUrl: data['imageUrl'] != null ? (data['imageUrl'] as String) : null,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }

  /// Present a compact label for UIs expecting `.title` on generic items.
  String get title => text.isNotEmpty ? text : (imageUrl ?? '');
}

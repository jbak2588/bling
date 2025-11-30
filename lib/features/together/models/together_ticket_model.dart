// lib/features/together/models/together_ticket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TogetherTicketModel {
  final String postId;
  final String title;
  final String description;
  final Timestamp meetTime;
  final String location;
  final String qrCodeString;
  final String hostId;
  final String designTheme;
  final Timestamp joinedAt;
  final bool isUsed;

  TogetherTicketModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.meetTime,
    required this.location,
    required this.qrCodeString,
    required this.hostId,
    required this.designTheme,
    required this.joinedAt,
    this.isUsed = false,
  });

  factory TogetherTicketModel.fromMap(Map<String, dynamic> data) {
    return TogetherTicketModel(
      postId: data['postId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      meetTime: data['meetTime'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      qrCodeString: data['qrCodeString'] ?? '',
      hostId: data['hostId'] ?? '',
      designTheme: data['designTheme'] ?? 'default',
      joinedAt: data['joinedAt'] ?? Timestamp.now(),
      isUsed: data['isUsed'] ?? false,
    );
  }
}

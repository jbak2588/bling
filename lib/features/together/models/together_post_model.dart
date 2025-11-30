// lib/features/together/models/together_post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// '함께 해요(Together)' 게시글 데이터 모델
/// Firestore Collection: together_posts
class TogetherPostModel {
  final String id;
  final String hostId; // 주최자 UID
  final String title; // "같이 걷기 하실 분?"
  final String description; // "오늘 저녁 8시, 센트럴 파크 입구에서..."
  final Timestamp meetTime; // 모임 시간
  final String location; // 모임 장소 (텍스트 or 좌표 정보)

  final int maxParticipants; // 최대 모집 인원
  final List<String> participants; // 참여자 UID 리스트

  // ✅ [핵심] Together Pass & Flyer 기능
  final String qrCodeString; // 모임 고유 인증 코드 (QR 생성용)
  final String designTheme; // 전단지 디자인 테마 (예: 'neon', 'paper', 'simple')

  final String status; // 'open', 'closed', 'completed', 'expired'
  final Timestamp createdAt;

  TogetherPostModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.meetTime,
    required this.location,
    required this.maxParticipants,
    required this.participants,
    required this.qrCodeString,
    this.designTheme = 'default',
    this.status = 'open',
    required this.createdAt,
  });

  factory TogetherPostModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TogetherPostModel(
      id: doc.id,
      hostId: data['hostId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      meetTime: data['meetTime'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 4,
      participants: List<String>.from(data['participants'] ?? []),
      qrCodeString: data['qrCodeString'] ?? '',
      designTheme: data['designTheme'] ?? 'default',
      status: data['status'] ?? 'open',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'title': title,
      'description': description,
      'meetTime': meetTime,
      'location': location,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'qrCodeString': qrCodeString,
      'designTheme': designTheme,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // 유효한 모임인지 확인 (시간 만료 여부)
  bool get isExpired {
    return meetTime.toDate().isBefore(DateTime.now());
  }
}

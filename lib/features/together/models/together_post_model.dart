// [Bling] Location refactor Step 1 (Together):
// - Introduced BlingLocation-based `meetLocation`
// - Uses AddressMapPicker to choose event place
// - Preserves writer location for trust/radius.
// lib/features/together/models/together_post_model.dart

import 'package:bling_app/core/models/bling_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// '함께 해요(Together)' 게시글 데이터 모델
// Firestore Collection: together_posts
class TogetherPostModel {
  final String id;
  final String hostId; // 주최자 UID
  final String title; // "같이 걷기 하실 분?"
  final String description; // "오늘 저녁 8시, 센트럴 파크 입구에서..."
  final Timestamp meetTime; // 모임 시간
  final String location; // 모임 장소 (텍스트 or 좌표 정보)
  // ✅ [추가] 지도 좌표 및 이미지
  final GeoPoint? geoPoint;
  final BlingLocation? meetLocation; // BlingLocation 기반 모임 장소
  final String? imageUrl;

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
    this.geoPoint,
    this.meetLocation,
    this.imageUrl,
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
    BlingLocation? parsedMeetLocation;
    final rawMeetLocation = data['meetLocation'];
    if (rawMeetLocation is Map<String, dynamic>) {
      try {
        parsedMeetLocation = BlingLocation.fromJson(rawMeetLocation);
      } catch (_) {
        parsedMeetLocation = null;
      }
    }

    final geoPoint = data['geoPoint'] as GeoPoint?;
    final fallbackLocation = geoPoint != null
        ? BlingLocation(geoPoint: geoPoint, mainAddress: data['location'] ?? '')
        : null;

    return TogetherPostModel(
      id: doc.id,
      hostId: data['hostId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      meetTime: data['meetTime'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      geoPoint: geoPoint,
      meetLocation: parsedMeetLocation ?? fallbackLocation,
      imageUrl: data['imageUrl'] as String?,
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
      'geoPoint': geoPoint,
      'meetLocation': meetLocation?.toJson(),
      'imageUrl': imageUrl,
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

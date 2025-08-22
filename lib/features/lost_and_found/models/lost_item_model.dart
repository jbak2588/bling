// lib/core/models/lost_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 분실/습득물 정보를 담는 데이터 모델입니다.
/// Firestore의 `lost_and_found` 컬렉션 문서 구조와 대응됩니다.
class LostItemModel {
  final String id;
  final String userId; // 등록자 ID
  final String type; // 'lost' 또는 'found'
  final String itemDescription; // 물건 설명
  final String locationDescription; // 분실/습득 장소 설명
  final GeoPoint? geoPoint;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final bool isHunted; // 현상금(Hunted) 여부
  final int? bountyAmount; // 현상금 금액

  LostItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemDescription,
    required this.locationDescription,
    this.geoPoint,
    required this.imageUrls,
    required this.createdAt,
    this.isHunted = false,
    this.bountyAmount,
  });
  

  factory LostItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LostItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'lost',
      itemDescription: data['itemDescription'] ?? '',
      locationDescription: data['locationDescription'] ?? '',
      geoPoint: data['geoPoint'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isHunted: data['isHunted'] ?? false,
      bountyAmount: data['bountyAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'itemDescription': itemDescription,
      'locationDescription': locationDescription,
      'geoPoint': geoPoint,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'isHunted': isHunted,
      'bountyAmount': bountyAmount,
    };
  }
}
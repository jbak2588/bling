// lib/core/models/shop_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 지역 상점 정보를 담는 데이터 모델입니다.
/// Firestore의 `shops` 컬렉션 문서 구조와 1:1로 대응됩니다.
class ShopModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final List<String>? products; // 간단한 대표 상품/서비스 이름 목록
  final String contactNumber;
  final String openHours;
  final bool trustLevelVerified;
  final Timestamp createdAt;
  final int viewsCount;
  final int likesCount;
  final String? imageUrl; // 상점 대표 이미지

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    this.locationName, // [수정]
    this.locationParts, // [수정]
    this.geoPoint,
    this.products,
    required this.contactNumber,
    required this.openHours,
    this.trustLevelVerified = false,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.imageUrl,
  });

  factory ShopModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      locationName: data['locationName'] ?? '',
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      products:
          data['products'] != null ? List<String>.from(data['products']) : [],
      contactNumber: data['contactNumber'] ?? '',
      openHours: data['openHours'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'products': products,
      'contactNumber': contactNumber,
      'openHours': openHours,
      'trustLevelVerified': trustLevelVerified,
      'createdAt': createdAt,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'imageUrl': imageUrl,
    };
  }
}

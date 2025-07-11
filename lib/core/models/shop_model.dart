// lib/core/models/shop_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a local shop listed in the Local Shops module.
class ShopModel {
  final String id;
  final String name;
  final String ownerId;
  final String location;
  final GeoPoint? geoPoint;
  final List<String> products;
  final String contactNumber;
  final String openHours;
  final bool trustLevelVerified;
  final Timestamp createdAt;
  final int viewsCount;
  final int likesCount;

  ShopModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.location,
    this.geoPoint,
    this.products = const [],
    required this.contactNumber,
    required this.openHours,
    this.trustLevelVerified = false,
    required this.createdAt,
    this.viewsCount = 0,
    this.likesCount = 0,
  });

  factory ShopModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ShopModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      geoPoint: data['geoPoint'],
      products:
          data['products'] != null ? List<String>.from(data['products']) : [],
      contactNumber: data['contactNumber'] ?? '',
      openHours: data['openHours'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ownerId': ownerId,
      'location': location,
      'geoPoint': geoPoint,
      'products': products,
      'contactNumber': contactNumber,
      'openHours': openHours,
      'trustLevelVerified': trustLevelVerified,
      'createdAt': createdAt,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
    };
  }
}


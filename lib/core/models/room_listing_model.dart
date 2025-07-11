// lib/core/models/room_listing_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a room or boarding house listing.
///
/// Used for KOS/boarding/real estate listings under the
/// `rooms_listings` collection as described in the project docs.
class RoomListingModel {
  final String id;
  final String roomType;
  final String address;
  final GeoPoint? geoPoint;
  final int price;
  final int? deposit;
  final String size;
  final List<String> amenities;
  final List<String> photos;
  final String contactInfo;
  final String ownerType;
  final Timestamp createdAt;

  RoomListingModel({
    required this.id,
    required this.roomType,
    required this.address,
    this.geoPoint,
    required this.price,
    this.deposit,
    required this.size,
    required this.amenities,
    required this.photos,
    required this.contactInfo,
    required this.ownerType,
    required this.createdAt,
  });

  factory RoomListingModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RoomListingModel(
      id: doc.id,
      roomType: data['roomType'] ?? '',
      address: data['address'] ?? '',
      geoPoint: data['geoPoint'],
      price: data['price'] ?? 0,
      deposit: data['deposit'],
      size: data['size'] ?? '',
      amenities:
          data['amenities'] != null ? List<String>.from(data['amenities']) : [],
      photos: data['photos'] != null ? List<String>.from(data['photos']) : [],
      contactInfo: data['contactInfo'] ?? '',
      ownerType: data['ownerType'] ?? 'owner',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomType': roomType,
      'address': address,
      'geoPoint': geoPoint,
      'price': price,
      'deposit': deposit,
      'size': size,
      'amenities': amenities,
      'photos': photos,
      'contactInfo': contactInfo,
      'ownerType': ownerType,
      'createdAt': createdAt,
    };
  }
}

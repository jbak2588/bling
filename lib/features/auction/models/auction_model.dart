// lib/core/models/auction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a local premium auction item.
///
/// The Bling app stores auctions under the `auctions` collection as shown in
/// the project documentation. Each document includes basic item information,
/// pricing details and verification flags, while individual bids live in the
/// `bids` subcollection of that auction. This model mirrors that schema so that
/// premium auctions can easily be managed locally and synced with Firestore.
class AuctionModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final int startPrice;
  final int currentBid;
  final List<Map<String, dynamic>> bidHistory;
  final String location;
  final GeoPoint? geoPoint;
  final Timestamp startAt;
  final Timestamp endAt;
  final String ownerId;
  final bool trustLevelVerified;
  final bool isAiVerified;

  AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.startPrice,
    required this.currentBid,
    required this.bidHistory,
    required this.location,
    this.geoPoint,
    required this.startAt,
    required this.endAt,
    required this.ownerId,
    this.trustLevelVerified = false,
    this.isAiVerified = false,
  });

  factory AuctionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AuctionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images:
          data['images'] != null ? List<String>.from(data['images']) : [],
      startPrice: data['startPrice'] ?? 0,
      currentBid: data['currentBid'] ?? 0,
      bidHistory: data['bidHistory'] != null
          ? List<Map<String, dynamic>>.from(data['bidHistory'])
          : [],
      location: data['location'] ?? '',
      geoPoint: data['geoPoint'],
      startAt: data['startAt'] ?? Timestamp.now(),
      endAt: data['endAt'] ?? Timestamp.now(),
      ownerId: data['ownerId'] ?? '',
      trustLevelVerified: data['trustLevelVerified'] ?? false,
      isAiVerified: data['isAiVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'startPrice': startPrice,
      'currentBid': currentBid,
      'bidHistory': bidHistory,
      'location': location,
      'geoPoint': geoPoint,
      'startAt': startAt,
      'endAt': endAt,
      'ownerId': ownerId,
      'trustLevelVerified': trustLevelVerified,
      'isAiVerified': isAiVerified,
    };
  }
}

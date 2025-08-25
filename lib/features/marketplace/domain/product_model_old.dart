// lib/features/marketplace/domain/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

// 최종 통합된 Product 데이터 모델
class Product {
  final String id;
  final List<String> imageUrls;
  final String title;
  final String description;
  final String categoryId;
  final int price;
  final bool negotiable;
  final String address;
  final String? transactionPlace;
  final Geo geo;

  final String status;
  final bool isAiVerified;

  final String userId;
  final String userName;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  final int likesCount;
  final int chatsCount;
  final int viewsCount;
  final String? condition;

  Product({
    required this.id,
    required this.imageUrls,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.negotiable,
    required this.address,
    this.transactionPlace,
    required this.geo,
    required this.status,
    required this.isAiVerified,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.updatedAt,
    this.condition,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
  });

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final geoData = data['geo'] as Map<String, dynamic>? ?? {};
    final geoPoint = geoData['geopoint'] as GeoPoint? ?? const GeoPoint(0, 0);
    final geo = GeoFlutterFire().point(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );

    return Product(
      id: snapshot.id,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      price: data['price'] ?? 0,
      negotiable: data['negotiable'] ?? false,
      address: data['address'] ?? '',
      transactionPlace: data['transactionPlace'],
      geo: geo,
      status: data['status'] ?? 'selling',
      isAiVerified: data['isAiVerified'] ?? false,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      condition: data['condition'],
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
    );
  }

Product copyWith({
    List<String>? imageUrls,
    String? title,
    String? description,
    String? categoryId,
    int? price,
    bool? negotiable,
    String? address,
    String? transactionPlace,
    Geo? geo,
    String? status,
    bool? isAiVerified,
    String? userId,
    String? userName,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? likesCount,
    int? chatsCount,
    int? viewsCount,
    String? condition,
  }) {
    return Product(
      id: id,
      imageUrls: imageUrls ?? this.imageUrls,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      negotiable: negotiable ?? this.negotiable,
      address: address ?? this.address,
      transactionPlace: transactionPlace ?? this.transactionPlace,
      geo: geo ?? this.geo,
      status: status ?? this.status,
      isAiVerified: isAiVerified ?? this.isAiVerified,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      chatsCount: chatsCount ?? this.chatsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      condition: condition ?? this.condition,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'imageUrls': imageUrls,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'negotiable': negotiable,
      'address': address,
      'transactionPlace': transactionPlace,
      'geo': geo.data,
      'status': status,
      'isAiVerified': isAiVerified,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'condition': condition,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
    };
  }
}

// Minimal Geo class definition for compatibility
class Geo {
  final Map<String, dynamic> data;

  Geo({required this.data});
}

class GeoFlutterFire {
  Geo point({required double latitude, required double longitude}) {
    return Geo(
      data: {
        'geopoint': GeoPoint(latitude, longitude),
      },
    );
  }
}

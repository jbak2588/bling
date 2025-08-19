// lib/core/models/product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String categoryId;
  final int price;
  final bool negotiable;

  // ✅ [통합] 신규 모델의 정교한 위치 정보 필드를 사용합니다.
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  // ✅ [통합] 구버전 모델의 상태 관리 필드를 가져옵니다.
  final String status; // 'selling', 'reserved', 'sold'
  final bool isAiVerified;
  final String condition; // 'new' or 'used'
  // ✅ [추가] 거래 희망 장소 필드를 추가합니다.
  final String? transactionPlace;

  // 카운트 필드
  final int likesCount;
  final int chatsCount;
  final int viewsCount;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.categoryId,
    required this.price,
    required this.negotiable,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.status = 'selling',
    this.isAiVerified = false,
    this.condition = 'used',
      // ✅ [추가] 생성자에 transactionPlace를 추가합니다.
    this.transactionPlace,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      categoryId: data['categoryId'] ?? '',
      price: data['price'] ?? 0,
      negotiable: data['negotiable'] ?? false,
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      status: data['status'] ?? 'selling',
      isAiVerified: data['isAiVerified'] ?? false,
      condition: data['condition'] ?? 'used',
      // ✅ [추가] Firestore에서 transactionPlace 필드를 가져옵니다.
      transactionPlace: data['transactionPlace'],
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'price': price,
      'negotiable': negotiable,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'status': status,
      'isAiVerified': isAiVerified,
      'condition': condition,
       // ✅ [추가] toJson 맵에 transactionPlace를 추가합니다.
      'transactionPlace': transactionPlace,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

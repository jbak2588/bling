// lib/core/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 앱의 Marketplace 상품에 대한 표준 데이터 모델 클래스입니다.
/// Firestore의 'products' 컬렉션 문서 구조와 1:1로 대응됩니다.
class ProductModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String categoryId;
  final int price;
  final bool negotiable; // 가격 협상 가능 여부
  final String? condition; // 'new', 'used' 등 상품 상태
  final String status; // 'selling', 'reserved', 'sold' 등 거래 상태

  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  final bool isAiVerified; // AI 검수 여부
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
    this.negotiable = false,
    this.condition,
    this.status = 'selling',
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.isAiVerified = false,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서로부터 ProductModel 객체를 생성합니다.
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
      condition: data['condition'],
      status: data['status'] ?? 'selling',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      isAiVerified: data['isAiVerified'] ?? false,
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// ProductModel 객체를 Firestore에 저장하기 위한 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'price': price,
      'negotiable': negotiable,
      'condition': condition,
      'status': status,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'isAiVerified': isAiVerified,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

# 7_04. Bling_Marketplace_Policy
# 

---

## ✅ Marketplace 개요

Bling Marketplace는 Keluharan(Kec.) 기반으로 운영되는  
**중고 & 신상품 거래 + AI 검수** 로컬 마켓입니다.  
Nextdoor의 Feed 구조와는 달리 **판매와 거래**가 중심이며,  
1:1 채팅, 찜(Wishlist), 신뢰등급 연계가 핵심입니다.

---

## ✅ 주요 기능

| 기능            | 상태                                                                                                         |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| 중고물품 등록       | ✔️ 초기 버전 완성                                                                                                |
| 카테고리 구조       | ✔️ Firestore 컬렉션 + CSV 설계                                                                                  |
| 상품 상세         | ✔️ 이미지, 설명, 가격 필드                                                                                          |
| 좋아요/찜         | ✔️ `likesCount` 필드, Wishlist 연계 예정                                                                         |
| 조회수           | ✔️ `viewsCount` 필드                                                                                         |
| 1:1 채팅        | ✔️ `chats` 컬렉션 연동                                                                                          |
| AI 검수         | ❌ 기획 완료, 모듈 미구현                                                                                            |
| TrustLevel 연계 | ❌ 판매자 신뢰등급 연동 예정                                                                                           |
| 다국어 카테고리      | ✔️ assets<br>       ├── lang<br>       │   ├── en.json<br>       │   ├── id.json<br>       │   └── ko.json |

---

## ✅ Firestore 구조

|컬렉션|필드|
|---|---|
|`products`|`title`, `description`, `images[]`, `price`, `likesCount`, `viewsCount`, `isAiVerified`, `chatCount`|
|위치|`latitude`, `longitude`, `address`|
|상태|`status` (`selling`, `sold`)|
|소유자|`userId`, `userName`|
|카테고리|`categories` → `name_en`, `name_id`, `parentId`, `order`|
|채팅|`chats/{chatId}/messages` → `participants[]`, `lastMessage`|

---

## ✅ AI 검수 상태

- `isAiVerified` 필드만 존재
    
- 이미지 허위 여부, 중복 매물 탐지 기능 미구현
    
- 추후 AI 태깅, 라벨링 자동화 예정
    

---

## ✅ TODO & 개선

1️⃣ `users/{uid}/wishlist` 구조 설계 → 좋아요/찜 내역 저장  
2️⃣ `users/{uid}/products` → 판매 히스토리 연동  
3️⃣ AI 이미지 검수 모듈 연계  
4️⃣ 카테고리 다국어 JSON 연결  
5️⃣ TrustLevel → 판매자 신뢰도 & 리뷰 연동

---

-  `products` 컬렉션 필드 최종 표준화 (`isAiVerified` 포함)
    
-  AI 이미지 검수 로직 설계 & 연계
    
-  거래 상태(`selling`/`sold` / reserverd / hide ) 변경 UI 완료
    
-  가격 협상 옵션 및 필드 (`negotiable`) 테스트
    
## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[6_03. Bling_Local_Feed_Policy & To-Do 목록]]
    
- [[4_21. User_Field_Standard]] → User ID, 위치 필드 연결
- [[3_18_2. TrustLevel_Policy]] → 판매자 신뢰 등급 조건
- Firestore: `products`, `users/{uid}/wishlist`

---

## ✅ 결론

Bling Marketplace는 **중고/신상품 거래, AI 검수, 신뢰등급 구조**를 하나로 결합한  
**Keluharan(Kec.) 기반 로컬 마켓 허브**입니다.  
기본 등록/상세/채팅은 완성되어 있으며, TrustLevel/Wishlist/AI 모듈로  
고도화가 진행됩니다.


# 7_06. product_model.dart
// lib/features/marketplace/domain/product_model.dart
// Bling App v0.9

import 'package:cloud_firestore/cloud_firestore.dart';

// geoflutterfire_plus 또는 다른 Geo 관련 패키지 사용 시 주석 해제
// import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

// [수정] Geo 관련 클래스는 호환성을 위해 임시로 여기에 정의합니다.
// 나중에 별도 파일로 분리하는 것이 좋습니다.
class Geo {
  final Map<String, dynamic> data;
  Geo({required this.data});
}

class GeoFlutterFire {
  Geo point({required double latitude, required double longitude}) {
    return Geo(data: {'geopoint': GeoPoint(latitude, longitude)});
  }
}


/// Marketplace 상품 데이터 모델 v0.9
class ProductModel {
  final String id;
  final String userId;
  // [삭제] userName 필드를 제거하여 UserModel과의 실시간 연동을 준비합니다.

  final String title;
  final String description;
  final List<String> imageUrls;
  final String categoryId;
  final int price;
  final bool negotiable;
  
  final String address;
  final String? transactionPlace;
  final Geo geo;

  final String status;
  final bool isAiVerified;
  final String? condition;
  
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
    required this.address,
    this.transactionPlace,
    required this.geo,
    required this.status,
    required this.isAiVerified,
    this.condition,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final geoData = data['geo'] as Map<String, dynamic>? ?? {};
    final geoPoint = geoData['geopoint'] as GeoPoint? ?? const GeoPoint(0, 0);
    final geo = GeoFlutterFire().point(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );

    return ProductModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      categoryId: data['categoryId'] ?? '',
      price: data['price'] ?? 0,
      negotiable: data['negotiable'] ?? false,
      address: data['address'] ?? '',
      transactionPlace: data['transactionPlace'],
      geo: geo,
      status: data['status'] ?? 'selling',
      isAiVerified: data['isAiVerified'] ?? false,
      condition: data['condition'],
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
      'address': address,
      'transactionPlace': transactionPlace,
      'geo': geo.data,
      'status': status,
      'isAiVerified': isAiVerified,
      'condition': condition,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


# 7_10. marketplace_screen.dart
// lib/features/marketplace/presentation/screens/marketplace_screen.dart

import 'package:bling_app/features/marketplace/domain/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  final String currentAddress;
  const MarketplaceScreen({super.key, required this.currentAddress});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'time_ago_now'.tr();
    } else if (diff.inHours < 1) {
      return 'time_ago_min'.tr(args: [diff.inMinutes.toString()]);
    } else if (diff.inDays < 1) {
      return 'time_ago_hour'.tr(args: [diff.inHours.toString()]);
    } else if (diff.inDays < 7) {
      return 'time_ago_day'.tr(args: [diff.inDays.toString()]);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }

  void _navigateToProductRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductRegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query;
    // 동네 정보가 유효한 경우, 해당 지역 상품만 필터링합니다.
    if (widget.currentAddress.isNotEmpty &&
        widget.currentAddress != 'location_loading'.tr() &&
        widget.currentAddress != 'location_not_set'.tr()) {
      query = FirebaseFirestore.instance
          .collection('products')
          .where('address', isEqualTo: widget.currentAddress)
          .orderBy('createdAt', descending: true);
    } else {
      // 동네 정보가 없으면, 전체 상품을 최신순으로 보여줍니다.
      query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(20);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProductRegistration,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Ada 10 tetangga dan 20 item di sekitar Anda!", // TODO: 다국어 및 실제 데이터 연동
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {}, // TODO: 지역 변경 기능 연결
                  child: const Text(
                    "Ganti Lokasi", // TODO: 다국어 키 추가 필요
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('marketplace_error'
                          .tr(args: [snapshot.error.toString()])));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('marketplace_empty'.tr(),
                        textAlign: TextAlign.center),
                  );
                }

                final productsDocs = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: productsDocs.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(productsDocs[index]);
                    final String registeredAt =
                        _formatTimestamp(product.createdAt);

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.imageUrls.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.imageUrls.first,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.broken_image,
                                          color: Colors.grey[400]),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[800]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${product.address} • $registeredAt',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(product.price),
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chat_bubble_outline,
                                          size: 16.0, color: Colors.grey),
                                      const SizedBox(width: 4.0),
                                      Text('${product.chatsCount}'),
                                      const SizedBox(width: 12.0),
                                      const Icon(Icons.favorite_outline,
                                          size: 16.0, color: Colors.grey),
                                      const SizedBox(width: 4.0),
                                      Text('${product.likesCount}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




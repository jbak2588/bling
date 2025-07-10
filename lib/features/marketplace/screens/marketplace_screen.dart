// lib/features/marketplace/screens/marketplace_screen.dart
// Bling App v0.4
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  // ✅ [수정] UserModel을 받도록 수정
  final UserModel? userModel;
  const MarketplaceScreen({super.key, this.userModel});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _formatTimestamp(Timestamp timestamp) {
    // ... (내용 변경 없음)
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'time.now'.tr();
    } else if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    } else if (diff.inDays < 1) {
      return 'time.hoursAgo'
          .tr(namedArgs: {'hours': diff.inHours.toString()});
    } else if (diff.inDays < 7) {
      return 'time.daysAgo'
          .tr(namedArgs: {'days': diff.inDays.toString()});
    } else {
      return DateFormat('time.dateFormat'.tr()).format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ [수정] 쿼리 생성 로직을 build 메소드 안으로 이동하고, Tangerang 권역을 모두 포함하도록 수정
    Query<Map<String, dynamic>> buildQuery() {
      final userKabupaten = widget.userModel?.locationParts?['kab'];

      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      List<String> targetLocations = [];

      // ✅ 사용자의 위치가 'Tangerang', 'Tangerang City', 'Tangerang Selatan' 중 하나이면 모두 조회
      if (userKabupaten == 'Tangerang' ||
          userKabupaten == 'Tangerang City' ||
          userKabupaten == 'Tangerang Selatan') {
        targetLocations = ['Tangerang', 'Tangerang City', 'Tangerang Selatan'];
      } else if (userKabupaten != null && userKabupaten.isNotEmpty) {
        targetLocations = [userKabupaten];
      }

      if (targetLocations.isNotEmpty) {
        query = query.where('locationParts.kab', whereIn: targetLocations);
      }

      return query.orderBy('createdAt', descending: true);
    }

    // ✅ [수정] 위치 정보가 없는 경우를 위한 UI 처리
    if (widget.userModel?.locationParts?['kab'] == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '중고거래 상품을 보려면 먼저 내 동네를 설정해주세요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // ✅ [수정] 수정된 쿼리 빌더 함수를 사용
        stream: buildQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('marketplace.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child:
                  Text('marketplace.empty'.tr(), textAlign: TextAlign.center),
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
             final product = ProductModel.fromFirestore(productsDocs[index]);
              final String registeredAt = _formatTimestamp(product.createdAt);

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
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              product.description,
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.grey[800]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${product.locationParts?['kel'] ?? 'postCard.locationNotSet'.tr()} • $registeredAt',
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[600]),
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
    );
  }
}

/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/marketplace_screen.dart
/// Purpose       : 위치 기반 필터로 상품 목록을 표시합니다.
/// User Impact   : 구매자가 주변 상품을 둘러보고 상세 페이지를 열 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/location/screens/location_filter_screen.dart
/// Data Model    : Firestore `products`를 `locationParts.prov`로 쿼리하고 `createdAt`으로 정렬합니다.
/// Location Scope: `locationFilter`를 통해 Prov→Kab/Kota→Kec→Kel 값을 지원합니다.
/// Trust Policy  : `isAiVerified` 상품만 강조하며 미검증 상품은 검토 대상입니다.
/// Monetization  : 프로모션 상품과 배너 광고를 지원하며 추후 판매 수수료가 예정되어 있습니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_marketplace`, `apply_location_filter`, `click_product`.
/// Analytics     : 쿼리 결과와 스크롤 깊이를 모니터링합니다.
/// I18N          : 키 `marketplace.error`, `marketplace.empty`, `time.*` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization, firebase_auth
/// Security/Auth : 조회는 공개이며 등록은 인증과 신뢰 점수가 필요합니다.
/// Edge Cases    : 사용자 위치가 없으면 설정 프롬프트를 표시합니다.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// ============================================================================
library;
/// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const MarketplaceScreen({super.key, this.userModel, this.locationFilter});

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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = widget.locationFilter;
    if (filter == null) return allDocs;

    String? key;
    if (filter['kel'] != null) {
      key = 'kel';
    } else if (filter['kec'] != null) {
      key = 'kec';
    } else if (filter['kab'] != null) {
      key = 'kab';
    } else if (filter['kota'] != null) {
      key = 'kota';
    } else if (filter['prov'] != null) {
      key = 'prov';
    }
    if (key == null) return allDocs;

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ [수정] 쿼리 생성 로직을 build 메소드 안으로 이동하고, Tangerang 권역을 모두 포함하도록 수정
    Query<Map<String, dynamic>> buildQuery() {
      final userProv = widget.userModel?.locationParts?['prov'];

      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      if (userProv != null && userProv.isNotEmpty) {
        query = query.where('locationParts.prov', isEqualTo: userProv);
      }

      return query.orderBy('createdAt', descending: true);
    }

    // ✅ [수정] 위치 정보가 없는 경우를 위한 UI 처리
    if (widget.userModel?.locationParts?['prov'] == null) {
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

          final allDocs = snapshot.data!.docs;
          final productsDocs = _applyLocationFilter(allDocs);
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
                              '${product.locationParts?['kel'] ?? product.locationParts?['kec'] ?? 'postCard.locationNotSet'.tr()} • $registeredAt',
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

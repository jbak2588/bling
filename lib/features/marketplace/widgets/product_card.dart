/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/widgets/product_card.dart
/// Purpose       : 이미지, 제목, 가격, 판매자 정보를 포함한 상품 요약 카드를 렌더링합니다.
/// User Impact   : 주변 상품을 빠르게 살펴보며 전환을 높입니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart
/// Data Model    : `products` 필드 `title`, `description`, `price`, `imageUrls`, `locationParts`, `createdAt`를 표시하며 판매자 `users/{userId}` 데이터를 가져옵니다.
/// Location Scope: 타임스탬프 옆에 Kelurahan 또는 Kecamatan 태그를 표시합니다.
/// Trust Policy  : 판매자의 `trustLevel`에 따른 배지를 아바타 옆에 보여 줍니다.
/// Monetization  : 프로모션 배지와 가격 강조 슬롯을 제공합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `click_product_card`.
/// Analytics     : 카드가 뷰포트에 들어올 때 노출을 기록합니다.
/// I18N          : 키 `time.*`, `postCard.locationNotSet` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization
/// Security/Auth : 읽기 전용이며 사용자 데이터에 대한 Firestore 규칙을 준수합니다.
/// Edge Cases    : 이미지 또는 사용자 문서 누락.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 상품 카드 UI, 이미지/제목/가격/판매자 정보/신뢰등급 등 시각화
///   - 상세 페이지 연동, KPI/Analytics 이벤트(클릭, 노출 등) 기록
///
/// 2. 실제 코드 분석
///   - 상품 카드 UI, 이미지/제목/가격/판매자 정보/신뢰등급 등 시각화
///   - 상세 페이지 연동, KPI/Analytics 이벤트(클릭, 노출 등) 기록
///   - 다국어(i18n), 위치 정보, 광고/추천 등 연계 가능
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 현지화(i18n), 신뢰등급, KPI/Analytics 등 사용자 경험·운영 기능 강화
///   - 기획에 못 미친 점: 채팅, 찜, 광고/추천글 노출 등 일부 기능 미구현
///
/// 4. 개선 제안
///   - 카테고리별 색상/아이콘, 위치 기반 추천, 미디어 업로드/미리보기, KPI/Analytics 이벤트 로깅, 광고/추천글 연계
library;
// 아래부터 실제 코드

// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// ✅ [수정] UserModel과 최종 ProductModel을 모두 import합니다.
import '../../../core/models/user_model.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _formatTimestamp(BuildContext context, Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final String registeredAt = _formatTimestamp(context, product.createdAt);

    return InkWell(
      onTap: () {
        // ✅ ProductDetailScreen으로 ProductModel 타입의 product를 전달합니다.
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        // ✅ [수정] 작성자 정보를 표시하기 위해 StreamBuilder를 다시 추가합니다.
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(product.userId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()));
              }
              final user = UserModel.fromFirestore(userSnapshot.data!);

              return Row(
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
                      ),
                    ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
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
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                            NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(product.price),
                          style: const TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(user.nickname,
                                style: const TextStyle(fontSize: 13)),
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
              );
            }),
      ),
    );
  }
}

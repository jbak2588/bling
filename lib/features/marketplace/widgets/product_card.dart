/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/widgets/product_card.dart
/// Purpose       : 이미지, 제목, 가격, 판매자 정보를 포함한 상품 요약 카드를 렌더링합니다.
/// User Impact   : 주변 상품을 빠르게 살펴보며 전환을 높입니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart
/// Data Model    : `products` 필드 `title`, `description`, `price`, `imageUrls`, `locationName`, `locationParts`, `geoPoint`, `createdAt`를 표시하며 판매자 `users/{userId}` 데이터를 가져옵니다.
/// Location Note : `locationName`은 전체 주소 문자열, `locationParts`는 {prov,kab,kec,kel,street,rt,rw} 구조를 가지며 행정구역명은 `LocationHelper.cleanName`으로 정규화되어야 합니다.
/// Privacy Note : 사용자 동의 없이 `locationParts['street']`나 전체 `locationName`을 피드(카드/목록)에서 표시하지 마세요. 피드에서는 행정구역만 축약형(`kel.`, `kec.`, `kab.`, `prov.`)으로 보여 주세요.
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
/// ============================================================================///
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

import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

// ✅ [수정] UserModel과 최종 ProductModel을 모두 import합니다.
import '../../../core/models/user_model.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';

import 'package:bling_app/features/marketplace/widgets/ai_verification_badge.dart'; // ✅ 배지 위젯 import

// ✅ 1. StatelessWidget을 StatefulWidget으로 변경합니다.
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final double? distanceKm; // optional distance to display (km)
  const ProductCard({super.key, required this.product, this.distanceKm});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

// ✅ 2. State 클래스를 만들고 with AutomaticKeepAliveClientMixin을 추가합니다.
class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  // ✅ 3. wantKeepAlive를 true로 설정하여 카드 상태를 유지합니다.
  @override
  bool get wantKeepAlive => true;

  // 안전한 미리보기 텍스트 생성: condition_check가 Map/String/List 어떤 형태든 처리하고,
  // 없으면 verification_summary 또는 기존 description으로 폴백합니다.
  String _aiDescriptionPreview(ProductModel product) {
    final Map<String, dynamic>? report =
        (product.aiReport ?? product.aiVerificationData)
            ?.map((key, value) => MapEntry(key.toString(), value));

    if (report == null) return product.description;

    final dynamic condition = report['condition_check'];
    String? condText;
    if (condition is Map) {
      try {
        condText =
            condition.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      } catch (_) {
        // ignore and fallback below
      }
    } else if (condition is List) {
      try {
        condText = condition.join(', ');
      } catch (_) {
        // ignore and fallback below
      }
    } else if (condition is String) {
      condText = condition;
    }

    if (condText != null && condText.trim().isNotEmpty) {
      return condText;
    }

    final dynamic summary = report['verification_summary'];
    if (summary is String && summary.trim().isNotEmpty) {
      return summary;
    }

    return product.description;
  }

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
    // ✅ 4. super.build(context)를 호출해야 합니다.
    super.build(context);

    // 기존 build 로직에서 product를 참조할 때 widget.product로 변경합니다.
    final product = widget.product;
    final String registeredAt = _formatTimestamp(context, product.createdAt);

    void goToDetail() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ));
    }

    final adminFilter = context.watch<LocationProvider>().adminFilter;
    final displayAddress = AddressFormatter.dynamicAdministrativeAddress(
      locationParts: product.locationParts,
      adminFilter: adminFilter,
      fallbackFullAddress: product.locationName,
    );

    return InkWell(
      onTap: goToDetail,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

              // [핵심 수정] 뱃지를 카드 내부에 조건부로 포함하기 위해 Column으로 감쌉니다.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.isAiVerified)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: AiVerificationBadge(),
                    ),
                  // [Fix #2] '예약중' 또는 '판매완료' 뱃지 표시
                  if (product.status == 'reserved')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildStatusBadge(
                          'marketplace.status.reserved'.tr(),
                          Colors.blue.shade700),
                    ),
                  if (product.status == 'sold')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildStatusBadge(
                          'marketplace.status.sold'.tr(), Colors.grey.shade700),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ImageCarouselCard(
                            imageUrls: product.imageUrls,
                            storageId: product.id,
                            width: 100,
                            height: 100,
                            // 리스트(카드)에서는 이미지 탭 시 갤러리 대신 상세로 이동
                            onImageTap: goToDetail,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              // [개선] AI 검수 상품일 경우, 설명 대신 AI 리포트 요약을 보여줍니다.
                              product.isAiVerified
                                  ? _aiDescriptionPreview(product)
                                  : product.description,
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.grey[800]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              // Build location / distance / time parts
                              <String>[
                                displayAddress.isNotEmpty
                                    ? displayAddress
                                    : 'postCard.locationNotSet'.tr(),
                                if (widget.distanceKm != null)
                                  'marketplace.distance'.tr(namedArgs: {
                                    'value':
                                        widget.distanceKm!.toStringAsFixed(1)
                                  }),
                                registeredAt,
                              ].where((s) => s.isNotEmpty).join(' • '),
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
                  ),
                ],
              );
            }),
      ),
    );
  }

  // [Fix #2] 상태 뱃지를 위한 헬퍼 위젯
  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

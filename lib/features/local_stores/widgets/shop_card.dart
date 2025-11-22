// ===================== DocHeader =====================
// [기획 요약]
// - 상점 카드. 대표 이미지, 상호명, 위치, 연락처 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 상호명, 위치, 연락처 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
// =====================================================
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) '평점/리뷰 수' 표시: 'averageRating'과 'reviewCount'를 카드에 표시.
// 2. (Task 1) '광고' 라벨: 'isSponsored'가 true일 때 "스폰서" 라벨 표시.
// 3. (Task 1) '거리' 표시: 'userModel'의 GeoPoint와 'shop.geoPoint'를 Geolocator로 계산하여 m/km 단위로 거리 표시.
// 4. (Task 4) '인증 배지' UI: 가게 이름 옆에 'trustLevelVerified' 값에 따라 인증 아이콘(Icons.verified) 표시.
// 5. (Task 6) 'Jobs' 연동: 'ShopDetailScreen'으로 'userModel'을 전달하기 위해 생성자에서 userModel을 받도록 수정.
// =====================================================
// lib/features/local_stores/widgets/shop_card.dart

import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/screens/shop_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// [추가] 거리 계산을 위해 geolocator 임포트
import 'package:geolocator/geolocator.dart';
// [추가] GeoPoint 타입 사용을 위해 cloud_firestore 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/local_news/screens/tag_search_result_screen.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final UserModel? userModel;
  const ShopCard({super.key, required this.shop, this.userModel});

  @override
  Widget build(BuildContext context) {
    // [추가] 사용자 위치 가져오기 (예시: Provider 또는 Riverpod 사용)
    // final userGeoPoint = context.watch<UserModel?>()?.geoPoint;

    // 사용자 위치 (연동되면 거리 계산에 사용)
    final GeoPoint? userGeoPoint = userModel?.geoPoint;

    String distanceText = '';
    if (userGeoPoint != null && shop.geoPoint != null) {
      final double distanceInMeters = Geolocator.distanceBetween(
        userGeoPoint.latitude,
        userGeoPoint.longitude,
        shop.geoPoint!.latitude,
        shop.geoPoint!.longitude,
      );
      if (distanceInMeters < 1000) {
        distanceText = '${distanceInMeters.toStringAsFixed(0)}m';
      } else {
        distanceText = '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 탭하면 ShopDetailScreen으로 이동하며, 선택된 shop 정보를 전달합니다.
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) =>
                    ShopDetailScreen(shop: shop, userModel: userModel)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // V V V --- [수정] imageUrl -> imageUrls.first 로 변경 --- V V V
              if (shop.imageUrls.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    shop.imageUrls.first, // 첫 번째 이미지를 썸네일로 사용
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // [추가] 스폰서 배지
              if (shop.isSponsored)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'common.sponsored'.tr(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
              // ✅ 태그 칩 표시 (PostCard와 동일한 UX)
              if (shop.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: shop.tags.map((tag) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TagSearchResultScreen(tags: [tag]),
                        ));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.grey.shade100,
                        padding: EdgeInsets.zero,
                        label:
                            Text('#$tag', style: const TextStyle(fontSize: 11)),
                      ),
                    );
                  }).toList(),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shop.name, // 가게 이름
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // [추가] 인증 배지
                  if (shop.trustLevelVerified) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.verified,
                        size: 18, color: Theme.of(context).primaryColor),
                  ]
                ],
              ),
              const SizedBox(height: 4),
              Text(
                shop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Divider(height: 24),
              // [수정] 기존 Row를 Row와 별점 Row로 분리
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                  const SizedBox(width: 4),
                  Text(
                    shop.averageRating.toStringAsFixed(1), // 평균 별점
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text('(${shop.reviewCount})'), // 리뷰 개수
                  const SizedBox(width: 12),
                  Icon(Icons.watch_later_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(shop.openHours,
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop.locationName ?? 'localStores.noLocation'.tr(),
                      overflow: TextOverflow.ellipsis, // 긴 주소는 ... 처리
                      maxLines: 1,
                    ),
                  ),
                  // [추가] 거리 표시
                  if (distanceText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      distanceText,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

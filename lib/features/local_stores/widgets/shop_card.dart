// lib/features/local_stores/widgets/shop_card.dart
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

import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/local_stores/screens/shop_detail_screen.dart'; // [추가] 상세 화면 임포트
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 탭하면 ShopDetailScreen으로 이동하며, 선택된 shop 정보를 전달합니다.
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
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
              // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
              Text(
                shop.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                shop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Divider(height: 24),
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
                  const SizedBox(width: 8),
                  Icon(Icons.watch_later_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(shop.openHours),
                ],
              )
            ],
          ),
        ),
      ),
    );
    }
  }
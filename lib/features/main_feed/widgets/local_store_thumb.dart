// lib/features/main_feed/widgets/local_store_thumb.dart
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/local_stores/screens/shop_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// [개편] 7단계: 메인 피드용 표준 썸네일 (Local Store 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Local Store 규칙: 상호 / 보조=카테고리
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class LocalStoreThumb extends StatelessWidget {
  final ShopModel shop;
  final void Function(Widget, String)? onIconTap;
  const LocalStoreThumb({super.key, required this.shop, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          final detailScreen = ShopDetailScreen(shop: shop);
          if (onIconTap != null) {
            onIconTap!(detailScreen, 'main.tabs.localStores');
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => detailScreen),
            );
          }
        },
        child: Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 이미지 (16:9 비율)
              _buildImageContent(context),
              // 2. 하단 메타 (상호, 카테고리)
              _buildMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 상단 이미지 (16:9 이미지) ---
  Widget _buildImageContent(BuildContext context) {
    // 16:9 비율
    const double imageHeight = 124.0;
    //
    final imageUrl = (shop.imageUrls.isNotEmpty) ? shop.imageUrls.first : null;

    return (imageUrl != null)
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            height: imageHeight,
            width: 220,
            fit: BoxFit.cover,
            // MD: "로딩/이미지 실패 시 스켈레톤/플레이스홀더"
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: 220,
              color: Colors.grey[200],
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: 220,
              color: Colors.grey[200],
              child: Center(
                  child: Icon(Icons.storefront_outlined,
                      color: Colors.grey[400], size: 40)),
            ),
          )
        : Container(
            // 이미지가 없는 경우 플레이스홀더
            height: imageHeight,
            width: 220,
            color: Colors.grey[200],
            child: Center(
                child: Icon(Icons.storefront_outlined,
                    color: Colors.grey[400], size: 40)),
          );
  }

  // --- 하단 메타 (상호 + 카테고리) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 124 = 116

    // 카테고리 ID를 다국어 키로 변환 (예: 'food' -> 'localStores.categories.food')
    //
    /* final categoryKey = 'localStores.categories.${shop.mainCategory ?? 'etc'}'; // ✅ [수정] 'category' 대신 'mainCategory' 필드 사용 -> 추후 실제 필드명으로 변경
    final categoryString = t[categoryKey]; // 번역된 카테고리 이름 */

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          children: [
            // MD: "상호"
            Text(
              shop.name, //
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // MD: "보조=카테고리"
            /* Text(
              categoryString,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ), */
          ],
        ),
      ),
    );
  }
}

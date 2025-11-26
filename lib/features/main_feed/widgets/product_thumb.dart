// lib/features/main_feed/widgets/product_thumb.dart
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [개편] 3단계: 메인 피드용 표준 썸네일 (Product 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Product 전용 규칙: 제목 / 보조=지역 / 배지=가격
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class ProductThumb extends StatelessWidget {
  final ProductModel product;
  final void Function(Widget, String)? onIconTap;
  const ProductThumb({super.key, required this.product, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          final detailScreen = ProductDetailScreen(product: product);
          if (onIconTap != null) {
            onIconTap!(detailScreen, 'main.tabs.marketplace');
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
              // 2. 하단 메타 (제목, 지역, 가격)
              _buildMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 상단 이미지 (16:9 이미지) ---
  Widget _buildImageContent(BuildContext context) {
    // 220 (width) / 1.777 (16:9) = 123.7
    const double imageHeight = 124.0;

    //
    final imageUrl =
        (product.imageUrls.isNotEmpty) ? product.imageUrls.first : null;

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
                  child:
                      Icon(Icons.image_not_supported, color: Colors.grey[400])),
            ),
          )
        : Container(
            // 이미지가 없는 경우 플레이스홀더
            height: imageHeight,
            width: 220,
            color: Colors.grey[200],
            child: Center(
                child: Icon(Icons.shopping_bag_outlined,
                    color: Colors.grey[400], size: 40)),
          );
  }

  // --- 하단 메타 (제목 + 지역 + 가격) ---
  Widget _buildMeta(BuildContext context) {
    // 240 (total) - 124 (image) = 116

    // MD: "보조=지역 또는 셀러" - 여기서는 '지역' 사용
    //
    final location =
        product.locationParts?['kab'] ?? product.locationParts?['kota'] ?? '';

    // MD: "배지=가격"
    //
    final priceFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final priceString = priceFormat.format(product.price);

    return Expanded(
      child: Padding(
        // ✅ [수정] 오버플로우 완화: 상하 Padding을 10 -> 8로 줄임
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목"
            Text(
              product.title, //
              // ✅ [수정] 오버플로우 완화: 본문 크기를 한 단계 낮춤
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // MD: "보조=지역"
            Text(
              location,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // MD: "배지=가격"
            Text(
              priceString,
              // ✅ [수정] 오버플로우 완화: 가격 텍스트 크기를 한 단계 낮춤
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

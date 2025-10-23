// lib/features/main_feed/widgets/auction_thumb.dart
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/auction/screens/auction_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 지원

/// [개편] 8단계: 메인 피드용 표준 썸네일 (Auction 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Auction 규칙: 제목 / 보조=지역 / 배지=현재가
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class AuctionThumb extends StatelessWidget {
  final AuctionModel auction;
  final void Function(Widget, String)? onIconTap;
  const AuctionThumb({super.key, required this.auction, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          final detailScreen = AuctionDetailScreen(auction: auction);
          if (onIconTap != null) {
            onIconTap!(detailScreen, 'main.tabs.auction');
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
              // 2. 하단 메타 (제목, 지역, 현재가)
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
    final imageUrl = (auction.images.isNotEmpty) ? auction.images.first : null;

    // ✅ [추가] 경매 종료 여부 확인
    final bool isEnded = auction.endAt.toDate().isBefore(DateTime.now());

    Widget imageWidget;
    if (imageUrl != null) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        height: imageHeight,
        width: 220,
        fit: BoxFit.cover,
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
              child: Icon(Icons.gavel_outlined,
                  color: Colors.grey[400], size: 40)),
        ),
      );
    } else {
      // 이미지가 없는 경우 플레이스홀더
      imageWidget = Container(
        height: imageHeight,
        width: 220,
        color: Colors.grey[200],
        child: Center(
            child:
                Icon(Icons.gavel_outlined, color: Colors.grey[400], size: 40)),
      );
    }

    // ✅ [추가] Stack을 사용하여 이미지 위에 종료 오버레이 추가
    return Stack(
      alignment: Alignment.center,
      children: [
        imageWidget,
        if (isEnded) // 종료된 경우에만 오버레이 표시 (탭은 통과)
          IgnorePointer(
            ignoring: true,
            child: Container(
              height: imageHeight,
              width: 220,
              color: Colors.black.withValues(alpha: 0.5), // 반투명 검은색 배경
              child: Center(
                child: Text(
                  'auctions.card.ended'.tr(), // "경매 종료" 텍스트 (다국어)
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- 하단 메타 (제목 + 지역 + 현재가) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 124 = 116

    // MD: "보조=지역"
    //
    final location =
        auction.locationParts?['kab'] ?? auction.locationParts?['kota'] ?? '';

    // MD: "배지=현재가"
    //
    final priceFormat = NumberFormat.currency(
        locale: context.locale.toString(), symbol: 'Rp ', decimalDigits: 0);
    final currentBidString = priceFormat.format(auction.currentBid);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목"
            Text(
              auction.title, //
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // MD: "보조=지역"
            Text(
              location,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // MD: "배지=현재가"
            Text(
              currentBidString,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // 강조 색상
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

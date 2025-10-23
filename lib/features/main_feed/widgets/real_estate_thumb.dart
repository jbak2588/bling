// lib/features/main_feed/widgets/real_estate_thumb.dart
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/screens/room_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 지원
import 'package:bling_app/core/utils/address_formatter.dart'; // 주소 단축 유틸

/// [개편] 11단계: 메인 피드용 표준 썸네일 (RealEstate 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 전환 (setState 방식)
/// 3. Real Estate 규칙: 제목 / 보조=주소 단축 / 배지=월세/매매가
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class RealEstateThumb extends StatelessWidget {
  final RoomListingModel room;
  final Function(Widget, String) onIconTap; // 네비게이션 콜백

  const RealEstateThumb({
    super.key,
    required this.room,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          // ✅ [Final Fix] Navigator.push 대신 onIconTap 콜백 사용
          final detailScreen = RoomDetailScreen(room: room);
          onIconTap(detailScreen, 'main.tabs.realEstate'); // 타이틀 키 전달
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
              // 2. 하단 메타 (제목, 주소 단축, 가격)
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
    const double imageHeight = 116.0;
    //
    final imageUrl = (room.imageUrls.isNotEmpty) ? room.imageUrls.first : null;

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
                  child: Icon(Icons.house_outlined,
                      color: Colors.grey[400], size: 40)),
            ),
          )
        : Container(
            // 이미지가 없는 경우 플레이스홀더
            height: imageHeight, width: 220, color: Colors.grey[200],
            child: Center(
                child: Icon(Icons.house_outlined,
                    color: Colors.grey[400], size: 40)),
          );
  }

  // --- 하단 메타 (제목 + 주소 단축 + 가격) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 124 = 116

    // MD: "보조=주소 단축"
    //
    final shortAddress = AddressFormatter.toSingkatan(
        room.locationName ?? ''); // AddressFormatter 사용

    // MD: "배지=월세/매매가"
    //
    final priceFormat = NumberFormat.currency(
        locale: context.locale.toString(), symbol: 'Rp ', decimalDigits: 0);
    final priceString = priceFormat.format(room.price);
    // 가격 단위 (monthly, yearly 등) - 다국어 키 필요 (예: 'realEstate.priceUnit.monthly')
    final priceUnitString = 'realEstate.priceUnit.${room.priceUnit}'.tr();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목"
            Text(
              room.title, //
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // MD: "보조=주소 단축"
            Text(
              shortAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // MD: "배지=월세/매매가"
            Text(
              '$priceString / $priceUnitString', // 예: "Rp 1.000.000 / 월"
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // 강조 색상
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

// lib/features/main_feed/widgets/lost_item_thumb.dart
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_item_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 지원

/// [개편] 10단계: 메인 피드용 표준 썸네일 (LostItem 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 전환 (setState 방식)
/// 3. Lost&Found 규칙: 제목(물건 설명) / 보조=장소 설명
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class LostItemThumb extends StatelessWidget {
  final LostItemModel item;
  final Function(Widget, String) onIconTap; // 네비게이션 콜백

  const LostItemThumb({
    super.key,
    required this.item,
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
          final detailScreen = LostItemDetailScreen(item: item);
          onIconTap(detailScreen, 'main.tabs.lostAndFound'.tr()); // 타이틀 키 전달
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
              // 2. 하단 메타 (물건 설명, 장소 설명)
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
    final imageUrl = (item.imageUrls.isNotEmpty) ? item.imageUrls.first : null;

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
                  child: Icon(
                      item.type == 'lost'
                          ? Icons.help_outline
                          : Icons.location_searching,
                      color: Colors.grey[400],
                      size: 40)),
            ),
          )
        : Container(
            // 이미지가 없는 경우 플레이스홀더
            height: imageHeight, width: 220, color: Colors.grey[200],
            child: Center(
                child: Icon(
                    item.type == 'lost'
                        ? Icons.help_outline
                        : Icons.location_searching,
                    color: Colors.grey[400],
                    size: 40)),
          );
  }

  // --- 하단 메타 (물건 설명 + 장소 설명) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 124 = 116
    final titleStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.grey[600]);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목" (itemDescription)
            //
            Text(
              item.itemDescription,
              style: titleStyle,
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(), // 내용이 짧을 경우 아래로 밀기
            // MD: "보조=장소" (locationDescription)
            //
            Text(
              item.locationDescription,
              style: subtitleStyle,
              maxLines: 2, // 장소 설명도 최대 2줄
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

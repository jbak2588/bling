// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 카드. 대표 이미지, 분실/습득 유형, 위치, 현상금 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 분실/습득 유형, 위치, 현상금 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
// =====================================================
// lib/features/lost_and_found/widgets/lost_item_card.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 카드. 대표 이미지, 분실/습득 유형, 위치, 현상금 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 분실/습득 유형, 위치, 현상금 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
// =====================================================

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_item_detail_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
// ✅ [작업 44] 현상금 포맷을 위해 추가

// ✅ StatelessWidget을 StatefulWidget으로 변경
class LostItemCard extends StatefulWidget {
  final LostItemModel item;
  const LostItemCard({super.key, required this.item});

  @override
  State<LostItemCard> createState() => _LostItemCardState();
}

class _LostItemCardState extends State<LostItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // ✅ 상태 유지

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ KeepAlive를 위해 호출
    final item = widget.item; // ✅ item 참조 방식 변경
    final Color typeColor =
        item.type == 'lost' ? Colors.redAccent : Colors.blueAccent;
    final bool isLost = item.type == 'lost';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // ✅ [작업 41] Stack 유지 (향후 오버레이 확장 가능); 현재는 내부 레이아웃에서 배지 처리
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => LostItemDetailScreen(item: item)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(item.type == 'lost'
                        ? 'lostAndFound.lost'.tr()
                        : 'lostAndFound.found'.tr()),
                    backgroundColor: typeColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                        color: typeColor, fontWeight: FontWeight.bold),
                    side: BorderSide(color: typeColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ 기존 이미지를 공용 이미지 캐러셀로 교체
                      if (item.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ImageCarouselCard(
                            imageUrls: item.imageUrls,
                            storageId: item.id,
                            width: 80,
                            height: 80,
                          ),
                        ),
                      if (item.imageUrls.isNotEmpty) const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목 단독 표시 후, 배지는 다음 줄에서 Wrap 처리하여 오버플로우 방지
                            Text(
                              item.itemDescription,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (item.isResolved)
                                  _ResolvedBadge(
                                    text: isLost
                                        ? 'lostAndFound.resolve.badgeLost'.tr()
                                        : 'lostAndFound.resolve.badgeFound'
                                            .tr(),
                                    color:
                                        isLost ? Colors.green : Colors.orange,
                                  ),
                                if (item.isHunted &&
                                    (item.bountyAmount ?? 0) > 0)
                                  Chip(
                                    label: Text(
                                      'Rp ${NumberFormat.compact(locale: context.locale.toString()).format(item.bountyAmount)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    visualDensity: VisualDensity.compact,
                                    avatar: const Icon(Icons.paid_outlined,
                                        color: Colors.white, size: 14),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'lostAndFound.card.location'.tr(namedArgs: {
                                'location': item.locationDescription
                              }),
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // ✅ [작업 42] 3. 통계 (조회수, 댓글) 표시
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.viewsCount.toString(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        item.commentsCount.toString(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // (오버레이 스크림 제거) - 스택은 유지하되, 배지를 제목 옆으로 이동하여 더 자연스러운 UX 제공
        ],
      ),
    );
  }
}

// 제목 옆에 표시되는 작고 따뜻한 톤의 해결 배지
class _ResolvedBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _ResolvedBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

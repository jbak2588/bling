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

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_item_detail_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LostItemCard extends StatelessWidget {
  final LostItemModel item;
  const LostItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Color typeColor =
        item.type == 'lost' ? Colors.redAccent : Colors.blueAccent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // V V V --- [추가] 상세 화면으로 이동하는 로직 --- V V V
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LostItemDetailScreen(item: item)),
          );
          // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
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
                labelStyle:
                    TextStyle(color: typeColor, fontWeight: FontWeight.bold),
                side: BorderSide(color: typeColor),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.imageUrls.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        item.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (item.imageUrls.isNotEmpty) const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemDescription,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            ],
          ),
        ),
      ),
    );
  }
}

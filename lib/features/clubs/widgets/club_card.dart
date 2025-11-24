// lib/features/clubs/widgets/club_card.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 동호회 카드에는 각 동호회의 제목, 대표 이미지, 위치, 멤버 수 등 요약 정보가 표시됩니다.
//
// [구현 요약]
// - 동호회 이미지, 제목, 설명, 위치, 멤버 수를 표시합니다.
// - 탭 시 상세 동호회 화면으로 이동합니다.
//
// [차이점 및 부족한 부분]
// - 신뢰 등급, 비공개 여부, 관심사 등 추가 정보와 운영자 기능(관리/수정) 표시가 부족합니다.
//
// [개선 제안]
// - 카드에 신뢰 등급, 비공개, 관심사 태그 등 추가 정보 표시.
// - 운영자를 위한 빠른 관리/수정 액션 지원.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) 기획서 6.1.5 '수익 모델' 반영.
// 2. 'club.isSponsored'가 true일 때 '스폰서' 배지(라벨)를 표시하는 UI 추가.
// =====================================================

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/i18n/strings.g.dart';

// ✅ 1. StatelessWidget을 StatefulWidget으로 변경합니다.
class ClubCard extends StatefulWidget {
  final ClubModel club;
  const ClubCard({super.key, required this.club});

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard>
    with AutomaticKeepAliveClientMixin {
  // ✅ 3. wantKeepAlive를 true로 설정하여 카드 상태를 유지합니다.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // ✅ 4. super.build(context)를 호출합니다.
    super.build(context); // ✅ KeepAlive를 위해 호출

    // State 클래스 내에서는 widget.club으로 데이터에 접근합니다.
    final club = widget.club;
    final now = DateTime.now();
    final bool hasExpired =
        club.adExpiryDate != null && club.adExpiryDate!.toDate().isBefore(now);
    final bool showSponsored = club.isSponsored && !hasExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. 대표 이미지 (기존과 동일) ---
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: club.imageUrl != null && club.imageUrl!.isNotEmpty
                    ? Image.network(
                        club.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),
              // --- 2. 텍스트 정보 (기존과 동일) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [추가] 스폰서 배지 (만료일 체크)
                    if (showSponsored)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(t.common.sponsored,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    Text(
                      club.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          Icons.group_outlined,
                          t.clubs.card.membersCount.replaceAll(
                              '{count}', club.membersCount.toString()),
                        ),
                        _buildInfoChip(
                          Icons.location_on_outlined,
                          club.location,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        ),
      ),
    );
  }

  // [추가] 이미지 플레이스홀더 위젯
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(Icons.groups, size: 40, color: Colors.grey.shade400),
    );
  }

  // [추가] 정보 칩 위젯
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}

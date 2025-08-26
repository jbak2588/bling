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

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  const ClubCard({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          // V V V --- [수정] 이미지를 포함하기 위해 Row 위젯으로 구조 변경 --- V V V
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. 대표 이미지 ---
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
              // --- 2. 텍스트 정보 ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(Icons.group_outlined, 'clubs.card.membersCount'.tr(namedArgs: {'count': club.membersCount.toString()})),
                        _buildInfoChip(Icons.location_on_outlined, club.location),
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
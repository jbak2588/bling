// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) '모임 제안' 탭 UI를 위해 신규 생성.
// 2. 'ClubProposalModel' 데이터를 받아 UI에 표시합니다.
// 3. [핵심] 'LinearPercentIndicator'를 사용하여 (현재 인원 / 목표 인원) 달성률을 시각화합니다.
// =====================================================
// lib/features/clubs/widgets/club_proposal_card.dart

import 'package:bling_app/features/clubs/models/club_proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:bling_app/features/clubs/screens/club_proposal_detail_screen.dart';

// [신규] '모임 제안'을 표시하기 위한 카드 위젯
class ClubProposalCard extends StatelessWidget {
  final ClubProposalModel proposal;
  const ClubProposalCard({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    double progress = proposal.currentMemberCount / proposal.targetMemberCount;
    if (progress > 1.0) progress = 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ClubProposalDetailScreen(proposal: proposal),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaceholderImage(proposal.imageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [추가] 비공개 제안 배지
                        if (proposal.isPrivate)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 14, color: Colors.orange[800]),
                                const SizedBox(width: 4),
                                Text('clubs.card.private'.tr(),
                                    style: TextStyle(
                                        color: Colors.orange[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        Text(
                          proposal.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proposal.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // [핵심] 인원 달성 현황
              Text(
                'clubs.proposal.memberStatus'.tr(namedArgs: {
                  'current': proposal.currentMemberCount.toString(),
                  'target': proposal.targetMemberCount.toString()
                }), // "{current}명 / {target}명"
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                percent: progress,
                lineHeight: 8.0,
                backgroundColor: Colors.grey[200],
                progressColor: Theme.of(context).primaryColor,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    proposal.location,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(Icons.groups_2_outlined,
            size: 40, color: Colors.grey.shade400),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

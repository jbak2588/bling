// lib/features/clubs/widgets/club_card.dart

import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart';
import 'package:flutter/material.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  const ClubCard({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 탭하면 ClubDetailScreen으로 이동하며, 선택된 club 정보를 전달합니다.
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                club.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 멤버 수
                  Row(
                    children: [
                      Icon(Icons.group_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${club.membersCount} members'), // TODO: 다국어
                    ],
                  ),
                  // 활동 지역
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(club.location),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
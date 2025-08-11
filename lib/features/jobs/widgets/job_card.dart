// lib/features/jobs/widgets/job_card.dart

import 'package:bling_app/core/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // TODO: '시급', '월급' 등 급여 정보를 모델에 추가하고 표시해야 합니다.
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              // TODO: 회사/가게 이름 필드 추가 필요
              job.locationName ?? '위치 정보 없음',
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              // TODO: 급여 정보 표시
              '시급: ${currencyFormat.format(100000)}', // 예시 데이터
              style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(job.category, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('몇 분 전', style: TextStyle(fontSize: 12, color: Colors.grey[600])), // TODO: 시간 포맷 함수 적용
              ],
            )
          ],
        ),
      ),
    );
  }
}
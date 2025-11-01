// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 카드. 대표 이미지, 제목, 급여, 위치 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 제목, 급여, 위치 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
// =====================================================
// lib/features/jobs/widgets/job_card.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 카드. 대표 이미지, 제목, 급여, 위치 등 요약 정보 표시, 상세 화면 연동.
//
// [실제 구현 비교]
// - 대표 이미지, 제목, 급여, 위치 등 모든 정보 정상 표시. 상세 화면 연동 및 UI/UX 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 신뢰 등급/차단/신고 UI 노출 및 기능 강화, 카드 UX 개선.
/// ============================================================================
/// 2025-10-31 (작업 36):
///   - 'Jobs' 피처 이원화(regular/quick_gig)에 따른 FAB(+) 버튼 로직 수정.
///   - 'AppSection.jobs' 케이스 및 '_showGlobalCreateSheet'의 '일자리' 항목이
///     'CreateJobScreen' 대신 'SelectJobTypeScreen'을 호출하도록 변경.
/// ============================================================================
library;
// (파일 내용...)

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/jobs/screens/job_detail_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// [추가] 숫자 포맷을 위해
import 'package:bling_app/features/jobs/constants/job_categories.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // InkWell 효과가 Card 모서리를 따르도록 함
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
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
                child: (job.imageUrls != null && job.imageUrls!.isNotEmpty)
                    ? Image.network(
                        job.imageUrls!.first,
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
                      job.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.locationName ?? 'jobs.card.noLocation'.tr(),
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      // 급여 정보 표시
                      job.jobType == JobType.quickGig.name
                          // 'quick_gig' (단순 일자리)
                          ? '${'jobs.form.totalPayLabel'.tr()}: ${currencyFormat.format(job.salaryAmount ?? 0)}' // '총 보수: 50,000'
                          // 'regular' (정규직)
                          : '${'jobs.salaryTypes.${job.salaryType ?? 'etc'}'.tr()}: ${currencyFormat.format(job.salaryAmount ?? 0)}', // '시급: 50,000'
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppJobCategories.getName(job.category),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        Text('jobs.card.minutesAgo'.tr(),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
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
      child: Icon(Icons.work_outline, size: 40, color: Colors.grey.shade400),
    );
  }
}

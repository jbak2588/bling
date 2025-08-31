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
// =====================================================

import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/jobs/screens/job_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ 공용 이미지 캐러셀 위젯을 import 합니다.
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';

// ✅ 1. StatelessWidget을 StatefulWidget으로 변경합니다.
class JobCard extends StatefulWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

// ✅ 2. State 클래스를 만들고 with AutomaticKeepAliveClientMixin을 추가합니다.
class _JobCardState extends State<JobCard> with AutomaticKeepAliveClientMixin {

  // ✅ 3. wantKeepAlive를 true로 설정하여 카드 상태를 유지합니다.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // ✅ 4. super.build(context)를 호출해야 합니다.
    super.build(context);
    
    // State 클래스 내에서는 widget.job으로 데이터에 접근합니다.
    final job = widget.job; 
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 5. 대표 이미지를 공용 ImageCarouselCard 위젯으로 교체합니다.
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: (job.imageUrls != null && job.imageUrls!.isNotEmpty)
                    ? ImageCarouselCard(
                        imageUrls: job.imageUrls!,
                        width: 80,
                        height: 80,
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),
              // --- 2. 텍스트 정보 (기존과 동일) ---
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
                      '${'jobs.salaryTypes.${job.salaryType ?? 'etc'}'.tr()}: ${currencyFormat.format(job.salaryAmount ?? 0)}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('jobs.categories.${job.category}'.tr(),
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
        ),
      ),
    );
  }

  // State 클래스 내부의 헬퍼 메서드로 유지합니다.
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
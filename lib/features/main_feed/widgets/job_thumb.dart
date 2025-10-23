// lib/features/main_feed/widgets/job_thumb.dart
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/jobs/screens/job_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ 이미지 위젯 import
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // 다국어 지원

/// [개편] 6단계: 메인 피드용 표준 썸네일 (Job 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Job 전용 규칙: 제목 / 보조=지역 / 배지=급여(한 줄)
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더 (Job은 이미지가 없으므로 아이콘으로 대체)
class JobThumb extends StatelessWidget {
  final JobModel job;
  const JobThumb({super.key, required this.job});

  // 급여 정보를 포맷하는 헬퍼 함수
  String _formatSalary(BuildContext context) {
    //
    final type = job.salaryType;
    final amount = job.salaryAmount;
    final negotiable = job.isSalaryNegotiable;

    if (type == null || amount == null) {
      return 'jobs.form.salaryNegotiable'.tr(); // 급여 협의 (기본값)
    }

    final currencyFormat = NumberFormat.currency(
        locale: context.locale.toString(), symbol: '', decimalDigits: 0);
    String formattedAmount = currencyFormat.format(amount);

    String prefix;
    switch (type) {
      case 'hourly':
        // ✅ [수정] i18n 키 경로 수정
        prefix = 'jobs.salaryTypes.hourly'.tr();
        break;
      case 'daily':
        // ✅ [수정] i18n 키 경로 수정
        prefix = 'jobs.salaryTypes.daily'.tr();
        break;
      case 'weekly':
        // ✅ [수정] i18n 키 경로 수정 (weekly 키가 json에 없다면 추가 필요)
        prefix = 'jobs.salaryTypes.weekly'.tr(); // 'weekly' 키가 없으면 기본값 표시됨
        break;
      case 'monthly':
        // ✅ [수정] i18n 키 경로 수정
        prefix = 'jobs.salaryTypes.monthly'.tr();
        break;
      case 'yearly':
        // ✅ [수정] i18n 키 경로 수정 (yearly 키가 json에 없다면 추가 필요)
        prefix = 'jobs.salaryTypes.yearly'.tr(); // 'yearly' 키가 없으면 기본값 표시됨
        break;
      default:
        prefix = type; // 알 수 없는 타입은 그대로 표시
    }

    // 인도네시아어의 경우 통화 기호(Rp)를 뒤에 붙임
    String currencySymbol =
        (context.locale.languageCode == 'id') ? ' Rp' : 'Rp ';
    if (context.locale.languageCode == 'id') {
      formattedAmount = '$prefix $formattedAmount$currencySymbol';
    } else {
      formattedAmount = '$prefix $currencySymbol$formattedAmount';
    }

    if (negotiable) {
      // ✅ [수정] 정의되지 않은 Short 키 대신 full 키를 사용하고 괄호로 감쌈
      formattedAmount += ' (${'jobs.form.salaryNegotiable'.tr()})';
    }

    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          // MD: "썸네일 탭 → 해당 feature의 _detail_screen.dart 'ontop push'"
          Navigator.of(context).push(
            MaterialPageRoute(
              //
              builder: (_) => JobDetailScreen(job: job),
            ),
          );
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
              // ✅ [수정] 이미지가 있으면 이미지 표시, 없으면 아이콘 표시
              (job.imageUrls != null && job.imageUrls!.isNotEmpty)
                  ? _buildImageContent(context, job.imageUrls!.first)
                  : _buildIconArea(context),
              // 2. 하단 메타 (제목, 지역, 급여)
              _buildMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ [추가] 이미지 표시 위젯 (_buildImageContent)
  Widget _buildImageContent(BuildContext context, String imageUrl) {
    // 16:9 비율 유지
    const double imageHeight = 124.0;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: imageHeight,
      width: 220,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: imageHeight,
        width: 220,
        color: Colors.grey[200],
        // child: const Center(child: CircularProgressIndicator()), // Placeholder 제거
      ),
      errorWidget: (context, url, error) => Container(
        // 에러 시 아이콘 영역 표시
        height: imageHeight,
        width: 220,
        color: Colors.blueGrey[50],
        child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400])),
      ),
    );
  }

  // --- 상단 아이콘 영역 ---
  Widget _buildIconArea(BuildContext context) {
    // 상단 영역 높이 조절 (이미지 대신 아이콘 사용)
    const double iconAreaHeight = 124.0;

    return Container(
      height: iconAreaHeight,
      width: 220,
      color: Colors.blueGrey[50], // 연한 배경색
      child: Center(
        child: Icon(
          Icons.work_outline, // 구인/구직 아이콘
          size: 50,
          color: Colors.blueGrey[300],
        ),
      ),
    );
  }

  // --- 하단 메타 (제목 + 지역 + 급여) ---
  Widget _buildMeta(BuildContext context) {
    // 하단 영역 높이: 240 - 124 = 116

    // MD: "보조=지역"
    //
    final location =
        job.locationParts?['kab'] ?? job.locationParts?['kota'] ?? '';

    // MD: "배지=급여(한 줄)"
    final salaryString = _formatSalary(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목"
            Text(
              job.title, //
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // MD: "보조=지역"
            Text(
              location,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // MD: "배지=급여(한 줄)"
            Text(
              salaryString,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor, // 강조 색상
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

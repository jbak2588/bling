import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/jobs/constants/job_categories.dart';

import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/screens/talent_detail_screen.dart';

class TalentCard extends StatelessWidget {
  final TalentModel talent;

  const TalentCard({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    // [수정] JobCard와 동일한 포맷터 사용 (없으면 기본값 사용)
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // [대안] Card 위젯 사용하되 margin 제거 및 하단 구분선 추가
    return Card(
      margin: EdgeInsets.zero, // 마진 제거하여 꽉 채움
      elevation: 0, // 그림자 제거 (깔끔한 리스트 스타일)
      shape:
          const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))), // 하단 구분선
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TalentDetailScreen(talent: talent)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 내부 패딩만 유지
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 좌측 썸네일 (JobCard 스타일)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: talent.portfolioUrls.isNotEmpty
                    ? Image.network(
                        talent.portfolioUrls.first,
                        width: 80, // JobCard 썸네일 너비
                        height: 80, // JobCard 썸네일 높이
                        fit: BoxFit.cover,
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),

              // 2. 우측 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // [카테고리] (상단 왼쪽 배지)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 177, 79, 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'jobs.selectType.talent.title'.tr(), // "전문가"
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF00B14F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // [제목] (최대 2줄)
                    Text(
                      talent.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // [위치 정보]
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            talent.locationName ?? 'location.unknown'.tr(),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // [가격 정보] (하단 강조)
                    Text(
                      '${currencyFormat.format(talent.price)} / ${talent.priceUnit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),
                    // 하단 Row: 카테고리명(left) / 시간(right) — job_card와 동일한 위치
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppJobCategories.getName(talent.category),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                        Text(_formatTimeAgo(talent.createdAt.toDate()),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(Icons.verified_user_outlined,
          size: 30, color: Colors.grey.shade400),
    );
  }

  // 시간 포맷 헬퍼: existing `time.*` i18n keys are used
  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) {
      final pattern = 'time.dateFormat'.tr();
      try {
        return DateFormat(pattern).format(dateTime);
      } catch (_) {
        return DateFormat('yy.MM.dd').format(dateTime);
      }
    } else if (diff.inDays > 0) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    } else if (diff.inHours > 0) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    } else if (diff.inMinutes > 0) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    } else {
      return 'time.now'.tr();
    }
  }
}

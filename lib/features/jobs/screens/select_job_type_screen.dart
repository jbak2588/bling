/// ============================================================================
/// Bling DocHeader
/// Module        : Jobs
/// File          : lib/features/jobs/screens/select_job_type_screen.dart
/// Purpose       : 구인글 작성 시 '정규직'과 '단순 일자리' 유형을 선택하는 진입 화면.
///
/// 2025-10-31 (작업 32):
///   - '하이브리드 기획안' 3단계를 위해 신규 생성.
///   - '정규/파트타임' 선택 시 -> 'create_job_screen.dart' (JobType.regular)
///   - '단순/일회성 도움' 선택 시 -> 'create_quick_gig_screen.dart' (JobType.quickGig)
/// ============================================================================
library;
// (파일 내용...)

// lib/features/jobs/screens/select_job_type_screen.dart
import 'package:bling_app/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/job_categories.dart'; // ✅ 1단계에서 생성한 JobType enum import
import 'create_job_screen.dart'; // ✅ 2. 기존 '정규직' 폼
import 'create_quick_gig_screen.dart'; // ✅ 3. (다음 단계에 생성할) '단순 일자리' 폼

/// 'Jobs' 피처의 진입점으로, '정규직'과 '단순 일자리' 중 등록할 유형을 선택하는 화면
class SelectJobTypeScreen extends StatelessWidget {
  final UserModel userModel;
  const SelectJobTypeScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('jobs.selectType.title'.tr()), // '일자리 유형 선택'
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. 정규/파트타임 일자리 (알바천국) ---
            _buildTypeCard(
              context: context,
              icon: Icons.business_center_outlined,
              titleKey: 'jobs.selectType.regularTitle', // '정규/파트타임 일자리'
              descriptionKey:
                  'jobs.selectType.regularDesc', // '카페, 식당, 오피스 등 정기적인 근무'
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreateJobScreen(
                    userModel: userModel,
                    // ✅ 'regular' 타입의 폼임을 명시
                    jobType: JobType.regular,
                  ),
                ));
              },
            ),
            const SizedBox(height: 16),

            // --- 2. 단순/일회성 도움 (당근 심부름) ---
            _buildTypeCard(
              context: context,
              icon: Icons.directions_run_rounded,
              titleKey: 'jobs.selectType.quickGigTitle', // '단순/일회성 도움'
              descriptionKey:
                  'jobs.selectType.quickGigDesc', // '오토바이 배송, 짐 옮기기, 청소 등'
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreateQuickGigScreen(
                    userModel: userModel,
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 선택 카드 UI 헬퍼
  Widget _buildTypeCard({
    required BuildContext context,
    required IconData icon,
    required String titleKey,
    required String descriptionKey,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptionKey.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

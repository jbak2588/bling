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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// Models
import 'package:bling_app/core/models/user_model.dart';

// Screens
import 'create_job_screen.dart';
import 'create_quick_gig_screen.dart';
import 'create_talent_screen.dart';

// Utils
// utils: removed unused imports after refactor

class SelectJobTypeScreen extends StatelessWidget {
  final UserModel userModel; // [수정] 필수 파라미터 추가

  const SelectJobTypeScreen({
    super.key,
    required this.userModel, // [수정] 생성자 수정
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('jobs.selectType.title'.tr()), // "작성 유형 선택"
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'jobs.selectType.subtitle'.tr(), // "어떤 게시글을 등록하시겠습니까?"
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),

            // 1. 직원/알바 (Hiring)
            _buildTypeCard(
              context: context,
              icon: Icons.store_mall_directory_rounded,
              color: Colors.blueAccent,
              titleKey: 'jobs.selectType.regular.title',
              descriptionKey: 'jobs.selectType.regular.desc',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // [수정] userModel 전달
                  builder: (_) => CreateJobScreen(userModel: userModel),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. 급한 도움 (Quick Gig)
            _buildTypeCard(
              context: context,
              icon: Icons.flash_on_rounded,
              color: Colors.orangeAccent,
              titleKey: 'jobs.selectType.quick.title',
              descriptionKey: 'jobs.selectType.quick.desc',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // [수정] userModel 전달
                  builder: (_) => CreateQuickGigScreen(userModel: userModel),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. 재능 판매 (Talent) - NEW
            _buildTypeCard(
              context: context,
              icon: Icons.verified_user_rounded,
              color: const Color(0xFF00B14F),
              titleKey: 'jobs.selectType.talent.title',
              descriptionKey: 'jobs.selectType.talent.desc',
              badgeKey: 'jobs.selectType.talent.badge',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // [수정] CreateTalentScreen에 userModel 전달 ('user' 파라미터명 사용)
                  builder: (_) => CreateTalentScreen(user: userModel),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String titleKey,
    required String descriptionKey,
    required VoidCallback onTap,
    String? badgeKey,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titleKey.tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeKey != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeKey.tr(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptionKey.tr(),
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600], height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

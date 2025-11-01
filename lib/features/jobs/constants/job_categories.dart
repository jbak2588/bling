/// ============================================================================
/// Bling DocHeader
/// Module        : Jobs
/// File          : lib/features/jobs/constants/job_categories.dart
/// Purpose       : 'Jobs' 피처에서 사용되는 모든 카테고리를 중앙에서 관리합니다.
///
/// 2025-10-31 (작업 31):
///   - '하이브리드 기획안' (알바천국 + 당근 심부름) 구현을 위해 신규 생성.
///   - 'JobType' enum (regular, quickGig)을 정의하여 일자리 유형 분리.
///   - 'AppJobCategories' 클래스에 '오토바이 배송', '짐 옮기기' 등 'quickGig' 유형 추가.
///   - 'getCategoriesByType(JobType type)' 헬퍼 함수 구현.
/// ============================================================================
library;
// (파일 내용...)

// lib/features/jobs/constants/job_categories.dart
// (신규 파일)

import 'package:easy_localization/easy_localization.dart';

/// 일자리 유형 ('알바천국' vs '당근 심부름')
enum JobType {
  regular, // 정규직/파트타임
  quickGig, // 단순/일회성
}

/// 단일 일자리 카테고리 모델
class JobCategory {
  final String id; // 예: 'service', 'quick_gig_delivery'
  final String nameKey; // 다국어 키 예: 'jobs.categories.service'
  final JobType jobType; // 'regular' 또는 'quick_gig'
  final String icon; // (옵션) 아이콘

  const JobCategory({
    required this.id,
    required this.nameKey,
    required this.jobType,
    this.icon = '🔹',
  });
}

/// 앱에서 사용되는 모든 일자리 카테고리 목록
class AppJobCategories {
  static final List<JobCategory> allCategories = [
    // --- 1. 'regular' (정규/파트타임) 일자리 ---
    JobCategory(
      id: 'service',
      nameKey: 'jobs.categories.service', // '서비스'
      jobType: JobType.regular,
      icon: '🛎️',
    ),
    JobCategory(
      id: 'sales_marketing',
      nameKey: 'jobs.categories.sales_marketing', // '영업/마케팅'
      jobType: JobType.regular,
      icon: '📈',
    ),
    JobCategory(
      id: 'delivery_logistics',
      nameKey: 'jobs.categories.delivery_logistics', // '배달/물류' (정규직)
      jobType: JobType.regular,
      icon: '🚚',
    ),
    JobCategory(
      id: 'it',
      nameKey: 'jobs.categories.it', // 'IT/기술'
      jobType: JobType.regular,
      icon: '💻',
    ),
    JobCategory(
      id: 'design',
      nameKey: 'jobs.categories.design', // '디자인'
      jobType: JobType.regular,
      icon: '🎨',
    ),
    JobCategory(
      id: 'education',
      nameKey: 'jobs.categories.education', // '교육'
      jobType: JobType.regular,
      icon: '📚',
    ),
    JobCategory(
      id: 'etc',
      nameKey: 'jobs.categories.etc', // '기타' (정규직)
      jobType: JobType.regular,
      icon: '📎',
    ),

    // --- 2. 'quick_gig' (단순/일회성) 일자리 ---
    JobCategory(
      id: 'quick_gig_delivery',
      nameKey: 'jobs.categories.quick_gig_delivery', // '오토바이 배송'
      jobType: JobType.quickGig,
      icon: '🛵',
    ),
    JobCategory(
      id: 'quick_gig_transport',
      nameKey: 'jobs.categories.quick_gig_transport', // '오토바이 이동 (Ojek)'
      jobType: JobType.quickGig,
      icon: '🙋‍♂️', // (아이콘 예시)
    ),
    JobCategory(
      id: 'quick_gig_moving',
      nameKey: 'jobs.categories.quick_gig_moving', // '짐 옮기기'
      jobType: JobType.quickGig,
      icon: '📦',
    ),
    JobCategory(
      id: 'quick_gig_cleaning',
      nameKey: 'jobs.categories.quick_gig_cleaning', // '청소/집안일'
      jobType: JobType.quickGig,
      icon: '🧹',
    ),
    JobCategory(
      id: 'quick_gig_queuing',
      nameKey: 'jobs.categories.quick_gig_queuing', // '줄서기'
      jobType: JobType.quickGig,
      icon: '🚶',
    ),
    JobCategory(
      id: 'quick_gig_etc',
      nameKey: 'jobs.categories.quick_gig_etc', // '기타 심부름'
      jobType: JobType.quickGig,
      icon: '💡',
    ),
  ];

  /// 특정 JobType에 해당하는 카테고리 목록만 가져옵니다.
  static List<JobCategory> getCategoriesByType(JobType type) {
    return allCategories.where((c) => c.jobType == type).toList();
  }

  /// ID로 카테고리 정보 찾기
  static JobCategory findById(String id) {
    return allCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => allCategories.firstWhere((c) => c.id == 'etc'), // 못찾으면 '기타'
    );
  }

  /// 다국어 이름 찾기 (Helper)
  static String getName(String id) {
    return findById(id).nameKey.tr();
  }
}

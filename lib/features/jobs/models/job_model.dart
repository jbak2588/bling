// lib/core/models/job_model.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 데이터 모델. Firestore jobs 컬렉션 구조와 1:1 매칭, 위치/신뢰 등급/급여/근무기간/이미지 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 모든 필드가 실제 Firestore 구조와 일치하며, 위치/신뢰 등급/급여/근무기간/이미지 등 완비.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 지원수, 부스트 등).
// - 신고/차단/신뢰 등급 필드 및 기능 강화, 데이터 유효성 검사 추가.
// =====================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// 지역 구인구직 게시글 정보를 담는 데이터 모델입니다.
/// Firestore의 `jobs` 컬렉션 문서 구조와 1:1로 대응됩니다.
class JobModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;
  final Timestamp createdAt;
  final String trustLevelRequired;
  final int viewsCount;
  final int likesCount;
  final bool isPaidListing;
  final String? salaryType; // 'hourly', 'daily', 'monthly', 'per_case'
  final int? salaryAmount;
  final bool isSalaryNegotiable;
  final String? workPeriod; // 'short_term', 'long_term' 등
  final String? workHours; // '월-금, 09:00-18:00' 등
  final List<String>? imageUrls;

  JobModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.locationName,
    this.locationParts,
    this.geoPoint,
    required this.createdAt,
    this.trustLevelRequired = 'normal',
    this.viewsCount = 0,
    this.likesCount = 0,
    this.isPaidListing = false,
    // [추가] 생성자에 추가
    this.salaryType,
    this.salaryAmount,
    this.isSalaryNegotiable = false,
    this.workPeriod,
    this.workHours,
    this.imageUrls,
  });

  factory JobModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'etc',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      trustLevelRequired: data['trustLevelRequired'] ?? 'normal',
      viewsCount: data['viewsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      isPaidListing: data['isPaidListing'] ?? false,
      salaryType: data['salaryType'],
      salaryAmount: data['salaryAmount'],
      isSalaryNegotiable: data['isSalaryNegotiable'] ?? false,
      workPeriod: data['workPeriod'],
      workHours: data['workHours'],
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'createdAt': createdAt,
      'trustLevelRequired': trustLevelRequired,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'isPaidListing': isPaidListing,
      'salaryType': salaryType,
      'salaryAmount': salaryAmount,
      'isSalaryNegotiable': isSalaryNegotiable,
      'workPeriod': workPeriod,
      'workHours': workHours,
      'imageUrls': imageUrls,
    };
  }
}

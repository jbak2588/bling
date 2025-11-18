// lib/features/admin/models/ai_case_model.dart
/// ============================================================================
/// Bling DocHeader (V3.1 AI Case Model, 2025-11-18)
/// Module        : Admin / Marketplace
/// File          : lib/features/admin/models/ai_case_model.dart
/// Purpose       : Firestore 'ai_cases' 컬렉션의 데이터 모델링.
///
/// [Schema Highlights]
/// - caseId, productId, sellerId, buyerId: 핵심 식별자.
/// - stage: 'enhancement'(등록) vs 'takeover'(인수).
/// - status/verdict: 진행 상태 및 AI/관리자의 최종 판정 결과.
/// - evidenceImageUrls: 현장 인수 시 촬영된 증거 사진 리스트 보존.
/// - aiResult: Gemini가 반환한 전체 분석 리포트(JSON Map).
/// ============================================================================
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class AiCaseModel {
  final String caseId;
  final String productId;
  final String sellerId;
  final String? buyerId;
  final String stage; // 'enhancement' | 'takeover'
  final String status; // 'pass' | 'fail' | 'completed' | 'pending'
  final String? verdict; // 'match_confirmed', 'safe', 'suspicious', etc.
  final List<String> evidenceImageUrls;
  final Map<String, dynamic>? aiResult;
  final Timestamp createdAt;

  AiCaseModel({
    required this.caseId,
    required this.productId,
    required this.sellerId,
    this.buyerId,
    required this.stage,
    required this.status,
    this.verdict,
    required this.evidenceImageUrls,
    this.aiResult,
    required this.createdAt,
  });

  factory AiCaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AiCaseModel(
      caseId: data['caseId'] ?? doc.id,
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      buyerId: data['buyerId'],
      stage: data['stage'] ?? 'unknown',
      status: data['status'] ?? 'pending',
      verdict: data['verdict'],
      evidenceImageUrls: List<String>.from(data['evidenceImageUrls'] ?? []),
      aiResult: data['aiResult'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

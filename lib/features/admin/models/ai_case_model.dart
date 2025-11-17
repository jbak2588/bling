// lib/features/admin/models/ai_case_model.dart

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

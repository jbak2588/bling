// lib/features/marketplace/models/ai_verification_rule_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// required_shots 맵의 각 항목을 나타내는 클래스
class RequiredShot {
  final String nameKo;
  final String descKo;

  RequiredShot({
    required this.nameKo,
    required this.descKo,
  });

  // Firestore Map -> RequiredShot 객체 변환
  factory RequiredShot.fromMap(Map<String, dynamic> map) {
    return RequiredShot(
      nameKo: map['name_ko'] ?? '',
      descKo: map['desc_ko'] ?? '',
    );
  }

  // RequiredShot 객체 -> Firestore Map 변환
  Map<String, dynamic> toMap() {
    return {
      'name_ko': nameKo,
      'desc_ko': descKo,
    };
  }
}

// 'ai_verification_rules' 컬렉션의 단일 문서를 나타내는 메인 클래스
class AiVerificationRule {
  final String id; // Firestore 문서 ID
  final String nameKo;
  final String nameId;
  final bool isAiVerificationSupported;
  final int minGalleryPhotos;
  final Map<String, RequiredShot> requiredShots;
  final String reportTemplatePrompt;
  final String initialAnalysisPromptTemplate;

  AiVerificationRule({
    required this.id,
    required this.nameKo,
    required this.nameId,
    required this.isAiVerificationSupported,
    required this.minGalleryPhotos,
    required this.requiredShots,
    required this.reportTemplatePrompt,
    required this.initialAnalysisPromptTemplate,
  });

  // DocumentSnapshot -> AiVerificationRule 객체 변환
  factory AiVerificationRule.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // requiredShots 맵 변환
    final shotsMap = data['required_shots'] as Map<String, dynamic>? ?? {};
    final requiredShots = shotsMap.map((key, value) {
      return MapEntry(key, RequiredShot.fromMap(value as Map<String, dynamic>));
    });

    return AiVerificationRule(
      id: doc.id,
      nameKo: data['name_ko'] ?? '',
      nameId: data['name_id'] ?? '',
      isAiVerificationSupported: data['is_ai_verification_supported'] ?? false,
      minGalleryPhotos: data['min_gallery_photos'] ?? 0,
      requiredShots: requiredShots,
      reportTemplatePrompt: data['report_template_prompt'] ?? '',
      initialAnalysisPromptTemplate:
          data['initial_analysis_prompt_template'] ?? '',
    );
  }

  // AiVerificationRule 객체 -> Firestore Map 변환
  Map<String, dynamic> toMap() {
    return {
      'name_ko': nameKo,
      'name_id': nameId,
      'is_ai_verification_supported': isAiVerificationSupported,
      'min_gallery_photos': minGalleryPhotos,
      'required_shots':
          requiredShots.map((key, value) => MapEntry(key, value.toMap())),
      'report_template_prompt': reportTemplatePrompt,
    };
  }
}

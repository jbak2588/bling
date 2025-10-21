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
  final Map<String, RequiredShot>
      suggestedShots; // [V2.1] 'required' -> 'suggested'로 변경
  final String reportTemplatePrompt;
  final String initialAnalysisPromptTemplate;

  AiVerificationRule({
    required this.id,
    required this.nameKo,
    required this.nameId,
    required this.isAiVerificationSupported,
    required this.minGalleryPhotos,
    required this.suggestedShots,
    required this.reportTemplatePrompt,
    required this.initialAnalysisPromptTemplate,
  });

  // DocumentSnapshot -> AiVerificationRule 객체 변환
  factory AiVerificationRule.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // [V2.1] Firestore에서도 suggested_shots 필드를 읽도록 변경
    final shotsMap = data['suggested_shots'] as Map<String, dynamic>? ?? {};
    final requiredShots = shotsMap.map((key, value) {
      return MapEntry(key, RequiredShot.fromMap(value as Map<String, dynamic>));
    });

    return AiVerificationRule(
      id: doc.id,
      nameKo: data['name_ko'] ?? '',
      nameId: data['name_id'] ?? '',
      isAiVerificationSupported: data['is_ai_verification_supported'] ?? false,
      minGalleryPhotos: data['min_gallery_photos'] ?? 0,
      suggestedShots: requiredShots,
      reportTemplatePrompt: data['report_template_prompt'] ?? '',
      initialAnalysisPromptTemplate:
          data['initial_analysis_prompt_template'] ?? '',
    );
  }

  // AiVerificationRule 객체 -> Firestore Map 변환
  Map<String, dynamic> toMap() {
    // [V2.1] suggestedShots 맵을 Firestore에 저장 가능한 형태로 변환
    final shotsToMap = suggestedShots.map((key, value) {
      return MapEntry(key, value.toMap());
    });

    return {
      'name_ko': nameKo,
      'name_id': nameId,
      'is_ai_verification_supported': isAiVerificationSupported,
      'min_gallery_photos': minGalleryPhotos,
      'suggested_shots':
          shotsToMap, // [V2.1] Firestore에도 suggested_shots 필드로 저장
      'report_template_prompt': reportTemplatePrompt,
      'initial_analysis_prompt_template': initialAnalysisPromptTemplate,
    };
  }

  // [추가] toMap()을 호출하는 toJson() 메소드. JSON 직렬화를 위한 표준 명칭.
  Map<String, dynamic> toJson() {
    return toMap();
  }
}

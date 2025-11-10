// lib/features/marketplace/ai/ai_rule_uploader_from_json.dart
// 설명(1~2줄): assets/ai/ai_rules_v2.json을 읽어 Firestore에 규칙 문서들을 업로드합니다.

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AiRuleUploaderFromJson {
  final FirebaseFirestore _db;
  AiRuleUploaderFromJson(this._db);

  Future<void> uploadAll() async {
    debugPrint("AI 규칙: assets/ai/ai_rules_v2.json 로드 중...");
    // 1) JSON 자산 로드
    final raw = await rootBundle.loadString('assets/ai/ai_rules_v2.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final List rules = (data['rules'] as List?) ?? const [];

    debugPrint("AI 규칙: ${rules.length}개 규칙 Firestore 업로드 시작...");
    // 2) 배치 업로드
    final batch = _db.batch();
    final col = _db.collection('ai_verification_rules');

    for (final r in rules) {
      if (r == null || r['id'] == null) continue;

      final docId = (r['id'] as String).trim();
      if (docId.isEmpty) continue;

      final docRef = col.doc(docId);

      // [Fix] JSON(camelCase) -> Firestore(snake_case) 변환
      // Transform suggestedShots inner keys (camelCase) -> snake_case expected by the model
      final rawShots = (r['suggestedShots'] as Map<String, dynamic>?) ?? {};
      final Map<String, dynamic> transformedShots = {};
      rawShots.forEach((shotKey, shotValue) {
        if (shotValue is Map<String, dynamic>) {
          transformedShots[shotKey] = {
            'name_ko': shotValue['nameKo'] ?? shotValue['name_ko'] ?? '',
            'name_en': shotValue['nameEn'] ??
                shotValue['name_en'] ??
                '', // [Fix] nameEn 읽기
            'desc_ko': shotValue['descKo'] ?? shotValue['desc_ko'] ?? '',
            'name_id': shotValue['nameId'] ??
                shotValue['name_id'] ??
                shotValue['nameKo'] ??
                '',
            'desc_id': shotValue['descId'] ?? shotValue['desc_id'] ?? '',
            'desc_en': shotValue['descEn'] ??
                shotValue['desc_en'] ??
                '', // [Fix] descEn 읽기
          };
        }
      });

      final jsonMap = {
        'id': r['id'], // 'id'는 Firestore 문서 ID이므로 snake_case 불필요
        'name_ko': r['nameKo'],
        'name_en':
            r['nameEn'] ?? r['name_en'] ?? r['nameKo'] ?? '', // [Fix] nameEn 읽기
        'name_id': r['nameId'],
        'is_ai_verification_supported': r['isAiVerificationSupported'],
        'min_gallery_photos': r['minGalleryPhotos'],
        'suggested_shots': transformedShots, // 'suggested_shots' (snake_case)
        'initial_analysis_prompt_template': r[
            'initialAnalysisPromptTemplate'], // 'initial_analysis_prompt_template' (snake_case)
        'report_template_prompt':
            r['reportTemplatePrompt'], // 'report_template_prompt' (snake_case)
      };

      batch.set(docRef, jsonMap);
    }

    await batch.commit();
    debugPrint("✅ AI 규칙: ${rules.length}개 규칙 Firestore 업로드 완료.");
  }
}

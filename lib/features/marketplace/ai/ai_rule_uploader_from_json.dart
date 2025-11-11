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

      // [Fix] 생성기(JS)가 이미 snake_case로 생성하므로, 변환 로직 제거
      final jsonMap = {
        'id': r['id'], // 'id'는 Firestore 문서 ID이므로 snake_case 불필요
        'name_ko': r['nameKo'] ?? '',
        'name_en': r['nameEn'] ?? '',
        'name_id': r['nameId'] ?? '',
        'is_ai_verification_supported': r['isAiVerificationSupported'],
        'min_gallery_photos': r['minGalleryPhotos'],
        // 생성기에서 이미 snake_case로 제공된 값을 그대로 사용
        'suggested_shots': r['suggested_shots'] ?? {},
        'initial_analysis_prompt_template':
            r['initial_analysis_prompt_template'] ?? '',
        'report_template_prompt': r['report_template_prompt'] ?? '',
      };

      batch.set(docRef, jsonMap);
    }

    await batch.commit();
    debugPrint("✅ AI 규칙: ${rules.length}개 규칙 Firestore 업로드 완료.");
  }
}

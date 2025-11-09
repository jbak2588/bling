import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bling_app/firebase_options.dart';

// 이 파일은 관리자 메뉴 또는 개발자가 직접 실행하여 Firestore의 AI 규칙을
// V2 시스템에 맞는 '범용 규칙' 하나로 깨끗하게 초기화하는 최종 스크립트입니다.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final uploader = AiRuleUploader();
  await uploader.uploadInitialRules();
}

class AiRuleUploader {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // main_navigation_screen.dart 의 관리자 메뉴에서 호출하는 최종 함수
  Future<void> uploadInitialRules() async {
    final rulesCollection = _db.collection('ai_verification_rules');

    debugPrint("[AI 규칙 V2.1 마이그레이션 시작]");

    // V2.1 규칙 목록 생성 (범용 + 스마트폰 전용)
    final List<AiVerificationRule> rulesToUpload = [
      _getGenericV2Rule(),
      _getSmartphoneV2Rule(),
    ];

    debugPrint("새로운 V2.1 규칙들을 업로드합니다...");
    try {
      // WriteBatch를 사용하여 모든 규칙을 한 번에 업로드 (원자적 연산)
      WriteBatch batch = _db.batch();
      for (final rule in rulesToUpload) {
        batch.set(rulesCollection.doc(rule.id), rule.toJson());
      }
      await batch.commit();
      debugPrint(
          '✅ 성공: ${rulesToUpload.length}개의 AI 검수 V2.1 규칙이 성공적으로 Firestore에 업로드되었습니다.');
    } catch (e) {
      debugPrint('❌ 실패: AI 검수 V2.1 규칙 업로드 실패: $e');
    }
  }

  // index.js 서버와 100% 호환되는 최종 프롬프트가 포함된 규칙 생성 함수
  AiVerificationRule _getGenericV2Rule() {
    // 1단계: 상품명 예측을 위한 프롬프트 (기존과 동일)
    const initialPrompt = '''
Analyze the provided images and return only a JSON object with the predicted item name. Do not include any other text. The JSON format must be: {"predicted_item_name": "PREDICTED_NAME"}''';

    // 2단계: 최종 AI 보고서 생성을 위한 프롬프트 (서버 변수와 완벽하게 일치)
    const v2ReportPrompt = '''
You are an expert product inspector for a marketplace, acting as a helpful assistant.
Your task is to verify a user's claims based on the information and evidence photos they provided.
Output a report in JSON format ONLY, in Indonesian.

**User's Input:**
- Product Name Claim: "{{confirmedProductName}}"
- Category: "{{categoryName}}"
- Sub-Category: "{{subCategoryName}}"
- User's Desired Price: "{{userPrice}}" IDR

**Your Instructions:**
1.  **Respect User Input:** Assume the user's "Product Name Claim" is correct. Your role is to find evidence in the photos to support it.
2.  **Dynamic Analysis:** Based on the given "Category" and "Sub-Category", identify 2-3 key specifications (e.g., for 'Smartphone', this would be 'Model' and 'Storage'; for 'Shoes', it would be 'Model' and 'Size'). Then, analyze the evidence photos to find values for these specs.
3.  **Objective Condition Check:** Objectively describe the visual condition of the item based on all provided photos. Note any visible scratches, dents, or signs of wear.
4.  **Suggest Market Price:** Based on all the information, suggest a reasonable used market price in Indonesian Rupiah (IDR).
5.  **JSON Output Only:** The entire response must be a single, valid JSON object.

{
  "verification_summary": "string (A brief summary confirming that you have analyzed the item based on user's claim and photos. Example: 'Berdasarkan klaim pengguna dan foto bukti, item telah diverifikasi sebagai...')",
  "key_specs": { "Spec 1 Name": "Value 1", "Spec 2 Name": "Value 2" },
  "condition_check": "string (A detailed, objective description of the item's condition based on the photos.)",
  "included_items": ["string array (List all items visible in the photos, e.g., 'Box', 'Charger')"],
  "suggested_price": "integer (Your suggested market price in IDR, numbers only)"
}
''';

    return AiVerificationRule(
      id: 'generic_v2', // 서버와 프론트엔드가 찾는 바로 그 ID
      nameKo: "범용 중고물품 검증 규칙 V2",
      nameId: "Aturan Verifikasi Barang Bekas Umum V2",
      isAiVerificationSupported: true,
      minGalleryPhotos: 1,
      suggestedShots: {}, // 범용 규칙이므로 추천샷 없음
      initialAnalysisPromptTemplate: initialPrompt,
      reportTemplatePrompt:
          v2ReportPrompt, // V1 필드명과의 호환성을 위해 reportTemplatePrompt 사용
    );
  }

  // [V2.1 신규] 스마트폰 전용 규칙 생성 함수
  AiVerificationRule _getSmartphoneV2Rule() {
    // 프롬프트는 범용 프롬프트를 그대로 재사용할 수 있습니다.
    // [Blocker-A Fix] 백엔드가 룰에서 직접 프롬프트를 읽으므로, 범용 룰의 프롬프트를 여기에 복사해야 합니다.
    final genericRule = _getGenericV2Rule();
    // V2.1의 핵심은 프롬프트가 아닌, 'suggestedShots' 데이터에 있습니다.

    return AiVerificationRule(
      id: 'smartphone-tablet', // 실제 카테고리 ID와 일치
      nameKo: "스마트폰/태블릿 전용 검증 규칙",
      nameId: "Aturan Verifikasi Khusus Smartphone/Tablet",
      isAiVerificationSupported: true,
      minGalleryPhotos: 1,
      suggestedShots: {
        'imei_shot': RequiredShot(
          nameKo: 'IMEI 정보 화면',
          descKo: '단말기 정보 또는 IMEI 화면을 촬영하면 신뢰도가 크게 상승합니다.',
        ),
        'battery_shot': RequiredShot(
          nameKo: '배터리 성능 화면',
          descKo: '배터리 성능 상태 화면을 촬영하여 구매자에게 정확한 정보를 제공하세요.',
        ),
        'info_shot': RequiredShot(
          nameKo: '기기 정보 화면',
          descKo: '설정 > 휴대전화 정보 화면을 촬영하여 모델명과 용량을 명확히 보여주세요.',
        ),
      },
      // initialAnalysisPromptTemplate, reportTemplatePrompt는 범용 규칙과 동일한 것을 사용하거나
      // 필요시 스마트폰에 더 특화된 프롬프트를 여기에 별도로 정의할 수 있습니다.
      initialAnalysisPromptTemplate: genericRule.initialAnalysisPromptTemplate,
      reportTemplatePrompt: genericRule.reportTemplatePrompt,
    );
  }
}

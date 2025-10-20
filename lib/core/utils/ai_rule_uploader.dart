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

    debugPrint("[AI 규칙 V2 마이그레이션 시작]");
    debugPrint("1. 기존의 모든 V1 AI 규칙을 삭제합니다...");
    final oldRules = await rulesCollection.get();
    WriteBatch deleteBatch = _db.batch();
    for (final doc in oldRules.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();
    debugPrint("=> 기존 규칙 삭제 완료.");

    // 최종 V2 범용 규칙 객체 생성
    final AiVerificationRule genericRule = _getFinalGenericV2Rule();

    debugPrint("2. 서버(index.js)와 호환되는 최종 V2 범용 규칙을 업로드합니다...");
    try {
      await rulesCollection.doc(genericRule.id).set(genericRule.toJson());
      debugPrint(
          '✅ 성공: AI 검수 V2 범용 규칙(`generic_v2`)이 성공적으로 Firestore에 업로드되었습니다.');
    } catch (e) {
      debugPrint('❌ 실패: AI 검수 V2 범용 규칙 업로드 실패: $e');
    }
  }

  // index.js 서버와 100% 호환되는 최종 프롬프트가 포함된 규칙 생성 함수
  AiVerificationRule _getFinalGenericV2Rule() {
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
      minGalleryPhotos: 1, // 모든 상품은 최소 1장의 사진만 있어도 검수 가능
      requiredShots: {}, // 범용 규칙이므로 특정 카테고리 전용 필수샷은 없음
      initialAnalysisPromptTemplate: initialPrompt,
      reportTemplatePrompt:
          v2ReportPrompt, // V1 필드명과의 호환성을 위해 reportTemplatePrompt 사용
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // [Fix] debugPrint
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

  final uploader = AiRuleUploader(FirebaseFirestore.instance);
  await uploader.uploadAll();
}

class AiRuleUploader {
  final FirebaseFirestore _db;
  AiRuleUploader(this._db);

  Future<void> uploadAll() async {
    final rulesCollection = _db.collection('ai_verification_rules');

    debugPrint("[AI 규칙 V2.1 마이그레이션 시작]");
    final generic = _getGenericV2Rule(); // [Fix #4] 1번만 생성

    // V2.1 규칙 목록 생성 (범용 + 스마트폰 전용)
    final List<AiVerificationRule> rulesToUpload = [
      generic,
      _getSmartphoneV2Rule(generic), // [Fix #4] 인스턴스 재사용
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
Output JSON in Indonesian only.

**User's Input:**
- Product Name Claim: "{{confirmedProductName}}"
- Category: "{{categoryName}}"
- Sub-Category: "{{subCategoryName}}"
- User Price: "{{userPrice}}"
 - Skipped Evidence: {{skipped_items}}

**Your Instructions:**
1) Respect user's claim. Try to support it with evidence.
2) Pick 2-3 key specs relevant to the sub-category (e.g., Shoes: Model, Size; Bag: Model, Material; Appliance: Model, Capacity).
3) Describe condition objectively (wear, scratch, dent).
4) List all visible included items.
5) Suggest reasonable market price in IDR (numbers only).
6) **notes_for_buyer** field IS MANDATORY.
   - If 'Skipped Evidence' is NOT empty, write a polite note in Indonesian suggesting the buyer verify those skipped items.
   - If 'Skipped Evidence' IS empty, return "notes_for_buyer": "".
   - Do NOT fabricate details for skipped items.

Return **one** JSON schema ONLY:
{
  "verification_summary": "string (A brief summary confirming that you have analyzed the item based on user's claim and photos.)",
  "key_specs": { "Spec 1 Name": "Value 1", "Spec 2 Name": "Value 2" },
  "condition_check": "string (A detailed, objective description of the item's condition based on the photos.)",
  "included_items": ["string array (List all items visible in the photos, e.g., 'Box', 'Charger')"],
  "suggested_price": 0,
  "notes_for_buyer": "string (empty if none)"
}
''';

    // [Fix] ⚠️ 이전에는 {} 였음 → 빈 제안으로 인해 missing_evidence_list가 항상 []이었음.
    final Map<String, RequiredShot> universalSuggestedShots = {
      // 공통: 전면/후면 전체샷
      'front_full': RequiredShot(
        nameKo: '전면 전체샷',
        descKo: '제품 전체가 보이도록 전면에서 촬영',
        nameId: 'Foto tampak depan',
        descId: 'Ambil foto seluruh barang dari depan',
      ),
      'back_full': RequiredShot(
        nameKo: '후면 전체샷',
        descKo: '제품 전체가 보이도록 후면에서 촬영',
        nameId: 'Foto tampak belakang',
        descId: 'Ambil foto seluruh barang dari belakang',
      ),
      // 식별/사이즈/모델
      'brand_model_tag': RequiredShot(
        nameKo: '브랜드/모델 태그',
        descKo: '라벨/택/금속각인/스티커 등 식별 태그 근접 촬영',
        nameId: 'Tag merek/model',
        descId: 'Foto dekat label/plat/ukiran/stiker identitas',
      ),
      'serial_or_size_label': RequiredShot(
        nameKo: '시리얼/사이즈 라벨',
        descKo: '전자: 시리얼/모델명 | 의류·신발: 사이즈 라벨 촬영',
        nameId: 'Label serial/ukuran',
        descId: 'Elektronik: serial/model | Pakaian/Sepatu: label ukuran',
      ),
      // 상태 확인
      'defect_closeups': RequiredShot(
        nameKo: '하자 부위 근접샷',
        descKo: '스크래치·찍힘·얼룩 등 하자 부위를 근접 촬영',
        nameId: 'Foto dekat cacat',
        descId: 'Foto dekat goresan, penyok, noda, dsb.',
      ),
      // 구성품
      'included_items_flatlay': RequiredShot(
        nameKo: '구성품 일괄샷',
        descKo: '박스·설명서·충전기 등 구성품을 한 장에 펼쳐 촬영',
        nameId: 'Semua kelengkapan',
        descId: 'Foto semua kelengkapan (box, manual, charger, dll.)',
      ),
      // 동작·치수
      'power_on_or_fit': RequiredShot(
        nameKo: '동작/착용샷',
        descKo: '전자: 전원 ON 화면 | 의류·신발: 착용 또는 핏 확인',
        nameId: 'Bukti menyala/fit',
        descId: 'Elektronik: layar menyala | Pakaian/Sepatu: fit/kenyamanan',
      ),
      'measurement_reference': RequiredShot(
        nameKo: '치수 기준샷',
        descKo: '자/줄자·종이 A4 등 크기 기준물과 함께 촬영',
        nameId: 'Referensi ukuran',
        descId: 'Foto dengan penggaris/kertas A4 sebagai referensi',
      ),
      // 증빙
      'receipt_or_warranty': RequiredShot(
        nameKo: '영수증/보증서',
        descKo: '가능하다면 구매 영수증이나 보증 카드를 촬영',
        nameId: 'Struk/garansi',
        descId: 'Jika ada, foto struk pembelian atau kartu garansi',
      ),
    };

    return AiVerificationRule(
      id: 'generic_v2', // 서버와 프론트엔드가 찾는 바로 그 ID
      nameKo: "범용 중고물품 검증 규칙 V2",
      nameId: "Aturan Verifikasi Barang Bekas Umum V2",
      isAiVerificationSupported: true,
      minGalleryPhotos: 1,
      suggestedShots: universalSuggestedShots, // ✅ 빈 맵 → 보편 제안 세트
      initialAnalysisPromptTemplate: initialPrompt,
      reportTemplatePrompt:
          v2ReportPrompt, // V1 필드명과의 호환성을 위해 reportTemplatePrompt 사용
    );
  }

  // [V2.1 신규] 스마트폰 전용 규칙 생성 함수
  AiVerificationRule _getSmartphoneV2Rule(AiVerificationRule genericRule) {
    // V2.1의 핵심은 프롬프트가 아닌, 'suggestedShots' 데이터에 있습니다.

    // [Fix] genericRule의 프롬프트를 사용하도록 수정 (작업 33의 수정 사항 반영)
    // (만약 smartphone 전용 프롬프트를 쓰고 싶다면 genericRule.reportTemplatePrompt 대신 여기에 새 프롬프트를 정의)
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
          nameId: 'Tampilan IMEI',
          descId:
              'Ambil foto layar informasi perangkat atau IMEI untuk meningkatkan kepercayaan',
        ),
        'battery_shot': RequiredShot(
          nameKo: '배터리 성능 화면',
          descKo: '배터리 성능 상태 화면을 촬영하여 구매자에게 정확한 정보를 제공하세요.',
          nameId: 'Tampilan performa baterai',
          descId:
              'Ambil foto layar menunjukkan kondisi baterai untuk informasi akurat',
        ),
        'info_shot': RequiredShot(
          nameKo: '기기 정보 화면',
          descKo: '설정 > 휴대전화 정보 화면을 촬영하여 모델명과 용량을 명확히 보여주세요.',
          nameId: 'Tampilan info perangkat',
          descId:
              'Ambil foto layar Pengaturan > Informasi perangkat untuk menunjukkan model dan kapasitas',
        ),
      },
      // [Blocker-A Fix] 백엔드가 룰에서 직접 프롬프트를 읽으므로, 범용 룰의 프롬프트를 여기에 복사해야 합니다.
      initialAnalysisPromptTemplate: genericRule.initialAnalysisPromptTemplate,
      reportTemplatePrompt: genericRule.reportTemplatePrompt,
    );
  }
}

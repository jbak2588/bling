
// functions-v2/util_ai_rules.js
// 디자인→AI 룰 규격 변환기 (nameEn/suggested_shots/템플릿 포함)
function defaultSuggestedShots() {
  return {
    front_full: {
      nameKo: '전면 전체샷', descKo: '제품 전체가 보이도록 전면에서 촬영',
      nameId: 'Foto tampak depan', descId: 'Ambil foto seluruh barang dari depan',
      nameEn: 'Full Front Shot', descEn: 'Take a photo of the entire item from the front',
    },
    back_full: {
      nameKo: '후면 전체샷', descKo: '제품 전체가 보이도록 후면에서 촬영',
      nameId: 'Foto tampak belakang', descId: 'Ambil foto seluruh barang dari belakang',
      nameEn: 'Full Back Shot', descEn: 'Take a photo of the entire item from the back',
    },
    brand_model_tag: {
      nameKo: '브랜드/모델 태그', descKo: '라벨/각인/스티커 등 식별 태그 근접 촬영',
      nameId: 'Tag merek/model', descId: 'Foto dekat label/ukiran/stiker identitas',
      nameEn: 'Brand/Model Tag', descEn: 'Close-up of identity tag (label, engraving, sticker)',
    },
    serial_or_size_label: {
      nameKo: '시리얼/사이즈 라벨', descKo: '전자: 시리얼/모델 | 의류·신발: 사이즈 라벨 촬영',
      nameId: 'Label serial/ukuran', descId: 'Elektronik: serial/model | Pakaian/Sepatu: label ukuran',
      nameEn: 'Serial/Size Label', descEn: 'Electronics: Serial/Model | Apparel/Shoes: Size label photo',
    },
    defect_closeups: {
      nameKo: '하자 부위 근접샷', descKo: '스크래치·찍힘·얼룩 등 하자 부위를 근접 촬영',
      nameId: 'Foto dekat cacat', descId: 'Foto dekat goresan, penyok, noda, dsb.',
      nameEn: 'Defect Close-ups', descEn: 'Close-up photo of any scratches, dents, or stains',
    },
    included_items_flatlay: {
      nameKo: '구성품 일괄샷', descKo: '박스·설명서·충전기 등 구성품을 한 장에 펼쳐 촬영',
      nameId: 'Semua kelengkapan', descId: 'Foto semua kelengkapan (box, manual, charger, dll.)',
      nameEn: 'Included Items Flatlay', descEn: 'Photo of all included items (box, manual, charger, etc.)',
    },
  };
}

const INITIAL_ANALYSIS_PROMPT = `You are an expert product inspector for a second-hand marketplace.
Analyze ONLY the provided images to help determine evidence completeness for the item.
Respond in JSON ONLY. Do not include any text outside JSON.
Do not invent details that are not visible in the images.
You will receive additional instructions and an explicit JSON schema in the same message. Follow them strictly.`;

const REPORT_TEMPLATE_PROMPT = `You are an expert product inspector for a marketplace. Output JSON in Indonesian only.

**User's Input**
- Product Name Claim: "{{confirmedProductName}}"
- Category: "{{categoryName}}"
- Sub-Category: "{{subCategoryName}}"
- User Price: "{{userPrice}}"

**Instructions**
1) Respect the user's claim. Support it with evidence.
2) Pick 2-3 key specs relevant to the sub-category.
3) Describe condition objectively (wear, scratch, dent).
4) List included items detected.
5) Suggest reasonable market price in IDR (numbers only).
If some evidence keys were missing, add:
"notes_for_buyer": "Saran untuk pembeli mengenai bukti yang tidak disediakan penjual."

Return one JSON:
{
  "verification_summary": "string",
  "key_specs": { "Spec 1": "Value 1", "Spec 2": "Value 2" },
  "condition_check": "string",
  "included_items": ["."],
  "suggested_price": 0,
  "notes_for_buyer": "optional"
}`;

function buildAiRulesFromDesign(design) {
  const rules = [];
  const SHOTS = defaultSuggestedShots();
  for (const parentSlug of Object.keys(design)) {
    const parent = design[parentSlug];
    const subs = parent.subCategories || {};
    for (const subSlug of Object.keys(subs)) {
      const s = subs[subSlug];
      rules.push({
        id: subSlug,
        nameKo: s.name_ko,
        nameId: s.name_id,
        nameEn: s.name_en,
        isAiVerificationSupported: true,
        minGalleryPhotos: 1,
        suggested_shots: SHOTS,
        initial_analysis_prompt_template: INITIAL_ANALYSIS_PROMPT,
        report_template_prompt: REPORT_TEMPLATE_PROMPT,
      });
    }
  }
  return { rules };
}

module.exports = { buildAiRulesFromDesign };

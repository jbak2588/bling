// tools/generate_ai_rules_from_categories.js
// 설명(1~2줄): categories_v2_design.js를 읽어 AiVerificationRule JSON을 생성합니다.
// 결과 파일: assets/ai/ai_rules_v2.json (rules 배열)

const fs = require('fs');
const path = require('path');

// Bling 카테고리 설계 (JS 모듈) - 필요 시 경로 조정
const design = require('../scripts/categories_v2_design.js');

// -------------------- 1) 추천샷(shot presets) 카탈로그 --------------------
const SHOT_CATALOG = {
  // 공통(모든 카테고리 폴백)
  universal: {
    front_full: {
      nameKo: '전면 전체샷',
      descKo: '제품 전체가 보이도록 전면에서 촬영',
      nameId: 'Foto tampak depan',
      descId: 'Ambil foto seluruh barang dari depan',
      nameEn: 'Full Front Shot',
      descEn: 'Take a photo of the entire item from the front',
    },
    back_full: {
      nameKo: '후면 전체샷',
      descKo: '제품 전체가 보이도록 후면에서 촬영',
      nameId: 'Foto tampak belakang',
      descId: 'Ambil foto seluruh barang dari belakang',
      nameEn: 'Full Back Shot',
      descEn: 'Take a photo of the entire item from the back',
    },
    brand_model_tag: {
      nameKo: '브랜드/모델 태그',
      descKo: '라벨/각인/스티커 등 식별 태그 근접 촬영',
      nameId: 'Tag merek/model',
      descId: 'Foto dekat label/ukiran/stiker identitas',
      nameEn: 'Brand/Model Tag',
      descEn: 'Close-up of identity tag (label, engraving, sticker)',
    },
    serial_or_size_label: {
      nameKo: '시리얼/사이즈 라벨',
      descKo: '전자: 시리얼/모델 | 의류·신발: 사이즈 라벨 촬영',
      nameId: 'Label serial/ukuran',
      descId: 'Elektronik: serial/model | Pakaian/Sepatu: label ukuran',
      nameEn: 'Serial/Size Label',
      descEn: 'Electronics: Serial/Model | Apparel/Shoes: Size label photo',
    },
    defect_closeups: {
      nameKo: '하자 부위 근접샷',
      descKo: '스크래치·찍힘·얼룩 등 하자 부위를 근접 촬영',
      nameId: 'Foto dekat cacat',
      descId: 'Foto dekat goresan, penyok, noda, dsb.',
      nameEn: 'Defect Close-ups',
      descEn: 'Close-up photo of any scratches, dents, or stains',
    },
    included_items_flatlay: {
      nameKo: '구성품 일괄샷',
      descKo: '박스·설명서·충전기 등 구성품을 한 장에 펼쳐 촬영',
      nameId: 'Semua kelengkapan',
      descId: 'Foto semua kelengkapan (box, manual, charger, dll.)',
      nameEn: 'Included Items Flatlay',
      descEn: 'Photo of all included items (box, manual, charger, etc.)',
    },
    power_on_or_fit: {
      nameKo: '동작/착용샷',
      descKo: '전자: 전원 ON 화면 | 의류·신발: 착용 또는 핏 확인',
      nameId: 'Bukti menyala/fit',
      descId: 'Elektronik: layar menyala | Pakaian/Sepatu: fit/kenyamanan',
      nameEn: 'Power-On / Fit Shot',
      descEn: 'Electronics: Screen powered on | Apparel/Shoes: Photo of item being worn',
    },
    measurement_reference: {
      nameKo: '치수 기준샷',
      descKo: '자·줄자·A4 종이 등 기준물과 함께 촬영',
      nameId: 'Referensi ukuran',
      descId: 'Foto dengan penggaris/kertas A4 sebagai referensi',
      nameEn: 'Measurement Reference',
      descEn: 'Photo with a ruler or standard object (e.g., A4 paper)',
    },
    receipt_or_warranty: {
      nameKo: '영수증/보증서',
      descKo: '가능하다면 구매 영수증이나 보증 카드를 촬영',
      nameId: 'Struk/garansi',
      descId: 'Jika ada, foto struk pembelian atau kartu garansi',
      nameEn: 'Receipt/Warranty',
      descEn: 'If available, photo of the purchase receipt or warranty card',
    },
  },

  // 전자 전용 추가
  electronics: {
    power_on_screen: {
      nameKo: '전원 ON 화면',
      descKo: '전원이 켜진 상태의 동작 화면 촬영',
      nameId: 'Layar menyala',
      descId: 'Ambil foto layar saat perangkat menyala',
      nameEn: 'Power-On Screen',
      descEn: 'Take a photo of the screen while the device is on',
    },
  },

  // 스마트폰/태블릿 전용
  smartphone: {
    imei_shot: {
      nameKo: 'IMEI 정보 화면',
      descKo: '설정/다이얼러 등 IMEI 화면 촬영',
      nameId: 'Tampilan IMEI',
      descId: 'Foto layar informasi perangkat/IMEI',
      nameEn: 'IMEI Info Screen',
      descEn: 'Photo of settings/dialer IMEI screen',
    },
    battery_shot: {
      nameKo: '배터리 성능 화면',
      descKo: '배터리 성능/건강도 화면 촬영',
      nameId: 'Kesehatan baterai',
      descId: 'Foto layar kesehatan baterai',
      nameEn: 'Battery Health Screen',
      descEn: 'Photo of the battery health/capacity screen',
    },
    info_shot: {
      nameKo: '기기 정보 화면',
      descKo: '모델명·용량이 보이는 기기 정보 화면',
      nameId: 'Info perangkat',
      descId: 'Foto layar informasi perangkat (model/kapasitas)',
      nameEn: 'Device Info Screen',
      descEn: 'Photo of device info screen (model/capacity)',
    },
  },

  // 가방/액세서리
  bag: {
    logo: {
      nameKo: '브랜드 로고',
      descKo: '브랜드 로고 부분 근접 촬영',
      nameId: 'Logo merek',
      descId: 'Foto dekat logo merek',
      nameEn: 'Brand Logo',
      descEn: 'Close-up photo of the brand logo',
    },
    interior: {
      nameKo: '가방 내부',
      descKo: '오염/파손 여부가 보이게 내부 전체 촬영',
      nameId: 'Bagian dalam',
      descId: 'Foto kondisi bagian dalam tas',
      nameEn: 'Interior',
      descEn: 'Photo of the condition inside the bag',
    },
    corners: {
      nameKo: '모서리 마모',
      descKo: '하단 모서리 등 마모 부위 근접 촬영',
      nameId: 'Sudut aus',
      descId: 'Foto dekat sudut bawah yang aus',
      nameEn: 'Corner Wear',
      descEn: 'Close-up photo of wear on bottom corners',
    },
  },

  // 신발
  footwear: {
    side: {
      nameKo: '측면 전체샷',
      descKo: '신발의 전체적인 옆모습',
      nameId: 'Tampak samping',
      descId: 'Foto sisi sepatu secara keseluruhan',
      nameEn: 'Full Side View',
      descEn: 'Overall side view of the shoes',
    },
    sole: {
      nameKo: '밑창 샷',
      descKo: '밑창 마모 상태가 보이게 촬영',
      nameId: 'Sol',
      descId: 'Foto kondisi keausan sol',
      nameEn: 'Sole Shot',
      descEn: 'Photo showing the sole wear and condition',
    },
    tag: {
      nameKo: '내부 탭/사이즈',
      descKo: '사이즈·모델 탭 근접 촬영',
      nameId: 'Tag ukuran/model',
      descId: 'Foto dekat tag ukuran/model',
      nameEn: 'Inner Tag/Size',
      descEn: 'Close-up photo of the size/model tag',
    },
    front: {
      nameKo: '앞코 샷',
      descKo: '앞코 사용감 근접 촬영',
      nameId: 'Bagian depan',
      descId: 'Foto kondisi ujung depan',
      nameEn: 'Toe Box Shot',
      descEn: 'Close-up photo of the toe box condition',
    },
  },

  // 가구
  furniture: {
    joints: {
      nameKo: '결합부/힌지',
      descKo: '결합부 강도·유격 확인용 근접 촬영',
      nameId: 'Sambungan/engsel',
      descId: 'Foto dekat sambungan/engsel furnitur',
      nameEn: 'Joints/Hinges',
      descEn: 'Close-up photo of furniture joints/hinges',
    },
  },

  // 카메라/드론
  camera: {
    lens_closeup: {
      nameKo: '렌즈 근접',
      descKo: '렌즈 스크래치/곰팡이 여부 근접 촬영',
      nameId: 'Lensa (dekat)',
      descId: 'Foto dekat lensa (goresan/jamur)',
      nameEn: 'Lens Close-up',
      descEn: 'Close-up photo of the lens (scratches/fungus)',
    },
    shutter_info: {
      nameKo: '셔터/플라이트 로그',
      descKo: '셔터카운트/비행로그 화면 촬영(가능시)',
      nameId: 'Info shutter/log',
      descId: 'Foto layar shutter count/log penerbangan (jika ada)',
      nameEn: 'Shutter/Flight Log',
      descEn: 'Photo of shutter count/flight log screen (if possible)',
    },
  },
};

// -------------------- 2) 카테고리→그룹 매핑 --------------------
function mapToGroup(parentNameEn, subKey, subNameEn) {
  const t = `${parentNameEn} ${subKey} ${subNameEn || ''}`.toLowerCase();

  // 스마트폰/태블릿
  if (t.includes('smartphone') || t.includes('handphone') || t.includes('tablet'))
    return ['universal', 'electronics', 'smartphone'];

  // 패션-가방/악세서리
  if (t.includes('bag') || t.includes('tas') || t.includes('accessories') || t.includes('aksesoris'))
    return ['universal', 'bag'];

  // 신발
  if (t.includes('shoes') || t.includes('sepatu') || t.includes('foot'))
    return ['universal', 'footwear'];

  // 카메라/드론
  if (t.includes('camera') || t.includes('kamera') || t.includes('drone'))
    return ['universal', 'electronics', 'camera'];

  // 전자/디지털
  if (t.includes('elect') || t.includes('digital') || t.includes('laptop') || t.includes('computer') || t.includes('komputer'))
    return ['universal', 'electronics'];

  // 가구
  if (t.includes('furniture') || t.includes('perabot'))
    return ['universal', 'furniture'];

  // 기본 폴백
  return ['universal'];
}

// -------------------- 3) 프롬프트 템플릿 --------------------
const INITIAL_PROMPT = `
Analyze the provided images and return only a JSON object with the predicted item name. Do not include any other text. The JSON format must be: {"predicted_item_name": "PREDICTED_NAME"}`.trim();

const REPORT_PROMPT_GENERIC_ID = `
You are an expert product inspector for a marketplace. Output JSON in Indonesian only.

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
  "included_items": ["..."],
  "suggested_price": 0,
  "notes_for_buyer": "optional"
}`.trim();

const REPORT_PROMPT_SMARTPHONE_ID = `
Anda adalah ahli transaksi HP bekas di Indonesia. Tulis JSON berbahasa Indonesia.

Input Pengguna:
- Harga yang diinginkan: {{userPrice}} IDR
- Deskripsi singkat: {{userDescription}}

Wajib isi: judul, deskripsi, spesifikasi (merek, model, kapasitas, warna), cek kondisi (layar, bodi, baterai), kelengkapan, harga pasar (angka IDR saja). Jika bukti kunci (IMEI/baterai/info perangkat) tidak ada, tambahkan "notes_for_buyer".
`.trim();

// -------------------- 4) 규칙 생성기 --------------------
function buildSuggestedShots(groups) {
  const merged = {};
  for (const g of groups) {
    const catalog = SHOT_CATALOG[g] || {};
    for (const [k, v] of Object.entries(catalog)) merged[k] = v;
  }
  return merged;
}

function fallback(val, alt) {
  return (val === undefined || val === null || String(val).trim() === '') ? alt : val;
}

function buildRule(id, nameKo, nameId, nameEn, parentNameEn, subKey, subNameEn) {
  const groups = mapToGroup(parentNameEn, subKey, subNameEn);
  const suggestedShots = buildSuggestedShots(groups);
  const isSmartphone = groups.includes('smartphone');
  const reportPrompt = isSmartphone ? REPORT_PROMPT_SMARTPHONE_ID : REPORT_PROMPT_GENERIC_ID;

  return {
    id,
    nameKo,
    nameId,
    nameEn, // [Fix] nameEn 필드 추가
    isAiVerificationSupported: true,
    minGalleryPhotos: 1,
    suggestedShots,
    initialAnalysisPromptTemplate: INITIAL_PROMPT,
    reportTemplatePrompt: reportPrompt,
  };
}

// -------------------- 5) 전체 카테고리 순회 → 규칙 배열 생성 --------------------
function generateAllRules() {
  const rules = [];

  for (const [parentId, parent] of Object.entries(design)) {
    const parentNameEn = parent.name_en || parent.nameEn || '';
    const subs = parent.subCategories || {};
    for (const [subKey, sub] of Object.entries(subs)) {
      const id = subKey; // Firestore 문서 ID로 하위키 사용
      const nameKo = fallback(sub.name_ko, subKey);
      const nameId = fallback(sub.name_id, subKey);
      const nameEn = fallback(sub.name_en || sub.nameEn, subKey);
      const subNameEn = sub.name_en || sub.nameEn || '';

      const rule = buildRule(id, nameKo, nameId, nameEn, parentNameEn, subKey, subNameEn);
      rules.push(rule);
    }
  }
  return rules;
}

// -------------------- 6) JSON 파일로 저장 --------------------
function main() {
  const rules = generateAllRules();
  const outDir = path.join(__dirname, '../assets/ai');
  const outPath = path.join(outDir, 'ai_rules_v2.json');
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify({ rules }, null, 2), 'utf-8');
  console.log(`✓ Generated ${rules.length} rules → ${outPath}`);
}

if (require.main === module) {
  main();
}

module.exports = {
  generateAllRules,
  buildRule,
  mapToGroup,
  SHOT_CATALOG,
};

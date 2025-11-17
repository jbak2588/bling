// functions-v2/util_ai_rules.js
// (요약) 카테고리 디자인 → AI 규칙 JSON 변환기.
// 그룹 프리셋 + 서브카테고리 오버라이드(overrideGroups/removeGroups/addShots/removeShots) 지원.

function SHOT_CATALOG() {
  return {
    // -------- 공통(폴백) --------
    universal: {
      front_full: {nameKo: "전면 전체샷", descKo: "제품 전체가 보이도록 전면에서 촬영", nameId: "Foto tampak depan", descId: "Ambil foto seluruh barang dari depan", nameEn: "Full Front Shot", descEn: "Front view of the entire item"},
      back_full: {nameKo: "후면 전체샷", descKo: "제품 전체가 보이도록 후면에서 촬영", nameId: "Foto tampak belakang", descId: "Ambil foto seluruh barang dari belakang", nameEn: "Full Back Shot", descEn: "Back view of the entire item"},
      brand_model_tag: {nameKo: "브랜드/모델 태그", descKo: "라벨/각인/스티커 등 식별 태그 근접", nameId: "Tag merek/model", descId: "Label/ukiran/stiker identitas", nameEn: "Brand/Model Tag", descEn: "Close-up of label/engraving/sticker"},
      serial_or_size_label: {nameKo: "시리얼/사이즈 라벨", descKo: "전자: 시리얼/모델 | 의류·신발: 사이즈 라벨", nameId: "Label serial/ukuran", descId: "Elektronik: serial/model | Pakaian/Sepatu: label ukuran", nameEn: "Serial/Size Label", descEn: "Serial/Model or size label"},
      defect_closeups: {nameKo: "하자 부위 근접샷", descKo: "스크래치·찍힘·얼룩 등 하자 근접", nameId: "Foto dekat cacat", descId: "Goresan/penyok/noda", nameEn: "Defect Close-ups", descEn: "Close-up of scratches/dents/stains"},
      included_items_flatlay: {nameKo: "구성품 일괄샷", descKo: "박스·설명서·충전기 등 구성품 한 장 촬영", nameId: "Semua kelengkapan", descId: "Semua kelengkapan (box/manual/charger)", nameEn: "Included Items Flatlay", descEn: "All included items in one photo"},
      power_on_or_fit: {nameKo: "동작/착용샷", descKo: "전자: 전원 ON 화면 | 의류·신발: 착용/핏", nameId: "Bukti menyala/fit", descId: "Elektronik: layar menyala | Pakaian/Sepatu: fit", nameEn: "Power-On / Fit", descEn: "Screen on / Wearing/fit"},
      measurement_reference: {nameKo: "치수 기준샷", descKo: "자/줄자/A4 등 기준물과 함께", nameId: "Referensi ukuran", descId: "Dengan penggaris/kertas A4", nameEn: "Measurement Reference", descEn: "With ruler or A4 paper"},
    },

    // -------- 전자 공통 --------
    electronics: {
      power_on_screen: {nameKo: "전원 ON 화면", descKo: "전원이 켜진 상태의 화면", nameId: "Layar menyala", descId: "Perangkat saat menyala", nameEn: "Power-On Screen", descEn: "Device powered on"},
      ports_closeup: {nameKo: "포트/단자 근접", descKo: "충전/입출력 단자 마모·이물", nameId: "Port & konektor", descId: "Kondisi port/connector", nameEn: "Ports Close-up", descEn: "I/O ports wear/foreign objects"},
    },

    // -------- 스마트폰/태블릿 --------
    smartphone: {
      imei_shot: {nameKo: "IMEI 화면", descKo: "*#06# 또는 설정의 IMEI", nameId: "IMEI", descId: "Tangkapan layar IMEI", nameEn: "IMEI Screen", descEn: "Dialer *#06# or settings"},
      battery_shot: {nameKo: "배터리 성능", descKo: "배터리 건강도 화면", nameId: "Kesehatan baterai", descId: "Layar kesehatan baterai", nameEn: "Battery Health", descEn: "Battery health screen"},
      info_shot: {nameKo: "기기 정보", descKo: "모델/용량 보이는 화면", nameId: "Info perangkat", descId: "Model/kapasitas", nameEn: "Device Info", descEn: "Model/capacity screen"},
    },

    // -------- 의류 --------
    apparel: {
      neckline_stitch: {nameKo: "넥라인/스티치", descKo: "넥/스티치 풀림·변형", nameId: "Leher & jahitan", descId: "Leher & jahitan", nameEn: "Neckline/Stitch", descEn: "Neckline & stitching"},
      care_label: {nameKo: "케어라벨", descKo: "세탁/소재 라벨 근접", nameId: "Label perawatan", descId: "Label perawatan/bahan", nameEn: "Care Label", descEn: "Care/material label"},
      fabric_closeup: {nameKo: "원단 접사", descKo: "필링/올트임 등", nameId: "Kain (dekat)", descId: "Bulu/pull out", nameEn: "Fabric Close-up", descEn: "Fabric/pilling"},
    },

    // -------- 신발 --------
    footwear: {
      side: {nameKo: "측면 전체샷", descKo: "신발 옆모습", nameId: "Tampak samping", descId: "Sisi sepatu", nameEn: "Full Side", descEn: "Side view"},
      sole: {nameKo: "밑창 샷", descKo: "밑창 마모", nameId: "Sol", descId: "Keausan sol", nameEn: "Sole", descEn: "Sole wear"},
      tag: {nameKo: "내부 탭/사이즈", descKo: "사이즈/생산태그", nameId: "Tag ukuran", descId: "Tag ukuran/produksi", nameEn: "Inner Tag/Size", descEn: "Size/production tag"},
    },

    // -------- 가방/럭셔리 --------
    bag: {
      logo: {nameKo: "브랜드 로고", descKo: "로고 근접", nameId: "Logo merek", descId: "Logo merek", nameEn: "Brand Logo", descEn: "Brand logo"},
      interior: {nameKo: "가방 내부", descKo: "내부 오염/파손", nameId: "Bagian dalam", descId: "Bagian dalam", nameEn: "Interior", descEn: "Interior condition"},
      corners: {nameKo: "모서리 마모", descKo: "하단 모서리 마모", nameId: "Sudut aus", descId: "Sudut bawah aus", nameEn: "Corner Wear", descEn: "Bottom corner wear"},
      date_code: {nameKo: "시리얼/데이트코드", descKo: "시리얼/히든태그", nameId: "Kode tanggal/serial", descId: "Kode/hidden tag", nameEn: "Serial/Date Code", descEn: "Serial/date code"},
      hardware_stamp: {nameKo: "하드웨어 각인", descKo: "지퍼/버클 각인", nameId: "Stempel hardware", descId: "Ukiran hardware", nameEn: "Hardware Stamp", descEn: "Hardware engravings"},
    },

    // -------- 카메라/드론 --------
    camera: {
      lens_closeup: {nameKo: "렌즈 근접", descKo: "스크래치/곰팡이", nameId: "Lensa (dekat)", descId: "Gores/jamur", nameEn: "Lens Close-up", descEn: "Lens scratches/fungus"},
      shutter_info: {nameKo: "셔터/로그", descKo: "셔터카운트/비행로그", nameId: "Info shutter/log", descId: "Shutter/log", nameEn: "Shutter/Log", descEn: "Shutter count/flight log"},
      sensor_dust: {nameKo: "센서/먼지", descKo: "센서 먼지/스팟", nameId: "Debu sensor", descId: "Debu/spot", nameEn: "Sensor Dust", descEn: "Sensor dust/spot"},
    },

    // -------- 자전거 --------
    bicycle: {
      frame_damage: {nameKo: "프레임 손상", descKo: "크랙/찍힘 근접", nameId: "Kerusakan rangka", descId: "Retak/penyok", nameEn: "Frame Damage", descEn: "Frame cracks/dents"},
      drivetrain_wear: {nameKo: "구동계 마모", descKo: "체인/스프라켓 마모", nameId: "Keausan drivetrain", descId: "Rantai/sproket", nameEn: "Drivetrain Wear", descEn: "Chain/sprocket wear"},
      bb_serial: {nameKo: "시리얼(BB)", descKo: "BB 하단 시리얼", nameId: "Serial BB", descId: "Serial di bawah BB", nameEn: "BB Serial", descEn: "Bottom bracket serial"},
    },

    // -------- 악기 --------
    instrument: {
      headstock_serial: {nameKo: "헤드/시리얼", descKo: "헤드 시리얼/로고", nameId: "Serial headstock", descId: "Serial/logo headstock", nameEn: "Headstock Serial", descEn: "Headstock serial/logo"},
      fretboard_wear: {nameKo: "프렛/지판 마모", descKo: "프렛/지판 마모", nameId: "Keausan fret", descId: "Keausan fret", nameEn: "Fretboard Wear", descEn: "Fret/fingerboard wear"},
      body_crack: {nameKo: "바디 균열", descKo: "바디 균열/충격", nameId: "Retak bodi", descId: "Retak/impact", nameEn: "Body Crack", descEn: "Body cracks/impacts"},
    },

    // -------- 시계/주얼리 --------
    watch: {
      caseback_serial: {nameKo: "케이스백/시리얼", descKo: "케이스백 각인·시리얼", nameId: "Serial caseback", descId: "Serial/ukiran belakang", nameEn: "Caseback Serial", descEn: "Caseback serial/engraving"},
      movement_photo: {nameKo: "무브먼트", descKo: "가능 시 무브먼트", nameId: "Movement", descId: "Movement (jika bisa)", nameEn: "Movement", descEn: "Movement (if possible)"},
    },
    jewelry: {
      hallmark_stamp: {nameKo: "함량/각인", descKo: "750/925 각인", nameId: "Stempel kadar", descId: "Kadar emas/perak", nameEn: "Hallmark", descEn: "Gold/silver hallmark"},
      certificate_card: {nameKo: "감정서/보증", descKo: "감정서/보증서", nameId: "Sertifikat", descId: "Sertifikat/garansi", nameEn: "Certificate", descEn: "Appraisal/warranty certificate"},
    },
  };
}

function INITIAL_ANALYSIS_PROMPT() {
  // [작업 66] AI가 '찾은 증거'와 '누락된 증거'를 매핑하도록 프롬프트 수정
  return `You are an expert product inspector for a second-hand marketplace.
Analyze the provided images (indexed 0, 1, 2, etc.) to check for evidence completeness.
You will receive a list of "required_shots" (keys) and a list of "user_images" (image parts).

**Your Task:**
1.  Analyze all "user_images" from index 0 onwards.
2.  For each "required_shots" key, determine if any user image satisfies that requirement.
3.  Respond in JSON ONLY. Do not include any text outside JSON.

**JSON Output Schema:**
{
  "found_evidence": {
    "shot_key_1": 0,
    "shot_key_2": 1
  },
  "missing_evidence_keys": [
    "shot_key_that_is_not_found"
  ]
}

**Example:** If 'front_full' is found in image 0, and 'imei_shot' is missing:
{ "found_evidence": { "front_full": 0 }, "missing_evidence_keys": [ "imei_shot" ] }

Strictly adhere to this JSON schema. Map all found shots (key: index) and list all missing shots (key).`;
}

/* exported REPORT_TEMPLATE_PROMPT_GENERIC */
// REPORT_TEMPLATE_PROMPT_GENERIC removed: unused V2 prompt helper (kept in repo history if needed)
/**
 * ============================================================================
 * [V3 아키텍처 개편] (작업 35, 36)
 * V2의 "통 프롬프트"(`REPORT_TEMPLATE_PROMPT_...`)를 폐기합니다.
 * 대신, 카테고리별로 "무엇을 추출할지" 정의하는 "추출 대상 템플릿"을 정의합니다.
 * 이 템플릿은 index.js에서 "증거 지도"와 결합되어 동적 프롬프트로 생성됩니다.
 * ============================================================================
 */
function EXTRACTION_TARGETS() {
  // 1. 범용(Generic) 추출 템플릿
  const generic_targets = {
    // V3 스키마 (ChatGPT 감수안 채택)
    // key_specs, condition_check, included_items는 List<Map> 형태가 됩니다.
    "key_specs": [
      {
        "spec_key": "brand", // 내부 고정 키
        "label_ko": "브랜드",
        "label_id": "Merek",
        "label_en": "Brand",
        // AI에게 내릴 "추출 지시"
        "prompt": "Extract the brand name (e.g., 'Samsung', 'Nike', 'Gucci') from the 'brand_model_tag' image. If unreadable, set value to null.",
        // 이 지시를 수행할 때 참조할 증거 키
        "evidence_key": "brand_model_tag",
      },
    ],
    "condition_check": [
      {
        "condition_key": "visible_defects",
        "label_ko": "주요 하자",
        "label_id": "Cacat Terlihat",
        "label_en": "Visible Defects",
        "prompt": "List any visible scratches, dents, or stains shown in 'defect_closeups'. If none are visible, state 'No visible defects found'.",
        "evidence_key": "defect_closeups",
      },
    ],
    "included_items": [
      {
        "item_key": "original_box",
        "label_ko": "정품 박스",
        "label_id": "Kotak Asli",
        "label_en": "Original Box",
        "prompt": "Is the original box visible in the 'included_items_flatlay' image? Respond true or false. If unsure, set value to null.",
        "evidence_key": "included_items_flatlay",
      },
    ],
  };

  // 2. 스마트폰(Smartphone) 전용 추출 템플릿
  const smartphone_targets = {
    "key_specs": [
      {
        "spec_key": "model_name",
        "label_ko": "모델명",
        "label_id": "Model",
        "label_en": "Model",
        "prompt": "Extract the exact model name (e.g., 'iPhone 15 Pro', 'Galaxy S24 Ultra') from the 'info_shot' image. If unreadable, set value to null.",
        "evidence_key": "info_shot",
      },
      {
        "spec_key": "storage_capacity",
        "label_ko": "저장용량",
        "label_id": "Kapasitas",
        "label_en": "Storage",
        "prompt": "Extract the storage capacity (e.g., '128GB', '256GB') from the 'info_shot' image. If unreadable, set value to null.",
        "evidence_key": "info_shot",
      },
      {
        "spec_key": "battery_health",
        "label_ko": "배터리 성능",
        "label_id": "Kesehatan Baterai",
        "label_en": "Battery Health",
        "prompt": "Extract the battery health percentage (e.g., '95%') from the 'battery_shot' image. If not a number or unreadable, set value to null.",
        "evidence_key": "battery_shot",
      },
      {
        "spec_key": "imei",
        "label_ko": "IMEI",
        "label_id": "IMEI",
        "label_en": "IMEI",
        "prompt": "Extract the IMEI number from the 'imei_shot' image. If unreadable, set value to null.",
        "evidence_key": "imei_shot",
      },
    ],
    "condition_check": [
      {
        "condition_key": "screen_condition",
        "label_ko": "화면 상태",
        "label_id": "Kondisi Layar",
        "label_en": "Screen Condition",
        "prompt": "Analyze the 'power_on_screen' and 'defect_closeups' images for any scratches, cracks, or dead pixels on the screen. If none, state 'No visible screen defects'.",
        "evidence_key": "power_on_screen", // index.js가 'defect_closeups'도 함께 참조하도록 동적 구성
      },
    ],
    "included_items": [
      {
        "item_key": "original_box",
        "label_ko": "정품 박스",
        "label_id": "Kotak Asli",
        "label_en": "Original Box",
        "prompt": "Is the original box visible in the 'included_items_flatlay' image? Respond true or false. If unsure, set value to null.",
        "evidence_key": "included_items_flatlay",
      },
      {
        "item_key": "charger",
        "label_ko": "충전기",
        "label_id": "Pengisi Daya",
        "label_en": "Charger",
        "prompt": "Is the charger visible in the 'included_items_flatlay' image? Respond true or false. If unsure, set value to null.",
        "evidence_key": "included_items_flatlay",
      },
    ],
  };

  return {
    "generic": generic_targets,
    "smartphone": smartphone_targets,
    // TODO: apparel, bag, camera 등에 대한 전용 템플릿을 여기에 추가
  };
}

// ---- 그룹 매핑(간단 키워드) ----
function mapToGroups(parentNameEn, subKey, subNameEn) {
  const t = `${parentNameEn} ${subKey} ${subNameEn || ""}`.toLowerCase();
  if (t.includes("smartphone") || t.includes("handphone") || t.includes("tablet")) return ["electronics", "smartphone"];
  if (t.includes("camera") || t.includes("kamera") || t.includes("drone")) return ["electronics", "camera"];
  if (t.includes("bicycle") || t.includes("bike") || t.includes("sepeda")) return ["bicycle"];
  if (t.includes("guitar") || t.includes("piano") || t.includes("violin") || t.includes("drum") || t.includes("keyboard")) return ["instrument"];
  if (t.includes("watch") || t.includes("jam tangan")) return ["watch"];
  if (t.includes("jewel") || t.includes("perhiasan")) return ["jewelry"];
  if (t.includes("clothing") || t.includes("apparel") || t.includes("pakaian") || t.includes("fashion")) return ["apparel"];
  if (t.includes("bag") || t.includes("tas") || t.includes("luxury")) return ["bag"];
  if (t.includes("shoe") || t.includes("sepatu") || t.includes("foot") || t.includes("sneaker")) return ["footwear"];
  if (t.includes("elect") || t.includes("digital") || t.includes("laptop") || t.includes("computer") || t.includes("komputer")) return ["electronics"];
  return ["universal"]; // 폴백
}

function mergeShots(groups) {
  const catalog = SHOT_CATALOG();
  const out = {};
  for (const g of groups) {
    const c = catalog[g] || {};
    for (const [k, v] of Object.entries(c)) out[k] = v;
  }
  return out;
}

// ---- 오버라이드 프리셋 세트 ----
// * 핵심: overrideGroups로 universal을 통째로 제외하거나, removeGroups로 선택적 삭제.
// * addShots로 필요 샷 보강, removeShots로 세부 제거.
const SUBCATEGORY_OVERRIDES = {
  // ===== 스마트폰/태블릿(참고: 유지) =====
  "smartphone-tablet": {overrideGroups: ["electronics", "smartphone"], minGalleryPhotos: 6},

  // ===== 의류(Apparel) =====
  "women-s-clothing": {
    overrideGroups: ["apparel"],
    addShots: ["included_items_flatlay", "measurement_reference"],
    minGalleryPhotos: 5,
  },
  "men-s-clothing": {
    overrideGroups: ["apparel"],
    addShots: ["included_items_flatlay", "measurement_reference"],
    minGalleryPhotos: 5,
  },
  "kids-clothing": {
    overrideGroups: ["apparel"],
    addShots: ["included_items_flatlay", "measurement_reference"],
    minGalleryPhotos: 5,
  },
  // 세부 의류 라인(키워드형 subKey 가정)
  "dress": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},
  "shirt": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},
  "pants": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},
  "jeans": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},
  "outerwear": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},
  "sportswear": {overrideGroups: ["apparel"], addShots: ["included_items_flatlay", "measurement_reference"], minGalleryPhotos: 5},

  // ===== 카메라/드론 =====
  "camera-dslr": {
    overrideGroups: ["electronics", "camera"],
    addShots: ["lens_closeup", "sensor_dust", "shutter_info", "ports_closeup", "power_on_screen"],
    minGalleryPhotos: 6,
  },
  "camera-mirrorless": {
    overrideGroups: ["electronics", "camera"],
    addShots: ["lens_closeup", "sensor_dust", "shutter_info", "ports_closeup", "power_on_screen"],
    minGalleryPhotos: 6,
  },
  "camera-compact": {
    overrideGroups: ["electronics", "camera"],
    addShots: ["lens_closeup", "ports_closeup", "power_on_screen"],
    minGalleryPhotos: 5,
  },
  "action-camera": {
    overrideGroups: ["electronics", "camera"],
    addShots: ["ports_closeup", "power_on_screen"],
    minGalleryPhotos: 5,
  },
  "drone": {
    overrideGroups: ["electronics", "camera"],
    addShots: ["shutter_info", "power_on_screen"],
    minGalleryPhotos: 6,
  },

  // ===== 자전거 =====
  "bicycle": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"], // 크랙·치수 보강
    minGalleryPhotos: 6,
  },
  "road-bike": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"],
    minGalleryPhotos: 6,
  },
  "mountain-bike": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"],
    minGalleryPhotos: 6,
  },
  "folding-bike": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"],
    minGalleryPhotos: 6,
  },
  "bmx": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"],
    minGalleryPhotos: 6,
  },
  "fixie": {
    overrideGroups: ["bicycle"],
    addShots: ["defect_closeups", "measurement_reference"],
    minGalleryPhotos: 6,
  },

  // ===== 악기 =====
  "guitar-electric": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 6,
  },
  "guitar-acoustic": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 6,
  },
  "bass-guitar": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 6,
  },
  "piano-keyboard": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 5,
  },
  "violin": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 5,
  },
  "drum": {
    overrideGroups: ["instrument"],
    addShots: ["defect_closeups", "included_items_flatlay"],
    minGalleryPhotos: 6,
  },

  // ===== 시계 =====
  "watch-analog": {
    overrideGroups: ["watch"],
    addShots: ["included_items_flatlay", "measurement_reference"],
    minGalleryPhotos: 5,
  },
  "watch-digital": {
    overrideGroups: ["watch"],
    addShots: ["included_items_flatlay", "measurement_reference"],
    minGalleryPhotos: 5,
  },
  "smartwatch": {
    overrideGroups: ["watch", "electronics"], // 화면/포트 필요
    addShots: ["power_on_screen", "ports_closeup", "included_items_flatlay"],
    minGalleryPhotos: 6,
  },

  // ===== (참고) 기존 등록됨 =====
  "sneakers": {overrideGroups: ["footwear"], addShots: ["side", "sole", "tag"], minGalleryPhotos: 6},
  "luxury-bag": {overrideGroups: ["bag"], addShots: ["date_code", "hardware_stamp"], minGalleryPhotos: 8},
};

// ---- 오버라이드 적용기 ----
function applyOverrides(suggestedShots, ov) {
  const catalog = SHOT_CATALOG();
  let shots = {...suggestedShots};

  if (ov.overrideGroups && ov.overrideGroups.length) {
    shots = mergeShots(ov.overrideGroups); // 통째 교체(= universal 완전 배제 가능)
  } else {
    if (ov.removeGroups && ov.removeGroups.length) {
      const keysToDrop = new Set();
      for (const g of ov.removeGroups) {
        const c = catalog[g] || {};
        for (const k of Object.keys(c)) keysToDrop.add(k);
      }
      for (const k of keysToDrop) delete shots[k];
    }
    if (ov.forceGroups && ov.forceGroups.length) {
      shots = {...shots, ...mergeShots(ov.forceGroups)};
    }
  }

  if (ov.addShots && ov.addShots.length) {
    for (const add of ov.addShots) {
      for (const [, c] of Object.entries(catalog)) {
        if (c[add]) {
          shots[add] = c[add]; break;
        }
      }
    }
  }
  if (ov.removeShots && ov.removeShots.length) {
    for (const del of ov.removeShots) delete shots[del];
  }
  return shots;
}

/**
 * [V3] V2의 pickReportPrompt를 대체합니다.
 * 카테고리 그룹에 맞는 "추출 대상 템플릿" (JSON 객체)을 반환합니다.
 */
function pickExtractionTargets(groups) {
  const targets = EXTRACTION_TARGETS();
  if (groups.includes("smartphone")) {
    return targets.smartphone;
  }
  return targets.generic; // 기본값
}

function buildAiRulesFromDesign(design) {
  const rules = [];
  for (const parentSlug of Object.keys(design)) {
    const parent = design[parentSlug];
    const parentNameEn = parent.name_en || parent.nameEn || "";
    const subs = parent.subCategories || {};
    for (const subSlug of Object.keys(subs)) {
      const s = subs[subSlug] || {};
      const nameKo = s.name_ko || s.nameKo || subSlug;
      const nameId = s.name_id || s.nameId || subSlug;
      const nameEn = s.name_en || s.nameEn || subSlug;

      // 기본: universal + 매핑 그룹
      const baseGroups = mapToGroups(parentNameEn, subSlug, nameEn);
      let suggested = mergeShots(["universal", ...baseGroups]);

      // 서브카테고리 오버라이드
      const ov = SUBCATEGORY_OVERRIDES[subSlug] || null;
      if (ov) suggested = applyOverrides(suggested, ov);

      rules.push({
        id: subSlug,
        nameKo, nameId, nameEn,
        isAiVerificationSupported: true,
        minGalleryPhotos: ov?.minGalleryPhotos ?? 4,
        suggested_shots: suggested,
        // [V3] 1차 분석 프롬프트는 V2와 동일하게 유지 (증거 매핑용)
        initial_analysis_prompt_template: INITIAL_ANALYSIS_PROMPT(),
        // [V3] 2차 분석용 '추출 대상 템플릿' (JSON 객체)을 저장
        extraction_targets: pickExtractionTargets(baseGroups),
      });
    }
  }
  return {rules};
}

module.exports = {buildAiRulesFromDesign};

// tools/generate_ai_rules_from_categories.js
// [최종 리팩토링 버전]
//
// 설명: 로컬 'scripts/categories_v2_design.js'를 읽어
//       'functions-v2/util_ai_rules.js'의 통합 엔진을 사용해
//       로컬 'assets/ai/ai_rules_v2.json'을 생성합니다.

const fs = require('fs');
const path = require('path');

// 1. [엔진] Cloud Function의 통합 룰 생성 엔진을 그대로 가져옵니다.
// (모든 SHOT_CATALOG, OVERRIDES 로직은 이 파일 안에 있습니다)
const { buildAiRulesFromDesign } = require('../functions-v2/util_ai_rules.js');

// 2. [입력] 로컬 디자인 마스터 파일을 가져옵니다.
const { design } = require('../scripts/categories_v2_design.js');

/**
 * 로컬 애셋(assets) 폴더에 ai_rules_v2.json 파일을 생성합니다.
 * @param {object} designData - scripts/categories_v2_design.js에서 로드한 디자인 객체
 */
function main(designData) {
  if (!designData) {
    console.error("오류: 'scripts/categories_v2_design.js'에서 design 객체를 로드하지 못했습니다.");
    return;
  }
  
  console.log("로컬 design.js 파일을 읽어 룰 생성 엔진(util_ai_rules.js)을 실행합니다...");

  // 3. [생성] 통합 엔진을 실행합니다. (결과물: { rules: [...] })
  const rulesJson = buildAiRulesFromDesign(designData);

  // 4. [출력] 로컬 애셋 파일 경로를 설정합니다.
  const outDir = path.join(__dirname, '../assets/ai');
  const outPath = path.join(outDir, 'ai_rules_v2.json');
  
  fs.mkdirSync(outDir, { recursive: true });
  
  // 5. 파일을 저장합니다.
  fs.writeFileSync(outPath, JSON.stringify(rulesJson, null, 2), 'utf-8');
  
  console.log(`✓ Generated ${rulesJson.rules.length} rules → ${outPath}`);
}

// 스크립트 실행
if (require.main === module) {
  main(design);
}

// 이 스크립트는 CLI 전용이므로 더 이상 export할 필요가 없습니다.
// module.exports = { ... }; // 제거
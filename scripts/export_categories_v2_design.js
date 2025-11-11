// scripts/export_categories_v2_design.js
// Firestore → scripts/categories_v2_design.js + assets/ai/ai_rules_v2.json 동기화
// 사용법: node scripts/export_categories_v2_design.js
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

// 서비스 키 경로 조정
const keyPath = path.join(__dirname, 'serviceAccountKey.json');
initializeApp({ credential: cert(require(keyPath)) });
const db = getFirestore();

// [Fix] 'generateFromDesign' -> 'generateAllRules'로 함수명 변경 (tools 파일과 일치)
const { generateAllRules } = require('../tools/generate_ai_rules_from_categories');

async function buildDesign() {
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  const design = {};
  for (const pDoc of parentsSnap.docs) {
    const p = pDoc.data();
    const subs = await pDoc.ref.collection('subCategories').orderBy('order').get();
    const subCategories = {};
    subs.forEach((sDoc) => {
      const s = sDoc.data();
      subCategories[s.slug] = {
        name_ko: s.nameKo, name_en: s.nameEn, name_id: s.nameId,
        order: s.order, active: !!s.active, icon: s.icon || null,
      };
    });
    design[p.slug] = {
      isParent: true,
      name_ko: p.nameKo, name_en: p.nameEn, name_id: p.nameId,
      order: p.order, active: !!p.active, icon: p.icon || null,
      subCategories,
    };
  }
  return design;
}

(async () => {
  const design = await buildDesign();

  // 1) scripts/categories_v2_design.js (JS 모듈)
  const jsOut = `// Auto-generated from Firestore. Do not edit by hand.
const design = ${JSON.stringify(design, null, 2)};
module.exports = { design };`;
  fs.writeFileSync(path.join(__dirname, 'categories_v2_design.js'), jsOut, 'utf-8');

  // 2) assets/ai/ai_rules_v2.json
  // [Fix] 'generateFromDesign' -> 'generateAllRules'로 함수명 변경
  const rules = generateAllRules(design);
  fs.writeFileSync(path.join(__dirname, '..', 'assets', 'ai', 'ai_rules_v2.json'), JSON.stringify(rules, null, 2), 'utf-8');

  console.log('Export completed.');
})();

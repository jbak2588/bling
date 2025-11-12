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

// Suggest icon asset basename based on slug/name (fallbacks to secondhand/community)
function suggestIcon(slug, { isParent = false } = {}) {
  const s = (slug || '').toString().toLowerCase();
  if (s.includes('news')) return 'ico_news.svg';
  if (s.includes('market') || s.includes('secondhand') || s.includes('preloved') || s.includes('jual') || s.includes('beli') || s.includes('fashion') || s.includes('clothing')) return 'ico_secondhand.svg';
  if (s.includes('friend') || s.includes('teman') || s.includes('pacar') || s.includes('find')) return 'ico_friend_3d_deep.svg';
  if (s.includes('club') || s.includes('group') || s.includes('komunitas') || s.includes('community')) return 'ico_community.svg';
  if (s.includes('job') || s.includes('kerja') || s.includes('gig') || s.includes('recruit')) return 'ico_job.svg';
  if (s.includes('store') || s.includes('toko') || s.includes('warung') || s.includes('shop')) return 'ico_store.svg';
  if (s.includes('auction') || s.includes('lelang')) return 'ico_auction.svg';
  if (s.includes('pom') || s.includes('short') || s.includes('video')) return 'ico_pom.svg';
  if (s.includes('lost') || s.includes('found') || s.includes('hilang')) return 'ico_lost_item.svg';
  if (s.includes('real') || s.includes('estate') || s.includes('room') || s.includes('kos') || s.includes('kost') || s.includes('apart') || s.includes('house') || s.includes('home')) return 'ico_real_estate.svg';
  // Korean keywords
  if (s.includes('디지털') || s.includes('디지털기기') || s.includes('전자') || s.includes('가전')) return 'ico_secondhand.svg';
  if (s.includes('생활') || s.includes('생활용품') || s.includes('가정')) return 'ico_store.svg';
  if (s.includes('패션') || s.includes('의류') || s.includes('의복')) return 'ico_secondhand.svg';
  if (s.includes('뷰티') || s.includes('미용') || s.includes('화장품')) return 'ico_secondhand.svg';
  if (s.includes('유아') || s.includes('아동')) return 'ico_secondhand.svg';
  if (s.includes('취미') || s.includes('여가') || s.includes('스포츠')) return 'ico_community.svg';
  return isParent ? 'ico_community.svg' : 'ico_secondhand.svg';
}

async function buildDesign() {
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  const design = {};
  for (const pDoc of parentsSnap.docs) {
    const p = pDoc.data();
      const subs = await pDoc.ref.collection('subCategories').orderBy('order').get();
      const subCategories = {};
      subs.forEach((sDoc) => {
        const s = sDoc.data();
        const subSlug = s.slug || s.id || sDoc.id;
        const iconVal = s.icon ? s.icon : suggestIcon(subSlug, { isParent: false });
        subCategories[subSlug] = {
          name_ko: s.nameKo, name_en: s.nameEn, name_id: s.nameId,
          order: s.order, active: !!s.active, icon: iconVal || null,
        };
      });
      const parentSlug = p.slug || p.id || pDoc.id;
      const parentIcon = p.icon ? p.icon : suggestIcon(parentSlug, { isParent: true });
      design[parentSlug] = {
        isParent: true,
        name_ko: p.nameKo, name_en: p.nameEn, name_id: p.nameId,
        order: p.order, active: !!p.active, icon: parentIcon || null,
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

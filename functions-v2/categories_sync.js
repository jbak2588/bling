// functions-v2/categories_sync.js
// 카테고리 변경 시 Cloud Storage에 categories_v2_design.json + ai_rules_v2.json 재생성
const functions = require('firebase-functions/v2');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall } = require('firebase-functions/v2/https'); // [추가]
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const { buildAiRulesFromDesign } = require('./util_ai_rules'); // 아래 util 파일

// admin.initializeApp(); // [Fix] index.js에서 이미 초기화됨
const db = admin.firestore();
const bucket = admin.storage().bucket();

// [Fix] 리전 정책 변경 (us-central1 -> asia-southeast2)
// (index.js의 setGlobalOptions가 이미 모든 함수를 asia-southeast2로 설정함)
// (개별 리전 설정이 필요하다면 여기에 setGlobalOptions({ region: "asia-southeast2" }) 추가)

async function buildDesignFromFirestore() {
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  const design = {};
  for (const pDoc of parentsSnap.docs) {
    const p = pDoc.data();
    const subSnap = await pDoc.ref.collection('subCategories').orderBy('order').get();
    const subCategories = {};
    for (const sDoc of subSnap.docs) {
      const s = sDoc.data();
      subCategories[s.slug] = {
        name_ko: s.nameKo, name_en: s.nameEn, name_id: s.nameId, order: s.order, active: !!s.active, icon: s.icon || null,
      };
    }
    design[p.slug] = {
      isParent: true,
      name_ko: p.nameKo, name_en: p.nameEn, name_id: p.nameId,
      order: p.order, active: !!p.active, icon: p.icon || null,
      subCategories,
    };
  }
  return design;
}

async function exportToStorage() {
  const design = await buildDesignFromFirestore();
  // 1) 디자인 JSON
  await bucket.file('configs/categories_v2_design.json').save(JSON.stringify({ design }, null, 2), { contentType: 'application/json' });
  // 2) AI 룰 JSON
  const rules = buildAiRulesFromDesign(design);
  await bucket.file('configs/ai_rules_v2.json').save(JSON.stringify(rules, null, 2), { contentType: 'application/json' });
  return { ok: true };
}

// 수동 호출용(관리자 Publish 버튼)
exports.exportCategoriesDesign = onCall(async (req) => { // [수정]
  const auth = req.auth;
  if (!auth) { throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.'); }
  // [Fix] auth.token.role (Custom Claim) 대신 Firestore 'users' 문서의 'role' 또는 'isAdmin'을 확인
  // (앱 UI의 userModel.isAdmin == true 로직과 일치시킴)
  const userDoc = await db.collection('users').doc(auth.uid).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', '사용자 문서를 찾을 수 없습니다.');
  }
  
  const userData = userDoc.data() || {};
  if (userData.role !== 'admin' && userData.isAdmin !== true) {
    throw new functions.https.HttpsError('permission-denied', '관리자만 가능합니다.');
  }

  const res = await exportToStorage();
  logger.info('categories design/rules exported by', auth.uid);
  return res;
});

// 변경 트리거(부모/자식)
exports.onCategoriesChanged = onDocumentWritten(
  {
    document: 'categories_v2/{parentId}/{anySub=**}',
    retries: 3,
  },
  async () => {
    await exportToStorage();
    logger.info('categories change detected -> exported.');
  }
);

// functions-v2/categories_sync.js
// 카테고리 변경 시 Cloud Storage에 categories_v2_design.json + ai_rules_v2.json 재생성
const functions = require('firebase-functions/v2');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onCall } = require('firebase-functions/v2/https'); // [추가]
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const { buildAiRulesFromDesign } = require('./util_ai_rules'); // V3 빌더

// admin.initializeApp(); // index.js에서 이미 초기화됨
const db = admin.firestore();

// note: Storage-based export removed in favor of Firestore atomic deploy

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

/**
 * [V3 원자적 배포] (작업 47)
 * Firestore에서 디자인을 읽고, V3 규칙을 생성하여
 * 'ai_verification_rules' 컬렉션에 원자적으로 덮어씁니다.
 */
async function deployV3RulesToFirestore() {
  // 1) Firestore에서 디자인 로드
  const design = await buildDesignFromFirestore();
  if (!design || Object.keys(design).length === 0) {
    logger.error('[V3 Atomic Deploy] 0 categories found in Firestore. Aborting.');
    throw new functions.https.HttpsError('failed-precondition', 'No categories found in Firestore. Publish aborted.');
  }

  // 2) V3 규칙 생성
  const rulesData = buildAiRulesFromDesign(design);
  const rules = rulesData.rules || [];

  // 3) 안전 장치: 0 rules 방지
  if (rules.length === 0) {
    logger.error('[V3 Atomic Deploy] 0 rules generated from design. Aborting deploy.');
    throw new functions.https.HttpsError('failed-precondition', 'Generated 0 rules. Aborting deploy. Check design or Firestore data.');
  }

  // 4) 원자적 배포: 기존 규칙 삭제 후 새 규칙 배치로 쓰기
  const batch = db.batch();
  const colRef = db.collection('ai_verification_rules');

  // 4a) 기존 규칙 삭제
  const oldRulesSnap = await colRef.get();
  oldRulesSnap.docs.forEach((doc) => batch.delete(doc.ref));
  logger.info(`[V3 Atomic Deploy] Deleting ${oldRulesSnap.size} old rules...`);

  // 4b) 새 규칙 추가 (Firestore에 저장하기 전에 필드명 조정)
  for (const r of rules) {
    if (!r || !r.id) continue;
    const docId = r.id.trim();
    if (!docId) continue;

    const docRef = colRef.doc(docId);
    const ruleMap = {
      id: docId,
      name_ko: r.nameKo || '',
      name_en: r.nameEn || '',
      name_id: r.nameId || '',
      is_ai_verification_supported: r.isAiVerificationSupported || false,
      min_gallery_photos: r.minGalleryPhotos || 4,
      suggested_shots: r.suggested_shots || {},
      initial_analysis_prompt_template: r.initial_analysis_prompt_template || '',
      extraction_targets: r.extraction_targets || {},
    };

    batch.set(docRef, ruleMap);
  }

  // 5) 커밋
  await batch.commit();
  logger.info(`[V3 Atomic Deploy] Successfully deployed ${rules.length} V3 rules to Firestore.`);
  return { ok: true, deployedRules: rules.length };
}

// 수동 호출용(관리자 Publish 버튼)
exports.exportCategoriesDesign = onCall({
  region: 'asia-southeast2',
  secrets: [],
}, async (req) => {
  const auth = req.auth || {};
  if (!auth.token || !auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', '관리자만 가능합니다.');
  }

  // [V3] Firestore에 원자적 배포 실행
  const res = await deployV3RulesToFirestore();
  logger.info(`[V3 Atomic Deploy] ${res.deployedRules} rules deployed by admin:`, auth.uid);
  return res;
});

// 자동 트리거 제거: 배포는 이제 수동(onCall)으로만 수행됩니다.
// (자동 배포는 실수로 대량 삭제/덮어쓰기를 발생시킬 수 있으므로 의도적으로 제거)

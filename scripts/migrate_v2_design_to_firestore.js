// scripts/migrate_v2_design_to_firestore.js
// [1회성 스크립트]
// 목적: 로컬 'scripts/categories_v2_design.js' 파일을 읽어
//       새로운 Firestore 'categories_v2' (doc + subcollection) 스키마로 마이그레이션합니다.

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
// [Fix] 'design' 객체를 직접 import합니다 (destructuring 제거).
const design = require('./categories_v2_design.js'); // [주의] 경로 확인

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const batch = db.batch();
const v2Col = db.collection('categories_v2');

async function migrate() {
  console.log('categories_v2_design.js -> Firestore categories_v2 마이그레이션 시작...');
  let parentCount = 0;
  let subCount = 0;

  for (const [parentId, parentData] of Object.entries(design)) {
    parentCount++;
    const parentRef = v2Col.doc(parentId);

    // 1. 부모 카테고리 문서 생성
    batch.set(parentRef, {
      slug: parentId,
      nameKo: parentData.name_ko || '',
      nameId: parentData.name_id || '',
      nameEn: parentData.name_en || '',
      order: parentData.order || 99,
      active: parentData.active !== undefined ? parentData.active : true,
      icon: parentData.icon || null,
      isParent: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'admin_migration_script',
    });

    // 2. 하위 카테고리 서브컬렉션 생성
    const subCategories = parentData.subCategories || {};
    for (const [subId, subData] of Object.entries(subCategories)) {
      subCount++;
      const subRef = parentRef.collection('subCategories').doc(subId);
      batch.set(subRef, {
        slug: subId,
        nameKo: subData.name_ko || '',
        nameId: subData.name_id || '',
        nameEn: subData.name_en || '',
        order: subData.order || 99,
        active: subData.active !== undefined ? subData.active : true,
        icon: subData.icon || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: 'admin_migration_script',
      });
    }
  }

  // 3. 배치 커밋
  await batch.commit();
  console.log(`✅ 마이그레이션 완료.`);
  console.log(`   - 부모 카테고리 ${parentCount}개 생성됨.`);
  console.log(`   - 하위 카테고리 ${subCount}개 생성됨.`);
}

migrate().catch(console.error);
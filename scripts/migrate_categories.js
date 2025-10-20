// scripts/migrate_categories.js

const admin = require('firebase-admin');

// [중요] 이 스크립트를 실행하기 전에 Firebase Console에서 다운로드한
// 서비스 계정 키 파일의 경로를 정확하게 지정해야 합니다.
// 이 파일은 절대 Git에 커밋하면 안 됩니다.
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

/**
 * 'name_en' 필드를 기반으로 사람이 읽을 수 있는 새 ID를 생성합니다.
 * 예: "Handphone & Tablet" -> "handphone-tablet"
 * @param {string} nameEn - The English name of the category.
 * @returns {string} The new human-readable ID.
 */
function generateNewId(nameEn) {
  if (!nameEn) {
    // name_en이 없는 경우를 대비한 예외 처리
    return `unknown-${Date.now()}`;
  }
  return nameEn
    .toLowerCase()
    .replace(/ \& /g, ' ') // '&'를 공백으로
    .replace(/[\s/]+/g, '-') // 공백, 슬래시를 하이픈으로
    .replace(/[^a-z0-9-]/g, ''); // 기타 특수문자 제거
}

async function migrateCategories() {
  console.log('카테고리 마이그레이션을 시작합니다...');

  const oldCategoriesRef = db.collection('categories');
  const newCategoriesRef = db.collection('categories_v2');
  const snapshot = await oldCategoriesRef.get();

  if (snapshot.empty) {
    console.log('기존 "categories" 컬렉션에 문서가 없습니다. 작업을 종료합니다.');
    return;
  }

  const batch = db.batch();
  let count = 0;

  console.log('-------------------------------------------');
  console.log('ID 변환 매핑:');
  snapshot.forEach(doc => {
    const oldData = doc.data();
    const newId = generateNewId(oldData.name_en);

    console.log(`${doc.id}  =>  ${newId}`);

    const newDocRef = newCategoriesRef.doc(newId);
    batch.set(newDocRef, oldData);
    count++;
  });
  console.log('-------------------------------------------');

  try {
    await batch.commit();
    console.log(`✅ 성공: 총 ${count}개의 카테고리 문서가 "categories_v2" 컬렉션으로 마이그레이션되었습니다.`);
  } catch (error) {
    console.error('❌ 오류: 마이그레이션 중 에러가 발생했습니다.', error);
  }
}

migrateCategories();
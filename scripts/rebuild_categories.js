const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const designData = require('./categories_v2_design.js'); // 방금 생성한 데이터 파일

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const collectionRef = db.collection('categories');

/**
 * 지정된 컬렉션의 모든 문서를 삭제하는 함수
 * @param {FirebaseFirestore.CollectionReference} ref - 삭제할 컬렉션 참조
 */
async function deleteAllDocuments(ref) {
  console.log(`[1단계] '${ref.path}' 컬렉션의 모든 문서를 삭제합니다...`);
  const snapshot = await ref.limit(500).get(); // 한 번에 500개씩 삭제
  
  if (snapshot.size === 0) {
    console.log("삭제할 문서가 없습니다.");
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  // 아직 문서가 남아있으면 재귀적으로 호출
  if (snapshot.size >= 500) {
    await deleteAllDocuments(ref);
  }
  console.log(`[1단계] 문서 삭제 완료.`);
}

/**
 * 설계도 데이터를 기반으로 카테고리 문서를 생성하는 함수
 */
async function createAllCategories() {
  console.log("\n[2단계] 설계도를 기반으로 카테고리 문서 생성을 시작합니다...");
  const batch = db.batch();

  for (const parentId in designData) {
    const parentData = designData[parentId];

    // 대분류 문서 생성
    const parentDocRef = collectionRef.doc(parentId);
    batch.set(parentDocRef, {
      name_ko: parentData.name_ko,
      name_en: parentData.name_en,
      name_id: parentData.name_id,
      order: parentData.order,
      parentId: "" // 대분류는 parentId가 비어있음
    });
    console.log(`  - 대분류 생성 준비: ${parentData.name_ko} (ID: ${parentId})`);

    // 소분류 문서들 생성
    for (const subId in parentData.subCategories) {
      const subData = parentData.subCategories[subId];
      const subDocRef = collectionRef.doc(subId);
      batch.set(subDocRef, {
        name_ko: subData.name_ko,
        name_en: subData.name_en,
        name_id: subData.name_id,
        order: subData.order,
        parentId: parentId // 소분류의 parentId는 대분류의 ID
      });
      console.log(`    - 소분류 생성 준비: ${subData.name_ko} (Parent: ${parentData.name_ko})`);
    }
  }

  await batch.commit();
  console.log("[2단계] 모든 카테고리 문서가 성공적으로 생성되었습니다.");
}

/**
 * 메인 실행 함수
 */
async function main() {
  try {
    // 1. 기존 데이터 모두 삭제
    await deleteAllDocuments(collectionRef);
    
    // 2. 설계도 기반으로 데이터 생성
    await createAllCategories();
    
    console.log("\n✅ 'categories_v2' 컬렉션 재건축 작업이 성공적으로 완료되었습니다.");
  } catch (error) {
    console.error("❌ 작업 중 심각한 오류가 발생했습니다:", error);
  }
}

// 스크립트 실행
main();

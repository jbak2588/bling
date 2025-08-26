// fix_location_parts.js

const admin = require('firebase-admin');

// 1. Firebase Admin SDK 초기화
const serviceAccount = require('./serviceAccountKey.json');
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  if (e.code !== 'app/duplicate-app') {
    console.error('Firebase 초기화 에러:', e);
  }
}
const db = admin.firestore();

// 부정확한 Kabupaten 이름을 공식 명칭으로 변환하는 규칙
const correctionMap = {
  'Tangerang City': 'Kota Tangerang',
  'Tangerang Selatan': 'Kota Tangerang Selatan',
  'Tangerang': 'Kabupaten Tangerang' // 'Tangerang'는 'Kabupaten Tangerang'으로 간주
};

async function fixLocationParts(collectionName) {
  console.log(`\n🔥 [${collectionName}] 컬렉션의 데이터 보정을 시작합니다...`);
  const snapshot = await db.collection(collectionName).get();
  
  if (snapshot.empty) {
    console.log(`- [${collectionName}] 컬렉션에 문서가 없습니다. 건너뜁니다.`);
    return 0;
  }

  let batch = db.batch();
  let updatedCount = 0;
  let processedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const locationParts = data.locationParts;

    if (locationParts && typeof locationParts.kab === 'string' && correctionMap[locationParts.kab]) {
      const oldKab = locationParts.kab;
      const newKab = correctionMap[oldKab];
      
      // locationParts 객체를 복사하고 kab 값을 수정한 후, 다시 업데이트
      const newLocationParts = { ...locationParts, kab: newKab };
      
      batch.update(doc.ref, { locationParts: newLocationParts });
      updatedCount++;
      
      // 500개 단위로 나누어 commit
      if (updatedCount % 499 === 0) {
        await batch.commit();
        batch = db.batch();
      }
    }
    processedCount++;
  }

  // 남은 작업이 있다면 마지막으로 commit
  if (updatedCount % 499 !== 0) {
    await batch.commit();
  }

  console.log(`✅ [${collectionName}] 컬렉션 처리 완료: 총 ${processedCount}개 문서 중 ${updatedCount}개의 locationParts.kab 필드를 수정했습니다.`);
  return updatedCount;
}

async function runAllFixes() {
    console.log("=============== 데이터 보정 작업 시작 ===============");
    let totalFixes = 0;
    totalFixes += await fixLocationParts('products');
    totalFixes += await fixLocationParts('posts');
    console.log("\n=============== 데이터 보정 작업 완료 ===============");
    console.log(`🎉 총 ${totalFixes}개의 문서가 성공적으로 업데이트되었습니다.`);
}

runAllFixes().catch(console.error);
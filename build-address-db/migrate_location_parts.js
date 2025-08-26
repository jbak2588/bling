// migrate_location_parts.js
const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');
const COLLECTIONS_TO_MIGRATE = ['posts', 'products'];

try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  if (e.code !== 'app/duplicate-app') {
    console.error('Firebase 초기화 에러:', e);
    process.exit(1);
  }
}

const db = admin.firestore();

const findCorrectPathByKecamatan = async (kecName) => {
  if (!kecName || typeof kecName !== 'string' || kecName.trim() === '') {
    console.warn(`[경고] 유효하지 않은 Kecamatan 이름입니다: ${kecName}`);
    return null;
  }
  try {
    const kecQuerySnapshot = await db.collectionGroup('kecamatan')
      .where('name', '==', kecName)
      .limit(1)
      .get();

    if (kecQuerySnapshot.empty) {
      console.warn(`[경고] DB에서 '${kecName}' Kecamatan을 찾을 수 없습니다.`);
      return null;
    }

    const kecDoc = kecQuerySnapshot.docs[0];
    const path = kecDoc.ref.path;
    const pathSegments = path.split('/');

    if (pathSegments.length < 6) {
        console.error(`[오류] '${kecName}'의 경로가 예상과 다릅니다: ${path}`);
        return null;
    }

    const prov = pathSegments[1];
    const type = pathSegments[2];
    const cityOrRegency = pathSegments[3];
    const kec = kecDoc.data().name;

    return {
      prov: prov,
      kota: type === 'kota' ? cityOrRegency : null,
      kab: type === 'kabupaten' ? cityOrRegency : null,
      kec: kec,
    };

  } catch (error) {
    console.error(`[오류] '${kecName}' Kecamatan 경로 탐색 중 Firestore 에러 발생:`, error.message);
    return null;
  }
};

const migrateCollection = async (collectionName) => {
  console.log(`\n🔥 [${collectionName}] 컬렉션의 '상향식 검증' 마이그레이션을 시작합니다...`);

  const collectionRef = db.collection(collectionName);
  const snapshot = await collectionRef.get();

  if (snapshot.empty) {
    console.log(`- [${collectionName}] 컬렉션에 문서가 없어 건너뜁니다.`);
    return { success: 0, fail: 0 };
  }

  let successCount = 0;
  let failCount = 0;
  let batch = db.batch();
  let operationCounter = 0;

  for (let i = 0; i < snapshot.docs.length; i++) {
    const doc = snapshot.docs[i];
    const data = doc.data();

    if (!data.locationParts || !data.locationParts.kec) {
      console.warn(`- [경고] 문서 ${doc.id}에 'locationParts.kec' 필드가 없어 건너뜁니다.`);
      failCount++;
      continue;
    }

    const oldKecName = data.locationParts.kec;
    const oldKelName = data.locationParts.kel || null;

    const correctPath = await findCorrectPathByKecamatan(oldKecName);

    if (!correctPath) {
      console.error(`- [실패] 문서 ${doc.id}: '${oldKecName}'의 상위 경로를 찾지 못했습니다.`);
      failCount++;
      continue;
    }

    const newLocationParts = {
      prov: correctPath.prov,
      kota: correctPath.kota,
      kab: correctPath.kab,
      kec: correctPath.kec,
      kel: oldKelName
    };

    batch.update(doc.ref, { locationParts: newLocationParts });
    operationCounter++;
    successCount++;

    if (operationCounter >= 499 || i === snapshot.docs.length - 1) {
      await batch.commit();
      console.log(`- ${operationCounter}개의 문서를 일괄 업데이트했습니다.`);
      batch = db.batch();
      operationCounter = 0;
    }
  }

  console.log(`✅ [${collectionName}] 컬렉션 처리 완료: 총 ${snapshot.docs.length}개 문서 중 ${successCount}개 성공, ${failCount}개 실패/건너뜀.`);
};

const runAllMigrations = async () => {
    console.log("=================================================");
    console.log("== Bling 앱 'locationParts' 구조 재설정 시작 ==");
    console.log("=================================================");
    
    for (const collectionName of COLLECTIONS_TO_MIGRATE) {
        await migrateCollection(collectionName);
    }

    console.log("\n================= 마이그레이션 완료 =================");
    console.log(`🎉 모든 작업이 성공적으로 완료되었습니다.`);
    // 반드시 프로세스를 종료시켜주어야 합니다.
    process.exit(0);
};

runAllMigrations().catch(err => {
  console.error("스크립트 실행 중 치명적인 오류 발생:", err);
  process.exit(1);
});
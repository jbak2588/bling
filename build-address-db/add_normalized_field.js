// add_normalized_field.js (최종 해결 버전)

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

// 문자열을 정규화하는 함수
function normalize(name) {
  if (typeof name !== 'string') return '';
  return name.toLowerCase().replace(/\s+/g, '');
}

async function runUpdate() {
  console.log('🔥 Firestore 데이터 업데이트를 시작합니다...');

  try {
    // --- 1단계: 모든 문서 경로를 찾아서 리스트에 저장 ---
    console.log('⏳ 1단계: DB에서 모든 주소 문서 경로를 찾는 중...');
    const allDocRefs = [];
    const provincesSnapshot = await db.collection('provinces').get();

    for (const provDoc of provincesSnapshot.docs) {
      allDocRefs.push(provDoc.ref);
      const kabSnapshot = await provDoc.ref.collection('kabupaten').get();
      for (const kabDoc of kabSnapshot.docs) {
        allDocRefs.push(kabDoc.ref);
        const kecSnapshot = await kabDoc.ref.collection('kecamatan').get();
        for (const kecDoc of kecSnapshot.docs) {
          allDocRefs.push(kecDoc.ref);
          const kelSnapshot = await kecDoc.ref.collection('kelurahan').get();
          for (const kelDoc of kelSnapshot.docs) {
            allDocRefs.push(kelDoc.ref);
          }
        }
      }
    }
    console.log(`✅ 1단계 완료: 총 ${allDocRefs.length}개의 문서 경로를 찾았습니다.`);
    
    if (allDocRefs.length === 0) {
        console.log('❌ 처리할 문서가 없습니다. 스크립트를 종료합니다.');
        return;
    }

    // --- 2단계: 찾아낸 모든 문서를 순회하며 필드 업데이트 ---
    console.log('⏳ 2단계: 찾은 문서를 하나씩 업데이트하는 중...');
    let batch = db.batch();
    let writeCount = 0;
    
    for (let i = 0; i < allDocRefs.length; i++) {
        const docRef = allDocRefs[i];
        const originalName = docRef.id.replace(/-/g, '/');
        const dataToUpdate = {
            name: originalName,
            name_normalized: normalize(originalName)
        };
        batch.set(docRef, dataToUpdate, { merge: true });
        writeCount++;

        // 500개 단위로 나누어 commit
        if (writeCount === 499 || i === allDocRefs.length - 1) {
            await batch.commit();
            console.log(`  ... ${i + 1} / ${allDocRefs.length}개 문서 처리 완료 ...`);
            batch = db.batch(); // 새 배치 시작
            writeCount = 0;
        }
    }

    console.log('🎉 모든 작업이 성공적으로 완료되었습니다!');

  } catch (error) {
    console.error('❌ 작업 중 심각한 오류가 발생했습니다:', error);
  }
}

runUpdate();
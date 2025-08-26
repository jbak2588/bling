// test_query.js
// 목적: 문제를 일으키는 단 한 줄의 쿼리만 독립적으로 실행하여
//      근본 원인이 쿼리 자체에 있는지, 데이터에 있는지,
//      아니면 정말로 색인 문제인지 최종적으로 확인합니다.

const admin = require('firebase-admin');

const serviceAccount = require('./serviceAccountKey.json');
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

// ----------------------------------------------------
// 딱 한 개의 'Kecamatan' 이름으로 직접 쿼리 테스트
const KECAMATAN_TO_TEST = 'Tangerang';
// ----------------------------------------------------

console.log(`[진단 시작] DB에서 '${KECAMATAN_TO_TEST}' Kecamatan을 직접 검색합니다...`);

db.collectionGroup('kecamatan')
  .where('name', '==', KECAMATAN_TO_TEST)
  .get()
  .then(snapshot => {
    console.log('----------------------------------------------------');
    if (snapshot.empty) {
      console.log(`[진단 결과] '성공'은 했지만, '${KECAMATAN_TO_TEST}' 이름의 문서를 찾지 못했습니다.`);
      console.log(`- 원인 추정 1: DB에 실제로 해당 이름의 Kecamatan이 없습니다.`);
      console.log(`- 원인 추정 2: Firestore 보안 규칙(Rules)이 쿼리를 막고 있을 수 있습니다.`);
    } else {
      console.log(`[진단 결과] 🎉 쿼리 성공! '${KECAMATAN_TO_TEST}' 문서를 ${snapshot.size}개 찾았습니다.`);
      snapshot.forEach(doc => {
        console.log(`  - 찾은 문서 경로: ${doc.ref.path}`);
        console.log(`  - 찾은 문서 내용:`, doc.data());
      });
    }
    console.log('----------------------------------------------------');
    process.exit(0);
  })
  .catch(err => {
    console.log('----------------------------------------------------');
    console.error(`[진단 결과] ❌ 쿼리 실행 중 심각한 오류 발생!`);
    console.error(`- 에러 코드: ${err.code}`);
    console.error(`- 에러 메시지: ${err.details || err.message}`);
    console.log('----------------------------------------------------');
    process.exit(1);
  });
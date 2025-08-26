// check_db.js

const admin = require('firebase-admin');

try {
  // 1. 서비스 계정 키를 로드합니다.
  const serviceAccount = require('./serviceAccountKey.json');
  console.log(`✅ [1/3] 서비스 계정 키 파일 (serviceAccountKey.json)을 성공적으로 읽었습니다.`);
  console.log(`   - 프로젝트 ID: ${serviceAccount.project_id}`);

  // 2. Firebase 앱을 초기화합니다.
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log(`✅ [2/3] Firebase 앱 초기화에 성공했습니다.`);
  
  const db = admin.firestore();

  // 3. Firestore DB의 모든 최상위 컬렉션 목록을 가져옵니다.
  console.log(`⏳ [3/3] Firestore 데이터베이스에서 컬렉션 목록을 가져오는 중...`);
  db.listCollections().then(collections => {
      console.log('----------------------------------------------------');
      if (collections.length === 0) {
          console.log('❌ 결과: 데이터베이스에서 어떤 컬렉션도 찾을 수 없습니다.');
          console.log('   - serviceAccountKey.json 파일이 올바른 프로젝트의 것인지 다시 확인해주세요.');
      } else {
          console.log('✅ 결과: 현재 프로젝트에서 다음 컬렉션들을 찾았습니다:');
          collections.forEach(collection => {
              console.log(`   - ${collection.id}`);
          });
      }
      console.log('----------------------------------------------------');
  }).catch(err => {
      console.error('❌ [오류] 컬렉션 목록을 가져오는 데 실패했습니다:', err);
  }).finally(() => {
      // 앱을 종료해야 프로세스가 멈춥니다.
      admin.app().delete();
  });

} catch (e) {
  console.error('❌ 스크립트 실행 중 심각한 오류가 발생했습니다:', e.message);
}
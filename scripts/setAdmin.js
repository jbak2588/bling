// setAdmin.js
// Firebase Admin SDK를 사용하여 특정 사용자에게 Custom Claim과 Firestore 권한을 부여합니다.

// ----------------- 설정 -----------------
// 1. 다운로드한 서비스 계정 JSON 파일 경로로 변경하세요.
const SERVICE_ACCOUNT_KEY_PATH = './serviceAccountKey.json'; 

// 2. 관리자 권한을 부여할 사용자의 UID로 변경하세요.
const UID_TO_MAKE_ADMIN = '2F4toylRRZPm1gyo7jVg1GiMPOS2'; 
// ----------------------------------------


const admin = require('firebase-admin');
const serviceAccount = require(SERVICE_ACCOUNT_KEY_PATH);

try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('Firebase Admin SDK 초기화 성공.');
} catch (e) {
  console.error('Firebase Admin SDK 초기화 실패:', e.message);
  process.exit(1);
}

const db = admin.firestore();

async function setAdminPermissions(uid) {
  if (!uid || uid === '여기에_관리자_UID를_입력하세요') {
    console.error('오류: UID_TO_MAKE_ADMIN 값을 정확히 입력해야 합니다.');
    return;
  }

  try {
    // 1. [Custom Claim 설정] (클라이언트 앱의 버튼 활성화를 위해)
    // category_admin_screen.dart의 _refreshAdmin()이 이 값을 확인합니다.
    await admin.auth().setCustomUserClaims(uid, { 
      admin: true,
      isAdmin: true,
      role: 'admin' 
    });
    console.log(`[1/2] 성공: UID ${uid}에 Custom Claim (admin: true)을 설정했습니다.`);
    console.log('   > 앱을 완전히 재시작해야 토큰이 갱신되어 버튼이 활성화됩니다.');

    // 2. [Firestore 문서 설정] (Cloud Function의 서버 측 권한 확인을 위해)
    // categories_sync.js의 exportCategoriesDesign()이 이 값을 확인합니다.
    const userRef = db.collection('users').doc(uid);
    await userRef.set({
      role: 'admin',
      isAdmin: true
    }, { merge: true }); // merge: true로 기존 데이터를 보존합니다.

    console.log(`[2/2] 성공: Firestore 'users/${uid}' 문서에 { role: 'admin', isAdmin: true }를 설정했습니다.`);
    console.log('\n작업 완료. 앱을 재시작하여 Publish 버튼 활성화 여부를 확인하세요.');

  } catch (error) {
    console.error('권한 설정 중 오류 발생:', error);
  }
}

// 스크립트 실행
setAdminPermissions(UID_TO_MAKE_ADMIN);
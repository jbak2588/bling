// export_data.js

const admin = require('firebase-admin');
const fs = require('fs'); // 파일 시스템 라이브러리

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

/**
 * 특정 컬렉션의 모든 문서를 JSON 파일로 저장하는 함수
 * @param {string} collectionName - 백업할 컬렉션 이름
 * @param {string} outputFileName - 저장될 JSON 파일 이름
 */
async function exportCollectionToJson(collectionName, outputFileName) {
  console.log(`\n🔥 [${collectionName}] 컬렉션 데이터 백업을 시작합니다...`);
  
  try {
    const snapshot = await db.collection(collectionName).get();
    
    if (snapshot.empty) {
      console.log(`- [${collectionName}] 컬렉션에 문서가 없습니다. 건너뜁니다.`);
      return 0;
    }

    const dataList = [];
    snapshot.forEach(doc => {
      // 문서의 모든 데이터와 함께, 문서 ID를 'id' 필드로 추가합니다.
      // product_model.dart 와 post_model.dart 의 fromFirestore 생성자와 형식을 맞춥니다.
      dataList.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // JSON 형식으로 변환 (보기 좋게 2칸 들여쓰기)
    const jsonData = JSON.stringify(dataList, null, 2);
    
    // 파일로 저장
    fs.writeFileSync(outputFileName, jsonData, 'utf8');
    
    console.log(`✅ [${collectionName}] 컬렉션 처리 완료: 총 ${dataList.length}개의 문서를 ${outputFileName} 파일로 저장했습니다.`);
    return dataList.length;

  } catch (error) {
    console.error(`❌ [${collectionName}] 컬렉션 백업 중 오류 발생:`, error);
    return 0;
  }
}

async function runAllExports() {
    console.log("=============== 데이터 백업 작업 시작 ===============");
    await exportCollectionToJson('products', 'products.json');
    await exportCollectionToJson('posts', 'posts.json');
    console.log("\n=============== 데이터 백업 작업 완료 ===============");
}

runAllExports();
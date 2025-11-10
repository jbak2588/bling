// clean_conditions.js
// 실행 명령어: node clean_conditions.js

const admin = require("firebase-admin");
// 본인의 서비스 계정 키 파일 경로
const serviceAccount = require("./serviceAccountKey.json"); 

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const productsRef = db.collection("products");

async function cleanConditions() {
  console.log("Firestore 데이터 정리를 시작합니다...");

  // 1. 'new' 또는 'used'가 아닌 오염된 데이터를 찾습니다.
  const querySnapshot = await productsRef
    .where("condition", "not-in", ["new", "used"])
    .get();

  if (querySnapshot.empty) {
    console.log("✅ 오염된 'condition' 필드를 가진 상품이 없습니다.");
    return;
  }

  console.log(`🔥 총 ${querySnapshot.size}개의 오염된 상품을 찾았습니다. 수정을 시작합니다...`);

  const batch = db.batch();
  querySnapshot.docs.forEach((doc) => {
    console.log(`- 수정 대상: ${doc.id} (현재 값: "${doc.data().condition.substring(0, 20)}...")`);
    const docRef = productsRef.doc(doc.id);
    // [Fix] 'used'로 강제 수정
    batch.update(docRef, { 
        condition: "used",
        updatedAt: admin.firestore.FieldValue.serverTimestamp() 
    });
  });

  // 4. 일괄 적용
  await batch.commit();
  console.log(`✅ ${querySnapshot.size}개 상품의 'condition' 필드 수정 완료.`);
}

cleanConditions().catch(console.error);
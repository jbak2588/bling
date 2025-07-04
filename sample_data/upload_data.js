// upload_data.js (최종 수정본)

const admin = require('firebase-admin');
const fs = require('fs');

// 1. Firebase Admin SDK 초기화
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// 2. JSON 파일 경로 설정
const usersFilePath = './sample_data/users_final.json';
const postsFilePath = './sample_data/posts_final.json';
const productsFilePath = './sample_data/products_final.json';


async function uploadData() {
  try {
    console.log('🔥 샘플 데이터 업로드를 시작합니다...');

    // --- Users 업로드 ---
    console.log('- Users 데이터 읽는 중...');
    const usersJson = JSON.parse(fs.readFileSync(usersFilePath, 'utf8'));
    const usersBatch = db.batch();
    
    // 중요: 실제 Firebase Auth에 생성된 사용자의 UID로 교체해야 합니다.
    const realUids = [
        "19aMuRqXsYgdmWQW5VNVUHtZdEJ3", "0Ux1pTBeNDe66VZ2XSmawB8f7km1", "WRIZrWRfP4QvmGgUQLYaO0duq372", "WCiUaersNsM5O56n2Dc8H47iAcF2", "A6DVwzS1IqcIEyQ4kYcisHeBmLl1",
        "0STuqqjlM1bDGX4myYmKU8vqk5F2", "b2UrVnAYsWTHjN72dgPCRkVXzCJ3", "pupbHFLj8gXZ5tZpWKEOvDfTO8I2", "g5UCJEsK38Mn0odvIA7OWCscZjG3", "Qjel9kgny0hKz1RDkl4bHAzB0ax2"
    ];

    if (usersJson.length > realUids.length) {
        console.error('❌ 에러: JSON 파일의 사용자 수보다 realUids 배열의 UID 개수가 적습니다.');
        return;
    }

    usersJson.forEach((user, index) => {
      const uid = realUids[index];
      const userRef = db.collection('users').doc(uid);
      
      const userData = { ...user };
      delete userData.geoPoint; // JSON에서 geoPoint 객체 제거
      delete userData.createdAt; // JSON에서 createdAt 문자열 제거

      userData.uid = uid;
      userData.createdAt = admin.firestore.Timestamp.fromDate(new Date(user.createdAt));
      userData.geoPoint = new admin.firestore.GeoPoint(user.geoPoint.latitude, user.geoPoint.longitude);
      
      usersBatch.set(userRef, userData);
    });
    await usersBatch.commit();
    console.log('✅ Users 데이터 업로드 완료!');


    // --- Posts 업로드 ---
    console.log('- Posts 데이터 읽는 중...');
    const postsJson = JSON.parse(fs.readFileSync(postsFilePath, 'utf8'));
    const postsBatch = db.batch();

    postsJson.forEach(post => {
      const postRef = db.collection('posts').doc(post.id);
      
      // ▼▼▼▼▼ userId에서 숫자만 정확히 추출하도록 로직 수정 ▼▼▼▼▼
      const userIndex = parseInt(post.userId.match(/\d+/)[0]) - 1;
      const realUid = realUids[userIndex];

      const postData = { ...post };
      delete postData.geoPoint;
      delete postData.createdAt;

      postData.userId = realUid;
      postData.createdAt = admin.firestore.Timestamp.fromDate(new Date(post.createdAt));
      postData.geoPoint = new admin.firestore.GeoPoint(post.geoPoint.latitude, post.geoPoint.longitude);
      
      postsBatch.set(postRef, postData);
    });
    await postsBatch.commit();
    console.log('✅ Posts 데이터 업로드 완료!');


    // --- Products 업로드 ---
    console.log('- Products 데이터 읽는 중...');
    const productsJson = JSON.parse(fs.readFileSync(productsFilePath, 'utf8'));
    const productsBatch = db.batch();

    productsJson.forEach(product => {
      const productRef = db.collection('products').doc(product.id);
      
      // ▼▼▼▼▼ userId에서 숫자만 정확히 추출하도록 로직 수정 ▼▼▼▼▼
      const userIndex = parseInt(product.userId.match(/\d+/)[0]) - 1;
      const realUid = realUids[userIndex];
      
      const productData = { ...product };
      delete productData.geoPoint;
      delete productData.createdAt;
      delete productData.updatedAt;

      productData.userId = realUid;
      productData.createdAt = admin.firestore.Timestamp.fromDate(new Date(product.createdAt));
      productData.updatedAt = admin.firestore.Timestamp.fromDate(new Date(product.updatedAt));
      productData.geoPoint = new admin.firestore.GeoPoint(product.geoPoint.latitude, product.geoPoint.longitude);
      
      productsBatch.set(productRef, productData);
    });
    await productsBatch.commit();
    console.log('✅ Products 데이터 업로드 완료!');

    console.log('🎉 모든 샘플 데이터 업로드가 성공적으로 완료되었습니다!');

  } catch (error) {
    console.error('❌ 업로드 중 에러 발생:', error);
  }
}

uploadData();
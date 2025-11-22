/**
 * [Search Index Migration Script]
 * 10개 Feature의 기존 데이터에 'searchIndex' 필드를 생성합니다.
 * * Usage: 
 * 1. firebase-admin 서비스 계정 키가 필요합니다. (service-account.json)
 * 2. node migrate_search_index.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // ⚠️ 서비스 계정 키 경로 확인

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Dart의 SearchHelper.generateSearchIndex와 동일한 로직 구현
function generateSearchIndex(texts = []) {
  const keywords = new Set();

  texts.forEach(text => {
    if (!text) return;
    
    // 1. 소문자 변환 및 특수문자 제거 (한글, 영문, 숫자, 공백만 허용)
    // Dart RegExp: r'[^\w\s가-힣]' -> JS: /[^\w\s\uAC00-\uD7A3]/g
    const cleanText = text.toLowerCase().replace(/[^\w\s\uAC00-\uD7A3]/g, '');
    
    // 2. 공백으로 분리
    const tokens = cleanText.split(/\s+/);
    
    tokens.forEach(token => {
      if (token.length >= 1) {
        keywords.add(token);
      }
    });
  });

  return Array.from(keywords);
}

async function migrateCollection(collectionName, fieldMap) {
  console.log(`🚀 Starting migration for: ${collectionName}`);
  const snapshot = await db.collection(collectionName).get();
  
  if (snapshot.empty) {
    console.log(`   No documents found in ${collectionName}. Skipping.`);
    return;
  }

  const batchSize = 500;
  let batch = db.batch();
  let count = 0;
  let totalUpdated = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    
    // 추출할 텍스트 수집
    const textsToTokenize = [];
    const rawTags = []; // 태그는 원본 그대로도 검색어에 추가 (선택 사항)

    // 1. 일반 텍스트 필드 (제목, 설명 등)
    if (fieldMap.textFields) {
      fieldMap.textFields.forEach(field => {
        if (data[field]) textsToTokenize.push(String(data[field]));
      });
    }

    // 2. 태그 필드 (배열)
    if (fieldMap.tagField && Array.isArray(data[fieldMap.tagField])) {
      data[fieldMap.tagField].forEach(tag => {
        textsToTokenize.push(tag); // 태그도 토큰화
        rawTags.push(tag.toLowerCase()); // 태그 원본 소문자도 추가
      });
    }

    // 키워드 생성
    const searchIndex = generateSearchIndex(textsToTokenize);
    // 태그 원본도 검색어에 포함 (띄어쓰기 있는 태그 통째로 검색 지원)
    rawTags.forEach(t => {
      if (!searchIndex.includes(t)) searchIndex.push(t);
    });

    // 업데이트 (searchIndex가 없거나 비어있을 때, 혹은 강제 갱신)
    batch.update(doc.ref, { searchIndex: searchIndex });
    count++;

    if (count >= batchSize) {
      await batch.commit();
      totalUpdated += count;
      console.log(`   Updated ${totalUpdated} docs...`);
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
    totalUpdated += count;
  }
  
  console.log(`✅ Finished ${collectionName}: ${totalUpdated} documents updated.\n`);
}

async function run() {
  try {
    // 1. Marketplace (Products)
    await migrateCollection('products', {
      textFields: ['title'], // description은 제외 (너무 많음) or 포함 선택
      tagField: 'tags'
    });

    // 2. Local News (Posts)
    await migrateCollection('posts', {
      textFields: ['title', 'body'],
      tagField: 'tags'
    });

    // 3. Jobs
    await migrateCollection('jobs', {
      textFields: ['title', 'description'],
      tagField: 'tags'
    });

    // 4. Find Friends (Users)
    await migrateCollection('users', {
      textFields: ['nickname', 'bio'],
      tagField: 'interests'
    });

    // 5. Local Stores (Shops)
    await migrateCollection('shops', {
      textFields: ['name', 'description'],
      tagField: 'tags'
    });

    // 6. Lost and Found
    await migrateCollection('lost_and_found', {
      textFields: ['itemDescription', 'locationDescription'],
      tagField: 'tags'
    });

    // 7. Clubs
    await migrateCollection('clubs', {
      textFields: ['title', 'description'],
      tagField: 'interestTags'
    });

    // 8. Real Estate (Room Listings)
    await migrateCollection('room_listings', {
      textFields: ['title', 'description'],
      tagField: 'tags'
    });

    // 9. Auctions
    await migrateCollection('auctions', {
      textFields: ['title', 'description'],
      tagField: 'tags'
    });

    // 10. Pom (Shorts)
    await migrateCollection('pom', {
      textFields: ['title', 'description'], // PomModel에 title 필드 존재 확인 필요 (V2에서 추가됨)
      tagField: 'tags'
    });

    console.log('🎉 All migrations completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

run();
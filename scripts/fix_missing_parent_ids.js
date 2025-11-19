/**
 * [Bling DB Migration Script]
 * Purpose: products 컬렉션에서 categoryParentId가 누락된 문서들을 찾아,
 * categoryId(소분류)를 기반으로 올바른 parentId(대분류)를 채워 넣습니다.
 *
 * Usage:
 * 1. Firebase 서비스 계정 키(serviceAccountKey.json)가 필요할 수 있습니다.
 * (로컬 에뮬레이터가 아닌 실제 DB 접근 시)
 * export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
 * * 2. 실행: node fix_missing_parent_ids.js
 */

const admin = require('firebase-admin');

// 초기화 (환경 변수 또는 기본 자격 증명 사용)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function main() {
  console.log('🚀 [Step 1] 카테고리 매핑 정보 로딩 중...');
  
  // subId -> parentId 매핑을 저장할 Map
  const subToParentMap = new Map();
  let parentCount = 0;
  let subCount = 0;

  try {
    // 1. 모든 대분류(categories_v2) 가져오기
    const parentSnapshot = await db.collection('categories_v2').get();
    parentCount = parentSnapshot.size;

    // 2. 각 대분류의 하위 소분류(subCategories) 가져오기
    for (const parentDoc of parentSnapshot.docs) {
      const parentId = parentDoc.id;
      
      // subCategories 서브 컬렉션 조회
      const subSnapshot = await parentDoc.ref.collection('subCategories').get();
      
      for (const subDoc of subSnapshot.docs) {
        // 소분류 ID를 키로, 대분류 ID를 값으로 저장
        subToParentMap.set(subDoc.id, parentId);
        subCount++;
      }
    }
    
    console.log(`✅ 카테고리 맵 로드 완료: 대분류 ${parentCount}개, 소분류 ${subCount}개`);

  } catch (error) {
    console.error('❌ 카테고리 로딩 실패:', error);
    process.exit(1);
  }

  console.log('\n🚀 [Step 2] 상품 데이터 스캔 및 패치 시작...');
  
  const productsRef = db.collection('products');
  // 메모리 효율을 위해 stream() 사용 (또는 대량 데이터 시 배치 처리)
  const snapshot = await productsRef.get();
  
  const bulkWriter = db.bulkWriter();
  let updatedCount = 0;
  let skippedCount = 0;
  let missingMappingCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    
    // 1. 이미 categoryParentId가 있고 유효한 경우 스킵
    if (data.categoryParentId && typeof data.categoryParentId === 'string' && data.categoryParentId.trim() !== '') {
      continue;
    }

    const categoryId = data.categoryId;
    
    // 2. categoryId(소분류)가 없는 경우 (데이터 오류)
    if (!categoryId) {
      console.warn(`⚠️ [SKIP] 상품(${doc.id}): categoryId 필드 자체가 없음.`);
      skippedCount++;
      continue;
    }

    // 3. 매핑 정보 조회
    const parentId = subToParentMap.get(categoryId);

    if (parentId) {
      // 4. 업데이트 큐에 추가
      // console.log(`🔄 [PATCH] 상품(${doc.id}): 소분류(${categoryId}) -> 대분류(${parentId}) 적용`);
      bulkWriter.update(doc.ref, { 
        categoryParentId: parentId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp() // 선택사항: 수정 시간 업데이트
      });
      updatedCount++;
    } else {
      // 5. 매핑을 찾을 수 없는 경우 (삭제된 카테고리 등)
      console.warn(`❌ [ERROR] 상품(${doc.id}): 소분류 ID('${categoryId}')에 해당하는 대분류를 찾을 수 없음.`);
      missingMappingCount++;
    }
  }

  console.log('\n⏳ DB 업데이트 적용 중...');
  await bulkWriter.close();

  console.log('\n===================================================');
  console.log(`🎉 작업 완료 요약`);
  console.log(`- 총 상품 수: ${snapshot.size}`);
  console.log(`- 업데이트됨: ${updatedCount} 건`);
  console.log(`- 스킵됨 (이미 존재/오류): ${skippedCount} 건`);
  console.log(`- 매핑 실패 (소분류 못찾음): ${missingMappingCount} 건`);
  console.log('===================================================');
}

main().catch(console.error);
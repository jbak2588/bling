// index.js (최종 방어 코드)

const admin = require('firebase-admin');
const axios = require('axios');

const serviceAccount = require('./serviceAccountKey.json');
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  if (e.code !== 'app/duplicate-app') console.error('Firebase Init Error:', e);
}
const db = admin.firestore();

// ... (sanitizeDocId, normalize 함수는 이전과 동일)

async function buildAddressDB() {
  console.log('🔥 [최종 방어 버전] 새로운 행정구역 DB 구축을 시작합니다...');

  try {
    const provincesResponse = await axios.get('https://wilayah.id/api/provinces.json');
    const provinces = provincesResponse.data.data;
    console.log(`✅ ${provinces.length}개의 주(Province)를 찾았습니다.`);

    // for...of 루프는 내부의 await 작업이 끝날 때까지 다음 반복을 기다립니다.
    for (const province of provinces) {
        console.log(`  - ${province.name} 처리 시작...`);
        const provinceId = sanitizeDocId(province.name);
        const provinceRef = db.collection('provinces').doc(provinceId);
        await provinceRef.set({ name: province.name, name_normalized: normalize(province.name) });

        const regenciesResponse = await axios.get(`https://wilayah.id/api/regencies/${province.code}.json`);
        const regencies = regenciesResponse.data.data;

        for (const regency of regencies) {
            let collectionName = 'kabupaten';
            let cleanRegencyName = regency.name.trim();

            if (/\bKOTA\b/i.test(cleanRegencyName)) {
                collectionName = 'kota';
                cleanRegencyName = cleanRegencyName.replace(/\bKOTA\b\s*/i, '').trim();
            } else if (/\bKABUPATEN\b/i.test(cleanRegencyName)) {
                collectionName = 'kabupaten';
                cleanRegencyName = cleanRegencyName.replace(/\bKABUPATEN\b\s*/i, '').trim();
            }
             if (cleanRegencyName === "") cleanRegencyName = regency.name.trim();

            const regencyId = sanitizeDocId(cleanRegencyName);
            const regencyRef = provinceRef.collection(collectionName).doc(regencyId);
            await regencyRef.set({ name: cleanRegencyName, name_normalized: normalize(cleanRegencyName) });

            const districtsResponse = await axios.get(`https://wilayah.id/api/districts/${regency.code}.json`);
            const districts = districtsResponse.data.data;
            for (const district of districts) {
                const districtId = sanitizeDocId(district.name);
                const districtRef = regencyRef.collection('kecamatan').doc(districtId);
                await districtRef.set({ name: district.name, name_normalized: normalize(district.name) });

                const villagesResponse = await axios.get(`https://wilayah.id/api/villages/${district.code}.json`);
                const villages = villagesResponse.data.data;
                
                // Kelurahan은 Batch를 사용하여 효율적으로 처리
                const batch = db.batch();
                villages.forEach(village => {
                    const villageId = sanitizeDocId(village.name);
                    const villageRef = districtRef.collection('kelurahan').doc(villageId);
                    batch.set(villageRef, { name: village.name, name_normalized: normalize(village.name) });
                });
                await batch.commit();
            }
        }
        console.log(`  - ${province.name} (${regencies.length}개 지역) 처리 완료.`);
    }

    console.log('🎉 새로운 행정구역 DB 구축이 성공적으로 완료되었습니다!');
  } catch (error) {
    console.error('❌ DB 구축 중 오류가 발생했습니다:', error);
  }
}


// --- 이전과 동일한 함수들 ---
function sanitizeDocId(name) {
  if (!name) return 'undefined_name';
  return name.replace(/\//g, '-').trim();
}

function normalize(name) {
  if (typeof name !== 'string') return '';
  return name.toLowerCase().replace(/\s+/g, '').trim();
}

buildAddressDB();
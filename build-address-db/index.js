// 파일 경로: c:/bling/bling_app/build-address-db/index.js
// 기존 파일을 이 코드로 완전히 대체해주십시오.

//
// 참고 문서: docs/index/피드 관련 위치 검색 규칙과 예시.md
// - 피드 위치 검색은 Kab. → Kec. → Kel. → RT/RW 순으로 이뤄집니다.
// - 모든 행정구역 이름은 Singkatan 표기와 함께 name_normalized 필드를 생성해야 합니다.
// - 이 스크립트는 위 규칙을 따르는 Firestore 주소 DB(provinces_baru)를 구축합니다.

const admin = require('firebase-admin');
const axios = require('axios');
const fs = require('fs');

const serviceAccount = require('./serviceAccountKey.json');

try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (e) {
  if (e.code !== 'app/duplicate-app') console.error('Firebase Init Error:', e);
}

const db = admin.firestore();

// ---------- Helpers ----------
function sanitizeDocId(name) {
  if (!name) return 'undefined_name';
  return name.replace(/[\/#$\[\]*?]/g, '-').trim();
}

function normalize(name) {
  // FeedQueryBuilder에서 대소문자/공백 없이 빠르게 비교할 수 있도록 name_normalized 값을 생성합니다.
  if (typeof name !== 'string') return '';
  return name.toLowerCase().replace(/\s+/g, '').trim();
}

function cleanKabKota(name) {
  // Kab./Kota 접두사를 구분해 Feed 검색용 Singkatan 필드에 맞는 컬렉션 이름과 본문을 반환합니다.
  let collectionName = 'kabupaten';
  let clean = name.trim();

  if (/\bKOTA\b/i.test(clean)) {
    collectionName = 'kota';
    clean = clean.replace(/\bKOTA\b\s*/i, '').trim();
  } else if (/\bKABUPATEN\b/i.test(clean)) {
    collectionName = 'kabupaten';
    clean = clean.replace(/\bKABUPATEN\b\s*/i, '').trim();
  }
  if (!clean) clean = name.trim();

  return { collectionName, cleanName: clean };
}

function chunk(array, size) {
  const out = [];
  for (let i = 0; i < array.length; i += size) out.push(array.slice(i, i + size));
  return out;
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// ---------- Main ----------
async function buildAddressDB() {
    // 피드 위치 검색 규칙에 맞춰 Province → Kabupaten/Kota → Kecamatan → Villages 계층을 생성합니다.
  console.log('🔥 [villages 단일 컬렉션] provinces_baru 구축을 시작합니다...');

  const startTime = Date.now();
  const errorLog = [];

  // [카운터] 1. 모든 카운터 변수를 0으로 초기화합니다.
  let provinceCount = 0;
  let regencyCount = 0;
  let districtCount = 0;
  let villageCount = 0;

  try {
    const provincesResponse = await axios.get('https://wilayah.id/api/provinces.json');
    const provinces = provincesResponse.data.data || [];
    console.log(`✅ Provinces: ${provinces.length.toLocaleString('en-US')}개를 찾았습니다.`);

    for (const province of provinces) {
      console.log(`  ▶ ${province.name} 처리 시작`);
      const provDocId = sanitizeDocId(province.name);
      const provRef = db.collection('provinces_baru').doc(provDocId);

      // Province 단계 저장: Feed에서 Kab. 필터를 시작하기 위한 최상위 기준입니다.
      await provRef.set({
        name: province.name,
        name_normalized: normalize(province.name),
        codes: { province: String(province.code || '') },
        meta: { source: 'wilayah.id', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      });
      provinceCount++; // [카운터] 2. Province를 저장할 때마다 1씩 증가시킵니다.

      try {
        const regenciesResponse = await axios.get(`https://wilayah.id/api/regencies/${province.code}.json`);
        const regencies = regenciesResponse.data.data || [];

        for (const regency of regencies) {
          const { collectionName, cleanName } = cleanKabKota(regency.name);
          const regencyDocId = sanitizeDocId(cleanName);
          const regRef = provRef.collection(collectionName).doc(regencyDocId);
          // Kabupaten/Kota 단계 저장: Singkatan을 제거한 본문과 normalized 필드를 저장합니다.
          await regRef.set({
            name: cleanName,
            name_normalized: normalize(cleanName),
            codes: { regency: String(regency.code || '') },
            meta: { source: 'wilayah.id', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
          });
          regencyCount++; // [카운터] 3. Regency를 저장할 때마다 1씩 증가시킵니다.

          try {
            const districtsResponse = await axios.get(`https://wilayah.id/api/districts/${regency.code}.json`);
            const districts = districtsResponse.data.data || [];

            for (const district of districts) {
              const kecId = sanitizeDocId(district.name);
              const kecRef = regRef.collection('kecamatan').doc(kecId);
              // Kecamatan 단계 저장: Feed 위치 검색의 두 번째 기준.
              await kecRef.set({
                name: district.name,
                name_normalized: normalize(district.name),
                codes: { district: String(district.code || '') },
                meta: { source: 'wilayah.id', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
              });
              districtCount++; // [카운터] 4. District를 저장할 때마다 1씩 증가시킵니다.

              try {
                const villagesResponse = await axios.get(`https://wilayah.id/api/villages/${district.code}.json`);
                const villages = villagesResponse.data.data || [];
                // docs/index/피드 관련 위치 검색 규칙과 예시.md 기준:
                // Kota 하위는 kelurahan, Kabupaten 하위는 desa로 분류하여 Feed 필터가 동작하게 합니다.
                const defaultType = (collectionName === 'kota') ? 'kelurahan' : 'desa';
                // kelurahan은 도시 지역이므로 반경 검색 시 isUrban 값을 true로 설정합니다.
                const defaultIsUrban = defaultType === 'kelurahan';

                for (const group of chunk(villages, 400)) {
                  const batch = db.batch();
                  for (const v of group) {
                    const vId = String(v.code || sanitizeDocId(v.name));
                    const vRef = kecRef.collection('villages').doc(vId);
                    // Kelurahan/Desa 단계 저장: Feed의 세 번째 기준이며 RT/RW 확장의 기반입니다.
                    batch.set(vRef, {
                      name: v.name,
                      name_normalized: normalize(v.name),
                      type: defaultType,
                      isUrban: defaultIsUrban,
                      codes: {
                        province: String(province.code || ''),
                        regency: String(regency.code || ''),
                        district: String(district.code || ''),
                        village: String(v.code || ''),
                      },
                      parent: {
                        provId: provDocId,
                        kabOrKotaId: regencyDocId,
                        kecId: kecId,
                        kabOrKotaType: collectionName,
                      },
                      meta: {
                        source: 'wilayah.id',
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                      },
                    });
                  }
                  await batch.commit();
                  villageCount += group.length; // [카운터] 5. Batch로 저장된 Village 그룹의 개수만큼 증가시킵니다.
                  await sleep(80);
                }
              } catch (villageError) {
                const msg = `    ✗ District '${district.name}'의 villages 수집 실패: ${villageError.message}`;
                console.error(msg);
                errorLog.push(msg);
              }
            }
          } catch (districtError) {
            const msg = `  ✗ Regency '${regency.name}'의 districts 수집 실패: ${districtError.message}`;
            console.error(msg);
            errorLog.push(msg);
          }
        }
      } catch (regencyError) {
        const msg = `✗ Province '${province.name}'의 regencies 수집 실패: ${regencyError.message}`;
        console.error(msg);
        errorLog.push(msg);
      }
      console.log(`  ✓ ${province.name} 처리 완료`);
      await sleep(120);
    }

    // [카운터] 6. 모든 작업이 끝난 후, 최종 결과를 요약하여 출력합니다.
    const durationMs = Date.now() - startTime;
    const summary = {
      startedAt: new Date(startTime).toISOString(),
      finishedAt: new Date().toISOString(),
      durationMs,
      counts: {
        provinces: provinceCount,
        regencies: regencyCount,
        districts: districtCount,
        villages: villageCount,
      },
      errors: errorLog.length,
    };

    console.log('🎉 provinces_baru 구축 완료 (villages 단일 컬렉션)');
    console.log('--- Build Summary ---');
    console.log(`Provinces: ${provinceCount.toLocaleString('en-US')}`);
    console.log(`Regencies: ${regencyCount.toLocaleString('en-US')}`);
    console.log(`Districts: ${districtCount.toLocaleString('en-US')}`);
    console.log(`Villages:  ${villageCount.toLocaleString('en-US')}`);
    console.log(`Errors:    ${errorLog.length.toLocaleString('en-US')}`);
    console.log(`Duration:  ${(durationMs / 1000).toLocaleString('en-US')}s`);

    fs.writeFileSync('build_stats.json', JSON.stringify(summary, null, 2));
    console.log(`📄 build_stats.json 파일로 요약을 저장했습니다.`);

    if (errorLog.length > 0) {
      fs.writeFileSync('error_log.txt', errorLog.join('\n'));
      console.log(`⚠️ 오류 ${errorLog.length}건 기록됨 → error_log.txt 파일을 확인해주세요.`);
    }
  } catch (e) {
    console.error('❌ 스크립트 실행 중 치명적인 오류가 발생했습니다:', e);
  }
}

buildAddressDB();
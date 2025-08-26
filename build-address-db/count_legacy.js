// 파일명: count_legacy.js
// 사용법: node count_legacy.js
// 환경변수: ROOT_COLLECTION=provinces (기본값: "provinces")

const admin = require('firebase-admin');
const fs = require('fs');

const ROOT_COLLECTION = process.env.ROOT_COLLECTION || 'provinces';

// 서비스 계정 키 경로가 다르면 수정하세요.
const serviceAccount = require('./serviceAccountKey.json');

try {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} catch (e) {
  if (e.code !== 'app/duplicate-app') console.error('Firebase Init Error:', e);
}
const db = admin.firestore();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function safeGet(ref, pathDesc) {
  try {
    const snap = await ref.get();
    return snap;
  } catch (e) {
    console.error(`✗ Read error @ ${pathDesc}:`, e.message);
    return null;
  }
}

async function main() {
  console.log(`🔎 Legacy count start — root collection: "${ROOT_COLLECTION}"`);
  const t0 = Date.now();

  let provinces = 0;
  let regencies = 0;       // kota + kabupaten
  let districts = 0;       // kecamatan
  let villages = 0;        // 최하위 전체(통합)
  let kelurahan = 0;       // 구형 스키마에서만 유효
  let desa = 0;            // 구형 스키마에서만 유효

  const summaryPerProvince = [];

  // 1) Provinces
  const provSnap = await safeGet(db.collection(ROOT_COLLECTION), `${ROOT_COLLECTION}`);
  if (!provSnap) return;

  provinces = provSnap.size;
  console.log(`✅ Provinces: ${provinces.toLocaleString('en-US')}`);

  for (const provDoc of provSnap.docs) {
    const provName = provDoc.id;
    let regCountP = 0;
    let disCountP = 0;
    let vilCountP = 0;

    // 2) Regencies — kota + kabupaten
    const kotaSnap = await safeGet(provDoc.ref.collection('kota'), `${ROOT_COLLECTION}/${provName}/kota`);
    const kabSnap  = await safeGet(provDoc.ref.collection('kabupaten'), `${ROOT_COLLECTION}/${provName}/kabupaten`);

    const kotaDocs = kotaSnap ? kotaSnap.docs : [];
    const kabDocs  = kabSnap  ? kabSnap.docs  : [];
    const allRegDocs = [...kotaDocs, ...kabDocs];

    regCountP += allRegDocs.length;
    regencies += allRegDocs.length;

    // 3) Districts & 4) Villages per regency
    for (const regDoc of allRegDocs) {
      const regPath = `${ROOT_COLLECTION}/${provName}/${regDoc.ref.parent.id}/${regDoc.id}`;

      const kecSnap = await safeGet(regDoc.ref.collection('kecamatan'), `${regPath}/kecamatan`);
      const kecDocs = kecSnap ? kecSnap.docs : [];

      disCountP += kecDocs.length;
      districts += kecDocs.length;

      for (const kecDoc of kecDocs) {
        const kecPath = `${regPath}/kecamatan/${kecDoc.id}`;

        // 우선 통합 스키마(villages) 확인
        const villagesSnap = await safeGet(kecDoc.ref.collection('villages'), `${kecPath}/villages`);
        if (villagesSnap && !villagesSnap.empty) {
          villages += villagesSnap.size;
          vilCountP += villagesSnap.size;
          continue;
        }

        // 구형 스키마(분리 저장) kelurahan/desa 확인
        const kelSnap = await safeGet(kecDoc.ref.collection('kelurahan'), `${kecPath}/kelurahan`);
        const desSnap = await safeGet(kecDoc.ref.collection('desa'), `${kecPath}/desa`);

        const kelSize = kelSnap ? kelSnap.size : 0;
        const desSize = desSnap ? desSnap.size : 0;

        kelurahan += kelSize;
        desa += desSize;

        villages += (kelSize + desSize); // 최하위 합계
        vilCountP += (kelSize + desSize);
      }

      // 과도한 읽기 제한 방지(필요 시 조정)
      await sleep(10);
    }

    summaryPerProvince.push({
      provinceId: provName,
      regencies: regCountP,
      districts: disCountP,
      villages: vilCountP,
    });

    console.log(
      `  ▶ ${provName}  | regencies: ${regCountP.toLocaleString('en-US')},` +
      ` districts: ${disCountP.toLocaleString('en-US')}, villages: ${vilCountP.toLocaleString('en-US')}`
    );

    await sleep(20); // 속도 조절
  }

  const elapsed = ((Date.now() - t0) / 1000).toFixed(1);
  const result = {
    rootCollection: ROOT_COLLECTION,
    counts: {
      provinces,
      regencies,
      districts,
      villages,
      kelurahan, // 참고용(구형 스키마)
      desa,      // 참고용(구형 스키마)
    },
    perProvince: summaryPerProvince,
    finishedAt: new Date().toISOString(),
    elapsedSeconds: Number(elapsed),
  };

  console.log('— — — Summary — — —');
  console.log(`Provinces: ${provinces.toLocaleString('en-US')}`);
  console.log(`Regencies: ${regencies.toLocaleString('en-US')}`);
  console.log(`Districts: ${districts.toLocaleString('en-US')}`);
  console.log(`Villages:  ${villages.toLocaleString('en-US')}`);
  if (kelurahan + desa > 0) {
    console.log(`  └─ kelurahan: ${kelurahan.toLocaleString('en-US')}, desa: ${desa.toLocaleString('en-US')}`);
  }
  console.log(`Elapsed:   ${elapsed}s`);

  fs.writeFileSync('provinces_legacy_count.json', JSON.stringify(result, null, 2));
  console.log('📄 Saved to provinces_legacy_count.json');
}

main().catch((e) => {
  console.error('Fatal:', e);
  process.exit(1);
});

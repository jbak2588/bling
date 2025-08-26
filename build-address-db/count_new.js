// 사용법: node count_new.js
// (선택) ROOT_COLLECTION=provinces_new node count_new.js

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const ROOT = process.env.ROOT_COLLECTION || 'provinces_new';

try { admin.initializeApp({ credential: admin.credential.cert(serviceAccount) }); }
catch (e) { if (e.code !== 'app/duplicate-app') console.error('Firebase Init Error:', e); }

const db = admin.firestore();

function deriveType(id, given) {
  if (typeof given === 'string') {
    const t = given.toLowerCase();
    if (t === 'kelurahan' || t === 'desa') return t;
  }
  const last4 = (String(id).split('.').pop() || String(id).slice(-4)).padStart(4, '0');
  if (/^1\d{3}$/.test(last4)) return 'kelurahan';
  if (/^2\d{3}$/.test(last4)) return 'desa';
  return 'unknown';
}

(async () => {
  console.log(`🔎 Counting (root="${ROOT}") ...`);

  let provinces = 0, regencies = 0, districts = 0, villages = 0;
  let kelurahan = 0, desa = 0, unknown = 0;

  const provSnap = await db.collection(ROOT).get();
  provinces = provSnap.size;

  for (const prov of provSnap.docs) {
    for (const kind of ['kota', 'kabupaten']) {
      const regSnap = await prov.ref.collection(kind).get();
      regencies += regSnap.size;

      for (const reg of regSnap.docs) {
        const kecSnap = await reg.ref.collection('kecamatan').get();
        districts += kecSnap.size;

        for (const kec of kecSnap.docs) {
          const vilSnap = await kec.ref.collection('villages').get();
          villages += vilSnap.size;

          for (const v of vilSnap.docs) {
            const t = deriveType(v.id, v.data()?.type);
            if (t === 'kelurahan') kelurahan++;
            else if (t === 'desa') desa++;
            else unknown++;
          }
        }
      }
    }
  }

  console.log('— — — Summary — — —');
  console.log(`Provinces: ${provinces.toLocaleString('en-US')}`);
  console.log(`Regencies: ${regencies.toLocaleString('en-US')}`);
  console.log(`Districts: ${districts.toLocaleString('en-US')}`);
  console.log(`Villages:  ${villages.toLocaleString('en-US')}`);
  console.log(`  └─ kelurahan: ${kelurahan.toLocaleString('en-US')}, desa: ${desa.toLocaleString('en-US')}, unknown: ${unknown}`);
  process.exit(0);
})().catch(e => { console.error('Fatal:', e); process.exit(1); });

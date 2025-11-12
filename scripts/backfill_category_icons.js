#!/usr/bin/env node
'use strict';
const admin = require('firebase-admin');
const sa = require('./serviceAccountKey.json');
if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}
const db = admin.firestore();

const FALLBACK = 'ms:category'; // 더 이상 ms:others 쓰지 않음

const norm = (s='') => s.toLowerCase()
  .replace(/&/g,' and ')
  .replace(/[^a-z0-9]+/g,' ')
  .replace(/\s+/g,' ')
  .trim();

function iconByParentNameEn(nameEn){
  const n = norm(nameEn);
  if (/(digital devices|electronics)/.test(n)) return 'ms:devices';
  if (/(home essentials|household|home)/.test(n)) return 'ms:home';
  if (/(fashion|apparel|clothing)/.test(n)) return 'ms:checkroom';
  if (/(beauty|care)/.test(n)) return 'ms:spa';
  if (/(limited|luxury)/.test(n)) return 'ms:diamond';
  if (/(hobby|leisure)/.test(n)) return 'ms:sports_esports';
  if (/(baby|kids)/.test(n)) return 'ms:child_friendly';
  if (/(motorcycle|motor)/.test(n)) return 'ms:two_wheeler';
  if (/(other items|others|other)/.test(n)) return 'ms:category';
  return null;
}

function iconBySubSlug(slug){
  const s = norm(slug);
  if (/(smartphone|phone|tablet)/.test(s)) return 'ms:smartphone';
  if (/(computer|laptop|pc)/.test(s)) return 'ms:laptop';
  if (/(camera|drone)/.test(s)) return 'ms:photo_camera';
  if (/electronics/.test(s)) return 'ms:devices';
  if (/(kitchen|kitchenware|cook)/.test(s)) return 'ms:restaurant';
  if (/furniture/.test(s)) return 'ms:weekend';
  if (/(lighting|electrical|lamp)/.test(s)) return 'ms:light';
  if (/(women|men|clothing|apparel)/.test(s)) return 'ms:checkroom';
  if (/shoes?/.test(s)) return 'ms:checkroom';
  if (/(bag|bags|accessor)/.test(s)) return 'ms:work';
  if (/skincare/.test(s)) return 'ms:spa';
  if (/makeup/.test(s)) return 'ms:face';
  if (/(hair|body)/.test(s)) return 'ms:brush';
  if (/limited/.test(s)) return 'ms:grade';
  if (/luxury/.test(s)) return 'ms:diamond';
  if (/hunter/.test(s)) return 'ms:explore';
  if (/(sports|leisure)/.test(s)) return 'ms:sports_soccer';
  if (/(games|consoles?)/.test(s)) return 'ms:sports_esports';
  if (/(instrument|musik)/.test(s)) return 'ms:music_note';
  if (/(books?|stationery)/.test(s)) return 'ms:menu_book';
  if (/baby/.test(s)) return 'ms:child_friendly';
  if (/toys?/.test(s)) return 'ms:toys';
  if (/(motor|motorcycle)/.test(s)) return 'ms:two_wheeler';
  return null;
}

function resolveIcon({isParent, nameEn, slug, current}){
  // 이미 유효 값이 있으면 유지 (idempotent)
  const cur = (current||'').trim();
  if (cur && cur !== 'ms:others' && cur !== FALLBACK) return cur;
  const byName = isParent ? iconByParentNameEn(nameEn) : null;
  const bySlug = !isParent ? iconBySubSlug(slug) : null;
  return byName || bySlug || FALLBACK;
}

async function backfill({dryRun=false}={}){
  // Fetch all category documents and treat those without a parentId as parents.
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  const parents = { docs: parentsSnap.docs.filter(d => {
    const data = d.data();
    return !('parentId' in data) || data.parentId === null;
  }) };
  let writes=0, skips=0;
  for (const p of parents.docs){
    const d = p.data();
    const next = resolveIcon({
      isParent:true,
      nameEn: d.nameEn || d.name_en,
      current: d.icon
    });
    if (next !== d.icon){
      console.log(`parent ${dryRun?'would set':'fixed'}: ${p.id} -> ${next}`);
      if (!dryRun) await p.ref.update({icon: next});
      writes++;
    } else {
      skips++;
    }
    // Subcategories are stored as a subcollection under each parent
    const subs = await p.ref.collection('subCategories').get();
    for (const s of subs.docs){
      const sd = s.data();
      const nextS = resolveIcon({
        isParent:false,
        slug: sd.slug || sd.id,
        current: sd.icon
      });
      if (nextS !== sd.icon){
        console.log(`sub ${dryRun?'would set':'fixed'}: ${s.id} -> ${nextS}`);
        if (!dryRun) await s.ref.update({icon: nextS});
        writes++;
      } else {
        skips++;
      }
    }
  }
  console.log(`Done. writes=${writes}, skipped=${skips}, dryRun=${dryRun}`);
}

const args = new Set(process.argv.slice(2));
backfill({ dryRun: args.has('--dry-run') })
  .then(()=>process.exit(0))
  .catch(e=>{ console.error(e); process.exit(1); });


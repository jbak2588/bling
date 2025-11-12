// scripts/seed_category_icons.js
// Fill 'icon' field for categories_v2 (parents & subCategories) if missing.
// Usage: node scripts/seed_category_icons.js [--dryRun]

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const servicePath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(servicePath)) {
  console.error('serviceAccountKey.json not found under scripts/.');
  process.exit(1);
}
admin.initializeApp({
  credential: admin.credential.cert(require(servicePath)),
});
const db = admin.firestore();

const DRY = process.argv.includes('--dryRun');

// -------- icon key resolver (parent & sub)
function iconForParent(slug) {
  const s = (slug || '').toLowerCase();
  if (s.includes('digital')) return 'ms:devices';
  if (s.includes('home')) return 'ms:home';
  if (s.includes('fashion')) return 'ms:checkroom';
  if (s.includes('beauty') || s.includes('makeup')) return 'ms:beauty';
  if (s.includes('limited') || s.includes('luxe') || s.includes('luxury')) return 'ms:luxury';
  if (s.includes('hobi') || s.includes('hobby') || s.includes('rekreasi') || s.includes('recreation')) return 'ms:sports';
  if (s.includes('baby') || s.includes('kids') || s.includes('anak')) return 'ms:baby';
  if (s.includes('motor')) return 'ms:moto';
  if (s.includes('other') || s.includes('lain')) return 'ms:others';
  return 'ms:others';
}

function iconForSub(parentSlug, subSlug) {
  const p = (parentSlug || '').toLowerCase();
  const s = (subSlug || '').toLowerCase();

  if (p.includes('digital')) {
    if (s.includes('smart') || s.includes('phone') || s.includes('tablet')) return 'ms:smartphone';
    if (s.includes('computer') || s.includes('laptop')) return 'ms:laptop';
    if (s.includes('camera') || s.includes('drone')) return 'ms:camera';
    if (s.includes('electr')) return 'ms:devices';
    return 'ms:devices';
  }

  if (p.includes('home')) {
    if (s.includes('kitchen')) return 'ms:kitchen';
    if (s.includes('furni')) return 'ms:furniture';
    if (s.includes('light') || s.includes('lamp') || s.includes('elect')) return 'ms:lighting';
    return 'ms:home';
  }

  if (p.includes('fashion')) {
    if (s.includes('women')) return 'ms:women';
    if (s.includes('men')) return 'ms:men';
    if (s.includes('shoe') || s.includes('sepatu')) return 'ms:shoes';
    if (s.includes('bag') || s.includes('wallet')) return 'ms:bag';
    return 'ms:checkroom';
  }

  if (p.includes('beauty')) {
    if (s.includes('makeup')) return 'ms:makeup';
    if (s.includes('hair') || s.includes('body')) return 'ms:hair';
    return 'ms:beauty';
  }

  if (p.includes('limited') || p.includes('lux')) {
    if (s.includes('limited')) return 'ms:limited';
    if (s.includes('lux') || s.includes('brand')) return 'ms:luxury';
    if (s.includes('hunter')) return 'ms:hunter';
    return 'ms:luxury';
  }

  if (p.includes('hobi') || p.includes('hobby') || p.includes('rekreasi') || p.includes('recreation')) {
    if (s.includes('sport')) return 'ms:sports';
    if (s.includes('game') || s.includes('console')) return 'ms:game';
    if (s.includes('music') || s.includes('instrument')) return 'ms:music';
    if (s.includes('book') || s.includes('stationery') || s.includes('buku') || s.includes('alat tulis')) return 'ms:book';
    return 'ms:sports';
  }

  if (p.includes('baby') || p.includes('kids') || p.includes('anak')) {
    if (s.includes('toy')) return 'ms:toys';
    if (s.includes('care') || s.includes('perawatan')) return 'ms:babycare';
    if (s.includes('clothing') || s.includes('pakaian')) return 'ms:baby';
    return 'ms:baby';
  }

  if (p.includes('motor')) {
    if (s.includes('part')) return 'ms:parts';
    if (s.includes('accessor')) return 'ms:accessory';
    return 'ms:moto';
  }

  if (p.includes('other') || p.includes('lain')) {
    if (s.includes('hand') || s.includes('craft')) return 'ms:handcrafts';
    return 'ms:others';
  }

  return 'ms:others';
}

async function run() {
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  console.log(`parents: ${parentsSnap.size}`);

  for (const pDoc of parentsSnap.docs) {
    const p = pDoc.data();
    const pSlug = (p.slug || p.id || pDoc.id).toString();
    if (!p.icon) {
      const icon = iconForParent(pSlug);
      console.log(`parent ${pDoc.id} -> ${icon}`);
      if (!DRY) await pDoc.ref.set({ icon }, { merge: true });
    }

    const subsSnap = await pDoc.ref.collection('subCategories').orderBy('order').get();
    for (const sDoc of subsSnap.docs) {
      const s = sDoc.data();
      const sSlug = (s.slug || s.id || sDoc.id).toString();
      if (!s.icon) {
        const icon = iconForSub(pSlug, sSlug);
        console.log(`  sub ${sDoc.id} -> ${icon}`);
        if (!DRY) await sDoc.ref.set({ icon }, { merge: true });
      }
    }
  }

  console.log(DRY ? 'Dry run done.' : 'Icon fill completed.');
  process.exit(0);
}

run().catch(e => {
  console.error(e);
  process.exit(1);
});

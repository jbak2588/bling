#!/usr/bin/env node
// scripts/print_categories_structure.js
// Prints all parents and their subcategories from categories_v2
const admin = require('firebase-admin');
const path = require('path');
const saPath = path.join(__dirname, 'serviceAccountKey.json');
const serviceAccount = require(saPath);
if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}
const db = admin.firestore();

async function listAll(){
  const parentsSnap = await db.collection('categories_v2').orderBy('order').get();
  console.log(`parents=${parentsSnap.size}`);
  for (const pDoc of parentsSnap.docs){
    const p = pDoc.data();
    const pid = pDoc.id;
    console.log(`\nPARENT: id=${pid} slug=${p.slug || ''} name_en=${p.nameEn || ''} icon=${p.icon || ''}`);
    const subsSnap = await pDoc.ref.collection('subCategories').orderBy('order').get();
    console.log(`  subs=${subsSnap.size}`);
    for (const sDoc of subsSnap.docs){
      const s = sDoc.data();
      console.log(`    - id=${sDoc.id} slug=${s.slug || ''} name_en=${s.nameEn || ''} icon=${s.icon || ''}`);
    }
  }
}

listAll().then(()=>process.exit(0)).catch(e=>{ console.error(e); process.exit(1); });

/**
 * Audit POM documents that still reference Firebase Storage paths under 'shorts/'.
 *
 * This script scans the 'pom' collection and prints any docs whose mediaUrls
 * contain 'shorts/'. Use this to identify records that will fail playback
 * because the old shorts storage files were deleted.
 *
 * Usage:
 *   node scripts/audit_pom_shorts_urls.js
 */

const admin = require('firebase-admin');
const path = require('path');

// Load service account key from scripts/serviceAccountKey.json (already in repo)
const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function run() {
  const pageSize = 500;
  let last = null;
  let total = 0;
  let flagged = 0;

  console.log('Scanning pom collection for mediaUrls containing "shorts/" ...');
  while (true) {
    let q = db.collection('pom').orderBy('createdAt', 'desc').limit(pageSize);
    if (last) q = q.startAfter(last);
    const snap = await q.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      total++;
      const data = doc.data() || {};
      const mediaUrls = Array.isArray(data.mediaUrls) ? data.mediaUrls : [];
      const bad = mediaUrls.filter((u) => typeof u === 'string' && u.includes('/shorts/'));
      if (bad.length > 0) {
        flagged++;
        console.log(`- ${doc.id} | createdAt=${data.createdAt?.toDate?.() || data.createdAt} | badUrls=${bad.length}`);
        bad.forEach((u) => console.log(`    ${u}`));
      }
    }

    last = snap.docs[snap.docs.length - 1];
    if (snap.size < pageSize) break;
  }

  console.log('---');
  console.log(`Checked: ${total} docs`);
  console.log(`Flagged: ${flagged} docs with mediaUrls referencing '/shorts/'`);
}

run().then(() => process.exit(0)).catch((e) => {
  console.error(e);
  process.exit(1);
});

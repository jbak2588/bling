// migrate_shorts_to_pom.js
// Copies all docs from 'shorts' to 'pom' with new PomModel schema
// - Sets mediaType: 'video'
// - Converts videoUrl -> mediaUrls: [videoUrl]
// - Preserves thumbnailUrl and other fields
// - Copies 'comments' subcollection for each doc
// Uses paginated reads on documentId to avoid memory spikes

const admin = require('firebase-admin');
const path = require('path');

// 1) Load service account from same directory
const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const SOURCE_COLLECTION = 'shorts';
const DEST_COLLECTION = 'pom';

// How many source docs to process per page
const PAGE_SIZE = 300; // keep modest to leave room for subcollection batched writes

// Helper: chunk an array into arrays of size n
function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) {
    out.push(arr.slice(i, i + n));
  }
  return out;
}

function toPomData(shortData) {
  const newPomData = {
    ...shortData,
    mediaType: 'video',
    mediaUrls: [],
    thumbnailUrl: shortData.thumbnailUrl || '',
  };
  if (shortData.videoUrl) {
    newPomData.mediaUrls = [shortData.videoUrl];
  }
  delete newPomData.videoUrl;
  return newPomData;
}

async function migrateDoc(doc) {
  const shortData = doc.data();
  const newPomData = toPomData(shortData);
  const destDocRef = db.collection(DEST_COLLECTION).doc(doc.id);

  // Write parent doc
  await destDocRef.set(newPomData, { merge: true });

  // Copy comments subcollection in chunks
  const commentsSnap = await doc.ref.collection('comments').get();
  if (!commentsSnap.empty) {
    const commentDocs = commentsSnap.docs;
    const chunks = chunk(commentDocs, 400); // Firestore batch hard limit 500 writes
    for (const ch of chunks) {
      const batch = db.batch();
      ch.forEach((c) => {
        const target = destDocRef.collection('comments').doc(c.id);
        batch.set(target, c.data());
      });
      await batch.commit();
    }
  }
}

async function migrateAll() {
  console.log(`Starting migration from '${SOURCE_COLLECTION}' to '${DEST_COLLECTION}'...`);
  let lastId = null;
  let total = 0;
  while (true) {
    let q = db
      .collection(SOURCE_COLLECTION)
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(PAGE_SIZE);

    if (lastId) {
      q = q.startAfter(lastId);
    }

    const snap = await q.get();
    if (snap.empty) {
      break;
    }

    // Migrate each doc sequentially to keep batch sizes safe
    for (const doc of snap.docs) {
      await migrateDoc(doc);
      total += 1;
      lastId = doc.id;
      if (total % 25 === 0) {
        console.log(`  Migrated ${total} docs so far... lastId=${lastId}`);
      }
    }
  }
  console.log(`✅ Migration complete. Total migrated docs: ${total}`);
}

(async () => {
  try {
    await migrateAll();
  } catch (err) {
    console.error('❌ Error during migration:', err);
    process.exitCode = 1;
  }
})();

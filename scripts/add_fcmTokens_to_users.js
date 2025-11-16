/*
 One-time script to add an empty `fcmTokens` array to all documents
 in the `users` collection that don't already have the field.

 Usage (PowerShell):
 1) Install deps (one-time):
    npm install firebase-admin

 2) Prepare credentials: Download a service account JSON for your Firebase project
    and set the environment variable. Example (PowerShell):
    $env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\service-account.json'

 3) Dry-run to preview changes:
    node scripts/add_fcmTokens_to_users.js --dry-run

 4) Commit changes:
    node scripts/add_fcmTokens_to_users.js --commit

 Notes:
 - Script will only update documents missing the `fcmTokens` field.
 - For ~20 users this will run quickly. The script uses batched commits
   (max 500 operations per batch) to be efficient.
 - Make a Firestore export or backup if you want a snapshot before changes.
*/

const admin = require('firebase-admin');
const args = process.argv.slice(2);

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.warn('\nWARNING: GOOGLE_APPLICATION_CREDENTIALS not set.');
  console.warn('If running locally, set it to your service account JSON path.');
}

admin.initializeApp();
const db = admin.firestore();

async function main() {
  const commit = args.includes('--commit');
  const dryRun = args.includes('--dry-run') || !commit;
  console.log(`Starting ${dryRun ? 'dry-run (no writes)' : 'commit (will write)'}...`);

  const usersRef = db.collection('users');
  const snapshot = await usersRef.get();
  console.log(`Found ${snapshot.size} user documents.`);

  const docsToUpdate = [];
  snapshot.forEach(doc => {
    const data = doc.data();
    if (!Object.prototype.hasOwnProperty.call(data, 'fcmTokens')) {
      docsToUpdate.push({ id: doc.id, ref: doc.ref });
    }
  });

  console.log(`Docs missing 'fcmTokens': ${docsToUpdate.length}`);
  if (docsToUpdate.length === 0) {
    console.log('Nothing to do. Exiting.');
    return;
  }

  if (dryRun) {
    console.log('\nDry-run list:');
    docsToUpdate.forEach(d => console.log(` - ${d.id}`));
    console.log('\nTo actually write, re-run with --commit');
    return;
  }

  // Commit in batches of 500
  const BATCH_SIZE = 500;
  for (let i = 0; i < docsToUpdate.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const slice = docsToUpdate.slice(i, i + BATCH_SIZE);
    slice.forEach(d => {
      batch.update(d.ref, { fcmTokens: [] });
    });
    await batch.commit();
    console.log(`Committed batch: ${i} -> ${i + slice.length}`);
  }

  console.log('All updates applied.');
}

main().catch(err => {
  console.error('Error running script:', err);
  process.exit(1);
});

/**
 * Backfill script: populate `categoryParentId` on products documents.
 *
 * Strategy per product:
 * 1) If product.categoryId is empty -> skip
 * 2) Try read `categories_v2/{categoryId}` -> if exists, product is a parent category
 *    - set product.categoryParentId = null
 * 3) Else, search collectionGroup('subCategories') where __name__ == categoryId
 *    - if found, use the parent's id (doc.reference.parent.parent.id)
 *    - set product.categoryParentId = parentId (or null if not found)
 *
 * Usage:
 *  - Install deps: `npm install` (in repo root, package.json already lists firebase-admin)
 *  - Provide credentials: set environment variable `GOOGLE_APPLICATION_CREDENTIALS` to a
 *    service account JSON with Firestore access, or run on a machine with gcloud auth.
 *  - Dry run (no writes): `node backfill_category_parent_for_products.js --dryRun`
 *  - Limit processed docs: `node backfill_category_parent_for_products.js --limit=100`
 *  - Run from repo root: `node scripts/backfill_category_parent_for_products.js`
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Optional: if you prefer to initialize using a service account file path hardcoded,
// you can uncomment and set the path below. Otherwise rely on GOOGLE_APPLICATION_CREDENTIALS env var.
// const serviceAccount = require('/path/to/serviceAccountKey.json');

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { dryRun: false, limit: null, keyPath: null, backup: false };
  args.forEach((a) => {
    if (a === '--dryRun' || a === '--dry-run') opts.dryRun = true;
    if (a.startsWith('--limit=')) opts.limit = parseInt(a.split('=')[1], 10);
    if (a.startsWith('--key=') || a.startsWith('--serviceAccount=')) {
      opts.keyPath = a.split('=')[1];
    }
    if (a === '--backup' || a === '--with-backup') {
      opts.backup = true;
    }
  });
  return opts;
}

async function main() {
  const opts = parseArgs();
  console.log('Starting backfill_category_parent_for_products', opts);

  // Initialize admin SDK
  if (!admin.apps.length) {
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      // Use ADC (Application Default Credentials) if set
      try {
        admin.initializeApp();
        console.log('Initialized admin SDK using GOOGLE_APPLICATION_CREDENTIALS');
      } catch (err) {
        console.error('Failed to initialize admin SDK from environment credentials:', err.message || err);
        throw err;
      }
    } else if (opts.keyPath) {
      // Try to load provided service account key file
      try {
        const key = require(path.resolve(opts.keyPath));
        admin.initializeApp({ credential: admin.credential.cert(key) });
        console.log('Initialized admin SDK using provided key:', opts.keyPath);
      } catch (err) {
        console.error('Failed to read service account key from', opts.keyPath, err.message || err);
        throw err;
      }
    } else {
      // No credentials found — instruct user
      throw new Error('No credentials found. Set GOOGLE_APPLICATION_CREDENTIALS or pass --key=/path/to/serviceAccount.json');
    }
  }

  const db = admin.firestore();
  const unresolved = [];
  // Preload parent category ids to allow per-parent subcategory doc checks
  console.log('[info] Loading parent category ids...');
  const parentDocsSnap = await db.collection('categories_v2').get();
  const parentIds = parentDocsSnap.docs.map((d) => d.id);
  console.log(`[info] Loaded ${parentIds.length} parent categories`);
  console.log('[info] parentIds:', parentIds.join(', '));

  // Helper: backup original product doc and update it
  async function backupAndUpdate(doc, productId, updateObj, originalData) {
    if (!opts.dryRun && opts.backup) {
      try {
        await db.collection('products_backups').doc(productId).set(Object.assign({}, originalData, { _backupAt: admin.firestore.FieldValue.serverTimestamp() }));
        console.log(`[info] Backed up product ${productId} to products_backups/${productId}`);
      } catch (err) {
        console.error(`[error] product ${productId}: failed to backup:`, err.message || err);
        // proceed with update attempt even if backup fails
      }
    }

    try {
      await doc.ref.update(updateObj);
      console.log(`[info] product ${productId}: updated with ${JSON.stringify(updateObj)}`);
    } catch (err) {
      console.error(`[error] product ${productId}: failed to update:`, err.message || err);
      unresolved.push({ productId, categoryId: originalData.categoryId, error: (err.message || String(err)) });
    }
  }

  const productsRef = db.collection('products');

  // iterate products in pages
  const pageSize = 500;
  let processed = 0;
  let lastDoc = null;
  let stopEarly = false;

  while (true) {
    let q = productsRef.orderBy('__name__').limit(pageSize);
    if (lastDoc) q = q.startAfter(lastDoc);
    const snap = await q.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      lastDoc = doc;
      processed += 1;
      if (opts.limit && processed > opts.limit) {
        console.log('Reached --limit, stopping');
        stopEarly = true;
        break;
      }

      const data = doc.data();
      const productId = doc.id;
      const catId = data.categoryId;

      if (!catId) {
        console.log(`[skip] product ${productId} has no categoryId`);
        continue;
      }

      // First try direct parent doc
      const parentDocRef = db.collection('categories_v2').doc(catId);
      const parentDoc = await parentDocRef.get();
        if (parentDoc.exists) {
        // product.categoryId points to a parent category
        const parentIdValue = null; // keep null to indicate top-level
        console.log(`[info] product ${productId}: categoryId ${catId} is parent; will set categoryParentId=null`);
        if (!opts.dryRun) {
          await backupAndUpdate(doc, productId, { categoryParentId: parentIdValue }, data);
        }
        continue;
      }

      // Fallback: try multiple strategies to resolve by slug when doc id lookup fails
      try {
        // 1) Try to find a parent doc whose `slug` equals catId
        const parentBySlugQ = await db.collection('categories_v2')
          .where('slug', '==', catId)
          .limit(1)
          .get();
        if (!parentBySlugQ.empty) {
          const parentDocFound = parentBySlugQ.docs[0];
          console.log(`[info] product ${productId}: resolved parent by slug -> ${parentDocFound.id}`);
          if (!opts.dryRun) await doc.ref.update({ categoryParentId: null });
          continue;
        }

        // 2) Try to find a subcategory document whose `slug` equals catId across all subcollections
        // Use collectionGroup for slug matches (should be indexed); fallback to per-parent checks
        let resolved = false;
        try {
          const subBySlugQ = await db.collectionGroup('subCategories')
            .where('slug', '==', catId)
            .limit(1)
            .get();
          if (!subBySlugQ.empty) {
            const subDoc = subBySlugQ.docs[0];
            const parentRef = subDoc.ref.parent.parent;
            const parentId = parentRef ? parentRef.id : null;
            console.log(`[info] product ${productId}: resolved parentId=${parentId} by sub.slug=${catId}`);
            if (!opts.dryRun) await backupAndUpdate(doc, productId, { categoryParentId: parentId }, data);
            resolved = true;
          }
        } catch (errSubSlug) {
          console.error(`[warn] product ${productId}: collectionGroup sub.slug query failed:`, errSubSlug.message || errSubSlug);
        }

        if (resolved) continue;

        // 3) Try per-parent subcollection lookups by doc id (avoid collectionGroup doc-id queries)
        try {
          for (const pId of parentIds) {
            const subRef = db.collection('categories_v2').doc(pId).collection('subCategories').doc(catId);
            const subSnap = await subRef.get();
            if (subSnap.exists) {
              console.log(`[info] product ${productId}: resolved parentId=${pId} by checking parent ${pId} for sub doc ${catId}`);
              if (!opts.dryRun) await backupAndUpdate(doc, productId, { categoryParentId: pId }, data);
              resolved = true;
              break;
            }
          }
        } catch (errPerParent) {
          console.error(`[error] product ${productId}: per-parent subcollection checks failed:`, errPerParent.message || errPerParent);
        }

        if (resolved) continue;

        console.log(`[warn] product ${productId}: could not find category ${catId} by slug or doc id`);
        if (!opts.dryRun) {
          await doc.ref.update({ categoryParentId: null });
        }
      } catch (err) {
        console.error(`[error] product ${productId}: fallback search failed:`, err.message || err);
        unresolved.push({ productId, categoryId: catId, error: (err.message || String(err)) });
      }
    }
    if (stopEarly) break;
  }

  console.log('Backfill complete');
  // Write unresolved report to file for manual inspection
  try {
    const outPath = path.join(__dirname, 'backfill_unresolved.json');
    fs.writeFileSync(outPath, JSON.stringify(unresolved, null, 2));
    console.log(`[info] Wrote unresolved report to ${outPath} (${unresolved.length} items)`);
  } catch (err) {
    console.error('[error] Failed to write unresolved report:', err.message || err);
  }
}

main().catch((err) => {
  console.error('Fatal error', err);
  process.exit(1);
});

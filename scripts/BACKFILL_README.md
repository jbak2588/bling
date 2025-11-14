Backfill `categoryParentId` for products

Purpose
- Some products only store `categoryId`, not the parent category id. This script will populate `categoryParentId` for existing product documents by resolving the category hierarchy in `categories_v2`.

Usage
1. Install dependencies in project root (package.json already contains `firebase-admin`):

```powershell
cd c:\bling\bling_app
npm install
```

2. Provide credentials (one of the options below):

- Option A (recommended): set `GOOGLE_APPLICATION_CREDENTIALS` to the path of a service account JSON with Firestore access, for example in PowerShell:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\path\to\serviceAccount.json'
```

- Option B: pass the key file path directly to the script with `--key=`:

```powershell
node scripts/backfill_category_parent_for_products.js --key='C:\path\to\serviceAccount.json' --dryRun
```

3. Run the script (dry run first):

```powershell
# Dry run (no writes) using environment credential
node scripts/backfill_category_parent_for_products.js --dryRun --limit=50

# Dry run using explicit key path
node scripts/backfill_category_parent_for_products.js --key='C:\path\to\serviceAccount.json' --dryRun --limit=50

# Full run (writes applied)
node scripts/backfill_category_parent_for_products.js --key='C:\path\to\serviceAccount.json'
```

Notes
- The script attempts a direct lookup at `categories_v2/{categoryId}` first. If found, it treats the category as a parent and writes `categoryParentId: null`.
- If not found, it searches `collectionGroup('subCategories')` for a doc with the same id and uses that doc's parent as `categoryParentId`.
- The script sets `categoryParentId` to `null` if the category cannot be resolved.
- Run in off-peak hours and consider snapshotting/backup before making large updates.

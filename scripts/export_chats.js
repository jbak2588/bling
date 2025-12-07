// scripts/export_chats.js
// Usage:
//   1) Install dependency (in repo root):
//        npm install firebase-admin
//   2) Run (PowerShell):
//        node .\scripts\export_chats.js --serviceAccount .\build\serviceAccountKey.json
//      or set env var GOOGLE_APPLICATION_CREDENTIALS to the service account JSON path and run without --serviceAccount
//
// This script exports all documents in the `chats` collection (including their subcollections)
// to a JSON file under `exports/chats_export_<timestamp>.json`.

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

function usageAndExit() {
  console.log('Usage: node scripts/export_chats.js [--serviceAccount <path/to/serviceAccount.json>] [--output <path>]');
  process.exit(1);
}

// Simple CLI parsing
const args = process.argv.slice(2);
let serviceAccountPath = null;
let outputPath = null;
for (let i = 0; i < args.length; i++) {
  const a = args[i];
  if (a === '--serviceAccount' && args[i+1]) {
    serviceAccountPath = args[i+1];
    i++;
  } else if (a === '--output' && args[i+1]) {
    outputPath = args[i+1];
    i++;
  } else if (a === '--help' || a === '-h') {
    usageAndExit();
  }
}

// If GOOGLE_APPLICATION_CREDENTIALS env var is set and no explicit path provided, use it
if (!serviceAccountPath && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
}
// Default to `scripts/serviceAccountKey.json` if present in the repo
if (!serviceAccountPath) {
  const defaultSa = path.resolve(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(defaultSa)) {
    serviceAccountPath = defaultSa;
    console.log(`Using default service account at: ${serviceAccountPath}`);
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  } else {
    console.warn('No service account path provided. You can set GOOGLE_APPLICATION_CREDENTIALS, pass --serviceAccount <path>, or place serviceAccountKey.json in the scripts/ folder.');
    // We'll still attempt applicationDefault credentials if available
  }
}

// Initialize Firebase Admin
try {
  if (serviceAccountPath && fs.existsSync(serviceAccountPath)) {
    const sa = require(path.resolve(serviceAccountPath));
    admin.initializeApp({ credential: admin.credential.cert(sa) });
  } else {
    // Try application default credentials
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
  }
} catch (e) {
  console.error('Failed to initialize Firebase Admin SDK:', e.message || e);
  process.exit(1);
}

const db = admin.firestore();

function convertValue(v) {
  if (v === null || v === undefined) return v;
  // Firestore Timestamp
  if (v && typeof v.toDate === 'function') {
    try {
      return v.toDate().toISOString();
    } catch (_) {
      return String(v);
    }
  }
  // GeoPoint
  if (v && typeof v.latitude === 'number' && typeof v.longitude === 'number') {
    return { _geoPoint: { lat: v.latitude, lng: v.longitude } };
  }
  // DocumentReference
  if (v && typeof v.path === 'string' && typeof v.id === 'string' && typeof v.get === 'function') {
    return { _ref: v.path };
  }
  // Arrays and objects
  if (Array.isArray(v)) return v.map(convertValue);
  if (typeof v === 'object') {
    const out = {};
    for (const key of Object.keys(v)) out[key] = convertValue(v[key]);
    return out;
  }
  return v;
}

async function getDocRecursively(docRef) {
  const docSnap = await docRef.get();
  if (!docSnap.exists) return null;

  const rawData = docSnap.data();
  const data = {};
  for (const k of Object.keys(rawData)) {
    data[k] = convertValue(rawData[k]);
  }

  // Metadata
  data.__id = docRef.id;
  data.__createTime = docSnap.createTime ? docSnap.createTime.toDate().toISOString() : null;
  data.__updateTime = docSnap.updateTime ? docSnap.updateTime.toDate().toISOString() : null;

  // Subcollections
  const subcols = await docRef.listCollections();
  for (const col of subcols) {
    const colSnap = await col.get();
    data[col.id] = [];
    for (const d of colSnap.docs) {
      const sub = await getDocRecursively(d.ref);
      data[col.id].push(sub);
    }
  }

  return data;
}

(async () => {
  try {
    console.log('Starting export of `chats` collection...');

    const chatsCol = db.collection('chats');
    const snapshot = await chatsCol.get();

    const result = {};
    let i = 0;
    for (const doc of snapshot.docs) {
      i++;
      process.stdout.write(`Processing ${i}/${snapshot.size}: ${doc.id}\r`);
      const obj = await getDocRecursively(doc.ref);
      result[doc.id] = obj;
    }
    console.log('\nFetch complete. Preparing output...');

    const ts = new Date().toISOString().replace(/[:.]/g, '-');
    const outDir = outputPath ? path.resolve(outputPath) : path.resolve(__dirname, '..', 'exports');
    if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
    const outFile = path.join(outDir, `chats_export_${ts}.json`);
    fs.writeFileSync(outFile, JSON.stringify(result, null, 2), 'utf8');

    console.log('Export saved to:', outFile);
    process.exit(0);
  } catch (err) {
    console.error('Export failed:', err);
    process.exit(1);
  }
})();

#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const REPORT_FILE = path.resolve(__dirname, 'i18n-keys-by-file.json');
const LOCALES = [
  { code: 'en', file: path.resolve(__dirname, '..', 'assets', 'lang', 'en.json') },
  { code: 'id', file: path.resolve(__dirname, '..', 'assets', 'lang', 'id.json') },
  { code: 'ko', file: path.resolve(__dirname, '..', 'assets', 'lang', 'ko.json') },
];

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (e) {
    console.error('Failed to read/parse', file, e.message);
    return null;
  }
}

function flatten(obj, prefix = '') {
  const res = {};
  for (const k of Object.keys(obj || {})) {
    const v = obj[k];
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      Object.assign(res, flatten(v, key));
    } else {
      res[key] = v;
    }
  }
  return res;
}

function unflatten(flat) {
  const res = {};
  for (const [k, v] of Object.entries(flat)) {
    const parts = k.split('.');
    let cur = res;
    for (let i = 0; i < parts.length; i++) {
      const p = parts[i];
      if (i === parts.length - 1) cur[p] = v;
      else {
        if (!cur[p] || typeof cur[p] !== 'object') cur[p] = {};
        cur = cur[p];
      }
    }
  }
  return res;
}

function writeJson(file, obj) {
  fs.writeFileSync(file, JSON.stringify(obj, null, 2) + '\n', 'utf8');
}

function ensureBackup(file, suffix) {
  const backup = file + suffix;
  if (!fs.existsSync(backup)) fs.copyFileSync(file, backup);
  return backup;
}

function loadReport() {
  if (!fs.existsSync(REPORT_FILE)) {
    console.error('Report file not found:', REPORT_FILE);
    process.exit(1);
  }
  return readJson(REPORT_FILE);
}

function buildUnionUsed(report) {
  const union = new Set();
  for (const [file, keys] of Object.entries(report.keysByFile || {})) {
    for (const k of keys) union.add(k);
  }
  // include dynamicCandidates that exist in original locales later
  const dynamic = new Set(report.dynamicCandidates || []);
  return { union: [...union].sort(), dynamic: [...dynamic].sort() };
}

function conservativeInclude(key, dynamicSet, originalFlat) {
  // include if used or if dynamic candidate exists in originalFlat
  if (originalFlat && Object.prototype.hasOwnProperty.call(originalFlat, key)) return true;
  if (dynamicSet && dynamicSet.has(key)) return true;
  return false;
}

function run() {
  console.log('Loading per-file report...');
  const report = loadReport();
  const { union, dynamic } = buildUnionUsed(report);
  const dynamicSet = new Set(dynamic);

  for (const loc of LOCALES) {
    const file = loc.file;
    console.log('\nProcessing locale:', loc.code, file);
    const orig = readJson(file);
    if (!orig) { console.warn(' - missing or invalid, skipping'); continue; }
    const origFlat = flatten(orig);

    // Back up original conservatively
    const backup = ensureBackup(file, '.conservative.orig');
    console.log(' - backup:', backup);

    // Build new flat map: include keys that are in union OR present in dynamic candidates in original
    const newFlat = {};
    for (const k of union) {
      if (Object.prototype.hasOwnProperty.call(origFlat, k)) {
        newFlat[k] = origFlat[k];
      }
    }
    // Also include dynamic candidates that exist in originalFlat
    for (const d of dynamic) {
      if (Object.prototype.hasOwnProperty.call(origFlat, d)) newFlat[d] = origFlat[d];
    }

    // As a conservative safety, include any top-level key in original that is an object and has at least one included descendant
    const includedTopLevel = new Set();
    for (const k of Object.keys(newFlat)) {
      const top = k.split('.')[0];
      includedTopLevel.add(top);
    }
    for (const t of includedTopLevel) {
      // nothing: this ensures top-level structure will exist when we unflatten
    }

    const rebuilt = unflatten(newFlat);
    const outFile = file.replace(/\.json$/, '.conservative.rebuilt.json');
    writeJson(outFile, rebuilt);
    console.log(' - wrote rebuilt file:', outFile, ' (keys included:', Object.keys(newFlat).length, ')');
  }

  console.log('\nDone. Rebuilt files written as *.conservative.rebuilt.json. Originals backed up as *.conservative.orig.');
}

run();

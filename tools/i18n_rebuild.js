#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

// Paths
const ROOT = path.resolve(__dirname, '..');
const LIB_DIR = path.join(ROOT, 'lib');
const LOCALES = [
  { code: 'en', file: path.join(ROOT, 'assets', 'lang', 'en.json') },
  { code: 'id', file: path.join(ROOT, 'assets', 'lang', 'id.json') },
  { code: 'ko', file: path.join(ROOT, 'assets', 'lang', 'ko.json') },
];

function flatten(obj, prefix = '') {
  const res = {};
  if (!obj) return res;
  for (const k of Object.keys(obj)) {
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
  const out = {};
  for (const [k, v] of Object.entries(flat)) {
    const parts = k.split('.');
    let cur = out;
    for (let i = 0; i < parts.length; i++) {
      const p = parts[i];
      if (i === parts.length - 1) {
        cur[p] = v;
      } else {
        if (!cur[p] || typeof cur[p] !== 'object') cur[p] = {};
        cur = cur[p];
      }
    }
  }
  return out;
}

async function scanDartFiles(root) {
  const results = [];
  async function walk(dir) {
    const entries = await fs.promises.readdir(dir, { withFileTypes: true });
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (['build', '.dart_tool', '.git'].includes(e.name)) continue;
        await walk(full);
      } else if (e.isFile() && e.name.endsWith('.dart')) {
        results.push(full);
      }
    }
  }
  await walk(root);
  return results;
}

function extractKeysFromText(text) {
  const keys = new Set();
  const reTrFunc = /\btr\s*\(\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;
  const reTrMethod = /['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]\s*\.tr\s*\(/g;
  const reSafeTr = /\bsafeTr\s*\(\s*[^,]+,\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;
  let m;
  while ((m = reTrFunc.exec(text))) keys.add(m[1]);
  while ((m = reTrMethod.exec(text))) keys.add(m[1]);
  while ((m = reSafeTr.exec(text))) keys.add(m[1]);
  return keys;
}

function backupFile(file) {
  try {
    const stat = fs.statSync(file);
    const bak = file + '.orig';
    if (!fs.existsSync(bak)) fs.copyFileSync(file, bak);
    return bak;
  } catch (e) {
    return null;
  }
}

async function main() {
  console.log('Rebuild: scanning Dart files to collect used translation keys...');
  const dartFiles = await scanDartFiles(LIB_DIR);
  console.log('Found', dartFiles.length, 'Dart files.');

  const usedKeys = new Set();
  for (const f of dartFiles) {
    try {
      const txt = await fs.promises.readFile(f, 'utf8');
      const ks = extractKeysFromText(txt);
      ks.forEach(k => usedKeys.add(k));
    } catch (e) {
      console.warn('Failed to read', f, e.message);
    }
  }
  console.log('Used keys found:', usedKeys.size);

  // Load locales
  const localeData = {};
  for (const loc of LOCALES) {
    try {
      const raw = await fs.promises.readFile(loc.file, 'utf8');
      const parsed = JSON.parse(raw);
      localeData[loc.code] = { file: loc.file, json: parsed, flat: flatten(parsed) };
    } catch (e) {
      console.warn('Failed to load locale', loc.file, e.message);
      localeData[loc.code] = { file: loc.file, json: {}, flat: {} };
    }
  }

  // Determine fallback order for copying missing translations
  const fallbackOrder = ['en', 'id', 'ko'];

  // Build rebuilt flat maps containing only used keys
  const rebuilt = {};
  for (const code of Object.keys(localeData)) {
    rebuilt[code] = {};
  }

  for (const key of usedKeys) {
    // For each locale, prefer existing value, otherwise fallback to other locales in order
    for (const code of Object.keys(localeData)) {
      const localeFlat = localeData[code].flat || {};
      if (Object.prototype.hasOwnProperty.call(localeFlat, key)) {
        rebuilt[code][key] = localeFlat[key];
      } else {
        // try fallback sources in order (prefer en)
        let found = false;
        for (const fb of fallbackOrder) {
          const fbFlat = localeData[fb] && localeData[fb].flat ? localeData[fb].flat : {};
          if (Object.prototype.hasOwnProperty.call(fbFlat, key)) {
            rebuilt[code][key] = fbFlat[key];
            found = true;
            break;
          }
        }
        if (!found) rebuilt[code][key] = '';
      }
    }
  }

  // Backup and write rebuilt locale files (also keep .orig backups)
  for (const code of Object.keys(localeData)) {
    const loc = localeData[code];
    const file = loc.file;
    const bak = backupFile(file);
    if (bak) console.log('Backed up', file, '->', bak);
    const unflat = unflatten(rebuilt[code]);
    const out = JSON.stringify(unflat, null, 2) + '\n';
    await fs.promises.writeFile(file, out, 'utf8');
    console.log('Wrote rebuilt locale:', file, `(keys: ${Object.keys(rebuilt[code]).length})`);
    // also write a copy for inspection without overwriting original name
    const inspectFile = file.replace(/\.json$/, '.rebuilt.json');
    await fs.promises.writeFile(inspectFile, out, 'utf8');
  }

  console.log('\nRebuild complete.');
  for (const code of Object.keys(localeData)) {
    const file = localeData[code].file;
    const rebuiltFile = file.replace(/\.json$/, '.rebuilt.json');
    console.log(`- ${code}: ${rebuiltFile}`);
  }
  console.log('\nIf you want to inspect the results before committing, review the `.rebuilt.json` files. Originals were backed up with `.orig` suffix.');
}

main().catch(err => {
  console.error('Error rebuilding locales:', err);
  process.exit(2);
});

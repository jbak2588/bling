// scripts/optimize_i18n.js
// Extract used i18n keys from lib/**/*.dart and generate trimmed JSON files into assets/i18n/.
//
// Usage (PowerShell):
//   node scripts/optimize_i18n.js

const fs = require('fs');
const path = require('path');

// ---- Manual whitelist (prefixes) ----
// Keys that are referenced indirectly (maps/lists/constants) and might not appear as `.tr()`.
// Add more prefixes as needed.
const manualWhitelist = [
  'categories.',
  'jobs.categories.',
  // Job (dynamic key patterns)
  'jobs.salaryTypes.',
  'jobs.workPeriods.',
  // Real Estate (dynamic key patterns)
  'realEstate.priceUnits.',
  'realEstate.form.',
  'realEstate.filter.',
  // App Info & Settings (dynamic key patterns)
  'appInfo.features.',
  'settings.notifications.scope.',
  // Profile (dynamic key patterns)
  'interests.items.',
];

const projectRoot = path.resolve(__dirname, '..');
const libRoot = path.join(projectRoot, 'lib');
const langDir = path.join(projectRoot, 'assets', 'lang');
const outDir = path.join(projectRoot, 'assets', 'i18n');

const languages = ['en', 'ko', 'id'];

function walkFiles(dir, predicate) {
  const results = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const ent of entries) {
    const full = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      results.push(...walkFiles(full, predicate));
    } else if (ent.isFile()) {
      if (!predicate || predicate(full)) results.push(full);
    }
  }
  return results;
}

function indexToLineNumber(text, index) {
  // 1-based line number
  let line = 1;
  for (let i = 0; i < index; i++) {
    if (text.charCodeAt(i) === 10) line++; // '\n'
  }
  return line;
}

function addKeyOrWarn(usedKeys, key, filePath, index) {
  if (!key) return;
  if (key.includes('$')) {
    const line = indexToLineNumber(fs.readFileSync(filePath, 'utf8'), index);
    console.log(`[WARNING] Dynamic key found: ${key} (${path.relative(projectRoot, filePath)}:${line})`);
    return;
  }
  usedKeys.add(key);
}

function extractUsedKeysFromDartFiles(dartFiles) {
  const usedKeys = new Set();

  // Patterns:
  // 1) 'some.key'.tr(  or  "some.key".tr(
  const reDotTr = /(['"])([^'"\n]+?)\1\s*\.\s*tr\s*\(/g;

  // 2) tr('some.key') or tr("some.key")
  const reTrFn = /\btr\s*\(\s*(['"])([^'"\n]+?)\1\s*[),]/g;

  // 3) Text('some.key').tr()  (non-standard but requested)
  const reTextDotTr = /\bText\s*\(\s*(['"])([^'"\n]+?)\1\s*\)\s*\.\s*tr\s*\(/g;

  // 4) plural('some.key', ...)
  const rePlural = /\bplural\s*\(\s*(['"])([^'"\n]+?)\1\s*,/g;

  const regexes = [reDotTr, reTrFn, reTextDotTr, rePlural];

  for (const file of dartFiles) {
    const text = fs.readFileSync(file, 'utf8');

    for (const re of regexes) {
      re.lastIndex = 0;
      let match;
      while ((match = re.exec(text)) !== null) {
        const key = match[2];
        addKeyOrWarn(usedKeys, key, file, match.index);
      }
    }
  }

  return usedKeys;
}

function shouldKeepPath(fullPath, usedKeys) {
  if (usedKeys.has(fullPath)) return true;
  for (const prefix of manualWhitelist) {
    if (fullPath.startsWith(prefix)) return true;
  }
  return false;
}

function filterJsonByUsedKeys(obj, usedKeys, prefix = '') {
  if (obj === null || obj === undefined) return undefined;

  // Arrays are treated as leaf values under their key path
  if (Array.isArray(obj)) {
    return shouldKeepPath(prefix, usedKeys) ? obj : undefined;
  }

  if (typeof obj !== 'object') {
    return shouldKeepPath(prefix, usedKeys) ? obj : undefined;
  }

  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    const nextPath = prefix ? `${prefix}.${k}` : k;

    if (v !== null && typeof v === 'object' && !Array.isArray(v)) {
      const child = filterJsonByUsedKeys(v, usedKeys, nextPath);
      if (child && typeof child === 'object' && Object.keys(child).length > 0) {
        out[k] = child;
      }
    } else {
      const kept = filterJsonByUsedKeys(v, usedKeys, nextPath);
      if (kept !== undefined) {
        out[k] = kept;
      }
    }
  }

  // If any descendant was kept, keep this object. Otherwise drop.
  return Object.keys(out).length > 0 ? out : undefined;
}

function countLeafKeys(obj) {
  if (obj === null || obj === undefined) return 0;
  if (Array.isArray(obj)) return 1;
  if (typeof obj !== 'object') return 1;
  let count = 0;
  for (const v of Object.values(obj)) {
    if (v !== null && typeof v === 'object' && !Array.isArray(v)) {
      count += countLeafKeys(v);
    } else {
      count += countLeafKeys(v);
    }
  }
  return count;
}

function main() {
  if (!fs.existsSync(libRoot)) {
    console.error(`lib/ directory not found at: ${libRoot}`);
    process.exit(1);
  }

  const dartFiles = walkFiles(libRoot, (p) => p.endsWith('.dart'));
  console.log(`Scanning ${dartFiles.length} Dart files under lib/...`);

  const usedKeys = extractUsedKeysFromDartFiles(dartFiles);
  console.log(`Found ${usedKeys.size} used keys (static).`);

  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  for (const lang of languages) {
    const inPath = path.join(langDir, `${lang}.json`);
    if (!fs.existsSync(inPath)) {
      console.log(`[SKIP] Missing: ${path.relative(projectRoot, inPath)}`);
      continue;
    }

    const raw = fs.readFileSync(inPath, 'utf8');
    const json = JSON.parse(raw);

    const beforeCount = countLeafKeys(json);
    const filtered = filterJsonByUsedKeys(json, usedKeys);
    const safeFiltered = filtered ?? {};
    const afterCount = countLeafKeys(safeFiltered);

    const outPath = path.join(outDir, `${lang}.json`);
    fs.writeFileSync(outPath, JSON.stringify(safeFiltered, null, 2) + '\n', 'utf8');

    console.log(`${lang}.json: ${beforeCount} -> ${afterCount}`);
  }

  console.log(`Done. Output written to ${path.relative(projectRoot, outDir)}/`);
}

main();

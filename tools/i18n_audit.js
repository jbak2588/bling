#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

// Configuration
const LIB_DIR = path.resolve(__dirname, '..', 'lib');
const LOCALES = [
  { code: 'en', file: path.resolve(__dirname, '..', 'assets', 'lang', 'en.json') },
  { code: 'id', file: path.resolve(__dirname, '..', 'assets', 'lang', 'id.json') },
  { code: 'ko', file: path.resolve(__dirname, '..', 'assets', 'lang', 'ko.json') },
];
const REPORT_FILE = path.resolve(__dirname, '..', 'tools', 'i18n-report.json');

async function readJson(file) {
  try {
    const raw = await fs.promises.readFile(file, 'utf8');
    return JSON.parse(raw);
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

async function scanDartFiles(root) {
  const results = [];
  async function walk(dir) {
    const entries = await fs.promises.readdir(dir, { withFileTypes: true });
    for (const e of entries) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) {
        // skip build and .dart_tool and ios/android build folders
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
  const dynamicCandidates = new Set();

  // tr('key') or tr("key")
  const reTrFunc = /\btr\s*\(\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;
  // 'key'.tr(...) or "key".tr(...)
  const reTrMethod = /['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]\s*\.tr\s*\(/g;
  // safeTr(context, 'key' ...)
  const reSafeTr = /\bsafeTr\s*\(\s*[^,]+,\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;

  // LocaleKeys.some_key OR LocaleKeys.someKey
  const reLocaleKeys = /LocaleKeys\.([A-Za-z0-9_\.]+)/g;

  // Any dotted string literal that appears anywhere (heuristic)
  const reStringLiterals = /['"]([A-Za-z0-9_\-:.\/]+\.[A-Za-z0-9_\-:.\/]+)['"]/g;

  // Interpolations or string concatenation hints
  const reInterpolation = /\$[A-Za-z0-9_]+|\$\{[^}]+\}/g;
  const reConcat = /['"][^'"']+['"]\s*\+\s*[A-Za-z0-9_\$]+|[A-Za-z0-9_\$]+\s*\+\s*['"][^'"']+['"]/g;

  let m;
  while ((m = reTrFunc.exec(text))) keys.add(m[1]);
  while ((m = reTrMethod.exec(text))) keys.add(m[1]);
  while ((m = reSafeTr.exec(text))) keys.add(m[1]);

  // Capture LocaleKeys usage. Generated code often uses underscores or camelCase.
  while ((m = reLocaleKeys.exec(text))) {
    const raw = m[1];
    // Add as-is
    keys.add(raw);
    // Also add a dotted variant if underscores are used: my_key_name -> my.key.name
    if (raw.indexOf('_') >= 0) {
      keys.add(raw.replace(/_/g, '.'));
      dynamicCandidates.add(raw.replace(/_/g, '.'));
    }
    // If raw contains dots, also consider it a dynamic candidate
    if (raw.indexOf('.') >= 0) dynamicCandidates.add(raw);
  }

  // Add any dotted string literal found anywhere (heuristic to catch non-tr/tr()-wrapped keys)
  while ((m = reStringLiterals.exec(text))) {
    const s = m[1];
    // likely a translation key if it contains dots and no slashes
    if (s && s.indexOf('.') >= 0 && s.indexOf('/') === -1) {
      keys.add(s);
      dynamicCandidates.add(s);
    }
  }

  // If the line contains interpolation or concatenation, mark the whole line as dynamic
  if (reInterpolation.test(text) || reConcat.test(text)) {
    // collect token-like dotted substrings as dynamic prefixes
    const reDots = /([A-Za-z0-9_]+\.)+[A-Za-z0-9_]+/g;
    while ((m = reDots.exec(text))) {
      dynamicCandidates.add(m[0]);
    }
  }

  return { keys, dynamicCandidates };
}

async function main() {
  console.log('Scanning Dart files under', LIB_DIR);
  const files = await scanDartFiles(LIB_DIR);
  console.log('Found', files.length, 'Dart files. Extracting translation keys...');

  const usedKeys = new Set();
  const dynamicCandidatesAll = new Set();
  for (const f of files) {
    try {
      const txt = await fs.promises.readFile(f, 'utf8');
      const fileKeys = extractKeysFromText(txt);
      // extractKeysFromText now returns { keys: Set, dynamicCandidates: Set }
      if (fileKeys && fileKeys.keys) {
        fileKeys.keys.forEach(k => usedKeys.add(k));
      }
      if (fileKeys && fileKeys.dynamicCandidates) {
        fileKeys.dynamicCandidates.forEach(d => dynamicCandidatesAll.add(d));
      }
    } catch (e) {
      console.error('Failed to read', f, e.message);
    }
  }

  console.log('Total used keys found in source:', usedKeys.size);

  // Load and flatten locales
  const locales = {};
  for (const loc of LOCALES) {
    const j = await readJson(loc.file);
    if (!j) {
      console.warn('Locale missing or invalid:', loc.file);
      locales[loc.code] = { keys: {}, file: loc.file };
      continue;
    }
    const flat = flatten(j);
    locales[loc.code] = { keys: flat, file: loc.file };
  }

  // Prepare sets & reports
  const definedSets = {};
  for (const code of Object.keys(locales)) {
    definedSets[code] = new Set(Object.keys(locales[code].keys));
  }

  const report = {
    summary: {
      usedKeys: [...usedKeys].length,
      locales: {}
    },
    missingInLocale: {},
    unusedInLocale: {},
    inconsistentPresence: {},
    duplicatedValues: {}
  };

  for (const code of Object.keys(locales)) {
    const defined = definedSets[code];
    // missing: used but not defined
    const missing = [...usedKeys].filter(k => !defined.has(k));
    // unused: defined but not used (but protect keys that look dynamic)
    function isProtectedByDynamic(key) {
      for (const p of dynamicCandidatesAll) {
        if (!p) continue;
        if (key === p) return true;
        if (key.indexOf(p) === 0) return true; // key starts with dynamic prefix
        if (p.indexOf(key) === 0) return true; // dynamic candidate starts with key
      }
      return false;
    }

    const unused = [...defined].filter(k => !usedKeys.has(k) && !isProtectedByDynamic(k));
    report.summary.locales[code] = { defined: defined.size };
    report.missingInLocale[code] = missing.sort();
    report.unusedInLocale[code] = unused.sort();
  }

  // Inconsistent presence across locales
  const allDefinedKeys = new Set();
  for (const code of Object.keys(definedSets)) {
    definedSets[code].forEach(k => allDefinedKeys.add(k));
  }
  for (const key of allDefinedKeys) {
    const presentIn = [];
    for (const code of Object.keys(definedSets)) {
      if (definedSets[code].has(key)) presentIn.push(code);
    }
    if (presentIn.length !== Object.keys(definedSets).length) {
      report.inconsistentPresence[key] = presentIn;
    }
  }

  // Duplicated values within each locale (same translation used by multiple keys)
  for (const code of Object.keys(locales)) {
    const map = new Map();
    for (const [k, v] of Object.entries(locales[code].keys)) {
      const str = (v === null || v === undefined) ? '' : String(v);
      if (!map.has(str)) map.set(str, []);
      map.get(str).push(k);
    }
    const dups = {};
    for (const [val, keys] of map.entries()) {
      if (keys.length > 1) {
        dups[val] = keys.sort();
      }
    }
    report.duplicatedValues[code] = dups;
  }

  // Add small stats
  report.stats = {
    totalUsedKeys: usedKeys.size,
    totalDefinedKeys: Object.values(locales).reduce((s, l) => s + Object.keys(l.keys).length, 0),
  };

  // include dynamic candidates for reviewer awareness
  report.dynamicCandidates = [...dynamicCandidatesAll].sort();

  await fs.promises.writeFile(REPORT_FILE, JSON.stringify(report, null, 2), 'utf8');
  console.log('\nReport written to', REPORT_FILE);

  // Console summary
  console.log('\nSummary:');
  for (const code of Object.keys(locales)) {
    console.log(`- ${code}: defined=${Object.keys(locales[code].keys).length}, missing=${report.missingInLocale[code].length}, unused=${report.unusedInLocale[code].length}`);
  }
  const inconsistentCount = Object.keys(report.inconsistentPresence).length;
  console.log(`- Keys with inconsistent presence across locales: ${inconsistentCount}`);
  for (const code of Object.keys(report.duplicatedValues)) {
    const dupCount = Object.keys(report.duplicatedValues[code]).length;
    console.log(`- ${code}: duplicated string values groups=${dupCount}`);
  }

  console.log('\nNext: run `node tools/i18n_audit.js` at the repo root.');
}

main().catch(err => {
  console.error('Error running audit:', err);
  process.exit(2);
});

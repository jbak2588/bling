#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const LIB_DIR = path.resolve(__dirname, '..', 'lib');
const OUT = path.resolve(__dirname, 'i18n-keys-by-file.json');

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

function extractKeysFromText(text) {
  const keys = new Set();
  const dynamicCandidates = new Set();

  const reTrFunc = /\btr\s*\(\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;
  const reTrMethod = /['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]\s*\.tr\s*\(/g;
  const reSafeTr = /\bsafeTr\s*\(\s*[^,]+,\s*['"]([^'"\\]+(?:\\.[^'"\\]*)*)['"]/g;
  const reLocaleKeys = /LocaleKeys\.([A-Za-z0-9_\.]+)/g;
  const reStringLiterals = /['"]([A-Za-z0-9_\-:.\/]+\.[A-Za-z0-9_\-:.\/]+)['"]/g;
  const reInterpolation = /\$[A-Za-z0-9_]+|\$\{[^}]+\}/g;
  const reConcat = /['"][^'"']+['"]\s*\+\s*[A-Za-z0-9_\$]+|[A-Za-z0-9_\$]+\s*\+\s*['"][^'"']+['"]/g;

  let m;
  while ((m = reTrFunc.exec(text))) keys.add(m[1]);
  while ((m = reTrMethod.exec(text))) keys.add(m[1]);
  while ((m = reSafeTr.exec(text))) keys.add(m[1]);
  while ((m = reLocaleKeys.exec(text))) {
    const raw = m[1];
    keys.add(raw);
    if (raw.indexOf('_') >= 0) {
      keys.add(raw.replace(/_/g, '.'));
      dynamicCandidates.add(raw.replace(/_/g, '.'));
    }
    if (raw.indexOf('.') >= 0) dynamicCandidates.add(raw);
  }
  while ((m = reStringLiterals.exec(text))) {
    const s = m[1];
    if (s && s.indexOf('.') >= 0 && s.indexOf('/') === -1) {
      keys.add(s);
      dynamicCandidates.add(s);
    }
  }
  if (reInterpolation.test(text) || reConcat.test(text)) {
    const reDots = /([A-Za-z0-9_]+\.)+[A-Za-z0-9_]+/g;
    while ((m = reDots.exec(text))) {
      dynamicCandidates.add(m[0]);
    }
  }

  return { keys: [...keys], dynamicCandidates: [...dynamicCandidates] };
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

async function main() {
  console.log('Scanning Dart files under', LIB_DIR);
  const files = await scanDartFiles(LIB_DIR);
  console.log('Found', files.length, 'Dart files.');

  const mapping = {};
  const globalKeys = new Set();
  const dynamicCandidates = new Set();

  for (const f of files) {
    try {
      const txt = await fs.promises.readFile(f, 'utf8');
      const res = extractKeysFromText(txt);
      mapping[f.replace(/\\/g, '/')] = res.keys.sort();
      res.keys.forEach(k => globalKeys.add(k));
      res.dynamicCandidates.forEach(d => dynamicCandidates.add(d));
    } catch (e) {
      console.error('Failed to read', f, e.message);
    }
  }

  const out = {
    generatedAt: new Date().toISOString(),
    filesScanned: files.length,
    keysByFile: mapping,
    globalUsedKeys: [...globalKeys].sort(),
    dynamicCandidates: [...dynamicCandidates].sort()
  };

  fs.writeFileSync(OUT, JSON.stringify(out, null, 2), 'utf8');
  console.log('Wrote per-file key map to', OUT);
}

main().catch(err => { console.error(err); process.exit(2); });

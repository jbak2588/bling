const fs = require('fs');
const path = require('path');

const root = process.cwd();
const langDir = path.join(root, 'assets', 'lang');

function flattenKeys(obj, prefix = '') {
  const keys = new Set();
  for (const k of Object.keys(obj)) {
    const v = obj[k];
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      const sub = flattenKeys(v, key);
      for (const s of sub) keys.add(s);
    } else {
      keys.add(key);
    }
  }
  return keys;
}

function setNested(obj, keyPath, value) {
  const parts = keyPath.split('.');
  let cur = obj;
  for (let i = 0; i < parts.length; i++) {
    const p = parts[i];
    if (i === parts.length - 1) {
      cur[p] = value;
    } else {
      if (!(p in cur) || typeof cur[p] !== 'object') cur[p] = {};
      cur = cur[p];
    }
  }
}

function readLocaleFiles() {
  const files = fs.readdirSync(langDir).filter(f => f.endsWith('.json'));
  const locales = {};
  for (const f of files) {
    const locale = path.basename(f, '.json');
    const text = fs.readFileSync(path.join(langDir, f), 'utf8');
    try {
      locales[locale] = JSON.parse(text);
    } catch (e) {
      console.error(`Failed to parse ${f}:`, e.message);
      process.exit(2);
    }
  }
  return locales;
}

function scanCodeForKeys(dir) {
  const used = new Set();
  function walk(p) {
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      for (const f of fs.readdirSync(p)) walk(path.join(p, f));
    } else if (p.endsWith('.dart')) {
      const txt = fs.readFileSync(p, 'utf8');
      const reDotTr = /(['"]([a-z0-9_\-\.\$]+)['"])\s*\.tr\b/gi;
      let m;
      while ((m = reDotTr.exec(txt))) {
        used.add(m[2]);
      }
      const reFunc = /tr\(\s*['"]([a-z0-9_\-\.\$]+)['"]/gi;
      while ((m = reFunc.exec(txt))) {
        used.add(m[1]);
      }
    }
  }
  walk(dir);
  return used;
}

(function main(){
  if (!fs.existsSync(langDir)) { console.error('lang dir not found', langDir); process.exit(1); }
  const locales = readLocaleFiles();
  const localeKeys = {};
  for (const L of Object.keys(locales)) {
    localeKeys[L] = flattenKeys(locales[L]);
  }
  const usedKeys = scanCodeForKeys(path.join(root, 'lib'));
  const missing = {};
  for (const L of Object.keys(locales)) {
    missing[L] = [];
    for (const k of usedKeys) {
      if (!localeKeys[L].has(k)) missing[L].push(k);
    }
  }

  // Print summary
  console.log('Found', usedKeys.size, 'unique used translation keys in code.');
  for (const L of Object.keys(missing)) {
    console.log(`Locale ${L}: missing ${missing[L].length} keys`);
  }

  // If any missing in en, add into en.json with fallback equal to last path segment
  const en = locales['en'];
  if (!en) {
    console.warn('No en.json found; will not auto-add keys.');
  }

  let anyAdded = false;
  for (const L of Object.keys(locales)) {
    if (missing[L].length === 0) continue;
    console.log('Missing for', L, ':');
    missing[L].slice(0,50).forEach(k => console.log('  ', k));

    // Add into the locale file: for en, set value to humanized, for others copy en value if present, otherwise set to empty string
    for (const k of missing[L]) {
      let fallback = '';
      if (locales['en']) {
        // try to read en value for this key
        const parts = k.split('.');
        let cur = locales['en'];
        let found = true;
        for (const p of parts) {
          if (cur && typeof cur === 'object' && p in cur) cur = cur[p]; else { found = false; break; }
        }
        if (found && (typeof cur === 'string' || typeof cur === 'number')) fallback = cur;
      }
      if (!fallback) {
        // humanize key
        const last = k.split('.').pop();
        fallback = last.replace(/_/g, ' ');
      }
      // only set if key absent
      function hasKey(obj, keyPath) { 
        const parts = keyPath.split('.');
        let cur = obj;
        for (const p of parts) { if (!cur || typeof cur !== 'object' || !(p in cur)) return false; cur = cur[p]; }
        return true;
      }
      if (!hasKey(locales[L], k)) {
        if (L === 'en') setNested(locales[L], k, fallback);
        else setNested(locales[L], k, fallback);
        anyAdded = true;
      }
    }

    // write back file
    const filePath = path.join(langDir, `${L}.json`);
    fs.writeFileSync(filePath, JSON.stringify(locales[L], null, 2) + '\n', 'utf8');
    console.log('Wrote', filePath);
  }

  if (!anyAdded) console.log('No keys were added; all locales already have used keys.');
})();

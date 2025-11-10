const fs = require('fs');
const path = require('path');

const root = process.cwd();
const langDir = path.join(root, 'assets', 'lang');

function flattenKeys(obj, prefix = '') {
  const map = new Map();
  for (const k of Object.keys(obj)) {
    const v = obj[k];
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      const sub = flattenKeys(v, key);
      for (const [sk, sv] of sub) map.set(sk, sv);
    } else {
      map.set(key, v);
    }
  }
  return map;
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
  const files = fs.readdirSync(langDir).filter(f => f.endsWith('.json'));
  const locales = {};
  for (const f of files) {
    const locale = path.basename(f, '.json');
    locales[locale] = JSON.parse(fs.readFileSync(path.join(langDir, f), 'utf8'));
  }

  const usedKeys = Array.from(scanCodeForKeys(path.join(root, 'lib'))).sort();
  const results = {};

  const enMap = flattenKeys(locales['en'] || {});

  for (const L of Object.keys(locales)) {
    const map = flattenKeys(locales[L]);
    const likely = [];
    for (const k of usedKeys) {
      if (!map.has(k)) continue; // shouldn't happen after our write
      const v = map.get(k);
      const last = k.split('.').pop();
      const human = last.replace(/_/g, ' ');
      const enVal = enMap.has(k) ? (enMap.get(k) + '') : null;
      const sval = (v === null || v === undefined) ? '' : (v + '');
      // heuristics: value equals humanized last segment OR equals en value that equals humanized OR english value same as human
      if (sval === human || (enVal && sval === enVal && enVal === human) || sval.trim().length === 0) {
        likely.push(k);
      } else if (L !== 'en' && enVal && sval === enVal) {
        // if non-en equals en, likely copied from en
        likely.push(k);
      }
    }
    results[L] = likely;
  }

  for (const L of Object.keys(results)) {
    console.log(`Locale ${L}: likely auto-added ${results[L].length} keys`);
    results[L].forEach(k => console.log('  ', k));
    console.log('');
  }
})();

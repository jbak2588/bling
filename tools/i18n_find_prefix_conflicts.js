#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const files = [
  {code:'en', file: path.join(__dirname, '..', 'assets', 'lang', 'en.json')},
  {code:'id', file: path.join(__dirname, '..', 'assets', 'lang', 'id.json')},
  {code:'ko', file: path.join(__dirname, '..', 'assets', 'lang', 'ko.json')}
];

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

for (const f of files) {
  try {
    const raw = fs.readFileSync(f.file, 'utf8');
    const j = JSON.parse(raw);
    const flat = flatten(j);
    const keys = Object.keys(flat).sort();
    const prefixConflicts = [];
    const keySet = new Set(keys);
    for (const k of keys) {
      // check if any child exists
      const prefix = k + '.';
      for (const other of keys) {
        if (other.startsWith(prefix)) {
          prefixConflicts.push({ parent: k, child: other, parentValueType: typeof flat[k], childValueType: typeof flat[other] });
          break;
        }
      }
    }
    console.log(`\nFile: ${f.file} — prefix conflicts: ${prefixConflicts.length}`);
    if (prefixConflicts.length) console.log(JSON.stringify(prefixConflicts.slice(0,200), null, 2));
  } catch (e) {
    console.error('Failed to load', f.file, e.message);
  }
}

console.log('\nDone.');

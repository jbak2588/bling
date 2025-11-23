#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const files = [
  path.join(__dirname, '..', 'assets', 'lang', 'en.json'),
  path.join(__dirname, '..', 'assets', 'lang', 'id.json'),
  path.join(__dirname, '..', 'assets', 'lang', 'ko.json')
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
    const raw = fs.readFileSync(f, 'utf8');
    const j = JSON.parse(raw);
    const flat = flatten(j);
    const bad = [];
    for (const [k, v] of Object.entries(flat)) {
      if (typeof v !== 'string') bad.push({ key: k, type: v === null ? 'null' : Array.isArray(v) ? 'array' : typeof v });
    }
    console.log(`\nFile: ${f} — non-string leaves: ${bad.length}`);
    if (bad.length) console.log(JSON.stringify(bad.slice(0,200), null, 2));
  } catch (e) {
    console.error('Failed to read/parse', f, e.message);
  }
}

console.log('\nDone.');

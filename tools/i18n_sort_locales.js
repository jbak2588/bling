#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

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

function writeJson(file, obj) {
  fs.writeFileSync(file, JSON.stringify(obj, null, 2) + '\n', 'utf8');
}

for (const loc of LOCALES) {
  const file = loc.file;
  const code = loc.code;
  console.log(`Processing ${code}: ${file}`);
  const data = readJson(file);
  if (!data || typeof data !== 'object') {
    console.warn(`Skipping ${file} (invalid JSON)`);
    continue;
  }

  // Backup original
  const backup = file + '.sorted.orig';
  if (!fs.existsSync(backup)) {
    fs.copyFileSync(file, backup);
    console.log(`- backup written: ${backup}`);
  } else {
    console.log(`- backup already exists: ${backup}`);
  }

  // Sort only top-level keys alphabetically
  const keys = Object.keys(data).sort((a,b) => a.localeCompare(b));
  const out = {};
  for (const k of keys) out[k] = data[k];

  writeJson(file, out);
  console.log(`- wrote sorted file: ${file} (top-level keys: ${keys.length})`);
  console.log(`- first 12 keys: ${keys.slice(0,12).join(', ')}`);
}

console.log('\nDone. Originals backed up to *.sorted.orig.');

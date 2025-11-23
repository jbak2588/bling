#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const REPORT = path.resolve(__dirname, 'i18n-report.json');
const OUT = path.resolve(__dirname, 'i18n-candidates.json');

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (e) {
    console.error('Failed to read', file, e.message);
    process.exit(1);
  }
}

const report = readJson(REPORT);

const unusedEn = new Set(report.unusedInLocale?.en || []);
const unusedId = new Set(report.unusedInLocale?.id || []);
const unusedKo = new Set(report.unusedInLocale?.ko || []);

// Conservative: candidate is unused in ALL locales
const unusedAll = [];
for (const k of unusedEn) {
  if (unusedId.has(k) && unusedKo.has(k)) unusedAll.push(k);
}

const dynamic = new Set(report.dynamicCandidates || []);

// Filter out dynamic candidates or obviously non-i18n tokens
function isSafeCandidate(k) {
  if (!k || k.length < 3) return false;
  if (dynamic.has(k)) return false;
  // ignore keys that look like filenames or code (contain .dart, /, @, or whitespace)
  if (/[\s\/\\@]|\.dart|\.png|:\/\//.test(k)) return false;
  // ignore long numeric tokens or credentials-looking strings
  if (/^[0-9-]{8,}$/.test(k)) return false;
  return true;
}

const safeUnused = unusedAll.filter(isSafeCandidate).sort().slice(0, 50);

// missingInLocale: keep per-locale lists, but limit to top 200 each
const missing = {};
for (const lc of ['en', 'id', 'ko']) {
  missing[lc] = (report.missingInLocale?.[lc] || []).filter(isSafeCandidate).slice(0, 200);
}

const out = {
  generatedAt: new Date().toISOString(),
  safeUnusedCount: safeUnused.length,
  safeUnused: safeUnused,
  missingInLocaleSample: missing,
  notes: [
    'safeUnused: keys unused in all three locales and not tagged as dynamicCandidates',
    'missingInLocaleSample: keys used in code but missing in the locale file (sample, up to 200 entries per locale)',
    'Review these lists before applying any edits. Archive instead of delete.'
  ]
};

fs.writeFileSync(OUT, JSON.stringify(out, null, 2), 'utf8');
console.log('Wrote candidates to', OUT);
console.log('safeUnusedCount =', safeUnused.length);
console.log('Sample missing counts:', Object.fromEntries(Object.keys(missing).map(k => [k, missing[k].length])));

// print top items to stdout for quick copy
console.log('\nTop safeUnused candidates (up to 50):');
safeUnused.forEach(k => console.log('-', k));

console.log('\nMissing in locales (sample):');
for (const lc of ['en', 'id', 'ko']) {
  console.log(`\n${lc} (${missing[lc].length}):`);
  missing[lc].slice(0, 50).forEach(k => console.log('-', k));
}

process.exit(0);

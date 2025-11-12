#!/usr/bin/env node
// Lightweight wrapper so users can run `node backfill_category_icons.js` from repo root.
// It forwards to the implementation under ./scripts.
try {
  require('./scripts/backfill_category_icons.js');
} catch (e) {
  // Show a clearer error if something goes wrong
  console.error('Failed to run scripts/backfill_category_icons.js:', e && e.stack ? e.stack : e);
  process.exit(1);
}

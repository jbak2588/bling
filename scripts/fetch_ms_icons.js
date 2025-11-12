// scripts/fetch_ms_icons.js
// 선택한 Material Symbols SVG를 node_modules에서 복사 → assets/icons/ms/*.svg
// 1) npm i @material-design-icons/svg --save-dev
// 2) node scripts/fetch_ms_icons.js
const fs = require('fs');
const path = require('path');

const PICK = [
  'devices', 'home', 'checkroom', 'spa', 'diamond',
  'sports_esports', 'child_friendly', 'two_wheeler', 'category',
];

const SRC_DIR = path.join('node_modules', '@material-design-icons', 'svg', 'filled');
const DEST_DIR = path.join('assets', 'icons', 'ms');

if (!fs.existsSync(DEST_DIR)) fs.mkdirSync(DEST_DIR, { recursive: true });

for (const name of PICK) {
  const src = path.join(SRC_DIR, `${name}.svg`);
  const dest = path.join(DEST_DIR, `${name}.svg`);
  if (!fs.existsSync(src)) {
    console.warn('skip (not found):', src);
    continue;
  }
  fs.copyFileSync(src, dest);
  console.log('copied:', dest);
}

console.log('Done. Remember to run:  flutter pub get');

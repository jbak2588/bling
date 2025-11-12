// scripts/check_design_icons.js
// Quick validator for scripts/categories_v2_design.js
const path = require('path');
const d = require(path.join(__dirname, 'categories_v2_design.js')).design;

let parents = 0, parentsWithIcon = 0, parentsOthers = 0;
let subs = 0, subsWithIcon = 0, subsOthers = 0;

for (const pid of Object.keys(d)) {
  parents++;
  const p = d[pid];
  if (p.icon) {
    parentsWithIcon++;
    if (p.icon === 'ms:others') parentsOthers++;
  }
  const subCats = p.subCategories || {};
  for (const sid of Object.keys(subCats)) {
    subs++;
    const s = subCats[sid];
    if (s.icon) {
      subsWithIcon++;
      if (s.icon === 'ms:others') subsOthers++;
    }
  }
}

console.log(`parents=${parents}, parentsWithIcon=${parentsWithIcon}, parentsOthers=${parentsOthers}`);
console.log(`subs=${subs}, subsWithIcon=${subsWithIcon}, subsOthers=${subsOthers}`);

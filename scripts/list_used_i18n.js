const fs = require('fs');
const path = require('path');

const root = process.cwd();
const libDir = path.join(root, 'lib');
const outDir = path.join(root, 'logs');
const outFile = path.join(outDir, 'used_i18n_keys.txt');

function scanCodeForKeys(dir) {
  const used = new Set();
  function walk(p) {
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      for (const f of fs.readdirSync(p)) walk(path.join(p, f));
    } else if (p.endsWith('.dart')) {
      const txt = fs.readFileSync(p, 'utf8');
      const reDotTr = /['"]([a-z0-9_\-\.\$]+)['"]\s*\.tr\b/gi;
      let m;
      while ((m = reDotTr.exec(txt))) used.add(m[1]);
      const reFunc = /tr\(\s*['"]([a-z0-9_\-\.\$]+)['"]/gi;
      while ((m = reFunc.exec(txt))) used.add(m[1]);
    }
  }
  walk(dir);
  return used;
}

try {
  if (!fs.existsSync(libDir)) {
    console.error('lib directory not found:', libDir);
    process.exit(1);
  }

  const used = Array.from(scanCodeForKeys(libDir)).sort();
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(outFile, used.join('\n') + '\n', 'utf8');
  console.log('Wrote', outFile, 'with', used.length, 'keys');
  if (used.length > 0) console.log('First 50 keys:\n', used.slice(0, 50).join('\n'));
} catch (e) {
  console.error('Error scanning for i18n keys:', e);
  process.exit(2);
}

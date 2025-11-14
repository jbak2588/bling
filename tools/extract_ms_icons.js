// tools/extract_ms_icons.js
// Node script: find material_symbols_icons package path via .dart_tool/package_config.json
// then parse lib/ .dart files to extract Symbols.values and Symbols.map and write TXT/CSV outputs.

const fs = require('fs');
const path = require('path');

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function extractBetween(src, openIdx, openChar, closeChar) {
  let depth = 0;
  let i = openIdx;
  let out = '';
  for (; i < src.length; i++) {
    const ch = src[i];
    if (ch === openChar) {
      depth++;
      if (depth === 1) continue;
    }
    if (ch === closeChar) {
      depth--;
      if (depth === 0) break;
    }
    if (depth >= 1) out += ch;
  }
  return out;
}

function parseStringList(body) {
  const re = /'([^']*)'|"([^"]*)"/g;
  const res = [];
  let m;
  while ((m = re.exec(body)) !== null) {
    res.push(m[1] || m[2]);
  }
  return res;
}

function parseMap(body) {
  const re = /'([^']*)'\s*:\s*(0x[0-9a-fA-F]+|\d+)/g;
  const out = {};
  let m;
  while ((m = re.exec(body)) !== null) {
    const key = m[1];
    const valStr = m[2];
    const val = valStr.startsWith('0x') ? parseInt(valStr.substring(2), 16) : parseInt(valStr, 10);
    out[key] = val;
  }
  return out;
}

function main() {
  const pkgCfg = path.join('.dart_tool', 'package_config.json');
  if (!fs.existsSync(pkgCfg)) {
    console.error('ERROR: .dart_tool/package_config.json not found. Run `flutter pub get` first.');
    process.exit(2);
  }
  const cfg = readJson(pkgCfg);
  const pkg = (cfg.packages || []).find(p => p.name === 'material_symbols_icons');
  if (!pkg) {
    console.error('ERROR: material_symbols_icons not found in package_config.json');
    process.exit(3);
  }

  const baseDir = path.dirname(pkgCfg);
  const rootUri = pkg.rootUri || pkg.packageUri || '.';
  let pkgPath = null;
  if (typeof rootUri === 'string' && rootUri.startsWith('file:')) {
    try {
      const u = new URL(rootUri);
      let p = u.pathname; // /C:/Users/...
      if (p.startsWith('/') && /^[A-Za-z]:/.test(p.slice(1,3))) p = p.slice(1);
      pkgPath = path.normalize(p);
    } catch (e) {
      pkgPath = path.resolve(baseDir, rootUri.replace(/^file:/i, ''));
    }
  } else {
    pkgPath = path.resolve(baseDir, String(rootUri));
  }
  const libDir = path.join(pkgPath, 'lib');
  if (!fs.existsSync(libDir)) {
    console.error('ERROR: lib/ not found at', libDir);
    process.exit(4);
  }

  const dartFiles = [];
  function walk(dir) {
    for (const fn of fs.readdirSync(dir)) {
      const full = path.join(dir, fn);
      const st = fs.statSync(full);
      if (st.isDirectory()) walk(full);
      else if (full.endsWith('.dart')) dartFiles.push(full);
    }
  }
  walk(libDir);

  console.log('Resolved material_symbols_icons path:', pkgPath);
  console.log('Dart files scanned:', dartFiles.length);

  const names = new Set();
  const map = {};
  const metadata = {};
  const arraysFound = []; // candidate string arrays found in files

  for (const f of dartFiles) {
    const src = fs.readFileSync(f, 'utf8');
    const vi = src.indexOf('values');
    if (vi !== -1) {
      const bi = src.indexOf('[', vi);
      if (bi !== -1) {
        const body = extractBetween(src, bi, '[', ']');
        console.log('--- values body preview (first 400 chars) ---');
        console.log(body.slice(0, 400).replace(/\n/g, '\\n'));
        for (const s of parseStringList(body)) names.add(s);
        console.log('Found values in:', f);
      }
    }
    const mi = src.indexOf('map');
    if (mi !== -1) {
      const bi = src.indexOf('{', mi);
      if (bi !== -1) {
        const body = extractBetween(src, bi, '{', '}');
        console.log('--- map body preview (first 400 chars) ---');
        console.log(body.slice(0, 400).replace(/\n/g, '\\n'));
        const m = parseMap(body);
        for (const k of Object.keys(m)) map[k] = m[k];
        console.log('Found map in:', f);
      }
    }

    // collect candidate string arrays (simple heuristic)
    for (let i = 0; i < src.length; i++) {
      if (src[i] === '[') {
        try {
          const body = extractBetween(src, i, '[', ']');
          const items = parseStringList(body);
          if (items.length >= 3) arraysFound.push(items);
        } catch (e) {
          // ignore
        }
      }
    }

    // parse SymbolsMetadata entries like 'ten_k': SymbolsMetadata(originalName: "10k", popularity: 204, codepoint: 0xe951, categories: [0], tags: [ ... ])
    const metaRe = /['"]([^'"]+)['"]\s*:\s*SymbolsMetadata\s*\(\s*([\s\S]*?)\)/g;
    let mm;
    while ((mm = metaRe.exec(src)) !== null) {
      const key = mm[1];
      const inner = mm[2];
      const md = {};
      const on = /originalName\s*:\s*['"]([^'"]+)['"]/m.exec(inner);
      if (on) md.originalName = on[1];
      const pop = /popularity\s*:\s*(\d+)/m.exec(inner);
      if (pop) md.popularity = parseInt(pop[1], 10);
      const cp = /codepoint\s*:\s*(0x[0-9a-fA-F]+|\d+)/m.exec(inner);
      if (cp) md.codepoint = cp[1].startsWith('0x') ? parseInt(cp[1].substring(2), 16) : parseInt(cp[1], 10);
      const cats = /categories\s*:\s*\[([^\]]*)\]/m.exec(inner);
      if (cats) {
        md.categories = cats[1].split(',').map(s => s.trim()).filter(Boolean).map(s => parseInt(s, 10));
      }
      const tags = /tags\s*:\s*\[([^\]]*)\]/m.exec(inner);
      if (tags) {
        md.tags = tags[1].split(',').map(s => s.trim()).filter(Boolean).map(s => parseInt(s, 10));
      }
      metadata[key] = md;
      console.log('Found metadata for:', key);
    }
  }

  const sorted = Array.from(names).sort();
  if (sorted.length === 0) {
    // fallback: if we couldn't extract a separate names list, use map keys
    const mapKeys = Object.keys(map || {});
    if (mapKeys.length > 0) {
      console.log('Names list empty — falling back to using map keys');
      for (const k of mapKeys) names.add(k);
    }
  }
  const finalNames = Array.from(names).sort();
  console.log('Names extracted:', finalNames.length, 'Map entries:', Object.keys(map || {}).length);
  fs.writeFileSync('material_symbols_list.txt', finalNames.join('\n'));

  const csvLines = ['name,codepoint_hex,codepoint_dec'];
  for (const n of finalNames) {
    const cp = map[n];
    const hex = cp != null ? '0x' + cp.toString(16).padStart(4, '0') : '';
    const dec = cp != null ? String(cp) : '';
    csvLines.push(`${n},${hex},${dec}`);
  }
  fs.writeFileSync('material_symbols_list.csv', csvLines.join('\n'));

  // Also write JSON output
  // Try to resolve readable tag/category names from discovered arrays
  let tagNames = null;
  let categoryNames = null;
  // compute max indexes used in metadata
  let maxTagIdx = -1;
  let maxCatIdx = -1;
  for (const k of Object.keys(metadata)) {
    const md = metadata[k];
    if (md && Array.isArray(md.tags)) md.tags.forEach(i => { if (i > maxTagIdx) maxTagIdx = i; });
    if (md && Array.isArray(md.categories)) md.categories.forEach(i => { if (i > maxCatIdx) maxCatIdx = i; });
  }
  // choose candidate arrays that fit the required lengths
  if (arraysFound.length > 0) {
    // choose smallest array that has length > maxTagIdx for tags
    if (maxTagIdx >= 0) {
      let best = null;
      for (const a of arraysFound) {
        if (a.length > maxTagIdx) {
          if (!best || a.length < best.length) best = a;
        }
      }
      if (best) tagNames = best;
    }
    // choose smallest array that has length > maxCatIdx for categories
    if (maxCatIdx >= 0) {
      let best = null;
      for (const a of arraysFound) {
        if (a.length > maxCatIdx) {
          if (!best || a.length < best.length) best = a;
        }
      }
      if (best) categoryNames = best;
    }
    // fallback heuristics: if not found, try likely candidates by size
    if (!tagNames) {
      // prefer larger arrays (tags often many)
      arraysFound.sort((x, y) => y.length - x.length);
      if (arraysFound[0] && arraysFound[0].length > 10) tagNames = arraysFound[0];
    }
    if (!categoryNames) {
      // prefer smaller arrays (categories fewer)
      arraysFound.sort((x, y) => x.length - y.length);
      if (arraysFound[0] && arraysFound[0].length <= 50) categoryNames = arraysFound[0];
    }
  }

  if (tagNames) console.log('Resolved tag names length:', tagNames.length);
  if (categoryNames) console.log('Resolved category names length:', categoryNames.length);

  const jsonOut = finalNames.map(n => {
    const md = metadata[n] || {};
    const cp = map[n] != null ? map[n] : (md.codepoint != null ? md.codepoint : null);
    const tags_readable = (Array.isArray(md.tags) && tagNames) ? md.tags.map(i => (tagNames[i] || null)) : null;
    const categories_readable = (Array.isArray(md.categories) && categoryNames) ? md.categories.map(i => (categoryNames[i] || null)) : null;
    return {
      name: n,
      codepoint_hex: cp != null ? '0x' + cp.toString(16).padStart(4, '0') : null,
      codepoint_dec: cp != null ? cp : null,
      originalName: md.originalName || null,
      popularity: md.popularity != null ? md.popularity : null,
      categories: md.categories || null,
      tags: md.tags || null,
      categories_readable: categories_readable,
      tags_readable: tags_readable
    };
  });
  fs.writeFileSync('material_symbols_list.json', JSON.stringify(jsonOut, null, 2));

  console.log(`✅ Generated material_symbols_list.txt (${finalNames.length}), material_symbols_list.csv and material_symbols_list.json`);
}

main();

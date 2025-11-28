const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const usedPath = path.join(root, 'assets', 'lang', 'used_i18n_keys.json');
const locales = ['en','id','ko'];

let usedRaw = fs.readFileSync(usedPath, 'utf8');
usedRaw = usedRaw.trim();
let used = [];
try{
  const parsed = JSON.parse(usedRaw);
  if(Array.isArray(parsed)) used = parsed;
  else if(parsed && typeof parsed === 'object') used = Object.keys(parsed);
  else throw new Error('Unexpected format for used_i18n_keys.json');
}catch(err){
  console.error('Failed to parse used_i18n_keys.json:', err.message);
  process.exit(1);
}

function flatten(obj, prefix=''){
  const keys = [];
  for(const k of Object.keys(obj)){
    const v = obj[k];
    const name = prefix? `${prefix}.${k}` : k;
    if(v && typeof v === 'object' && !Array.isArray(v)){
      keys.push(...flatten(v, name));
    } else {
      keys.push(name);
    }
  }
  return keys;
}

for(const lang of locales){
  const file = path.join(root, 'assets', 'lang', `${lang}.json`);
  if(!fs.existsSync(file)){
    console.log(`MISSING_FILE:${lang}`);
    continue;
  }
  try{
    const content = fs.readFileSync(file, 'utf8');
    const obj = JSON.parse(content);
    const keys = flatten(obj);
    const missing = used.filter(k => !keys.includes(k));
    const outPath = path.join(root, 'assets', 'lang', `missing_keys_${lang}.txt`);
    fs.writeFileSync(outPath, missing.sort().join('\n'), 'utf8');
    console.log(`MISSING_${lang}:${missing.length}`);
  }catch(err){
    console.log(`ERROR_${lang}:${err.message}`);
  }
}
console.log('Done.');

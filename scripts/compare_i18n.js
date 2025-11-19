const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..', 'assets', 'lang');
const files = ['en.json','id.json','ko.json'].map(f=>path.join(dir,f));

function load(p){return JSON.parse(fs.readFileSync(p,'utf8'));}

const [en,id,ko] = files.map(load);

function flatten(obj, prefix=''){
  const res = {};
  if (obj === null) return res;
  if (typeof obj !== 'object' || Array.isArray(obj)){
    res[prefix] = {type: typeof obj, value: obj};
    return res;
  }
  for (const k of Object.keys(obj)){
    const key = prefix?prefix+"."+k:k;
    if (typeof obj[k] === 'object' && !Array.isArray(obj[k]) && obj[k] !== null){
      Object.assign(res, flatten(obj[k], key));
    } else {
      res[key] = {type: Array.isArray(obj[k])? 'array': typeof obj[k] , value: obj[k]};
    }
  }
  return res;
}

const fEn = flatten(en);
const fId = flatten(id);
const fKo = flatten(ko);

const allKeys = new Set([...Object.keys(fEn), ...Object.keys(fId), ...Object.keys(fKo)]);

const missing = [];
const typeMismatches = [];
for (const k of allKeys){
  const e = fEn[k];
  const i = fId[k];
  const o = fKo[k];
  if (!e || !i || !o){
    missing.push({key:k,en:!!e,id:!!i,ko:!!o});
  } else {
    if (e.type !== i.type || e.type !== o.type){
      typeMismatches.push({key:k,enType:e.type,idType:i.type,koType:o.type});
    }
  }
}

console.log('Total keys (flattened):', allKeys.size);
console.log('Missing keys across locales:', missing.length);
if(missing.length) console.log(missing.slice(0,50));
console.log('Type mismatches count:', typeMismatches.length);
if(typeMismatches.length) console.log(typeMismatches.slice(0,50));

if (missing.length === 0 && typeMismatches.length === 0) console.log('OK: no structural issues found');
else process.exit(2);

const fs = require('fs');
const path = require('path');

const root = process.cwd();
const langDir = path.join(root, 'assets', 'lang');
const libDir = path.join(root, 'lib');
const outDir = path.join(root, 'logs');
const reportFile = path.join(outDir, 'i18n_optimization_report.txt');

// 1. JSON 파일 평탄화 (Nested Object -> Dot Notation)
function flattenKeys(obj, prefix = '') {
  const result = {};
  for (const k of Object.keys(obj)) {
    const v = obj[k];
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      Object.assign(result, flattenKeys(v, key));
    } else {
      result[key] = v;
    }
  }
  return result;
}

// 2. 다트 코드에서 사용된 키 스캔 (Regex 활용)
function scanCodeForKeys(dir) {
  const used = new Set();
  function walk(p) {
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      for (const f of fs.readdirSync(p)) walk(path.join(p, f));
    } else if (p.endsWith('.dart')) {
      const txt = fs.readFileSync(p, 'utf8');
      // .tr() 패턴
      const reDotTr = /['"]([a-z0-9_\-\.\$]+)['"]\s*\.tr\b/gi;
      let m;
      while ((m = reDotTr.exec(txt))) used.add(m[1]);
      // tr("key") 패턴
      const reFunc = /tr\(\s*['"]([a-z0-9_\-\.\$]+)['"]/gi;
      while ((m = reFunc.exec(txt))) used.add(m[1]);
      // LocaleKeys.xxx 패턴 (필요시 추가)
    }
  }
  walk(dir);
  return used;
}

(function main() {
  console.log('🔍 Analyzing i18n files for optimization...');

  // 결과 수집을 위한 버퍼
  let outputBuffer = '';
  function log(msg = '') {
    console.log(msg); // 콘솔에도 출력
    outputBuffer += msg + '\n'; // 파일 저장을 위해 버퍼에 추가
  }

  // 언어 파일 로드
  const enPath = path.join(langDir, 'en.json');
  if (!fs.existsSync(enPath)) {
    log('❌ en.json not found');
    return;
  }
  const enJson = JSON.parse(fs.readFileSync(enPath, 'utf8'));
  const flatEn = flattenKeys(enJson);
  
  // 코드 스캔
  const usedKeys = scanCodeForKeys(libDir);
  
  // 분석 1: 미사용 키 (Unused Keys) 찾기
  const allEnKeys = Object.keys(flatEn);
  const unusedKeys = allEnKeys.filter(k => !usedKeys.has(k));

  // 분석 2: 값 중복 (Value Duplication) 찾기
  const valueMap = {};
  for (const [key, value] of Object.entries(flatEn)) {
    if (!valueMap[value]) valueMap[value] = [];
    valueMap[value].push(key);
  }

  // 리포트 생성
  log('\n==================================================');
  log(`📊 Analysis Report`);
  log('==================================================');
  log(`Total Keys in en.json: ${allEnKeys.length}`);
  log(`Used Keys in Code:     ${usedKeys.size}`);
  log(`Potential Unused Keys: ${unusedKeys.length}`);
  log('==================================================\n');

  log('⚠️  TOP DUPLICATED VALUES (Candidate for merging into "common")');
  const sortedDuplicates = Object.entries(valueMap)
    .filter(([val, keys]) => keys.length > 1)
    .sort((a, b) => b[1].length - a[1].length); // 중복 많은 순 정렬

  // 중복 항목은 상위 30개만 보여주고, 나머지는 생략 (파일 용량 및 가독성 고려)
  sortedDuplicates.slice(0, 50).forEach(([val, keys]) => {
    log(`\n"${val}" is used in ${keys.length} keys:`);
    keys.forEach(k => log(`   - ${k}`));
  });

  log('\n--------------------------------------------------');
  log(`🗑️  POTENTIAL UNUSED KEYS (Total: ${unusedKeys.length})`);
  log('    (These keys are not found in .dart files)');
  log('--------------------------------------------------');
  
  if (unusedKeys.length > 0) {
    // 🔥 수정된 부분: 생략 없이 모든 미사용 키를 출력합니다.
    unusedKeys.forEach(k => log(`   - ${k}`));
  } else {
    log('   (Great! No unused keys found)');
  }

  log('\n✅ Recommendation:');
  log('1. Check "TOP DUPLICATED VALUES" and migrate to "common".');
  log('2. Review "POTENTIAL UNUSED KEYS" and remove them from .json files if truly unused.');

  // 파일 저장
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }
  fs.writeFileSync(reportFile, outputBuffer, 'utf8');
  console.log(`\n💾 Full report saved to: ${reportFile}`);
})();
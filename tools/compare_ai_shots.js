const fs = require('fs');
const path = require('path');

const src = path.resolve(__dirname, '..', 'assets', 'ai', 'ai_rules_v2.json');
const out = path.resolve(__dirname, '..', 'assets', 'ai', 'ai_rules_shot_report.json');

if (!fs.existsSync(src)) {
  console.error('Missing ai_rules_v2.json at', src);
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(src, 'utf8'));
const rules = data.rules || [];
if (!rules.length) {
  console.error('No rules found');
  process.exit(1);
}

// Choose baseline: rule with id 'electronics' if present, otherwise the one with most suggested shots
let baselineRule = rules.find(r => r.id === 'electronics');
if (!baselineRule) {
  baselineRule = rules.reduce((best, r) => {
    const cnt = r.suggested_shots ? Object.keys(r.suggested_shots).length : 0;
    const bestCnt = best.suggested_shots ? Object.keys(best.suggested_shots).length : 0;
    return cnt > bestCnt ? r : best;
  }, rules[0]);
}

const baselineKeys = baselineRule.suggested_shots ? Object.keys(baselineRule.suggested_shots) : [];

const report = {
  generatedAt: new Date().toISOString(),
  baseline: { id: baselineRule.id, nameEn: baselineRule.nameEn, shotCount: baselineKeys.length, keys: baselineKeys },
  perRule: []
};

for (const r of rules) {
  const keys = r.suggested_shots ? Object.keys(r.suggested_shots) : [];
  const removed = baselineKeys.filter(k => !keys.includes(k));
  const added = keys.filter(k => !baselineKeys.includes(k));
  report.perRule.push({ id: r.id, nameEn: r.nameEn, totalShots: keys.length, removed, added });
}

fs.writeFileSync(out, JSON.stringify(report, null, 2), 'utf8');
console.log('Wrote report to', out);
console.log('Baseline:', report.baseline.id, 'shots=', report.baseline.shotCount);
console.log('Total rules:', report.perRule.length);

// Print top 10 rules that removed the most shots
const sorted = report.perRule.slice().sort((a,b) => b.removed.length - a.removed.length);
console.log('\nTop 10 rules by removed shots:');
for (let i=0;i<Math.min(10, sorted.length);i++){
  const x = sorted[i];
  console.log(`${i+1}. ${x.id} (removed ${x.removed.length}, total ${x.totalShots})`);
}

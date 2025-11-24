#!/usr/bin/env python3
import re
from pathlib import Path
root = Path('c:/bling/bling_app')
lib_dir = root / 'lib'
i18n_dir = lib_dir / 'i18n'

# collect translation keys
key_pattern = re.compile(r"'([^']+)'\s*=>")
translation_keys = set()
for f in i18n_dir.glob('strings_*.g.dart'):
    try:
        txt = f.read_text(encoding='utf-8')
    except Exception:
        continue
    for m in key_pattern.finditer(txt):
        translation_keys.add(m.group(1))

access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

results = []
for path in lib_dir.rglob('*.dart'):
    if 'i18n' in path.parts and path.name.startswith('strings'):
        continue
    text = path.read_text(encoding='utf-8')
    for m in access_pattern.finditer(text):
        key = m.group(1)
        start = m.start()
        # compute line number
        line_no = text.count('\n', 0, start) + 1
        is_dynamic = bool(dynamic_pattern.search(key))
        exists = key in translation_keys
        snippet = text[m.start(): m.end()+20].split('\n')[0]
        results.append((str(path), line_no, key, is_dynamic, exists, snippet))

# print report
print(f"Loaded {len(translation_keys)} translation keys")
print(f"Found {len(results)} bracket occurrences")

# group by existence
exist_count = sum(1 for r in results if r[4])
print(f"Occurrences with existing translation key: {exist_count}")

# print first 200 results for review
for r in results[:500]:
    print(f"{r[0]}:{r[1]} | dynamic={r[3]} | exists={r[4]} | {r[2]} | {r[5]}")

# also print a summary of types
from collections import Counter
cnt = Counter((r[3], r[4]) for r in results)
print('\nSummary counts (dynamic,exists):')
for k,v in cnt.items():
    print(f"{k}: {v}")

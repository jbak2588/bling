#!/usr/bin/env python3
import re
from pathlib import Path

root = Path('c:/bling/bling_app')
lib_dir = root / 'lib'
i18n_file = lib_dir / 'i18n' / 'strings_ko.g.dart'

translation_keys = set()

if i18n_file.exists():
    txt = i18n_file.read_text(encoding='utf-8')
    # find all Path: comments and associated getters until next Path or end
    path_pattern = re.compile(r"// Path: (.+)")
    get_pattern = re.compile(r"\s*///.*\n\s*String get (\w+) =>")
    # Split by lines and iterate, track current path
    lines = txt.splitlines()
    current_path = None
    for i, line in enumerate(lines):
        m = path_pattern.match(line)
        if m:
            current_path = m.group(1).strip()
            continue
        if current_path:
            # look ahead a few lines to find 'String get name =>'
            m2 = re.match(r"\s*String get (\w+) =>", line)
            if m2:
                name = m2.group(1)
                key = current_path + '.' + name
                translation_keys.add(key)

    # Also capture top-level getters (no Path) e.g., String get selectCategory =>
    top_get_pattern = re.compile(r"\s*///.*\n\s*String get (\w+) =>")
    # simple top-level pattern: look for 'String get name =>' not preceded by Path
    all_gets = re.findall(r"\n\s*String get (\w+) =>", txt)
    for g in all_gets:
        # avoid duplicates of ones already captured
        if not any(k.endswith('.' + g) for k in translation_keys):
            translation_keys.add(g)

print(f"Extracted {len(translation_keys)} keys from {i18n_file.name}")

import re

access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

def to_camel(segment: str) -> str:
    if '-' in segment:
        parts = segment.split('-')
    else:
        parts = segment.split('_')
    if len(parts) == 1:
        return parts[0]
    first = parts[0]
    rest = ''.join(p.capitalize() if p else '' for p in parts[1:])
    return first + rest

def to_pascal(segment: str) -> str:
    if '-' in segment:
        parts = segment.split('-')
    else:
        parts = segment.split('_')
    return ''.join(p.capitalize() if p else '' for p in parts)

def candidates_for_key(key: str):
    parts = key.split('.')
    seg_variants = []
    for seg in parts:
        variants = set()
        variants.add(seg)
        variants.add(seg.replace('-', ''))
        variants.add(seg.replace('_', ''))
        variants.add(to_camel(seg))
        variants.add(to_pascal(seg))
        variants.add(seg.lower())
        seg_variants.append([v for v in variants if v])
    from itertools import product
    for combo in product(*seg_variants):
        yield '.'.join(combo)

files_changed = []
converted_count = 0

for path in lib_dir.rglob('*.dart'):
    if 'i18n' in path.parts and path.name.startswith('strings'):
        continue
    text = path.read_text(encoding='utf-8')
    new_text = text
    modified = False
    for m in reversed(list(access_pattern.finditer(text))):
        key = m.group(1)
        span = m.span()
        orig = m.group(0)
        if dynamic_pattern.search(key):
            after = text[span[1]:span[1]+10]
            if '??' not in after:
                replacement = orig + " ?? ''"
                new_text = new_text[:span[0]] + replacement + new_text[span[1]:]
                modified = True
            continue
        found = None
        for cand in candidates_for_key(key):
            if cand in translation_keys:
                found = cand
                break
        if found:
            dot_accessor = 't.' + '.'.join(found.split('.'))
            new_text = new_text[:span[0]] + dot_accessor + new_text[span[1]:]
            modified = True
            converted_count += 1
        else:
            after = text[span[1]:span[1]+10]
            if '??' not in after:
                replacement = orig + " ?? ''"
                new_text = new_text[:span[0]] + replacement + new_text[span[1]:]
                modified = True
    if modified:
        path.write_text(new_text, encoding='utf-8')
        files_changed.append(str(path))
        print(f"Modified {path}")

print(f"Files changed: {len(files_changed)}")
print(f"Total bracket occurrences converted: {converted_count}")
for p in files_changed:
    print(p)

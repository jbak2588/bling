#!/usr/bin/env python3
import re
from pathlib import Path

root = Path('c:/bling/bling_app')
lib_dir = root / 'lib'
i18n_dir = lib_dir / 'i18n'

# load translation keys
key_pattern = re.compile(r"'([^']+)'\s*=>")
translation_keys = set()
for f in i18n_dir.glob('strings_*.g.dart'):
    try:
        txt = f.read_text(encoding='utf-8')
    except Exception:
        continue
    for m in key_pattern.finditer(txt):
        translation_keys.add(m.group(1))

print(f"Loaded {len(translation_keys)} translation keys")

access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

# helper functions
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

# generate candidate full keys from original key
def candidates_for_key(key: str):
    parts = key.split('.')
    # variants per segment
    seg_variants = []
    for seg in parts:
        variants = set()
        variants.add(seg)
        variants.add(seg.replace('-', ''))
        variants.add(seg.replace('_', ''))
        variants.add(to_camel(seg))
        variants.add(to_pascal(seg))
        # also lowercased
        variants.add(seg.lower())
        seg_variants.append([v for v in variants if v])
    # combine to create candidate keys
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
        # skip dynamic
        if dynamic_pattern.search(key):
            # ensure fallback exists
            after = text[span[1]:span[1]+10]
            if '??' not in after:
                replacement = orig + " ?? ''"
                new_text = new_text[:span[0]] + replacement + new_text[span[1]:]
                modified = True
            continue
        # try candidates
        found = None
        for cand in candidates_for_key(key):
            if cand in translation_keys:
                found = cand
                break
        if found:
            # build dot accessor with found's segments (respect case)
            dot_accessor = 't.' + '.'.join(found.split('.'))
            new_text = new_text[:span[0]] + dot_accessor + new_text[span[1]:]
            modified = True
            converted_count += 1
        else:
            # ensure fallback exists
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

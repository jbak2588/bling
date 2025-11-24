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

print(f"Loaded {len(translation_keys)} translation keys from generated files")

# patterns
access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

# helper: convert snake_case or kebab-case to camelCase for one segment
def to_camel(segment: str) -> str:
    # if already camelCase likely leave; also handle digits
    if '-' in segment:
        parts = segment.split('-')
    else:
        parts = segment.split('_')
    if len(parts) == 1:
        return parts[0]
    first = parts[0]
    rest = ''.join(p.capitalize() if p else '' for p in parts[1:])
    return first + rest

files_changed = []
converted_count = 0

for path in lib_dir.rglob('*.dart'):
    # skip generated i18n files
    if 'i18n' in path.parts and path.name.startswith('strings'):
        continue
    text = path.read_text(encoding='utf-8')
    new_text = text
    modified = False

    # iterate matches from end
    for m in reversed(list(access_pattern.finditer(text))):
        key = m.group(1)
        span = m.span()
        orig = m.group(0)
        # skip dynamic keys
        if dynamic_pattern.search(key):
            continue
        # compute camelCase key per segment
        parts = key.split('.')
        camel_parts = [to_camel(p) for p in parts]
        camel_key = '.'.join(camel_parts)
        if camel_key in translation_keys:
            # replace with dot accessor using camel parts
            dot_accessor = 't.' + '.'.join(camel_parts)
            new_text = new_text[:span[0]] + dot_accessor + new_text[span[1]:]
            modified = True
            converted_count += 1
    if modified:
        path.write_text(new_text, encoding='utf-8')
        files_changed.append(str(path))
        print(f"Modified {path}")

print(f"Files changed: {len(files_changed)}")
print(f"Total bracket occurrences converted: {converted_count}")
for p in files_changed:
    print(p)

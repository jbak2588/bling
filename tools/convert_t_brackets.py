#!/usr/bin/env python3
import re
import io
import os
from pathlib import Path

root = Path('c:/bling/bling_app')
lib_dir = root / 'lib'
i18n_dir = lib_dir / 'i18n'

# collect all translation keys from generated files
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

# regex to find t['...'] or t["..."]
access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
# dynamic detection
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

files_changed = []
for path in lib_dir.rglob('*.dart'):
    # skip generated files
    if 'i18n' in path.parts and path.name.startswith('strings'):
        continue
    text = path.read_text(encoding='utf-8')
    new_text = text
    modified = False

    # We'll replace from end to start to keep indices valid
    for m in reversed(list(access_pattern.finditer(text))):
        key = m.group(1)
        span = m.span()
        orig = m.group(0)
        if dynamic_pattern.search(key):
            # dynamic -> add null-fallback if not present
            # check if already has fallback e.g., t['...'] ?? ''
            after = text[span[1]:span[1]+5]
            if not re.match(r"\s*\?\?", after):
                replacement = orig + ' ?? \u0027\u0027'
                new_text = new_text[:span[0]] + replacement + new_text[span[1]:]
                modified = True
        else:
            # static key -> only convert if key exists in translations
            if key in translation_keys:
                # convert to dot notation
                parts = key.split('.')
                dot = 't.' + '.'.join(parts)
                new_text = new_text[:span[0]] + dot + new_text[span[1]:]
                modified = True
            else:
                # key not in generated keys; skip conversion
                pass

    if modified:
        path.write_text(new_text, encoding='utf-8')
        files_changed.append(str(path))
        print(f"Modified {path}")

print(f"Files changed: {len(files_changed)}")
for p in files_changed:
    print(p)

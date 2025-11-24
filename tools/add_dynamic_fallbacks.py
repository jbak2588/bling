#!/usr/bin/env python3
import re
from pathlib import Path
root = Path('c:/bling/bling_app')
lib_dir = root / 'lib'

access_pattern = re.compile(r"t\[(?:'|\")([^'\"]+)(?:'|\")\]")
dynamic_pattern = re.compile(r"\$\{|\$[a-zA-Z_]")

files_changed = []
for path in lib_dir.rglob('*.dart'):
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
        if dynamic_pattern.search(key):
            # check if there is already a fallback '??' after the bracket
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
for p in files_changed:
    print(p)

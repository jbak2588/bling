import json, sys

path = r"c:/bling/bling_app/assets/lang/en.json"
try:
    with open(path, 'r', encoding='utf-8') as f:
        json.load(f)
    print('PARSE_OK')
except Exception as e:
    print('PARSE_ERROR', repr(e))
    # print context
    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        lineno = getattr(e, 'lineno', None) or getattr(e, 'lineno', None) or None
        if lineno is None:
            # try to extract from message
            import re
            m = re.search(r'line (\d+)', repr(e))
            if m:
                lineno = int(m.group(1))
        if lineno:
            start = max(0, lineno-6)
            end = min(len(lines), lineno+4)
            print('--- context ---')
            for i in range(start, end):
                print(f'{i+1:5d}: {lines[i].rstrip()}')
            print('--- end context ---')
    except Exception:
        pass
    sys.exit(1)
    # Try incremental parse to find earliest failing line
    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        for i in range(1, len(lines)+1):
            try:
                json.loads(''.join(lines[:i]))
            except Exception:
                # print context and exit
                start = max(0, i-6)
                end = min(len(lines), i+4)
                print('--- incremental fail at line', i, '---')
                for k in range(start, end):
                    print(f'{k+1:5d}: {lines[k].rstrip()}')
                break
    except Exception:
        pass

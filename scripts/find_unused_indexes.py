#!/usr/bin/env python3
"""
Find candidate unused composite indexes by statically searching repository for index field paths.
Usage: python scripts/find_unused_indexes.py firestore-indexes.json
Produces: index_usage_report.csv and prints candidates with total_hits==0
"""
import sys, json, subprocess, csv, os

if len(sys.argv) < 2:
    print("Usage: python scripts/find_unused_indexes.py <firestore-indexes.json>")
    sys.exit(1)

indexes_file = sys.argv[1]
repo_root = os.getcwd()

with open(indexes_file, 'r', encoding='utf-8-sig') as f:
    try:
        idxs = json.load(f)
    except Exception as e:
        print('Failed to parse JSON:', e)
        sys.exit(2)

rows = []
candidates = []

for idx in idxs:
    name = idx.get('name') or idx.get('indexId') or ''
    # normalize short id
    short_id = name.split('/')[-1] if name else ''
    collection_group = ''
    # extract collectionGroup from name if present
    if name and 'collectionGroups' in name:
        # older format may have collectionGroups
        parts = name.split('/')
        try:
            cg_index = parts.index('collectionGroups')
            collection_group = parts[cg_index+1]
        except Exception:
            collection_group = ''
    else:
        collection_group = idx.get('collectionGroup') or idx.get('collection_group') or ''

    fields = idx.get('fields', [])
    field_paths = []
    for f in fields:
        fp = f.get('fieldPath')
        if not fp:
            continue
        field_paths.append(fp)

    total_hits = 0
    hits_detail = {}
    for fp in field_paths:
        # use git grep literal (-F) to avoid regex surprises
        try:
            res = subprocess.run(['git','grep','-n','-F','--', fp], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, cwd=repo_root)
            out = res.stdout.strip()
            count = len(out.splitlines()) if out else 0
        except Exception:
            count = 0
        hits_detail[fp] = count
        total_hits += count

    rows.append({'index_id': short_id, 'name': name, 'collection': collection_group, 'fields': ';'.join(field_paths), 'total_hits': total_hits})
    if total_hits == 0:
        candidates.append({'index_id': short_id, 'name': name, 'fields': field_paths})

csv_path = os.path.join(repo_root, 'index_usage_report.csv')
with open(csv_path,'w',newline='',encoding='utf-8') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=['index_id','name','collection','fields','total_hits'])
    writer.writeheader()
    for r in rows:
        writer.writerow(r)

print('\nReport saved to', csv_path)
print('\nCandidate unused indexes (no static hits):')
for c in candidates:
    print(c['index_id'], '-', c['collection'], '-', ', '.join(c['fields']))

print('\nNote: static scan misses dynamic/server-side/other-repos queries. Use logs or staging tests to confirm before deleting.')

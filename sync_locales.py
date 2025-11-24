import json
import os

# 파일 경로 설정
base_dir = os.path.join('assets', 'lang')
file_en = os.path.join(base_dir, 'en.json')
file_ko = os.path.join(base_dir, 'ko.json')
file_id = os.path.join(base_dir, 'id.json')

def load_json(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {path}: {e}")
        return {}

def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def sync_structure(master, target, path=""):
    """
    master(en)의 구조를 target(ko/id)에 강제 적용.
    키가 없거나 타입이 다르면 master의 값을 target에 복사.
    """
    modified = False
    
    # master가 딕셔너리(Map)인 경우
    if isinstance(master, dict):
        if not isinstance(target, dict):
            # 타겟이 맵이 아니면(문자열이거나 없으면) 마스터 구조로 덮어쓰기
            return master, True
        
        # 마스터의 모든 키를 순회
        for k, v in master.items():
            if k not in target:
                print(f"  [Missing] Adding key: {path}.{k}")
                target[k] = v
                modified = True
            else:
                # 재귀적으로 하위 구조 동기화
                new_val, sub_mod = sync_structure(v, target[k], f"{path}.{k}")
                if sub_mod:
                    target[k] = new_val
                    modified = True
                    
        # 타겟에만 있는 불필요한 키 삭제 (선택 사항: Slang 에러 방지 위해 삭제 추천)
        keys_to_remove = [k for k in target.keys() if k not in master]
        for k in keys_to_remove:
            print(f"  [Garbage] Removing key: {path}.{k}")
            del target[k]
            modified = True

        return target, modified
    
    # master가 문자열 등 값인 경우
    else:
        # 타겟이 딕셔너리라면(구조 불일치) 마스터 값으로 덮어쓰기
        if isinstance(target, dict):
            print(f"  [TypeMismatch] Overwriting map with value at: {path}")
            return master, True
        return target, False

# 1. 로드
print("Loading JSON files...")
data_en = load_json(file_en)
data_ko = load_json(file_ko)
data_id = load_json(file_id)

# 2. 동기화 (EN -> KO)
print("\nSyncing EN -> KO...")
data_ko, modified_ko = sync_structure(data_en, data_ko)
if modified_ko:
    save_json(file_ko, data_ko)
    print("✅ ko.json updated.")
else:
    print("👌 ko.json is already synced.")

# 3. 동기화 (EN -> ID)
print("\nSyncing EN -> ID...")
data_id, modified_id = sync_structure(data_en, data_id)
if modified_id:
    save_json(file_id, data_id)
    print("✅ id.json updated.")
else:
    print("👌 id.json is already synced.")

print("\nDone. Now run 'dart run slang'.")
import json
from pathlib import Path

def update(path, results_text, locationfilter_obj):
    p = Path(path)
    data = json.loads(p.read_text(encoding='utf-8'))
    # ensure top-level search exists
    if 'search' not in data:
        print(path, 'missing search key')
        return
    data['search']['results'] = results_text
    data['search']['locationfilter'] = locationfilter_obj
    p.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

loc_obj_en = {
  "title": "Location Filter",
  "reset": "Reset",
  "apply": "Apply",
  "provinsi": "Province",
  "kabupaten": "Regency (Kabupaten)",
  "kota": "City (Kota)",
  "kecamatan": "District (Kecamatan)",
  "kelurahan": "Village (Kelurahan)",
  "tab": {"admin": "Select Area", "nearby": "Nearby", "national": "National"},
  "nearby": {"radius": "Search within {km}km radius", "desc": "Adjust the range to find items near you."},
  "national": {"title": "National Search", "desc": "Search all items and posts without location limits."},
  "hint": {"selectParent": "Please select a parent region first", "all": "All Areas"}
}

loc_obj_ko = {
  "title": "지역 설정",
  "reset": "초기화",
  "apply": "적용",
  "provinsi": "시/도 (Provinsi)",
  "kabupaten": "시/군 (Kabupaten)",
  "kota": "시 (Kota)",
  "kecamatan": "구 (Kecamatan)",
  "kelurahan": "동 (Kelurahan)",
  "tab": {"admin": "동네 선택", "nearby": "내 주변", "national": "전국"},
  "nearby": {"radius": "내 위치 반경 {km}km 검색", "desc": "범위를 조정하여 주변 상품을 찾아보세요."},
  "national": {"title": "인도네시아 전국 검색", "desc": "위치 제한 없이 등록된 모든 상품과 게시물을 검색합니다."},
  "hint": {"selectParent": "상위 지역을 먼저 선택하세요", "all": "전체 (모든 지역)"}
}

loc_obj_id = {
  "title": "Filter Lokasi",
  "reset": "Atur Ulang",
  "apply": "Terapkan",
  "provinsi": "Provinsi",
  "kabupaten": "Kabupaten",
  "kota": "Kota",
  "kecamatan": "Kecamatan",
  "kelurahan": "Kelurahan",
  "tab": {"admin": "Pilih Area", "nearby": "Di Sekitar", "national": "Nasional"},
  "nearby": {"radius": "Cari dalam radius {km}km", "desc": "Sesuaikan jangkauan untuk menemukan item di sekitarmu."},
  "national": {"title": "Pencarian Nasional", "desc": "Cari semua item dan posting tanpa batasan lokasi."},
  "hint": {"selectParent": "Silakan pilih wilayah induk terlebih dahulu", "all": "Semua Wilayah"}
}

update('c:/bling/bling_app/assets/lang/en.json', 'Results', loc_obj_en)
update('c:/bling/bling_app/assets/lang/ko.json', '검색 결과', loc_obj_ko)
update('c:/bling/bling_app/assets/lang/id.json', 'Hasil', loc_obj_id)
print('Updated files')

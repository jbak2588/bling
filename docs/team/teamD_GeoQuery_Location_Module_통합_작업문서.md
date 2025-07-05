
## 📌 `[팀D] Bling_GeoQuery_Location_Module_통합_작업문서 (Ver.3)`

**담당:** GeoQuery & Location 담당팀  
**총괄:** ChatGPT (총괄 책임자)  
**버전:** Bling Ver.3 기준

---

## ✅ 1️⃣ 모듈 목적

Bling의 **Kabupaten → Kecamatan → Kelurahan → RT/RW 단계 주소 DropDown**,  
**Singkatan 표기**, **GeoPoint 기반 반경 검색**, **Google Maps 연동**까지  
지역 기반 Feed/Marketplace/Club 등 모든 모듈에 **위치 일관성**을 제공한다.

---

## ✅ 2️⃣ 실전 Firestore DB 스키마 (Ver.3 확정)

```json
posts/{postId} {
  "locationParts": {
    "kabupaten": "Kab. Tangerang",
    "kecamatan": "Kec. Cibodas",
    "kelurahan": "Kel. Panunggangan Barat",
    "rt": "RT.03",
    "rw": "RW.05"
  },
  "locationName": "RT.03/RW.05 - Kel. Panunggangan Barat, Kec. Cibodas",
  "geoPoint": GeoPoint(-6.2, 106.8),
  "geohash": "u6k2kq...",
  ...
}
```

---

## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**Singkatan 표기**|`Kab.`, `Kec.`, `Kel.`, `RT.`, `RW.` 통일|
|**DropDown 단계**|Kabupaten → Kecamatan → Kelurahan → RT/RW|
|**반경 검색**|GeoPoint + geohash, `within()`|
|**지도 연동**|Google Maps Marker + 반경 Circle|
|**Firestore 인덱스**|`kabupaten`, `kecamatan`, `geohash`, `createdAt` 복합 인덱스 필수|

---

## ✅ 4️⃣ 연계 모듈 필수

- CRUD 팀: Feed/Marketplace 위치 정보 저장 시 `locationParts` 사용
    
- Chat 팀: RT 공지 시 `kabupaten`, `kecamatan` 필터 연계
    
- TrustLevel/Privacy: GeoPoint 공개 범위는 `privacySettings`로 가드
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트

|No.|작업 항목|설명|
|---|---|---|
|D-1|단계별 DropDown UI|Kab. → Kec. → Kel. → RT/RW|
|D-2|Singkatan Helper|입력 값 자동 축약 적용|
|D-3|GeoPoint 저장/변환|사용자 GPS → GeoPoint + geohash|
|D-4|반경 쿼리 within()|`geoflutterfire2` 적용|
|D-5|Google Maps Marker|Feed/Marketplace 위치 Marker 렌더링|
|D-6|반경 Circle|Slidable 반경 조절 + 지도 반영|
|D-7|복합 인덱스 Proof|Firestore Console 설정 & QA|
|D-8|DropDown Modal UX|BottomSheet or FullScreen 선택|

---

## ✅ 6️⃣ 팀 D 작업 지시 상세

1️⃣ **DropDown & Singkatan**

- 모든 주소 입력 → Singkatan Helper에서 자동 변환
    
- DropDown 단계별 종속성 (Kabupaten 선택 → Kecamatan 리스트)
    

2️⃣ **GeoQuery 로직**

- `GeoHelpers` 모듈로 `within()` 반경 쿼리 Proof
    
- 반경 슬라이더로 실시간 반영
    

3️⃣ **지도 연동**

- Marker 커스텀 아이콘
    
- 반경 Circle 색상 가이드
    
- 사용자 현재 위치 표시 옵션
    

4️⃣ **복합 인덱스**

- Firestore Console → `kabupaten` + `kecamatan` + `geohash` + `createdAt`
    

---

## ✅ 7️⃣ 필수 체크리스트

✅ Singkatan Helper Test Pass  
✅ DropDown 단계별 UX Pass  
✅ 반경 within() 쿼리 QA OK  
✅ GeoPoint & geohash 저장 일치  
✅ Google Maps Marker & Circle Proof  
✅ Firestore 인덱스 구성 → 인덱스 URL Vault 기록  
✅ PR + Vault `📌 Bling_Ver3_Rebase_Build.md` 반영

---

## ✅ 8️⃣ 작업 완료시 팀 D 제출물

- 단계별 DropDown Flow 캡처
    
- Singkatan Helper Dart Snippet
    
- 반경 쿼리 결과 Proof JSON
    
- Google Maps Marker 렌더링 스크린샷
    
- 복합 인덱스 등록 스크린샷 & URL
    
- PR & Vault 기록
    

---

## ✅ 🔗 연계 문서

- [[📌 Bling_Location_Singkat_And_Dropdown_Policy]]
    
- [[📌 Bling_Location_GeoQuery_Structure]]
    
    

---


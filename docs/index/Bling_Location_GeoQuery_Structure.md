
 
# 📌 Bling_Location_GeoQuery_Structure.md

---
## **반경 + 단계별 주소 + 지도 + Feed 쿼리 연동 흐름**


## ✅ 목적

Bling 앱의 **전체 피드/마켓/이웃 검색**은  
**Kabupaten → Kecamatan → Kelurahan → RT/RW + 반경 GeoPoint** 구조로  
최적화됩니다. 이 문서는 Flutter + Firestore + Geo 쿼리 + Map 연동 전체 흐름을 정리합니다.

---

## ✅ 단계별 DropDown 흐름

| 단계 | 설명 |
| ---- | ---- |
| Kabupaten | 검색 시작 기준 (필수) |
| Kecamatan | Kabupaten 선택 시 활성화 |
| Kelurahan | Kecamatan 선택 시 활성화 |
| RT/RW | 옵션 단계 (선택 시 Equal Filter) |

- Singkatan 표기 필수: Kab., Kec., Kel., RT., RW.
- 선택 시 상위 단계가 바뀌면 하위 단계는 자동 초기화.

---

## ✅ Geo 반경 검색

- 중심점: 사용자 GeoPoint
- 반경: 1~10km (슬라이더로 조정)
- Firestore 쿼리: `geohash` + `location` + 단계별 Equal 혼합
- `geoflutterfire2` 패키지 사용

---

## ✅ 파일 구조 제안

```

lib/  
├── core/  
│ ├── utils/  
│ │ └── geo_helpers.dart  
├── features/  
│ ├── location/  
│ │ ├── controllers/location_provider.dart  
│ │ ├── widgets/location_dropdown_modal.dart  
│ ├── feed/  
│ │ ├── data/feed_query_builder.dart  
│ │ ├── screens/feed_screen.dart

````

---

## ✅ 핵심 위젯 & 로직

### 📂 `location_provider.dart`

- 단계별 선택 값 (`selectedKabupaten`, `selectedKecamatan` 등) 저장
- 단계별 변경 시 하위 초기화
- `firestoreQueryParams`로 Equal 파라미터 Map 제공

---

### 📂 `location_dropdown_modal.dart`

- `ModalBottomSheet`에 DropDown 단계별 표시
- 선택 → Provider 값 갱신 → 하위 단계 초기화
- 완료 시 `Navigator.pop()`

---

### 📂 `geo_helpers.dart`

- `GeoFlutterFire`로 GeoPoint + 반경 → Firestore 쿼리
- `within()` 사용 → 반경 내 문서 실시간 Stream
- `geohash` + Equal 조건 혼합 필터

---

### 📂 `feed_query_builder.dart`

- `LocationProvider` Equal 파라미터와 Geo 반경 Stream 결합
- 단계별 Equal → `.where()`  
- Geo 반경 → `GeoHelpers` within() 사용
- Feed, Map Marker, Circle 동기화

---

### 📂 `MapFeedScreen` (예시)

- GoogleMap 위에 반경 Circle + Marker
- Feed 리스트 `StreamBuilder`로 동일 문서 출력
- 반경 슬라이더 → `setState`로 반경 재조정 → 쿼리 실시간 재실행
- DropDown 변경 → Equal 쿼리 갱신

---

## ✅ Firestore 필드 구조

| 필드명 | 예시 | 설명 |
| --- | --- | --- |
| kabupaten | Kab. Tangerang | Singkatan |
| kecamatan | Kec. Cibodas | Singkatan |
| kelurahan | Kel. Panunggangan Barat | Singkatan |
| rt | RT.03 | 옵션 |
| rw | RW.05 | 옵션 |
| location | GeoPoint | 중심 좌표 |
| geohash | u6k2kq... | 반경 검색용 |
| createdAt | Timestamp | 정렬 |

---

## ✅ 필수 Firestore 복합 인덱스

| 필드 | 설정 |
| --- | --- |
| kabupaten | Ascending |
| kecamatan | Ascending |
| geohash | Ascending |
| createdAt | Descending |

---

## ✅ 지도 Marker + Circle 연계

```dart
Marker(
  markerId: MarkerId(doc.id),
  position: LatLng(geo.latitude, geo.longitude),
  infoWindow: InfoWindow(title: title),
);

Circle(
  circleId: CircleId('radius'),
  center: LatLng(center.latitude, center.longitude),
  radius: radiusInKm * 1000,
);
````

---

## ✅ QA 체크리스트

-  단계별 DropDown Singkatan 일치 여부
    
-  GeoPoint 저장 시 geohash 포함 여부
    
-  반경 쿼리 + Equal 쿼리 동시 적용
    
-  복합 인덱스 구성
    
-  Google Maps API Key 활성화
    

---

## ✅ 결론

이 구조로 Bling은 **Kab. → Kec. → Kel. → RT/RW + Geo 반경** 흐름을  
단일 Provider & 쿼리로 관리하고, Feed/지도/슬라이더가 연동됩니다.


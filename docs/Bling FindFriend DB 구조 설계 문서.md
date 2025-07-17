# 📦 Bling FindFriend DB 구조 설계 문서

작성일: 2025-07-12  
버전: DB 설계 기준 Ver.0.5  
작성자: Planner

---

## ✅ 목적

- Bling의 친구찾기 기능(`FindFriend`)의 Firestore 데이터 구조를 명확히 정의하고,
    
- 기존 user 컬렉션 필드 혼잡 문제 해결 및 하위 문서 기반 구조로 전환
    

---

## ✅ 기본 설계 원칙

### 🔹 상위 컬렉션 (`users/{uid}`)

- 사용자 전반의 공통 정보만 유지
    
- FindFriend, MatchProfile 등 세부 기능은 별도 서브 문서로 분리
    

### 🔹 조건 필드

|필드명|타입|설명|
|---|---|---|
|`isDatingProfile`|`bool`|친구찾기 기능 활성화 여부|
|`isMatchProfile`|`bool`|데이팅 기능 활성화 여부|
|`neighborhoodVerified`|`bool`|지역 인증 여부 (위치 기반 친구 찾기 허용 여부)|

이 필드들은 UI 진입 조건과 Firestore 문서 생성 조건으로 사용됨

---

## ✅ Firestore 구조 설계

```plaintext
/users/{uid}
├── nickname: "Dika"
├── photoUrl: "https://..."
├── isDatingProfile: true
├── isMatchProfile: false
├── neighborhoodVerified: true

/users/{uid}/findfriend_profile/main
├── nickname: "Dika"
├── ageRange: "25-34"
├── gender: "male"
├── interests: ["travel", "coffee"]
├── profileImages: ["url1", "url2"]
├── bio: "Suka jalan-jalan dan ngopi"
├── location: "Tangerang, Banten"
├── geoPoint: GeoPoint
├── trustLevel: 1
├── isNeighborVerified: true
```

> 📎 참고: `findfriend_profile` 문서명은 `main` 고정 또는 UID와 동일하게 설정 가능 (권장: `main`)

---

## ✅ UI 조건 흐름 예시

### 🔹 친구찾기 탭 진입 조건

```dart
if (user['isDatingProfile'] == true) {
  // Proceed to load findfriend_profile
} else {
  // Show: "Please create your FindFriend profile."
}
```

### 🔹 프로필 저장 시 조건

- `isDatingProfile == true` → `/findfriend_profile/main` 문서 생성
    
- 입력 완료 시 상위 필드도 true로 업데이트
    

---

## ✅ 장점 요약

|항목|하위 문서 구조 장점|
|---|---|
|가독성|필드 혼잡 없이 분리됨|
|보안|문서 단위 Firestore Rule 적용 가능|
|확장성|기능별 하위 문서 무한 확장 가능 (ex. group_profile, dating_profile 등)|
|쿼리 최적화|조건 필터링 및 lazy-load 유리|

---

## ✅ 개발 시 주의사항

- 기존 `/users/{uid}` 필드에 존재하는 `findfriend` 필드는 더 이상 사용하지 말 것
    
- 새 저장 위치는 반드시: `/users/{uid}/findfriend_profile/main`
    
- `SetOptions(merge: true)`로 상위 필드 업데이트 병행
    
- 초기 진입 시 `isDatingProfile == true` 체크 → 문서 유무 확인 → 불러오기
    

---

## ✅ 향후 확장 대비 구조 제안

```plaintext
/users/{uid}/findfriend_profile/main
/users/{uid}/match_profile/main
/users/{uid}/group_profile/main
```

> 이 방식으로 향후 기능 (`Group Matching`, `Dating`, `Club`) 등을 기능 단위로 모듈화 가능

---

## 📌 결론

Planner는 Bling Ver.0.5 기준부터 친구찾기 관련 모든 데이터를 `/users/{uid}/findfriend_profile` 하위 문서 구조로 전환하기로 한다.  
모든 UI 조건 분기, Firestore 저장 및 조회, 보안 규칙 또한 이 기준에 맞춰 변경해야 한다.
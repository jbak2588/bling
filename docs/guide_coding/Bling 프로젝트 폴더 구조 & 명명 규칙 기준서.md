# 📁 Bling 프로젝트 폴더 구조 & 명명 규칙 기준서

작성일: 2025-07-12  
기준 버전: Bling Ver.0.5  
작성자: Planner

---

## ✅ 1. 최상위 폴더 구조

```
lib/
├── core/            # 전역 모델, 유틸, 상수 등 공통 코드
├── features/        # 기능 단위 모듈 (도메인 기준 분리)
├── shared/          # 공통 위젯 및 컨트롤러
├── main.dart        # 앱 진입점
```

---

## ✅ 2. core 하위 구조

```
core/
├── models/          # 앱 전역에서 공통으로 쓰이는 모델
├── constants/       # 앱 범용 상수 (카테고리, 경로 등)
├── utils/           # 공용 함수, 포매터, 헬퍼 등
```

### 📌 모델 예시

- user_model.dart
    
- product_model.dart
    
- post_model.dart
    

---

## ✅ 3. features 하위 구조 (Clean Architecture 적용 기준)

```
features/
└── [기능명]/
    ├── data/         # repository, data provider, storage 등
    ├── domain/       # 선택적: 모델 정의 또는 핵심 비즈니스 규칙
    ├── screens/      # 화면 단위 UI 파일들
    ├── widgets/      # 해당 기능 내에서만 쓰는 컴포넌트
```

### 📌 예시 구조

```
features/find_friends/
├── data/
│   ├── findfriend_repository.dart
│   ├── follow_repository.dart
├── screens/
│   ├── find_friends_screen.dart
│   ├── findfriend_profile_form.dart
│   ├── findfriend_profile_detail.dart
│   ├── friend_requests_screen.dart
```

---

## ✅ 4. 파일명 규칙

- 모두 **snake_case** 사용
    
- 접미사는 역할을 명확히 나타냄
    

|타입|접미사 예시|
|---|---|
|화면|*_screen.dart|
|폼/입력|*_form.dart|
|상세 보기|*_detail.dart|
|위젯|*_card.dart, *_tile.dart|
|저장소|*_repository.dart|
|모델|*_model.dart|
|도메인|단수형, ex) category.dart|

### 📌 예시

- `user_profile_screen.dart`
    
- `post_card.dart`
    
- `product_repository.dart`
    

---

## ✅ 5. 필드명 규칙 (Firestore 및 모델 내)

- camelCase 사용 (Firebase 권장 스타일)
    
- 불리언은 is~/has~ 접두사 사용
    
- 지역, 인증 관련은 명확하게 구체적 단어 사용
    

|목적|예시|
|---|---|
|닉네임|nickname|
|지역명|locationName, locationParts|
|인증여부|isNeighborVerified|
|데이팅|isDatingProfile|
|관심사|interests (List)|
|이미지|profileImages (List)|

---

## ✅ 6. 모델 위치 기준

- **앱 전반에서 공통 사용** → `core/models/`
    
- **특정 feature 한정 사용** → `features/[기능]/domain/` or `data/`
    

> 단, 모든 핵심 모델 (`user`, `product`, `post`)은 반드시 `core/models/`에 위치

---

## ✅ 7. 예외 규칙

- legacy 파일(ex: product_model_old.dart)은 `deprecated` 주석 명시
    
- 외부 라이브러리 확장 클래스(ex: map_utils.dart)는 `utils/`에 보관
    

---

## ✅ 8. 향후 확장 시 규칙 유지

- 새 기능 추가 시 반드시 동일한 규칙으로 폴더 생성
    
- Codex/Gemini에게 자동 생성 시 이 기준서 전달 필수
    
- PR 리뷰 시 기준 위반 항목은 반드시 수정 요청
    

---

## 🧩 참고 문서

- 01 프로젝트 개요 & 폴더트리.md
    
- 1 디자인 UX 가이드 n i18n.md
    
- 03 User 필드 & TrustLevel & 프로필정책.md
    

---

> ✨ 이 기준은 Bling Ver.1.0 출시까지 유지되며, 팀 확장 시 공식 스펙으로 제안됩니다.
## Copilot 사용 지침 — Bling 앱 저장소

간단 요약: 이 파일은 GitHub Copilot / repo-aware AI에게 이 저장소에서 생산적으로 작업하기 위한 핵심 컨텍스트와 규칙을 알려줍니다. 모든 응답은 한국어(표준 한국어, 존댓말)로 해 주세요. 코드 블록은 기존 식별자(영어 변수/클래스명)를 유지합니다.

- **아키텍처 핵심 (한 문장씩)**
  - UI: `lib/features/*/screens`와 `lib/features/*/widgets`에 화면/위젯이 모여 있습니다.
  - 도메인/모델: `lib/features/*/models`와 `lib/core/models`에 데이터 모델이 있습니다 (예: `post_model.dart`, `post_category_model.dart`, `user_model.dart`).
  - 상태/로직: Provider 패턴을 사용합니다 (`lib/features/location/providers/location_provider.dart` 등).
  - 외부 통합: Firebase(Firestore, Storage, Auth), Google Maps, Cloud Functions (`functions-v2`).

- **핵심 파일/패턴 (찾아야 할 것들)**
  - `lib/core/constants/app_categories.dart` — 카테고리 정의(emoji, id, nameKey 등). 사용법: 카테고리 드롭다운과 탭 생성.
  - `lib/core/constants/app_tags.dart` — 태그 메타(추천/가이드형 필드 포함). 태그 관련 로직은 `CustomTagInputField`와 결합됩니다.
  - `lib/features/local_news/models/post_model.dart` — `category` 필드(카테고리 ID)와 `tags`(List<String>) 정책을 준수하세요.
  - `lib/features/local_news/screens/{create,edit,local_news_screen}.dart` — 카테고리/태그 UI와 Firestore 쿼리(카테고리 기반 탭, `category` 필터)를 반영해야 합니다.
  - `lib/features/main_screen/main_navigation_screen.dart` — 앱 전역 네비게이션, PopScope(back handling), 초기 위치 필터 초기화 로직.

- **데이터/쿼리 관례**
  - Feed 쿼리는 대부분 Firestore `posts` 컬렉션을 사용합니다. 카테고리 필터는 `category == '<id>'` 입니다. 태그 검색은 `array-contains` 혹은 searchIndex를 사용합니다.
  - Post 저장/업데이트 시 `createdAt`/`updatedAt`은 `FieldValue.serverTimestamp()`를 사용합니다.
  - 사용자 위치는 `users` 문서의 `locationParts`와 `geoPoint`를 사용하며, 화면 출력 시 `LocationHelper.cleanName` 규칙을 지켜야 합니다(privacy 규칙).

- **로컬 개발 / 빌드 / 배포 커맨드 (필수)**
  - 의존성 설치: `flutter pub get`
  - 정적분석: `flutter analyze` (변경 후 항상 권장)
  - 에뮬레이터 실행 및 앱 실행: `flutter run`
  - Firestore 인덱스 배포: 로컬 `firestore.indexes.json`을 사용하여 `firebase deploy --only firestore:indexes` 또는 Firebase CLI의 지침에 따르십시오. (주의: 서버에 존재하는 인덱스와 차이가 있으면 CLI가 삭제를 요구할 수 있음 — 확인 후 진행)
  - Functions: `cd functions-v2 && npm install` 후 `npm run serve`(로컬) 또는 `npm run deploy`(배포)

- **코드 수정 시 체크리스트 (AI가 자동으로 고려할 규칙)**
  - PostModel의 `category`가 required로 복구된 경우, 모든 생성/편집 화면에서 카테고리 값을 설정/저장해야 합니다 (`create_local_news_screen.dart`, `edit_local_news_screen.dart`).
  - 태그 관련 로직을 변경하면 `CustomTagInputField`를 사용하는 곳과 `AppTags.localNewsTags` 정의를 함께 점검하세요.
  - Firestore 쿼리 변경(예: tags → category로 필터 변경)은 `firestore.indexes.json`의 인덱스와 일치시키세요.
  - 네비게이션 변경(예: 썸네일 onTap이 항상 Navigator.push로 이동) 시 중복 AppBar/Back 동작이 발생하지 않는지 확인하세요.

- **프로젝트 규칙/스타일 (명시적 규약)**
  - 다국어: `easy_localization`을 사용합니다. 텍스트는 `assets/lang/*.json`의 키를 사용하여 `tr()`로 번역하세요.
  - 날짜/시간: Firestore 서버 타임스탬프 사용 권장.
  - 이미지 업로드: Storage 경로 규칙 `post_images/{userId}/{postId}/{fileId}.jpg`를 따릅니다.

- **디버깅/검증 포인트 (AI가 PR에 남겨야 할 체크 항목)**
  - `flutter analyze` 통과 여부
  - 런타임에서 카테고리 드롭다운 초기값/저장 확인(생성/수정 모두)
  - Firestore 인덱스 변경이 있는 경우 `firestore.indexes.json` 검토 및 배포 로그 확인
  - 위치 관련 변경 시 개인정보 규칙(README의 Privacy: Location Display Guidelines) 준수 여부

- **작업 스타일 가이드 (간단)**
  - 변경 범위가 크면 작은 커밋(기능 단위)과 상세한 커밋 메시지(무엇을/왜 변경했는지)를 남기세요.
  - 리팩토링 시 기존 동작(특히 Firestore 쿼리, 인덱스, Provider 상태)과 호환되는지 unit/integration 테스트 또는 수동 검증을 추가로 권장합니다.

문서가 충분하지 않거나 특정 파일의 의도를 명확히 해야 하면, 간단히 질문해 주세요 — 예: "create_local_news_screen의 _selectedCategory 초기값을 어디서 가져와야 하나요?" 같은 구체적 질문이 가장 빠릅니다.

---
피드백: 이 파일에 추가할 내용(예: 팀 내부 규칙, CI 명령어, 추가 중요 파일)을 알려주시면 반영하겠습니다.

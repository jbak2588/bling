### **1\. Bling 프로젝트 DevLog (작업 세션 요약)**

**세션:** 2025년 10월 30일 **주요 기획 문서:**

* `하이브리드 방식 로컬 뉴스 게시글 개선 방안.md` (이하 '하이브리드 기획안')  
* `Bling 프로젝트 DevLog (작업 세션 요약).docx` (이전 세션 DevLog)

---

#### **1.1. 완료된 작업 (Phase 2: Local News 태그 필터링)**

이전 DevLog의 '이어서 진행할 작업' (Source 61-67)을 완료했습니다.

* **`local_news_screen.dart` (수정):**  
  * 기존 `AppCategories` 기반의 상단 탭을 `AppTags` 기반의 태그 필터 탭으로 교체했습니다.  
  * Firestore 쿼리를 `where('category', ...)`에서 `where('tags', arrayContains: selectedTagId)`로 성공적으로 변경했습니다.  
  * `TagInfo` 모델에 `showInFilter` 필드가 없어 발생한 컴파일 에러를 `filterableTagIds`라는 명시적 목록을 정의하여 해결했습니다.  
* **`feed_repository.dart` (점검):**  
  * `_fetchLatestPosts` 함수가 `category` 필드를 참조하지 않고 `createdAt` 기준으로만 데이터를 가져옴을 확인했습니다. (수정 불필요)

#### **1.2. 완료된 작업 (Phase 3: 푸시 구독 스키마 구현)**

'하이브리드 기획안' 3\) 푸시 구독 스키마 구현을 완료했습니다.

* **데이터 모델 (신규/수정):**  
  * `push_prefs_model.dart`: `regionKeys`를 `Map<String, String>`으로 정의하는 등 백엔드와 호환되는 모델을 신규 생성했습니다.  
  * `user_model.dart`: `PushPrefsModel`을 참조하는 `pushPrefs` 필드를 추가했습니다.  
* **프론트엔드 (UI):**  
  * `notification_settings_screen.dart`: 기존 `Map` 기반 로직을 `PushPrefsModel` 기반으로 리팩토링했습니다. 사용자가 '알림 범위(scope)'와 '구독 태그(tags)'를 선택하고 저장하는 UI를 구현했습니다.  
* **백엔드 (Cloud Function):**  
  * `index.js`: `onUserPushPrefsWrite` 함수를 추가했습니다. 이 함수는 `user.pushPrefs` 변경(토큰, 태그, 범위)을 감지하고, `buildTopicsFromPrefs` 헬퍼를 통해 FCM 토픽 구독(`subscribe/unsubscribe`)을 자동으로 동기화합니다.

#### **1.3. 완료된 작업 (Phase 4: 동네 게시판 자동 생성 및 연동)**

'하이브리드 기획안' 4\) 동네 게시판 구현을 완료했습니다.

* **데이터 모델 (신규):**  
  * `board_model.dart`, `board_thread_model.dart`, `board_chat_room_model.dart` 3종의 Firestore 모델을 신규 생성했습니다.  
* **백엔드 (Cloud Function):**  
  * `index.js`: `onLocalNewsPostCreate` 함수를 추가했습니다.  
  * 게시글 생성 시 `boards/{kel_key}` 문서의 `metrics.last30dPosts`를 트랜잭션으로 증가시킵니다.  
  * **\[룰 완화 적용\]** 카운트가 **10건**에 도달하면 `features.hasGroupChat` 플래그를 `true`로 설정하여 게시판을 활성화합니다.  
* **프론트엔드 (동적 탭):**  
  * `main_navigation_screen.dart`: `_checkKelurahanBoardStatus` 함수를 추가했습니다. `userModel` 로드 시 `boards/{kel_key}`의 `features.hasGroupChat` 플래그를 확인하여, `true`일 경우 하단 네비게이션 바에 '동네' 탭을 동적으로 추가합니다.  
* **프론트엔드 (게시판 UI):**  
  * `kelurahan_board_screen.dart`: 사용자의 `locationParts.kel` 기준으로 게시글을 필터링하는 '동네 전용 피드' 화면을 신규 생성했습니다.  
* **채팅 연동 (기존 코드 확장):**  
  * `chat_service.dart`: `getOrCreateBoardChatRoom` 함수를 추가하여, `kelKey`를 ID로 사용하는 그룹 채팅방을 생성/조회하도록 확장했습니다.  
  * `kelurahan_board_screen.dart`: 화면 상단 채팅 아이콘 클릭 시, `getOrCreateBoardChatRoom`을 호출하고 기존 `ChatRoomScreen`을 `isGroupChat: true` 모드로 실행하도록 연동했습니다.

#### **1.4. 버그 수정**

* **`chat_room_screen.dart` (수정):**  
  * `Scaffold`에 `resizeToAvoidBottomInset: true` 속성을 추가하여, 키보드가 채팅 입력창을 가리는 현상을 해결했습니다.


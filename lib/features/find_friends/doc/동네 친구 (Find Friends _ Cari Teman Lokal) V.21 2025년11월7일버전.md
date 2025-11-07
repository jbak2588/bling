# 3.0 동네 친구 (Find Friends / Cari Teman Lokal) \- v2.1

### **3.1.1 필요성 / 목적 (v2.1)**

'동네 친구' 기능은 블링앱의 핵심 가치인 '하이퍼로컬 커뮤니티'를 활성화하는 핵심 진입 기능입니다. 기존 v1의 '친구/연인(Pacar)' 찾기 기능은 데이팅 앱의 성격이 강해 매춘, 사기 등의 부작용이 우려되고, '친구 요청/수락'의 허들이 높아 사용자 유입을 방해했습니다.

v2.1은 이러한 문제점을 해결하고, '연인' 찾기 기능을 **완전 제거**합니다. 대신 블링의 정체성에 맞춰 \*\*'하이퍼로컬 관심사 기반의 대화 상대 찾기'\*\*로 전면 개편합니다.

1. **부작용 방지:** 데이팅 앱 요소를 제거하여 범죄 목적의 사용자 유입을 원천 차단합니다.  
2. **사용자 유입 확대:** '요청/수락' 절차를 폐지하고 '즉시 대화'로 변경하여, 사용자가 부담 없이 가벼운 대화 상대를 찾도록 유도합니다.  
3. **하이퍼로컬 구현:** GPS 기반 거리 대신, 앱의 핵심인 '동네 인증(Neighborhood Verified)' 및 '동네 필터(Kel/Kec)'를 매칭의 최우선 기준으로 삼습니다.

### **3.1.2 주요 구성 / Key Components (v2.1)**

**1\. 프로필 요소 (Profile)**

* '데이팅 프로필'(`findfriend_form_screen`)을 폐지하고, 사용자의 기본 커뮤니티 프로필(`user_model`)을 사용합니다.  
* **표시 정보:** `nickname`(닉네임), `interests`(관심사), `trustLevelLabel`(신뢰 등급), `neighborhoodVerified`(동네 인증 여부)를 강조합니다.  
* **제거된 정보:** `age`(나이), `gender`(성별), `genderPreference`(성별 선호) 등 데이팅 관련 필드를 제거합니다.  
* **설정:** `profile_edit_screen.dart`에 "동네 친구 리스트에 나를 노출" (`isVisibleInList`) 토글을 이관합니다.

**2\. 발견 탭 (Discovery Tabs)** `find_friends_screen.dart`는 2개의 탭으로 구성됩니다.

* **Tab 1: 동네 친구 (Friends):** 1:1 사용자 리스트.  
* **Tab 2: 동네 모임 (Groups):** 1:N 모임 리스트. `clubs` (정식 모임) 및 `clubProposals` (모임 제안)을 모두 노출합니다.

**3\. 매칭 기능 (Matching)**

* **\[폐지\] '친구 요청' (Friend Request):** `friend_requests` 컬렉션 및 관련 로직(요청/수락/거절)을 모두 삭제했습니다.  
* **\[신규\] '대화 시작하기' (Start Chat):**  
  * `find_friend_detail_screen.dart`의 FAB 버튼입니다.  
  * 클릭 시 별도 수락 과정 없이 `chat_room_screen.dart`로 즉시 이동합니다.

**4\. 정렬 로직 (Sorting)** `find_friend_repository.dart`에서 클라이언트 측 정렬을 수행합니다.

1. **1순위:** 동네 인증 (`neighborhoodVerified: true`) 사용자  
2. **2순위:** 신뢰 등급 (`trustLevel`) 높은 순서 (Trusted \-\> Verified \-\> Normal)  
3. **3순위:** 공통 관심사 (`interests`) 개수가 많은 순서  
4. **4순위:** 최근 접속일 (`lastActiveAt`) 최신 순서

### **3.1.3 안전 장치 (Safety Features \- v2.1)**

'즉시 대화'의 부작용을 방지하기 위해 강력한 3중 안전 장치를 구현합니다.

**1\. 스팸 방지 (Daily Chat Limit)**

* **기능:** '동네 친구'를 통해 *새로운* 사용자에게 대화를 시작할 수 있는 횟수를 1일 5회(예시)로 제한합니다. (기존 채팅방은 무제한)  
* **구현:** `functions-v2/index.js`에 `startFriendChat` (onCall) 함수를 추가. `find_friend_detail_screen.dart`에서 대화 시작 시 이 함수를 호출하여 `allow: true` 응답을 받아야만 채팅방으로 이동합니다.

**2\. 24시간 보호 모드 (Protection Mode)**

* **기능:** `isNewChat: true` 플래그가 전달된 채팅방에 24시간 동안 적용됩니다.  
* **구현 (`chat_room_screen.dart`):**  
  * **텍스트 마스킹:** 정규식(RegExp)을 사용해 메시지 본문의 URL(`http...`)과 전화번호(8자리 이상)를 `[안전 모드: 숨김]`으로 자동 치환합니다.  
  * **미디어 차단:** 이미지/카메라 전송 버튼을 비활성화(`IconButton(onPressed: null)`)합니다.  
  * **이미지 블러:** 24시간 이내에 수신된 이미지는 `BackdropFilter`를 사용해 블러(Blur) 처리되어 전송되며, 사용자가 탭해야 원본을 볼 수 있습니다.

**3\. 아이스브레이커 (Icebreakers)**

* **기능:** `isNewChat: true`이고 대화 내역이 없을 때, 대화를 유도하는 3개의 추천 질문(`ActionChip`)을 표시합니다.  
* **구현:** 칩 클릭 시 해당 텍스트가 `_sendMessage` 함수로 전달되어 즉시 전송됩니다.

### **3.1.4 기술 아키텍처 / DB (v2.1)**

* **`users` (Collection):**  
  * `isDatingProfile`, `age`, `gender`, `findfriend_profileImages` 필드 **삭제**.  
  * `trustLevelLabel` (String) 필드 **추가**.  
  * `chatLimits` (Map) 필드 **추가** (예: `{'findFriendCount': 2, 'findFriendLastReset': '2025-11-07'}`).  
* **`friend_requests` (Collection):**  
  * **삭제됨 (DELETED).**  
* **`chats` (Collection):**  
  * `chat_room_screen.dart`가 `isNewChat: bool` 파라미터를 받도록 수정됨.  
  * `chat_service.dart`의 `sendMessage`가 `batch.set(..., merge: true)`를 사용하도록 수정 (신규 채팅방 즉시 생성).  
* **`functions-v2/index.js`:**  
  * `startFriendChat` (onCall) 함수 **추가**.

### **3.1.5 수익 모델 (Monetization)**

* **\[유지\] 프로필 부스팅:** '동네 친구' 리스트 상단에 프로필을 고정 노출하는 유료 아이템.  
* **\[신규\] 다른 동네 탐색권:** 현재 설정된 동네(Kab/Kec) 외에 다른 동네의 '친구/모임' 리스트를 볼 수 있는 유료 확장권.  
* **\[폐지\]** '관심 상대 10명 초과 시 유료' 등 데이팅 앱 기반의 수익 모델.

### **3.1.6 확장성 및 로드맵 (Roadmap)**

* **즉시 시행 (Short-term):**  
  * **\[필수\] Firestore 인덱스 해결:** '모임' 탭의 'Active Clubs'가 `getClubsByLocationStream`을 사용하지 못하는 임시 조치(Job 45)를 해결해야 합니다. `locationParts`와 `isSponsored`를 포함하는 복합 인덱스를 생성하고 쿼리를 복원해야 합니다.  
  * **'모임 제안' 상세:** '모임 제안' 카드 클릭 시 상세 내역을 볼 수 있는 화면(`ClubProposalDetailScreen`) 구현.  
* **중기 (Mid-term):**  
  * **음성 프로필:** 텍스트/사진 대신 음성으로 자기를 소개하여 '인간적인' 매칭 강화.  
  * **Bling 활동 연동:** "최근 '동네 소식'에 글을 올린 사람", "최근 '중고 거래'를 완료한 신뢰도 높은 사람" 등 실제 앱 활동을 기반으로 한 추천 로직 도입.  
* **\[폐지된 로드맵\]:**  
  * 스와이프 기반 매칭, 종교 필터, 진지한 만남 모드 (v2.1 기획 방향과 불일치).


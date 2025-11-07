# **DevLog: Bling 앱 개선 작업 (Job 0 \- 45\)**

## **1\. 홈 화면 UI 개선 (Job 0-3)**

* **(Job 0\)** `home_screen.dart`의 그리드 아이콘 UI (`GrabIconTile`) 수정.  
  * 기획: 아이콘 그림자 제거, 흰색 배경, 띄어진(floating) 느낌.  
  * 조치: 기존 `GrabIconTile`을 주석 처리하고, `Container`와 `BoxShadow`를 사용한 신규 UI로 교체.  
* **(Job 1\)** 텍스트 라벨 오버플로우(1.4px)로 인한 런타임 에러 수정.  
  * 조치: 아이콘과 라벨 사이 `SizedBox` 높이 조정 (8.0 \-\> 6.0).  
* **(Job 2\)** 2줄 라벨 적용 시 아이콘이 위로 밀리는 정렬 문제 수정.  
  * 조치: 라벨 `Text`를 `Container`로 감싸고 2줄 높이로 고정하여 모든 아이콘의 수직 정렬을 통일.  
* **(Job 3\)** `Column`의 `children` 내부에 `final` 변수를 선언하여 발생한 컴파일 에러 수정.  
  * 조치: `textStyle` 및 `minTextHeight` 변수 선언을 `InkWell` 빌더 상단으로 이동.

## **2\. '동네 친구' (Find Friends) v2.1 리팩토링 (Job 4-45)**

기존의 전통적인 데이팅 앱('친구/연인 찾기') 기능을 '하이퍼로컬 관심사 기반 대화' 기능으로 전면 개편.

### **2.1. 기획 및 핵심 기능 제거 (Job 4-9, 25-26)**

* **(Job 4, 5\)** 신규 기획(v2.1) 수립:  
  * '연인 찾기(Pacar)' 기능 완전 제거.  
  * '친구 요청/수락' 흐름(Pending/Accepted) 완전 제거.  
  * '즉시 대화 시작' 및 '하이퍼로컬' 정체성 강화로 방향 설정.  
* **(Job 6-9)** 데이팅 기능 코드 제거:  
  * `friend_request_model.dart`, `findfriend_form_screen.dart`, `findfriend_edit_screen.dart` 파일 삭제.  
  * `my_bling_screen.dart` 및 `blocked_users_screen.dart`에서 '친구 요청' 관련 메뉴 및 로직 제거.  
* **(Job 7, 25, 26\)** `user_model.dart` 리팩토링:  
  * `isDatingProfile`, `age`, `ageRange`, `gender` 등 데이팅 관련 필드 삭제/null 처리.  
  * \[버그 수정\] `trustLevel` (int: 정렬용)과 `trustLevelLabel` (String: UI용) 필드를 명확히 분리.  
  * `TrustLevelBadge` 위젯 및 이를 사용하는 모든 파일(7개)의 파라미터를 `String trustLevelLabel`로 수정.

### **2.2. 신규 기능 구현: 즉시 대화 및 안전장치 (Job 10-19, 28-31)**

* **(Job 10, 11\)** '즉시 대화 시작' 구현:  
  * `find_friend_detail_screen.dart`의 FAB 로직을 `startFriendChat` 함수 호출로 변경.  
  * `ChatRoomScreen`의 생성자 변경에 따라 `chatId`를 생성하여 전달하도록 수정.  
* **(Job 15-18)** '24시간 보호 모드' (`chat_room_screen.dart`):  
  * `isNewChat: true` 플래그를 추가.  
  * 보호 모드 활성화 시:  
    * (텍스트) 링크(`http`) 및 전화번호(8자리 이상) 마스킹.  
    * (미디어) 이미지/카메라 전송 버튼 비활성화.  
    * (미디어) 수신된 `CachedNetworkImage`에 `BackdropFilter`를 적용하여 블러(Blur) 처리.  
* **(Job 15\)** '아이스브레이커' (`chat_room_screen.dart`):  
  * `isNewChat: true`이고 메시지가 없을 때, 3개의 추천 질문(`ActionChip`)을 표시하여 대화 유도.  
* **(Job 19\)** `chat_room_screen.dart` 경고 수정 (`_scrollController` 연결, 불필요한 `Container` 제거).  
* **(Job 28-31)** '스팸 방지' (일일 한도):  
  * `functions-v2/index.js`에 `startFriendChat` (onCall) 함수 추가.  
  * `DAILY_CHAT_LIMIT` (5회) 상수 정의.  
  * `users` 컬렉션의 `chatLimits` 필드를 읽어 한도 초과 시 `allow: false` 반환.  
  * `find_friend_detail_screen.dart`가 이 함수를 호출하여 `allow: true`일 때만 채팅방으로 이동하도록 수정.

### **2.3. 신규 기능 구현: UI/UX 및 정렬 (Job 20-27)**

* **(Job 9, 27\)** `findfriend_card.dart` UI 수정:  
  * '나이(age)' 표시를 제거하고 '관심사(interests)' 칩으로 교체.  
  * 닉네임 옆에 `TrustLevelBadge` (텍스트 라벨 포함)가 표시되도록 수정.  
* **(Job 20-25)** '친구' 탭 정렬 로직 구현 (`find_friend_repository.dart`):  
  * `getFindFriendListStream`이 클라이언트(Dart) 측에서 정렬 수행.  
  * 최종 정렬 순서: `neighborhoodVerified` (1순위) \-\> `trustLevel` (2순위) \-\> `interests` (3순위) \-\> `lastActiveAt` (4순위).  
  * (Job 24\) `b.compareTo(a)` (내림차순) 적용을 확인하여 'Trusted' 등급이 'Normal'보다 상위에 표시되도록 보장.

### **2.4. 신규 기능 구현: '모임' 탭 통합 (Job 32-45)**

* **(Job 32-33)** `find_friends_screen.dart` 구조 변경:  
  * `DefaultTabController`를 적용하고 '친구' 탭 / '모임' 탭으로 분리.  
* **(Job 39\)** '모임' 탭 기능 확장:  
  * `club_repository.dart`에 `getClubProposalsByLocationStream` (위치 기반 제안) 함수 추가.  
  * '모임' 탭이 'Active Clubs'와 'Proposals' 2개의 섹션을 모두 렌더링하도록 UI 수정.  
* **(Job 34-44)** \[디버깅\] 'Active Clubs' 리스트가 비어 있고 Firestore 인덱스 링크가 보이지 않는 문제 추적.  
  * 원인: `club_repository.dart`의 `getClubsByLocationStream` 쿼리가 `where`(위치)와 `orderBy`(스폰서)를 동시에 사용하려 했으나, 복합 인덱스가 없어 쿼리가 실패하고 빈 리스트를 반환함.  
* **(Job 45\)** \[임시 조치\]  
  * `find_friends_screen.dart`의 '모임' 탭이 'Active Clubs'를 로드할 때, 인덱스 문제가 해결될 때까지 `getClubsByLocationStream` 대신 `getClubsStream` (위치 필터 없음)을 호출하도록 수정.  
  * 관련 `DevLog` 주석을 코드에 추가.


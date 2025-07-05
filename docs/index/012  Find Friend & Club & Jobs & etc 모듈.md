# 8_05_0. Find_Friend_Policy & To-Do 목록

---

## ✅ Cari Teman (Find Friend) 개요

Bling의 **Find Friend(친구찾기)**는  Kelurahan(Kec.)  인증 기반으로 내 주변 이웃과 안전하게 연결되는  **친구찾기/이웃추천/데이팅 확장형** 기능입니다.

---

## ✅ 핵심 목적

- 내 주변 1~5km 반경 이웃 자동 추천
    
- 관심사, 연령대, 활동 범위 조건 기반 Matching
    
- 팔로우/팔로워 구조 연계
    
- 1:1 채팅으로 대화 연결
    
- 선택적 데이팅 프로필 공개
    

---

## ✅ 주요 흐름

| 기능                     |상태|
| ---------------------- | ----------------- |
| 친구 프로필 페이지             |❌ 기획만 있음|
| 지역 이웃 검색               |❌ 기획만 있음|
| 팔로우/언팔로우               |❌ 미완|
| 1:1 채팅                 |✅ `chats` 컬렉션 재활용|
| Kelurahan(Kec.)  인증 필수 |✔️ 필드 설계 완료|
| 관심사 Tag                |❌ 기획만 있음|
| 연령대 조건                 |❌ 기획만 있음|
| Matching 추천            |❌ 기획만 있음|

---

## ✅ Firestore 구조

|컬렉션|필드|
|---|---|
|`users`|`nickname`, `trustLevel`, `location`, `geoPoint`, `interests[]`, `ageRange`, `isDatingProfile`, `bio`, `profileImageUrl`|
|`follows`|`fromUserId`, `toUserId`, `createdAt`|
|`chats`|기존 구조 사용|

---

## ✅ Matching 추천 로직

- Keluharan(Kec.) 동일 사용자 우선
    
- GEO 반경 1~5km 내 사용자 우선
    
- `interests[]` 관심사 매칭 점수
    
- 연령대 일치 가중치 부여
    
- TrustLevel 높은 사용자 우선 추천
    

---

## ✅ TODO & 개선

1️⃣ 프로필 입력 → `interests[]`, `bio`, `ageRange`  
2️⃣ `follows` 구조 설계  
3️⃣ GEO 쿼리 → 반경 이웃 추천  
4️⃣ Matching 추천 로직 정교화  
5️⃣ `isDatingProfile` 필드 → 선택적 데이팅 프로필 공개  
6️⃣ 1:1 Chat 흐름 연계


-  GEO 반경 1~5km 쿼리 PoC
    
-  `interests[]`, `ageRange` 필드 → Matching 점수 계산 로직
    
-  `follows` 컬렉션 구조 설계 (`fromUserId` → `toUserId`)
    
-  선택적 데이팅 프로필 공개 `isDatingProfile` 로직
    
-  1:1 채팅 흐름 기존 Chat 모듈 재활용
    
-  Matching 추천 화면 UI/UX
    


### 9️⃣ **Chat**

-  공통 `chats` 컬렉션 → Feed, Marketplace, Find Friend, Auction 전 모듈 재사용 검증
    
-  차단/허용 로직 → `blockedUsers` 필드 연계
    
-  메시지 알림 → Notification 모듈 연계
    
-  TrustLevel 조건 메시지 가드(`trusted` 이상)
    

---

### 10️⃣ **Notifications**

-  Firestore 구조 `notifications` 표준화
    
-  RT Pengumuman 연동 흐름 최종 적용
    
-  WhatsApp 공유 CTA
    
-  사용자 알림 설정 ON/OFF (`notificationSettings`)
    
-  읽음 상태 → `readNotifications[]` 로 저장
    
-  중요 알림 → 상단 고정 & FCM 테스트
    

---

### 11️⃣ **Location**

-  Kelurahan(Kec.) DropDown → GEO 연계 쿼리 최종 PoC
    
-  계층형 카테고리(Province ~ RT) 구조 적용
    
-  단계별 축약 Helper (`formatShortLocation()`)
    
-  Privacy Center 옵트인 & 철회 흐름 UI
    

---

### 12️⃣ **User DB & TrustLevel**

-  `users/{uid}` 필드 표준화 (`trustLevel`, `thanksReceived`, `reportCount`)
    
-  신고/차단 흐름 → `reports` + `blockList[]`
    
-  TrustLevel 자동 상향/하향 로직
    
-  프로필 지연 활성화 → `profileCompleted` 동기화
    
-  감사 수(`thanksReceived`) UI & 버튼 흐름
    

---

## ✅ 공통

-  `.json` 다국어 키 QA → `{TODO}` 제거
    
-  Obsidian Vault → 최신 정책 연동 유지
    
-  DevOps → CI/CD 파이프라인 GitHub 연동
    
-  버전별 릴리즈 노트 작성 (`docs/releases/`)
    


---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
- Firestore: `users`, `follows`
---


---


# ✅ 8_05. Bling_Find_Friend_Policy & To-Do 목록 (보완)

## 8_05_1. 필요성 / Purpose

지역 기반으로 새로운 사람과의 연결을 도모하는 가벼운 소셜 기능입니다. Nextdoor와 달리 친구/연인 찾기 전용, Kelurahan 신뢰 기반 연결 구조.

## 8_05_2. 주요 구성 / Key Components

- 프로필: 닉네임, 나이대/성별, GPS 기반 거리, 취미/관심사, 자기소개
    
- 카드 UI: 1~3km 반경 사용자 카드 리스트
    
- 매칭: 채팅 신청 → 수락 시 자동 채팅방 개설 → 거절 시 상대방 화면에서 제외
    
- 안전장치: 하루 채팅 요청 3건 제한, 신고/차단, 전화번호/이메일 인증 뱃지
    

## 8_05_3. 시스템 로직 / System Logic

- FlatList 카드 구성, Haversine 거리 계산
    
- 매칭 Flow: 요청→수락→채팅방 자동 생성 / 거절→상대 제외
    
- 알림: 매칭 성공 시 Push, 관심 횟수/매칭률 통계
    

## 8_05_4. 기술 아키텍처 / Technical Architecture

- Firestore `/users`, `/match_requests`, `/chats`
    
- Flutter: 카드 뷰, 거리 필터
    
- Firebase Auth & Cloud Messaging 연동
    

## 8_05_5. Monetization & Ops

- 기본: 무료 채팅 요청 제한(3회)
    
- 유료: 하트 발송권, 관심 10명 초과 해제권, 인기 사용자 상단 고정권
    
- 운영: AI 허위 프로필 필터, 실명/셀카 인증 선택, 피드백 기반 TrustLevel 강화
    

## 8_05_6. Scalability & Roadmap

- 스와이프 빠른 매칭, 음성 프로필, 그룹 소개, 종교 필터, 결혼모드, "누가 나를 좋아했는지" 기능.
    

## ✅ To-Do

-  하루 요청 3건 제한 로직 적용
    
-  인증 뱃지 UI 연동
    
-  AI 허위 프로필 필터 연계
    
-  관심 횟수/매칭률 통계 표시
    
-  상단 고정/하트 발송 유료 옵션 추가
    
-  확장 기능 스와이프/음성/그룹 매칭 To-Do 추가



![[Pasted image 20250702160859.png]]


---

# ✅ 8_05. Bling_Find_Friend_Policy & Dating_Policy (보완)

## 8_05_11 Friends & Neighbors (이웃/친구찾기)

- `/users` → `PublicProfile`: 닉네임, 지역, 취미, 한줄소개
    
- `/users/{uid}/follows` : 팔로우 리스트
    
- 노출 범위: Kelurahan 반경 1~5km
    
- 공개 설정: 기본 정보만 노출, Privacy On/Off
    

## 8_05_21 Dating (연인찾기)

- `/users` → `MatchProfile`: 성별, 연령대, 이상형, 연애 자기소개, 추가 사진
    
- `/users/{uid}/match_requests` : 관심목록, 매칭요청
    
- 차단/신고: `/users/{uid}/blockList`
    
- 노출 조건: 거리+연령+성별 필터 + MatchProfile 활성화 On
    

## ✅ System Logic

- 연인찾기 프로필은 기본 프로필과 별도로 On/Off 가능
    
- 신고 누적 시 자동 숨김, 허위 필터 AI 연동
    
- 친구찾기와 연인찾기는 데이터 흐름/화면 분리
    

## ✅ To-Do

-  `/users/PublicProfile` / `MatchProfile` 컬렉션 구조 QA
    
-  연인찾기 활성화 On/Off 시나리오 Proof
    
-  신고/차단 상태 필드 설계
    
-  Privacy 설정 UX 시나리오 작성



## ✅ 결론

Cari Teman은 Bling의 **지역 기반 친구찾기 + Matching 추천 + 팔로우 기반 소셜 기능**으로,  
Keluharan(Kec.)인증과 TrustLevel을 통해 안전한 이웃 연결을 지원합니다.




# 8_05_1. 친구 찾기 초기 기획 의도


**

# Find Friends / Cari Teman/Pacar / 친구·연인 찾기

## 8_05_1 필요성 / Purpose

지역 기반으로 새로운 사람들과의 연결을 도모하기 위한 메뉴입니다. 친구 또는 연인을 찾는 가벼운 소셜 기능으로, 기존 데이팅 앱과 달리 지역 친밀감과 안전성을 우선시합니다.

## 8.1.2. 주요 구성 / Key Components

- 프로필 요소:
    

- 닉네임
    
- 나이대/성별
    
- GPS 기반 거리 표시
    
- 취미/관심사 (선택)
    
- 자기소개 문구
    

- 매칭 기능:
    

- 1~3km 이내 사용자 카드 리스트
    
- “채팅 신청하기” 버튼
    
- 수락 시 채팅방 자동 개설
    
- 거절 시 상대방에게 노출되지 않음
    

- 안전 장치:
    

- 하루 채팅 요청 제한 (예: 3건)
    
- 신고/차단 시스템
    
- 전화번호/이메일 인증 뱃지 부여
    

## 8.1.3 핵심 시스템 설명 / System Logic

- 카드 UI 기반 추천 리스트:
    

- FlatList로 사용자 카드 구성
    
- 거리 계산: Haversine 공식 적용
    

- 매칭 플로우:
    

- 채팅 요청 → 수락 → 자동 채팅방 생성
    
- 거절 시 상대방 화면에서 자동 제외
    

- 알림 구조:
    

- 매칭 성공 시 푸시 알림 발송
    
- 관심 받은 횟수, 매칭률 등 통계 제공 가능
    

## 8.1.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /users: 프로필, 위치, 관심사, 인증 정보
    
- /match_requests: 요청 상태(대기/수락/거절)
    
- /chats: 채팅방 정보 및 메시지
    

- 기능 구현:
    

- Flutter: 사용자 카드 뷰 + 거리 필터링
    
- Firebase Firestore: 유저 검색 및 상태 저장
    
- Firebase Auth + Cloud Messaging: 인증 & 알림
    

## 8.1.5 수익 모델 및 운영 계획 / Monetization & Ops

- 기본 이용: 무료 채팅 요청(일일 제한)
    
- 유료 모델 제안:
    

- 관심 상대 10명 초과 → 유료 해제
    
- 하트 발송 시 스팸 회피용 제한 해제권 판매
    
- ‘인기 사용자’ 상단 고정 노출권
    

- 운영 장치:
    

- 허위 프로필 자동 필터링(AI 탐지)
    
- 실명 인증/셀카 인증 유도 (선택사항)
    
- 유저 피드백 기반 자동 등급제 도입 가능
    

## 8.1.6 확장성 및 로드맵 / Scalability & Roadmap

- 향후 기능:
    

- 스와이프 기반 빠른 매칭
    
- 음성 프로필 등록
    
- 그룹 소개 기능 (ex. 같이 운동할 사람 찾기)
    

- 문화적 현지화:
    

- 종교 필터(이슬람, 기독교 등)
    
- 가족/결혼 중심 사용자에게 맞춘 ‘진지한 만남’ 모드 옵션
    
- 소극적 사용자 위해 ‘누가 나를 좋아했는지 보기’ 기능 도입 예정
    

---

친구·연인 찾기 메뉴는 블링 앱에서 가장 빠르게 사용자 유입을 끌 수 있는 “입구 기능”입니다. 과도한 데이팅앱 이미지는 지양하고, 가볍고 안전한 지역 기반 연결 기능으로 설계되었습니다.

**


# 8_06_0. Bling_Club_Policy & To-Do 목록

---

## ✅ Club (동호회/소모임) 개요

Bling Club은 Kelurahan(Kec.) 인증을 기반으로 주민들이  
공통 관심사를 중심으로 **소규모 지역 모임/동호회**를 만들고 운영할 수 있는  
커뮤니티 기능입니다.

---

## ✅ 핵심 목적

- Kelurahan(Kec.)  기반 취미/학습/스포츠/공동구매 등 지역 모임 활성화
    
- 그룹 전용 게시판, 공지, 일정 관리 지원
    
- 그룹 멤버 간 전용 채팅
    
- 사용자(User) 프로필과 직접 연계 → 참여/운영 히스토리 기록
    

---

## ✅ 핵심 흐름

|기능|상태|
|---|---|
|그룹 생성|❌ 기획만 있음|
|그룹 프로필|❌ 기획만 있음|
|멤버 관리|❌ 기획만 있음|
|그룹 게시판|❌ 기획만 있음|
|공지/일정 관리|❌ 기획만 있음|
|그룹 채팅|✅ 기존 Chat 일부 재활용 가능|
|TrustLevel 제한|❌ 구상만 있음|

---

## ✅ Firestore 구조

|컬렉션| 필드                                                                                                                                                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|`clubs`| `title`, `description`, `ownerId` (users/{uid}), `location` (Kelurahan(Kec.) ), `interests[]`, `createdAt`, `membersCount`, `isPrivate`, `trustLevelRequired` |
|`clubs/{clubId}/members`| `userId` (users/{uid}), `joinedAt`                                                                                                                            |
|`clubs/{clubId}/posts`| 그룹 전용 게시판/공지                                                                                                                                                  |
|`users/{uid}/clubs`| 사용자가 참여한 클럽 목록                                                                                                                                                |

## ✅ 📄 clubs  스키마 예시

|필드|설명|
|---|---|
|`clubId: String`||
|`title, description`||
|`ownerId: String`||
|`location, geoPoint`||
|`interests: List<String>`||
|`membersCount: int`||
|`isPrivate: bool`||
|`trustLevelRequired: String`||
|`createdAt: Timestamp`||

---

## ✅ 사용자 연계 흐름

- 사용자가 클럽을 생성하면 `ownerId`에 UID 저장
    
- 참여 시 `clubs/{clubId}/members` + `users/{uid}/clubs` 동시 기록
    
- 탈퇴 시 양쪽에서 모두 삭제
    
- TrustLevel 조건 확인 → 가입 가능 여부 결정
    

---

## ✅ 특징

- Keluharan(Kec.) 위치 기반 → 지역성 강화
    
- TrustLevel 제한 → 인증 사용자만 가입 가능
    
- 관심사 기반 그룹 추천 → `interests[]` 필드 매칭
    
- 그룹 전용 채팅 Room → Chat 모듈 재사용
    

---

## ✅ TODO & 개선

1️⃣ `clubs` + 하위 `members`, `posts` 설계  
2️⃣ `users/{uid}/clubs` 참여/탈퇴 → 연계 구조 확정  
3️⃣ 그룹 생성/가입/탈퇴 UI 흐름  
4️⃣ TrustLevel 가입 조건 로직 구현  
5️⃣ 관심사 기반 추천 로직 개발  
6️⃣ 공지/일정 관리 기능 설계  
7️⃣ 그룹 전용 채팅 연동
    
-  그룹 채팅 Room → 기존 Chat 재사용

---


### 9️⃣ **Chat**

-  공통 `chats` 컬렉션 → Feed, Marketplace, Find Friend, Auction 전 모듈 재사용 검증
    
-  차단/허용 로직 → `blockedUsers` 필드 연계
    
-  메시지 알림 → Notification 모듈 연계
    
-  TrustLevel 조건 메시지 가드(`trusted` 이상)
    

 

---

## ✅ 공통

-  `.json` 다국어 키 QA → `{TODO}` 제거
    

---

# ✅ 8_06. Bling_Club_Policy & To-Do 목록 (보완)

## 8_06_1 필요성 / Purpose

지역 주민이 공통 관심사(취미, 운동, 종교 등)로 모임을 제안/운영. 목표 인원 달성 시 그룹 자동 생성. 지역 기반 커뮤니티 체류시간 극대화.

## 8_06_2 Key Components

- 모임 제안 게시판 (‘함께해요’)
    
- 목표 인원 달성 → Cloud Function으로 `/groups` 자동 생성
    
- 모임명/활동/위치/조건/인원/대표 이미지
    
- 활동 피드, 공지, 자유글, 사진/후기, 건의, 투표
    
- 참여/탈퇴 UI + 참여자 트래킹 + 모임장 권한
    

## 8_06_3 System Logic

- Firestore: `/group_proposals`, `/groups`, `/group_members`
    
- 참여자 수 실시간 체크 → 조건 달성 시 그룹 생성
    
- 참여자 가입 → ‘가입됨’ 상태 + 자동 채팅방 생성
    
- 모임장 권한: 공지/삭제/멤버 관리
    

## 8_06_4 Technical Architecture

- Flutter ListView/GridView 카드 구성
    
- Cloud Function 그룹 자동 생성
    
- 채팅 연계: `/groups/{groupId}/chats`
    

## 8_06_5 Monetization & Ops

- 무료: 기본 게시, 그룹 자동 생성
    
- 유료: 상단 고정 노출, 프로 그룹 배지, 상위 그룹 광고 대상
    
- 운영: 신고, 운영자 승인, 지역 기관 연계 우선 배치
    

## 8_06_6 Scalability & Roadmap

- 추천: 활동 반경 + 카테고리 매칭 로직 설계
    
- 분류 체계: 운동/종교/예술/가족/여성/온라인/게임 등
    
- 문화적 현지화: 종교 커뮤니티, 모터사이클 투어, 모바일 게임 클럽 등
    

## ✅ To-Do

-  참여자 → 채팅방 자동 생성 시퀀스 QA
    
-  추천 알고리즘 로직 문서화
    
-  분류 체계 확장 설계
    
-  문화적 현지화 시나리오 반영

---



## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---

## ✅ 결론

Bling Club은 Keluharan(Kec.) 기반의 **지역 동호회/소모임 허브**로,  
사용자(User) 컬렉션과 직접 연결되어 **참여 기록과 TrustLevel**로  
안전하고 신뢰할 수 있는 커뮤니티를 제공합니다.

---

와이어 프레임 

![[Pasted image 20250702170028.png]]


# 8_06_1. Bling_Club_동네 모임 기획 의도 설명
**

# 8_06_1 Groups / Grup Komunitas / 지역 모임

## 8_06_1.1 필요성 / Purpose

지역 주민들이 취미, 운동, 종교 등 공통 관심사를 중심으로 함께 활동할 수 있는 커뮤니티 그룹을 제안·운영하는 메뉴입니다. 지역 기반 커뮤니케이션의 핵심이자 사용자 체류시간을 극대화할 수 있는 구성입니다.

## 8_06_1.2 주요 구성 / Key Components

- 모임 제안 게시판 (‘함께해요’)
    

- 누구나 모임 아이디어 게시 가능
    
- 예: 자카르타 조깅, 수공예, 요가 모임 등
    

- 그룹 자동 생성 구조
    

- 게시물 목표 인원 도달 시 (예: 10명)
    
- 별도 그룹 게시판 자동 생성 → 활동 피드 + 회원 글 + 공지
    

- 기본 정보 입력 항목
    

- 모임명 / 활동 내용 / 위치 / 참여 조건 / 필요 인원 / 대표 이미지
    

- 활동 기능:
    

- 활동 소식, 사진/후기 업로드
    
- 회원 자유게시, 건의, 투표 등
    
- 참여/탈퇴 버튼
    

## 8_06_1.3 핵심 시스템 설명 / System Logic

- 인원수 트래킹: Firestore 기준 참여 수 체크
    
- 그룹 게시판 자동 생성: Cloud Function으로 조건 달성 시 /groups 하위에 게시판 생성
    
- 모임장 권한 관리: 그룹 개설자에게 공지/삭제/멤버 관리 권한 제공
    
- 참여 UI: 참여자 → ‘가입됨’ 상태 변경 → 활동 접근 권한 자동 활성화
    

## 8_06_1.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /group_proposals: 제안 모임
    
- /groups: 실제 생성된 활동 그룹
    
- /group_members: 참여자 목록
    

- 기능 구현:
    

- Flutter ListView + GridView 활용 그룹 카드 구성
    
- Firestore 실시간 참여수 반영
    
- 가입 → 알림 및 자동 채팅방 생성 가능
    

## 8_06_1.5 수익 모델 및 운영 계획 / Monetization & Ops

- 기본 이용: 무료 게시 / 그룹 자동 생성
    
- 유료 모델 제안:
    

- 상단 고정 노출 (제안 게시물 / 인기 그룹)
    
- 프로 그룹 배지 부여 (검증된 모임장)
    
- 활동량 기준 상위 그룹 → 지역 광고 대상화
    

- 운영 방안:
    

- 신고 기능 + 운영자 수동 승인 가능
    
- 지역 기관/단체와 연계된 모임 우선 배치 가능
    

## 8_06_1.6 확장성 및 로드맵 / Scalability & Roadmap

- 추천 기능:
    

- 사용자의 활동 반경 기반으로 모임 추천
    
- 인기도 + 카테고리 매칭 기반 추천 알고리즘 도입 예정
    

- 분류 체계 확대:
    

- 운동 / 종교 / 온라인 / 예술 / 가족 / 여성 소모임 등 테마 분류
    

- 문화적 최적화:
    

- 종교 기반 모임(이슬람 커뮤니티 등)
    
- 오토바이·사이클 투어 / 모바일 게임 클럽 등
    

---

지역 모임 메뉴는 단순한 게시판이 아닌, 자발적 커뮤니티 생성 기능이 내장된 확장형 플랫폼입니다. 이 기능은 사용자의 앱 체류 시간을 늘리고, 향후 커뮤니티 광고나 로컬 협업 사업의 중심 허브가 될 수 있습니다.

**


# 8_07_0. Bling_Jobs_Policy & To-Do 목록

---

## ✅ Jobs (지역 구인구직) 개요

Bling의 **Jobs (Lowongan)**는  
Kelurahan(Kec.)  기반으로 이웃 간 소규모 알바, 채용, 소상공인 구인 공고를  
안전하게 공유할 수 있는 **지역 구인구직 허브**입니다.

---

## ✅ 핵심 목적

- Keluharan(Kec.) 인증으로 신뢰성 있는 채용/지원 구조
    
- TrustLevel로 허위 공고 방지
    
- 구인자-지원자 간 1:1 채팅
    
- 사용자(User) 컬렉션과 구인/지원 기록 연계
    

---

## ✅ 주요 흐름

|기능|상태|
|---|---|
|구인 글 작성|❌ 기획만 있음|
|직종 카테고리|✅ 일부 설계 완료|
|상세보기|❌ 미완|
|지원자 관리|❌ 기획만 있음|
|채팅 연결|✅ `chats` 컬렉션 재활용 가능|
|TrustLevel 제한|❌ 기획만 있음|
|유료 공고|❌ 아이디어만 있음|

---

## ✅ Firestore 구조

|컬렉션| 필드                                                                                                                                                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|`jobs`| `title`, `description`, `category` (직종/업종), `location` (Kelurahan(Kec.) ), `geoPoint`, `createdAt`, `userId` (users/{uid}), `trustLevelRequired`, `viewsCount`, `likesCount`, `isPaidListing` |
|`users/{uid}/jobs`| 사용자가 작성한 구인 공고 기록                                                                                                                                                                             |
|`chats`| 지원자/채용자 문의 채널                                                                                                                                                                                 |

---

## ✅ 사용자 연계 흐름

- 작성자 `userId` → `users/{uid}` 연결
    
- 지원자 문의 → `chats` 컬렉션 저장
    
- 작성자 히스토리 → `users/{uid}/jobs` 기록
    

---

## ✅ 특징

- Keluharan(Kec.) 인증 필수 → 지역성 보장
    
- TrustLevel 제한 옵션 → 허위 공고 차단
    
- 직종별 카테고리 필터 제공
    
- GEO 기반 반경 검색 (Kelurahan(Kec.)  ~ Kecamatan ~ Kabupaten)
    
- 유료 상단 공고 옵션 (수익화 가능성)
    

---

## ✅ TODO & 개선

1️⃣ `jobs` 컬렉션 설계 + 인덱스   → 직종 카테고리 필드 확정
2️⃣ `users/{uid}/jobs` 연계,  히스토리 연계
3️⃣ TrustLevel 조건 검증 로직    → 허위 공고 방지
4️⃣ 채팅 연결 흐름 구축  
5️⃣ 직종 카테고리/필터 UI 설계  
6️⃣ 유료 공고 로직 기획  → 유료 상단 공고 옵션 아이디어 확정
    
-  지원자-채용자 1:1 채팅 연결
    
-  공통 `chats` 컬렉션 → Feed, Marketplace, Find Friend, Auction 전 모듈 재사용 검증
    
-  차단/허용 로직 → `blockedUsers` 필드 연계
    
-  메시지 알림 → Notification 모듈 연계
    
-  TrustLevel 조건 메시지 가드(`trusted` 이상)
---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---


# ✅ 8_07. Bling_Jobs_Policy & To-Do 목록 (보완)

## 8_07.1 필요성 / Purpose

지역 내 소규모 채용, 단기 일자리, 주민 간 ‘Help Me’ 요청까지 매칭하는 지역 기반 마이크로 고용 플랫폼.

## 8_07.2 주요 구성 / Key Components

- 구인: 파트타임/단기/장기
    
- 구직: 기술/경험 기반 제안
    
- 게시 필드: 제목, 고용형태, 업체명, 위치, 시간, 임금, 연락처, 마감일
    
- ‘Help Me’ 1회성 요청 포함
    

## 8_07.3 System Logic

- 구인/구직 이중 탭 UI
    
- 카테고리 & 위치 필터
    
- 지원/문의 → 자동 채팅
    
- 관리자 승인 없이 자동 게시, 스팸 필터 존재
    

## 8_07.4 Technical Architecture

- Firestore: `/job_posts`, `/applications` (지원자 리스트, 상태)
    
- `/users`: 지원 내역, 후기, 알림 설정
    
- Flutter TabView, 위치 필터, 정렬
    

## 8_07.5 Monetization & Ops

- 무료: 기본 등록 3개월 1회, 리스트 노출
    
- 유료: 상단 고정, 급구 라벨, Help Me 배너 강조, 추천 인재 상단 노출
    
- 운영: 자동 리뷰 요청, 신고 기반 필터, ChatGPT 이력서 도우미
    

## 8_07.6 Scalability & 경쟁사 비교

- 향후: 채용 완료 표시, ‘내 지원 내역’ 관리, AI 이력서 생성
    
- 비교: 당근마켓(지역성) + 알바천국(전문성) 융합 → 블링 고유성 강조
    

## ✅ To-Do

-  Help Me 요청 강조 배너 흐름 설계
    
-  Applications 컬렉션 상세 필드 설계
    
-  관리자 승인 X + 스팸 필터 로직 명시
    
-  상단 고정/추천 인재 유료 옵션 QA
    
-  ChatGPT 이력서 도우미 기능 Proof 작성



## ✅ 결론

Bling Jobs는 Kelurahan(Kec.) 기반으로 운영되는  
**지역 구인구직/알바 허브**로, 사용자 신뢰등급과 채팅,  
위치 기반 구조를 연계해 안전하고 실효성 높은 채용 플랫폼을 지향합니다.


![[Pasted image 20250702163012.png]]


# 8_07_1. Job 피드 초기 기획 의도
**

# 8_07.0 Local Jobs / Pekerjaan Lokal / 동네 구인구직

## 8_07.1 필요성 / Purpose

지역 내의 소규모 채용과 단기 일자리, 그리고 주민 간 도움 요청을 원활히 연결하기 위한 기능입니다. 인도네시아 시장 특성상 비정규/일회성 업무 수요가 높으며, 블링은 이를 커뮤니티 기반으로 매칭하는 구조를 제안합니다.

## 8_07.2 주요 구성 / Key Components

- 게시 유형:
    

- 구인: 파트타임, 단기, 장기 근무 요청
    
- 구직: 본인의 기술/경험을 활용한 업무 제안
    

- 구인 게시 필드:
    

- 제목 / 고용형태 (단기/장기/파트타임)
    
- 업체명 (선택)
    
- 근무 위치 / 시간 / 조건
    
- 임금 (예: 시급 50,000 IDR)
    
- 연락 방법 (전화, 이메일, WhatsApp)
    
- 모집 마감일
    
- ‘도와주세요’ 게시물 (청소, 설치 등 1회성 요청)
    

- 구직 게시 필드:
    

- 기술 카테고리 (예: 청소, 번역, 웹디자인)
    
- 자기소개 / 희망 임금 / 가능 시간 / 위치
    
- 연락 수단
    

## 8_07.3 핵심 시스템 설명 / System Logic

- 구인/구직 이중 탭 UI 제공
    
- 카테고리별 필터 및 위치 기반 검색
    
- 지원/문의 버튼 → 채팅 자동 연결
    
- 관리자 승인 없는 자동 게시 구조, 단 스팸 필터 존재
    

## 8_07.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /job_posts: 구인·구직 통합 게시물
    
- /users: 지원 내역, 후기, 알림 설정
    
- /applications: 지원자 목록 및 상태
    

- 기능 구현:
    

- Flutter TabView: 구인/구직 탭 구성
    
- 위치 기반 필터, 정렬 옵션 포함
    
- Firebase Storage + Firestore
    

## 8_07.5 수익 모델 및 운영 계획 / Monetization & Ops

- 무료 기능:
    

- 기본 등록 3개월당 1회 (초기 제한)
    
- 일반 게시물 리스트 노출
    

- 유료 기능 제안:
    

- 상단 고정 노출 (15일, 30일)
    
- ‘급구’ 강조 라벨 부여
    
- Help Me 게시물 배너 강조
    
- 추천 인재 리스트 상단 노출 (구직자)
    

- 운영 고려사항:
    

- 사용자 후기 및 신고 기반 필터 강화
    
- 자동 리뷰 요청 / 거래 이력 반영
    

## 8_07.6 확장성 및 로드맵 / Scalability & Roadmap

- 향후 기능:
    

- 채용 완료 표시 기능
    
- 블링 내 ‘내 지원 내역’ 관리 탭
    
- ChatGPT 기반 ‘이력서 도우미’ 기능 (자기소개 생성)
    

- 경쟁사 비교:
    

- 당근마켓: 지역성 강하지만 알바 분리 미흡
    
- 알바천국: 직군 분류 전문성 있지만 지역친화성 낮음
    
- 블링: 지역성 + 간편성 + 유연성 융합 구조 제안
    

---

Local Jobs 메뉴는 단순한 아르바이트 매칭이 아니라, 지역 내 마이크로 고용시장을 커버하는 ’커뮤니티 고용 플랫폼’입니다. 특히 Help Me 요청은 당근마켓에서도 시도하지 않은 틈새 전략입니다.

**


# 8_08_0. Bling_LocalShops_Policy & To-Do 목록

---

## ✅ Local Shops (지역 상점) 개요

Bling의 **Local Shops (Toko Lokal)**는  
Kelurahan(Kec.)  기반으로 지역 소상공인과 주민을 연결하는  
**동네 상점 정보 허브**입니다.

---

## ✅ 핵심 목적

- Keluharan(Kec.) 기반 상점 정보 노출
    
- 주민에게 위치, 운영시간, 연락처, 간단한 제품 정보 제공
    
- 상점 문의/채팅/리뷰/추천 기능 포함
    
- TrustLevel로 상점 인증 마크 부여 가능
    

---

## ✅ 주요 흐름

| 기능                 |상태|
| ------------------ | -------------------- |
| 상점 등록              |❌ 기획만 있음|
| 상점 프로필             |❌ 기획만 있음|
| 제품 리스트             |❌ 기획만 있음|
| 리뷰/평점              |❌ 기획만 있음|
| 상점 문의 채팅           |✅ `chats` 컬렉션 재활용 가능|
| Keluharan(Kec.) 인증 |❌ 구상만 있음|
| 신뢰/인증마크            |❌ 아이디어만 있음|

---

## ✅ Firestore 구조

|컬렉션| 필드                                                                                                                                                                                                              |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|`shops`| `name`, `description`, `ownerId` (users/{uid}), `location` (Keluharan(Kec.)), `geoPoint`, `products[]` (간단 제품 리스트), `contactNumber`, `openHours`, `trustLevelVerified`, `createdAt`, `viewsCount`, `likesCount` |
|`shops/{shopId}/reviews`| `userId` (users/{uid}), `rating`, `comment`, `createdAt`                                                                                                                                                        |
|`users/{uid}/shops`| 사용자가 소유한 상점 목록                                                                                                                                                                                                  |
|`chats`| 상점 관리자와 1:1 문의 채널                                                                                                                                                                                               |

## ✅ 📄 shops 스키마 예시

| 필드                            | 설명               |
| ----------------------------- | ---------------- |
| `shopId: String`              |                  |
| `name, description`           |                  |
| `ownerId: String`             |                  |
| `location, geoPoint`          | Kelurahan(Kec.)  |
| `products: List<Map>`         | 간단 제품 리스트        |
| `contactNumber: String`       |                  |
| `openHours: String`           |                  |
| `trustLevelVerified: bool`    |                  |
| `viewsCount, likesCount: int` |                  |
| `createdAt: Timestamp`        |                  |

---

## ✅ 사용자 연계 흐름

- 상점 `ownerId` → `users/{uid}` 연결
    
- `users/{uid}/shops` → 사용자가 가진 상점 리스트
    
- 리뷰 작성자 `userId` → `users/{uid}`
    
- 문의 채팅 → `chats` 컬렉션 연동
    

---

## ✅ 특징

- Keluharan(Kec.) 필드 기반 상점 노출
    
- TrustLevel 인증 상점 필터 제공
    
- 리뷰/평점 기반 신뢰 구조
    
- 간단 제품 리스트 → Marketplace 연계 가능
    

---

## ✅ TODO & 개선

1️⃣ `shops` 컬렉션 + `reviews` 설계  
2️⃣ `users/{uid}/shops` 연계  
3️⃣ 위치 필드 표준화  
4️⃣ TrustLevel 인증 상점 로직 → 인증 뱃지 표시 
5️⃣ 제품 리스트 → Marketplace 연계 여부 결정  
6️⃣ 상점 문의 Chat 흐름 확정


-  리뷰/평점 모듈 설계
        
-  지도 기반 상점 노출 정밀 테스트
    
---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    
---
# ✅ 8_08. Bling_LocalShops_Policy & To-Do 목록 (보완)

## 8_08.1 필요성 / Purpose

지역 소상공인을 연결하는 홍보 & 커뮤니티 플랫폼. 사용자와 가까운 가게 정보 제공 + 광고 수익화 핵심.

## 8_08.2 주요 구성 / Key Components

- 가게 등록: 사업자 등록 여부 무관, Verified Badge
    
- 필수 필드: 가게명, 위치, 업종, 연락처, 운영시간, 사진, 설명
    
- 업종: 음식점/카페/마사지/미용/네일/정비/키즈/병원/기타
    
- 반경 필터(1~10km) + 카테고리 리스트 + ‘우리동네 핫플’ 자동 노출
    

## 8_08.3 System Logic

- 위치 기반 거리순 정렬
    
- 가게 카드: 썸네일, 이름, 평점, 운영시간, 거리
    
- 리뷰/별점: 승인 후 공개, 많은순 정렬
    
- 추천 알고리즘: 인기순+리뷰점수+거리+광고 가중치
    

## 8_08.4 Technical Architecture

- Firestore: `/shops`, `/reviews`, `/ads`
    
- `/shops/{shopId}/chats`: 전용 고객응대 채팅
    
- Flutter 지도 연동 + ListView
    
- Cloud Function: 광고 기간/우선순위 관리
    

## 8_08.5 Monetization & Ops

- 무료: 기본 등록 1개월
    
- 유료: 상단 고정, 근거리 우선, 스폰서 라벨, 광고 성과 리포트(KPI)
    
- 동네 홍보대사 제도: 인증 유저가 가게 등록, Verified Badge
    
- POS 연동, 배달 플랫폼 연동 로드맵 포함
    

## 8_08.6 Scalability & Roadmap

- 광고 리포트 대시보드 (클릭수, 도달수, 리뷰전환)
    
- 가게 프로필 커스터마이징: 메뉴판, 사진첩
    
- AI 추천 + 사용자 취향 자동 푸시
    
- 가게 전용 채팅 시스템
    

## ✅ To-Do

-  리뷰 승인/정렬 로직 QA
    
-  추천 알고리즘 수식 정의
    
-  광고 성과 리포트 대시보드 설계
    
-  가게 프로필 메뉴판/사진첩 설계
    
-  POS/배달 API 연동 Proof
    
-  AI 추천 자동 푸시 시나리오
    
-  `/shops/{shopId}/chats` 구조 QA



---

## ✅ 결론

Bling Local Shops는 Kelurahan(Kec.) 기반으로 운영되는  
**지역 소상공인 연결 허브**로, 주민과 상점의 신뢰를 기반으로  
안전하고 효율적인 로컬 커머스를 지원합니다.



![[Pasted image 20250702163920.png]]




# 8_08_1. Local Shops 기획 의도 설명
**

# 8_08_1 Nearby Shops / Toko Sekitar / 우리동네 가게

## 8_08_1 필요성 / Purpose

지역 소상공인을 위한 홍보 플랫폼으로, 사용자와 물리적으로 가까운 가게/서비스를 소개하는 메뉴입니다. 블링 커뮤니티와 지역 경제를 연결하며, 광고 수익화의 핵심 축을 담당합니다.

## 8_08_2 주요 구성 / Key Components

- 가게 등록 구조:
    

- 사업자 등록 여부와 관계없이 등록 가능
    
- 필수 정보: 가게명 / 위치 / 업종 / 연락처 / 운영시간 / 사진 / 간단 설명
    

- 업종 분류:
    

- 음식점 / 카페 / 마사지 / 미용 / 네일샵 / 정비 / 키즈 / 병원 / 기타
    
- 필터 및 검색 기능 제공
    

- 노출 방식:
    

- 사용자 위치 기반 반경 필터 (1~10km)
    
- 카테고리별 리스트 + 홈화면 요약 노출
    
- ‘우리동네 핫플’ 섹션에 인기 가게 자동 노출
    

## 8_08_3 핵심 시스템 설명 / System Logic

- 가게 위치 기반 정렬: 사용자 GPS 기준 거리순 정렬
    
- 가게 정보 카드: 썸네일, 이름, 평점, 운영시간, 거리 표시
    
- 사용자 리뷰/별점 기능 내장:
    

- 리뷰 승인 후 공개
    
- 리뷰 많은 순 정렬 옵션 제공
    

- 추천 알고리즘:
    

- 인기순 / 리뷰점수 / 거리 / 유료 광고 우선순위 조합
    

## 8_08_4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /shops: 가게 기본 정보
    
- /reviews: 사용자 리뷰
    
- /ads: 유료 노출 정보 (기간, 유형)
    

- 기능 구현:
    

- Flutter 지도 연동 + ListView 병렬 표시
    
- Firestore 저장 + Cloud Function으로 광고 기간 체크
    

## 8_08_5 수익 모델 및 운영 계획 / Monetization & Ops

- 기본 등록: 무료 (최초 1개월)
    
- 유료 광고 상품:
    

- 상단 고정 (기간제)
    
- 근거리 사용자 우선 노출
    
- ‘스폰서 가게’ 라벨 부여
    

- 운영 주체:
    

- 동네 홍보대사 제도 운영 가능 (인증 유저가 직접 가게 등록)
    
- 사업자 인증 시 Verified Badge 부여
    

## 8_08_6 확장성 및 로드맵 / Scalability & Roadmap

- 향후 기능:
    

- 광고 성과 리포트 대시보드 (클릭수, 도달수, 리뷰 전환율 등)
    
- 가게 프로필 페이지 커스터마이징 (메뉴판, 후기 사진첩 등)
    

- B2B 제휴:
    

- POS 연동 / 로컬 배달 플랫폼 연동
    
- 가게 전용 채팅 고객 응대 시스템
    

- AI 활용:
    

- ‘내가 갈 만한 가게 추천’ 기능
    
- 사용자 취향 기반 자동 푸시 알림
    

---

Nearby Shops 메뉴는 블링의 지역 광고 수익의 핵심이며, 사용자에게 실질적 생활 정보도 제공합니다. 단순 디렉토리보다 진화된 ‘지역 가게 미니페이지 + 리뷰 + 프로모션’ 구조로 발전시킬 수 있습니다.

**


# 8_09_0. Bling_Auction_Policy & To-Do 목록

---

## ✅ Auction (경매) 개요

Bling의 **Auction (Lelang)**은  Kelurahan(Kec.)  인증과 TrustLevel, AI 검수를 결합해  
레어 아이템이나 고가 상품을 안전하게 거래할 수 있는  **지역 기반 경매 허브**입니다.

---

## ✅ 핵심 목적

- Keluharan(Kec.) 인증으로 지역성 보장
    
- TrustLevel과 AI 검수로 안전한 고가 거래 지원
    
- 실시간 입찰, 마감, 낙찰자 자동 처리
    
- 판매자와 입찰자 간 1:1 문의 채팅
    

---

## ✅ 주요 흐름

| 기능             | 상태                   |
| -------------- | -------------------- |
| 경매 상품 등록       | ❌ 기획만 있음             |
| 입찰 시스템         | ❌ 기획만 있음             |
| 낙찰자 결정         | ❌ 기획만 있음             |
| 실시간 입찰 내역      | ❌ 기획만 있음             |
| 판매자 TrustLevel | ❌ 아이디어 단계            |
| AI 검수          | ❌ 필드 설계만 완료          |
| 1:1 채팅         | ✅ `chats` 컬렉션 재활용 가능 |

---

## ✅ Firestore 구조

| 컬렉션                         | 필드                                                                                                                                                                                                          |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `auctions`                  | `title`, `description`, `images[]`, `startPrice`, `currentBid`, `bidHistory[]`, `location` (Keluharan(Kec.)), `geoPoint`, `startAt`, `endAt`, `ownerId` (users/{uid}), `trustLevelVerified`, `isAiVerified` |
| `auctions/{auctionId}/bids` | `userId` (users/{uid}), `bidAmount`, `bidTime`                                                                                                                                                              |
| `users/{uid}/auctions`      | 사용자 등록/참여 기록                                                                                                                                                                                                |
| `chats`                     | 판매자-입찰자 문의 채널                                                                                                                                                                                               |

## ✅ 📄 auctions db 스키마 예시

| 필드                          | 설명              |
| --------------------------- | --------------- |
| `auctionId: String`         |                 |
| `title, description`        |                 |
| `images: List<String>`      |                 |
| `startPrice: int`           |                 |
| `currentBid: int`           |                 |
| `bidHistory: List<Map>`     |                 |
| `ownerId: String`           | 판매자 UID         |
| `location, geoPoint`        | Keluharan(Kec.) |
| `trustLevelVerified: bool`  |                 |
| `isAiVerified: bool`        |                 |
| `startAt, endAt: Timestamp` |                 |
|                             |                 |

---

## ✅ 사용자 연계 흐름

- 판매자 `ownerId` → `users/{uid}` 연결
    
- 입찰자 `userId` → `users/{uid}` 연계
    
- 사용자 경매 히스토리 → `users/{uid}/auctions` 기록
    
- 문의 채팅 → `chats` 컬렉션 연동
    

---

## ✅ 특징

- Kelurahan(Kec.)  인증 판매자만 경매 등록 가능
    
- TrustLevel 제한 → 고신뢰 사용자만 입찰 허용
    
- AI 검수 → 상품 품질, 허위 여부 필터링
    
- 실시간 입찰 반영 & 자동 낙찰
    
- 결제/보증 연계 모듈 확장 가능성
    

---

## ✅ TODO & 개선

1️⃣ `auctions` + `bids` 구조 설계  
2️⃣ `users/{uid}/auctions` 연계  
3️⃣ 입찰 로직 → `bidAmount`, `bidHistory` 설계  
4️⃣ AI 검수 흐름 → `isAiVerified` 필드 적용  
5️⃣ TrustLevel 조건 로직 확정  - 판매자 TrustLevel 제한 로직
6️⃣ Chat 흐름 연계  - 경매 낙찰 → Chat + 결제 흐름 연계
7️⃣ 결제/보증 로직 기획

    
-  실시간 입찰 내역 UI → 실시간 업데이트 테스트

---

# ✅ 8_09. Bling_Auction_Policy & To-Do 목록 (보완)

## 8_09_1 필요성 / Purpose

희귀 물품/레어템/한정판 거래에 최적화된 경매 메뉴. AI 검수 + 에스크로로 안전 보장.

## 8_09_2 Key Components

- 경매 대상: AI 검수 희귀품, 컬렉터 아이템, 한정판 Pre-Loved
    
- 시작가: AI 자동 제안 or 판매자 지정
    
- 최소 입찰 단위 설정
    
- 제한 시간형 경매 (3~7일)
    
- 미입금 → 차순위 낙찰자 or 자동 연장
    
- 일반 등록 → ‘AI 검수 + 경매’ 선택 모드 활성화
    

## 8_09_3 System Logic

- Firestore + Cloud Function → 입찰 실시간 순위/중복 입찰자 알림
    
- 마감 후 자동 에스크로 잠금 → 인수 후 정산
    
- 입찰 내역 투명 공개 UI: 입찰자/금액/순위 표시
    

## 8_09_4 Technical Architecture

- DB: `/auction_items`, `/bids`, `/transactions`
    
- Flutter: 남은 시간, 현재가, 내 입찰가
    
- Firebase Function: 마감 타이머, 우선순위 판정, 자동 연장 처리
    

## 8_09_5 Monetization & Ops

- 등록 수수료 (예: 5,000 IDR)
    
- 낙찰 수수료 (낙찰가 5%)
    
- 상단 고정, 스폰서 경매 노출권
    
- 운영: 판매자 신원 인증, 반복 미입금 사용자 제재, 신고 기능
    

## 8_09_6 Scalability & Roadmap

- 추가: 영상 리뷰, 블라인드 경매(입찰가 비공개)
    
- 유사상품 추천: 입찰 실패 시 알림 기반 추천
    
- 오늘의 인기 경매 자동 추천 + 인플루언서 콜라보 경매
    

## ✅ To-Do

-  미입금 → 차순위 낙찰/자동 연장 로직 QA
    
-  일반 등록폼 → ‘AI 검수 + 경매’ 선택 UX 흐름 정리
    
-  중복 입찰자 푸시 알림 트리거 상세화
    
-  입찰 내역 투명 공개 UI 설계
    
-  영상 리뷰/블라인드 경매 Proof 작성
    
-  유사상품 추천 로직 Proof
    
-  인기 경매/콜라보 운영 가이드 작성

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[21. Bling](https://chatgpt.com/g/g-p-6857c4d4483c81918d998fb59ce040cf-bling-peurojegteu/c/685bb329-5ca8-800a-94f7-d18df30d0b65)]()


# 8_09_1. 블링 옥션 기획의도 설명
**

# 8_09_1. Bling Auction / Lelang Premium / 블링 경매  
(블링 9번째 메뉴임)

## 8_09_1.1 필요성 / Purpose

희귀 물품(레어 피규어, 한정판 신발, 빈티지 컬렉션 등)은 일반 중고거래 구조보다 경매 방식이 더 적합합니다. Bling은 기존의 AI 검수 시스템과 에스크로 결제를 활용하여, 신뢰 기반 프리미엄 경매 기능을 제공합니다.

## 8_09_1.2 주요 구성 / Key Components

- 경매 대상:
    

- AI 감수된 희귀물품 / 컬렉터 아이템 / 한정판 Pre-Loved 상품
    

- 경매 방식:
    

- AI 시작가 자동 제안 or 판매자 지정
    
- 최소 입찰 단위 설정 가능 (예: 10,000 IDR)
    
- 제한 시간형 경매 (예: 3일, 5일, 7일)
    

- 낙찰 프로세스:
    

- 마감 시 최고가 입찰자 낙찰
    
- 낙찰 후 24시간 이내 입금 (예약금 구조)
    
- 입금 없을 경우: 차순위 낙찰자 or 경매 자동 연장 가능
    

## 8_09_1.3 핵심 시스템 설명 / System Logic

- 게시 흐름:
    

- 일반 중고 등록 → “AI 검수 + 경매 선택” 시 경매 모드 활성화
    

- 입찰 처리:
    

- Firestore + Cloud Function으로 입찰 순위 실시간 갱신
    
- 중복 입찰자 알림, 푸시 전송 등 지원
    

- 결제 구조:
    

- 낙찰 시 자동 에스크로 잠금 → 인수 후 정산
    

## 8_09_1.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /auction_items: 경매 전용 게시글
    
- /bids: 입찰 기록, 입찰자 ID, 시간, 금액
    
- /transactions: 예약금, 낙찰 처리, 거래 완료 상태
    

- 기능 구현:
    

- Flutter UI: 남은 시간, 현재가, 내 입찰가 표시
    
- Firebase Function: 경매 마감 타이머, 입찰 우선순위 판정
    

## 8_09_1.5 수익 모델 및 운영 계획 / Monetization & Ops

- 수익 모델:
    

- 경매 등록 수수료 (예: 5,000 IDR)
    
- 낙찰 시 수수료 (예: 낙찰가의 5%)
    
- 상단 고정/스폰서 경매 상품 노출권
    

- 운영 방안:
    

- 고가 제품은 판매자 신원 인증 필요
    
- 반복 미입금/낙찰 파기 사용자 제재 시스템 구축
    
- 신고 기능 + 입찰 내역 기록 투명 공개
    

## 8_09_1.6 확장성 및 로드맵 / Scalability & Roadmap

- 추가 기능 제안:
    

- 영상 리뷰 첨부 / 블라인드 경매 옵션 (입찰가 비공개)
    
- 프리미엄 레어템 전용 탭 신설 (레고, 나이키, 빈티지 등)
    
- 입찰 실패 시 알림 기반 유사상품 추천
    

- 마케팅 전략:
    

- ‘오늘의 인기 경매’ 자동 추천
    
- 인플루언서 콜라보 경매 (예: 한정판 신발, 셀럽 기증품)
    

---

Bling Auction은 기존 중고거래 신뢰성 문제를 AI 기술로 보완하면서, 수요가 높은 프리미엄 아이템 거래에 대한 새로운 해법을 제시합니다. 감정 기반 경매 구조는 블링의 차별성과 수익성을 동시에 강화하는 강력한 확장 메뉴입니다.

**

### 와이어 프레임

![[Pasted image 20250702172913.png]]


# 8_10. Bling_POM_Policy & To-Do 목록

---

## ✅ POM (짧은 영상/쇼츠) 개요

Bling의 **POM (Piece of Moment)**은  
Kelurahan(Kec.)  기반으로 유저가 짧은 영상(쇼츠)을 올려  
웃음, 정보, 지역 이야기를 공유할 수 있는  
**지역형 TikTok/Shorts 허브**입니다.

---

## ✅ 핵심 목적

- Kelurahan(Kec.) 인증 사용자 중심 지역 쇼츠 플랫폼
    
- 지역 해시태그/위치 기반 트렌딩
    
- 좋아요, 댓글, 공유로 빠른 확산
    
- TrustLevel과 AI 검수로 부적절 콘텐츠 방지
    

---

## ✅ 주요 흐름

| 기능                  |상태|
| ------------------- | ---------------- |
| 쇼츠 업로드              |❌ 기획만 있음|
| Kelurahan(Kec.)  태그 |❌ 기획만 있음|
| 지역 트렌딩              |❌ 기획만 있음|
| 좋아요/댓글              |✅ Feed 구조 재활용|
| 조회수                 |✅ Post 필드 일부 재활용|
| 공유                  |❌ 기획만 있음|
| TrustLevel 제한       |❌ 설계만 있음|
| AI 검수               |❌ 필드만 존재|

---

## ✅ Firestore 구조

| 컬렉션                         | 필드                                                                                                                                                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `shorts`                    | `title`, `videoUrl`, `thumbnailUrl`, `description`, `location` (Keluharan(Kec.)), `geoPoint`, `tags[]`, `likesCount`, `viewsCount`, `userId` (users/{uid}), `trustLevelVerified`, `isAiVerified`, `createdAt` |
| `shorts/{shortId}/comments` | `userId` (users/{uid}), `body`, `createdAt`                                                                                                                                                                   |
| `users/{uid}/shorts`        | 사용자 업로드 기록                                                                                                                                                                                                    |

## ✅ 📄 shorts (POM)   스키마 예시

|필드|설명|
|---|---|
|`shortId: String`||
|`userId: String`||
|`title, description`||
|`videoUrl, thumbnailUrl`||
|`tags: List<String>`||
|`location, geoPoint`||
|`likesCount, viewsCount`||
|`trustLevelVerified, isAiVerified: bool`||
|`createdAt: Timestamp`||

---

## ✅ 사용자 연계 흐름

- `userId` → `users/{uid}` 연결
    
- 댓글 작성자 `userId` → `users/{uid}`
    
- `users/{uid}/shorts` → 업로드 기록 관리
    
- TrustLevel로 업로드 자격 제한
    
- AI 검수 → 부적절 영상 자동 필터링
    

---

## ✅ 특징

- Keluharan(Kec.) 태그로 지역성 유지
    
- AI 모자이크/필터링 → 음란/혐오 차단
    
- 좋아요/댓글 → Feed 구조와 동일
    
- 공유 → WhatsApp 등 외부 확산
    

---

## ✅ TODO & 개선

1️⃣ `shorts` + `comments` 구조 설계  
2️⃣ `users/{uid}/shorts` 연계  
3️⃣ TrustLevel 업로드 제한 로직 구현  
4️⃣ AI 검수 모듈 연계   → 부적절 콘텐츠 자동 필터링
5️⃣ 지역 트렌딩 로직 설계  
6️⃣ 외부 공유 모듈 기획 - WhatsApp 공유 모듈 연계

-  조회수(`viewsCount`) 필드 → 실시간 증가 테스트
    



---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---

## ✅ 결론

Bling POM은 Kelurahan(Kec.)  기반의 **지역형 쇼츠 허브**로,  
짧은 영상으로 지역성과 커뮤니티를 동시에 확장하며,  
AI 검수와 TrustLevel로 안전성을 보장합니다.


# 8_11_0. Bling_Lost&Found_Policy & To-Do 목록
# ✅ 8_11. Bling_Lost&Found_Policy & To-Do 목록

## 8_11_1 필요성 / Purpose

지역 내 분실물/습득물 연결 플랫폼. 신뢰 기반 사용자 간 실제 유용성 강화.

## 8_11_2 Key Components

- 유형: 분실물 / 습득물
    
- 필드: 제목, 날짜, 대략적 위치, 설명, 사진, 연락처, 사례금 여부
    
- 유효기간: 기본 7일, 유료 연장 30일 단위
    
- ‘HUNTED’ 배지: 현상금 등록 시 표시, 홈/지도 강조 노출
    

## 8_11_3 System Logic

- Firestore: `/lost_items`
    
- Cloud Function: 유효기간 자동 숨김 처리
    
- HUNTED/WANTED 모드 → 배지 표시, 지도 강조
    
- 허위 신고/분실 주장 이력 → `/users` 프로필에 기록, 신뢰도 점수 반영
    

## 8_11_4 Technical Architecture

- Firestore: `/lost_items`, `/users`, `/reports`
    
- Flutter: 탭 전환형 등록, 지도/리스트 병렬
    
- Firebase Storage: 이미지 업로드
    
- Cloud Scheduler + Function: 만료 게시물 처리
    

## 8_11_5 Monetization & Ops

- 무료: 기본 7일 노출
    
- 유료: 30일 연장, HUNTED 배지, 홈 화면/지도 강조 노출
    
- 신고 기록 DB 관리, 수수료 기반 대리 지원 서비스 가능
    

## 8_11_6 Scalability & Roadmap

- QR코드 스티커/등록 연동 (펫 목걸이 등)
    
- 습득물 보관소 지도화(공공기관 연계)
    
- 보상 지급 완료 체크
    
- AI 이미지 분석 → 유사 분실물 추천
    

## ✅ To-Do

-  Firestore 컬렉션 구조 QA
    
-  HUNTED 배지 노출 흐름 Proof
    
-  유효기간 자동 숨김 로직 QA
    
-  신고 기록/허위 이력 처리 시나리오 작성
    
-  QR코드/AI 자동 분류 Proof
    
-  공공기관 연계 시나리오 문서화



![[Pasted image 20250702175458.png]]


# 8_11_1. Lost & Found 기획 의도설명
**

# 8_11_1 Lost & Found / Barang Hilang / 분실물 찾기

## 8_11_1.1 필요성 / Purpose

지역 사회 내에서 발생하는 분실물과 습득물을 신속하고 효율적으로 연결하기 위한 메뉴입니다. 사용자 간 신뢰 기반 거래를 강화하고, 커뮤니티의 실질적 유용성을 높이는 기능입니다.

## 8_11_1.2 주요 구성 / Key Components

- 게시물 유형:
    

- 분실물: 지갑, 핸드폰, 반려동물 등
    
- 습득물: 발견 위치, 보관 위치, 사진 등
    

- 등록 필드:
    

- 유형 선택 (분실 / 습득)
    
- 제목
    
- 날짜 및 대략적 위치 (텍스트)
    
- 설명
    
- 사진 (선택)
    
- 연락 방법 (전화 or 앱 내 채팅)
    
- 사례금 여부 선택 (금액 입력 가능)
    

- 유효기간 설정:
    

- 기본: 7일 또는 30일 등록
    
- 유료 옵션: 1개월 단위 연장 가능
    

## 8_11_1.3 핵심 시스템 설명 / System Logic

- 게시물 구조: Firestore에 /lost_items 컬렉션 생성
    
- 유효기간 로직: Cloud Function으로 게시일 기준 자동 숨김 처리
    
- HUNTED / WANTED 모드:
    

- 유료 현상금 등록 게시물은 ‘HUNTED’ 배지 부여
    
- 홈 화면 및 지도에서 시각적 강조 노출
    

- 악용 방지:
    

- 허위 게시물 신고 기능
    
- 허위신고·분실 주장 이력은 사용자 프로필에 기록 가능 (신뢰도에 반영)
    

## 8_11_.1.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /lost_items: 분실/습득 게시물
    
- /users: 신고 기록, 신뢰도 점수
    
- /reports: 허위 게시물 관련 로그
    

- 기능 구현:
    

- Flutter UI: 탭 전환형 등록 화면, 지도/리스트 병렬 보기
    
- Firebase Storage: 이미지 저장
    
- Cloud Scheduler + Function: 유효기간 자동 숨김
    

## 8_11_.5 수익 모델 및 운영 계획 / Monetization & Ops

- 무료: 일반 분실물 등록, 7일 노출
    
- 유료 기능:
    

- 30일 노출 연장
    
- ‘HUNTED’ 배지 부여 및 홈 화면 우선 노출
    
- Google Maps 상 시각적 강조 표시
    

- 운영 방식:
    

- 사용자 신고/검수 기록 관리 시스템 필요
    
- Hunted 물품의 경우 수수료 기반 지원 서비스 제공 가능 (예: 대리 전달, 현장 확인 등)
    

## 8_11_1.6 확장성 및 로드맵 / Scalability & Roadmap

- 향후 기능:
    

- QR코드 스티커 + 등록 연동 (잃어버린 가방, 펫용 목걸이 등)
    
- ‘습득물 보관소’ 위치 지도화 (지역 공공기관 연계)
    
- 보상 지급 완료 여부 확인 체크 기능
    

- AI 도입 예정:
    

- 이미지 분석 기반 물품 카테고리 자동 분류
    
- ‘유사한 분실물’ 자동 추천
    

---

분실물 찾기 메뉴는 단순 게시판 이상의 실질적 문제 해결 플랫폼입니다. 블링의 신뢰 기반 구조를 가장 잘 보여주는 메뉴 중 하나이며, HUNTED/WANTED 강조 모델은 사용자 참여를 극대화하는 유료 UX 요소로 설계되었습니다.

**


# 8_12_0. Bling_Rooms & Boarding_Policy & To-Do 목록
# ✅ 8_12_0. Bling_Rooms & Boarding_Policy & To-Do 목록

## 8_12_1 필요성 / Purpose

Kelurahan 기반으로 인도네시아 도시 서민과 젊은 직장인들이 쉽게 찾을 수 있는 KOS, 하숙집, 월세 방 전용 메뉴. 복잡한 부동산 대신 지역별 실 매물, 저가 코스트, 공유룸 정보 중심.

## 8_12_2 Key Components

- 유형: KOS(하숙), 저가 월세, 셰어룸, 코스트
    
- 필수 필드: 방 유형(독실/공유), 위치(Google Maps), 가격(월/연), 보증금 여부, 방 크기/편의시설, 사진(10장), 연락처(전화/앱채팅), 주인/중개 여부
    
- 검색/필터: 위치 반경, 가격대, 방 크기, 화장실 포함 여부, 입주 가능일
    
- 저장: 찜 목록, 최근 본 매물
    

## 8_12_3 System Logic

- GPS 반경 기반 매물 노출 우선
    
- 찜/최근 본 목록 Firestore 저장
    
- Google Maps 주소 자동 검색/핀 노출
    
- Verified Badge: 실제 하숙집 인증 뱃지
    

## 8_12_4 Technical Architecture

- Firestore: `/rooms_listings`, `/boarding_hosts`, `/favorites`
    
- Flutter: 지도 연동, 필터, 찜 리스트
    
- Firebase Storage: 사진 저장, 주소/위치 핀 저장
    

## 8_12_5 Monetization & Ops

- 기본: 무료 등록(30일)
    
- 유료: 상단 고정 노출, 지역 카테고리별 우선 노출, Verified Kos Badge 발급 유료화 가능
    
- 운영: 지역 하숙집/코스트 운영자와 파트너십, 공공기관 연계로 허위 매물 방지
    

## 8_12_6 Scalability & Roadmap

- 향후: 영상 룸투어, 찜 비교 기능(2~3개), 계약서 PDF 자동화
    
- 현지화: 인도네시아 주요 도시 API 연동, Kos Finder AI 가격 예측/추천
    

## ✅ To-Do

-  GPS 기반 반경 노출 Proof
    
-  Verified Kos Badge QA
    
-  찜/최근 본 Firestore 연동 QA
    
-  상단 고정/광고 키워드 Proof
    
-  영상 룸투어/계약서 PDF 기능 시나리오 설계

![[Pasted image 20250702175247.png]]


# 8_12_1. 블링 직방 기획 의도
**

# 8_12_1. Real Estate / Properti / 부동산

## 8_12_1.1 필요성 / Purpose

지역 내의 매물 정보를 빠르고 정확하게 제공하며, 사용자가 임대, 매매, 단기 숙박 등의 부동산 정보를 쉽게 검색하고 연결될 수 있도록 하는 메뉴입니다. 블링은 커뮤니티 중심 앱의 신뢰도를 바탕으로, 공인중개사/개인 간 부동산 거래를 동시에 다룹니다.

## 8_12_1.1.2 주요 구성 / Key Components

- 게시 유형:
    

- 임대 / 매매 / 전세 / 단기 (월세·하숙 등)
    
- 일반 사용자 등록 + 사업자(중개인) 등록 구분 가능
    

- 등록 항목:
    

- 매물 유형 (아파트, 코스트, 집, 상가 등)
    
- 위치 (주소 + Google Maps 연동)
    
- 가격 (월/년/총액)
    
- 면적, 방 수, 욕실 수
    
- 사진 최대 10장 첨부
    
- 연락처 (전화 / 채팅)
    
- 중개인 여부 표시
    

- 검색 기능:
    

- 위치 기반 거리 필터
    
- 가격대 / 평수 / 입주 가능일 등 필터
    
- 찜 / 최근 본 매물 기능
    

## 8_12_1.1.3 핵심 시스템 설명 / System Logic

- 지역별 노출 우선: 사용자의 GPS 기준으로 매물 우선 정렬
    
- 찜한 목록 / 최근 본 목록 저장: LocalStorage 또는 Firestore 활용
    
- Google Maps 연동: 주소 자동 검색 → 지도상 위치 핀으로 표시
    
- 거래 유형에 따라 뱃지 부여: (직거래 / 중개 / Verified)
    

## 8_12_1.1.4 기술 아키텍처 / Technical Architecture

- DB 구조:
    

- /listings: 매물 게시글
    
- /agents: 공인중개사 정보 (인증 포함)
    
- /favorites: 찜 목록
    

- 기능 구현:
    

- Flutter 지도 연동 (Google Maps API)
    
- Firestore + Firebase Storage (이미지 저장)
    
- 중개인 여부 표시용 권한 관리
    

## 8_12_1.1.5 수익 모델 및 운영 계획 / Monetization & Ops

- 기본 이용: 매물 등록은 무료 제공 (1개월 단위 기본)
    
- 유료 모델:
    

- 상단 고정 노출 (지역·카테고리별)
    
- 우선 노출 필터 + 키워드 광고
    
- 중개사 인증 배지 유료 발급
    
- 클릭 기반 광고 과금 (PPC: Pay-per-click 가능성 검토)
    

- 운영 전략:
    

- 공인중개사 협회, 부동산 플랫폼과 파트너십 체결
    
- 자동 만료 시스템으로 유효 매물만 노출
    

## 8_12_1.1.6 확장성 및 로드맵 / Scalability & Roadmap

- 향후 기능:
    

- 영상 투어 등록 기능
    
- 매물 비교 기능 (찜 2~3개 나란히 보기)
    
- 계약서 작성 지원 기능 (PDF 자동 생성)
    

- 시장 확장:
    

- 코스트, 아파트 위주 지역 특화 모델 구축
    
- 인도네시아 주요 도시 매물 API 연동
    

- AI 활용 예정:
    

- 가격 예측 / 매물 품질 점수 자동 평가
    
- 사용자 검색 행동 기반 추천 알고리즘 도입
    

---

Real Estate 메뉴는 단순 매물 리스트가 아닌, 지역 기반 신뢰도+위치 필터링+추천 알고리즘을 갖춘 마이크로 부동산 플랫폼입니다. 향후 B2B 연동 및 중개인 광고 수익 모델이 가장 활발히 구현될 수 있는 고부가 메뉴입니다.

**





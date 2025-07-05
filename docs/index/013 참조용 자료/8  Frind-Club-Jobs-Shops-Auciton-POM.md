# 8_01 Bling Feature별 To-Do 목록

## ✅ 📌 Bling Feature별 To-Do 목록

---

### 3️⃣ **Find Friend**

-  GEO 반경 1~5km 쿼리 PoC
    
-  `interests[]`, `ageRange` 필드 → Matching 점수 계산 로직
    
-  `follows` 컬렉션 구조 설계 (`fromUserId` → `toUserId`)
    
-  선택적 데이팅 프로필 공개 `isDatingProfile` 로직
    
-  1:1 채팅 흐름 기존 Chat 모듈 재활용
    
-  Matching 추천 화면 UI/UX
    

---

### 4️⃣ **Club**

-  `clubs` + `members` + `posts` 컬렉션 설계
    
-  TrustLevel 제한 조건 로직 적용
    
-  관심사 기반 그룹 추천 로직 PoC
    
-  그룹 공지/일정 관리 설계
    
-  그룹 채팅 Room → 기존 Chat 재사용
    
-  참여/탈퇴 → `users/{uid}/clubs` 연계
    

---

### 5️⃣ **Jobs**

-  `jobs` 컬렉션 구조 → 직종 카테고리 필드 확정
    
-  TrustLevel 조건 → 허위 공고 방지
    
-  유료 상단 공고 옵션 아이디어 확정
    
-  지원자-채용자 1:1 채팅 연결
    
-  `users/{uid}/jobs` 히스토리 연계
    
-  직종별 필터 UI 설계
    

---

### 6️⃣ **Local Shops**

-  `shops` + `reviews` 구조 설계
    
-  TrustLevel 인증 상점 로직 → 인증 뱃지 표시
    
-  리뷰/평점 모듈 설계
    
-  제품 리스트 → Marketplace 연계 여부 결정
    
-  상점 문의 채팅 흐름 확정
    
-  지도 기반 상점 노출 정밀 테스트
    

---

### 7️⃣ **Auction**

-  `auctions` + `bids` 구조 설계
    
-  입찰 히스토리(`bidHistory[]`) 로직
    
-  실시간 입찰 내역 UI → 실시간 업데이트 테스트
    
-  판매자 TrustLevel 제한 로직
    
-  AI 검수 흐름(`isAiVerified`) 필드 적용
    
-  경매 낙찰 → Chat + 결제 흐름 연계
    

---

### 8️⃣ **POM (Shorts)**

-  `shorts` + `comments` 구조 설계
    
-  TrustLevel 업로드 제한 로직
    
-  AI 검수 모듈 연계 → 부적절 콘텐츠 자동 필터링
    
-  지역 트렌딩 로직 설계
    
-  WhatsApp 공유 모듈 연계
    
-  조회수(`viewsCount`) 필드 → 실시간 증가 테스트
    

---

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

-  Keluharan(Kec.) DropDown → GEO 연계 쿼리 최종 PoC
    
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

## ✅ 🚩 결론

이대로 진행하면 **Bling Ver.0.3 → Ver.1.0** 완성 흐름에 필요한 **핵심 To-Do**를 빠짐없이 커버할 수 있습니다.

필요하다면 👉 **Google Sheets** or **Obsidian Task Table**로 내보내 드릴까요?  
필요하면 말씀만 해주세요! 🔥✨


# 8_05. Bling_Find_Friend_Policy & To-Do 목록

---

## ✅ Cari Teman (Find Friend) 개요

Bling의 **Find Friend(친구찾기)**는  
Kelurahan(Kec.)  인증 기반으로 내 주변 이웃과 안전하게 연결되는  
**친구찾기/이웃추천/데이팅 확장형** 기능입니다.

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

## ✅ 결론

Cari Teman은 Bling의 **지역 기반 친구찾기 + Matching 추천 + 팔로우 기반 소셜 기능**으로,  
Keluharan(Kec.)인증과 TrustLevel을 통해 안전한 이웃 연결을 지원합니다.


# 8_06. Bling_Club_Policy & To-Do 목록

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


# 8_07. Bling_Jobs_Policy & To-Do 목록

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

## ✅ 결론

Bling Jobs는 Kelurahan(Kec.) 기반으로 운영되는  
**지역 구인구직/알바 허브**로, 사용자 신뢰등급과 채팅,  
위치 기반 구조를 연계해 안전하고 실효성 높은 채용 플랫폼을 지향합니다.


# 8_08. Bling_LocalShops_Policy & To-Do 목록

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

## ✅ 결론

Bling Local Shops는 Kelurahan(Kec.) 기반으로 운영되는  
**지역 소상공인 연결 허브**로, 주민과 상점의 신뢰를 기반으로  
안전하고 효율적인 로컬 커머스를 지원합니다.


# 8_09. Bling_Auction_Policy & To-Do 목록

---

## ✅ Auction (경매) 개요

Bling의 **Auction (Lelang)**은  
Kelurahan(Kec.)  인증과 TrustLevel, AI 검수를 결합해  
레어 아이템이나 고가 상품을 안전하게 거래할 수 있는  
**지역 기반 경매 허브**입니다.

---

## ✅ 핵심 목적

- Keluharan(Kec.) 인증으로 지역성 보장
    
- TrustLevel과 AI 검수로 안전한 고가 거래 지원
    
- 실시간 입찰, 마감, 낙찰자 자동 처리
    
- 판매자와 입찰자 간 1:1 문의 채팅
    

---

## ✅ 주요 흐름

|기능|상태|
|---|---|
|경매 상품 등록|❌ 기획만 있음|
|입찰 시스템|❌ 기획만 있음|
|낙찰자 결정|❌ 기획만 있음|
|실시간 입찰 내역|❌ 기획만 있음|
|판매자 TrustLevel|❌ 아이디어 단계|
|AI 검수|❌ 필드 설계만 완료|
|1:1 채팅|✅ `chats` 컬렉션 재활용 가능|

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

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[21. Bling](https://chatgpt.com/g/g-p-6857c4d4483c81918d998fb59ce040cf-bling-peurojegteu/c/685bb329-5ca8-800a-94f7-d18df30d0b65)]()


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



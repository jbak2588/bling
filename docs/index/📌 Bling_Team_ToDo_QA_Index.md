
---

## ✅ Bling Ver.3 — 아카이브 기반 실전 팀별 To-Do & QA 표

---

## 📁 [팀 A] Auth & Trust (아카이브: User Field & TrustLevel)

| No. | 작업 항목                  | 내용                                                             | QA                    |
| --- | ---------------------- | -------------------------------------------------------------- | --------------------- |
| A-1 | `users/{uid}` 필드 표준화   | nickname, trustLevel, locationParts, geoPoint, privacySettings | ✅ JSON Snapshot       |
| A-2 | TrustLevel 자동 상향/하향    | thanksReceived, reportCount, 신고/차단 로직 연동                       | ✅ 신고 누적 → 자동 하향 Proof |
| A-3 | 지연된 프로필 활성화            | profileCompleted 필드, 가입 직후 제한 플로우                              | ✅ 최초 로그인 → 비활성 시나리오   |
| A-4 | `blockList` & 신고 흐름    | 신고/차단 누적 → 메시지 제한/Feed 숨김                                      | ✅ blockedUsers 적용     |
| A-5 | 감사 수 UI                | Feed & 프로필에서 thanksReceived 버튼                                 | ✅ 감사 버튼 Flow          |
| A-6 | 인증 필드 QA               | 이메일/전화번호/신분증 추가 인증 흐름 (Optional)                               | ✅ 인증 배지 출력            |
| A-7 | TrustLevel Badge Style | normal/verified/trusted 배지 색상/출력                               | ✅ 배지 UI 캡처            |
| A-8 | Firestore Rules        | Self-Write Only + Cloud Function 가드                            | ✅ Rule 테스트            |

---

## 📁 [팀 B] Feed & CRUD (아카이브: Feed(Post) 모듈)

| No. | 작업 항목                   | 내용                                                | QA               |
| --- | ----------------------- | ------------------------------------------------- | ---------------- |
| B-1 | posts 컬렉션 필드            | category, title, body, tags, mediaUrl, likesCount | ✅ 필드명 일치 검증      |
| B-2 | 댓글/대댓글 구조               | comments/{commentId}, parentCommentId             | ✅ 대댓글 트리 Proof   |
| B-3 | 좋아요 + 찜                 | likesCount, wishlist 연동                           | ✅ 좋아요/찜 QA       |
| B-4 | AI 검수 필드 연동             | isAiVerified, flagged 처리                          | ✅ Flag 상태 QA     |
| B-5 | viewsCount & chatsCount | 상품 클릭수, 채팅건수                                      | ✅ Count 증가 검증    |
| B-6 | Draft & 임시저장            | 등록중 중간저장 구조                                       | ✅ Draft 작성 → 재편집 |
| B-7 | 이미지 갯수                  | 최대 10장 Storage 연동                                 | ✅ 업로드 순서 Proof   |
| B-8 | Feed Infinite Scroll    | 반경 + 카테고리 기반 Paging                               | ✅ Lazy Load QA   |

---

## 📁 [팀 C] Chat & Notification (아카이브: Chat 모듈 Core)

|No.|작업 항목|내용|QA|
|---|---|---|---|
|C-1|chats 컬렉션 표준화|participants[], messages Sub, unreadCounts|✅ Firestore 구조 검증|
|C-2|1:1 채팅 Room 재사용|Feed/Market/Jobs/FindFriend 통합|✅ Room 중복방지 Proof|
|C-3|메시지 알림 → Notifications|알림 타입별 연동 & 읽음 처리|✅ FCM & Local QA|
|C-4|blockedUsers 적용|차단 시 채팅 송수신 제한|✅ 차단 Flow QA|
|C-5|TrustLevel 메시지 가드|trusted 이상만 메시지 허용|✅ TrustLevel 필터|
|C-6|채팅 메시지 상태|sent/failed/read|✅ 상태 QA|
|C-7|공지/RT Pengumuman|RT 알림 우선순위|✅ priority: high Proof|
|C-8|WhatsApp CTA PoC|외부 공유 연계 (Optional)|✅ 외부연동 흐름|

---

## 📁 [팀 D] GeoQuery & Location (아카이브: 주소 DropDown & Singkatan)

|No.|작업 항목|내용|QA|
|---|---|---|---|
|D-1|단계별 DropDown|Kap → Kec → Kel → RT/RW|✅ 단계별 선택 흐름|
|D-2|Singkatan Helper|Kab., Kec., Kel. 자동 표기|✅ Helper Output Proof|
|D-3|GeoPoint + geohash|반경 쿼리 GeoHash 일치|✅ GeoPoint 저장 QA|
|D-4|반경 within() 쿼리|GeoHelpers → Firestore within|✅ 반경 Filter 동작|
|D-5|지도 연동|Google Maps Marker, Circle|✅ Marker 좌표 Proof|
|D-6|인덱스 구성|kabupaten + kecamatan + geohash|✅ 복합 인덱스 QA|
|D-7|DropDown UI Modal|BottomSheet/FullPage|✅ UX 캡처|

---

## 📁 [팀 E] AI Moderation (아카이브: Feed, Marketplace, Auction)

|No.|작업 항목|내용|QA|
|---|---|---|---|
|E-1|텍스트 욕설/불법어 필터|AI API → flagged 저장|✅ Flag 상태 Proof|
|E-2|이미지 AI 검수|NSFW, Duplicate|✅ 이미지 검수 결과|
|E-3|동일성 검증 로직|Preloved 중복 이미지 비교|✅ 동일 이미지 시나리오|
|E-4|Cloud Function 트리거|등록시 AI 호출|✅ Trigger QA|
|E-5|isAiVerified 필드|결과에 따른 True/False|✅ Proof 저장|
|E-6|검수 실패 처리|자동 숨김 + 수정 재검수|✅ Flow 동작|
|E-7|Escrow 연계|Auction 고가 검수 필수|✅ Escrow 시나리오 QA|

---

## 📁 [팀 F] Design & Privacy (아카이브: Design Guide + i18n)

|No.|작업 항목|내용|QA|
|---|---|---|---|
|F-1|i18n JSON 키|en/id/ko Key Naming|✅ Key 구조 QA|
|F-2|Key Naming Rule|feature.component.property|✅ 중복/누락 Proof|
|F-3|ThemeData 표준|Primary/Secondary/Accent|✅ Theme QA|
|F-4|TrustLevel Badge|normal/verified/trusted Badge|✅ 배지 출력 캡처|
|F-5|PrivacySettings|ProfilePublic/MapVisible|✅ DB → Toggle QA|
|F-6|Dark/Light Mode|모드 전환 테스트|✅ 대비/폰트 Proof|
|F-7|Brand Guide|Splash, App Icon|✅ 디자인 시안|
|F-8|Localization QA|번역 Key 다국어|✅ Proof|

---

## ✅ 📌 공통 연계 및 관리

- QA 완료 후 [[📌 Bling_Team_ToDo_QA_Index.md]]에서 상태 갱신
    
- Firestore 컬렉션/필드 충돌 발생 시 즉시 리포트

---


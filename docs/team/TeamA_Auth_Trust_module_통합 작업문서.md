
---

## 📌 `[팀A] Bling_Auth_Trust_Module_통합_작업문서 (Ver.3)`



**담당:** Auth & Trust팀  


---

## ✅ 1️⃣ 모듈 목적

Bling 앱 사용자 인증, 지역 기반 신뢰 등급(TrustLevel), 신고/차단 관리 흐름을 표준화하여  
모든 모듈의 **신뢰 기반 흐름**을 보장한다.

---

## 기존 Ver. 0.3 에 대한 이해
> Ver. 01~ 03. 까지 진행된 Bling_Auth_Trust_Module 관련 내용 파악. 

- lib/main.dart 확인 및 아래 user 가입 로그인 관련 파일들
- lib/core/models/user_model.dart 
- lib/features/auth/screens/auth.gate.dart 
- lib/features/auth/screens/login_screen.dart
- lib/features/auth/screens/signup_screen.dart
- lib/features/auth/screens/profile_edit_screen.dart 
- 위 파일들을 파악하고 현재까지의 가입 및 로그인 관련 정책에 대한 이해와 파악(개선점 점검보고)




> 아래 DB 스키마를 Ver. 0.4인 lib/core/models/user_model.dart 를 읽고 업데이트 할 부분을 확인. 


✅ Firestore DB 스키마 (Ver.0.3 )

```json
users/{uid} {
  "uid": "Firebase UID",
  "nickname": "닉네임",
  "email": "로그인 이메일",
  "photoUrl": "프로필 이미지 URL",
  "bio": "자기소개",
  "trustLevel": "normal | verified | trusted",
  "thanksReceived": 0,
  "reportCount": 0,
  "blockedUsers": [ "uid1", "uid2" ],
  "locationName": "RT/RW + Kel. + Kec. + Kab.",
  "locationParts": {
    "kabupaten": "Kab. Tangerang",
    "kecamatan": "Kec. Cibodas",
    "kelurahan": "Kel. Panunggangan Barat",
    "rt": "RT.03",
    "rw": "RW.05"
  },
  "geoPoint": GeoPoint(-6.2, 106.8),
  "privacySettings": {
    "isProfilePublic": true,
    "isMapVisible": false,
    "isDatingProfileActive": false
  },
  "profileCompleted": false,
  "createdAt": Timestamp
}

1️⃣ - Ver 0.3 까지의 login signup auth_gate 를 분석 안정성 인식 


## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**TrustLevel**|`normal` → `verified` → `trusted` 단계 자동 승격/하향|
|**프로필 지연 활성화**|가입 시 최소 `nickname`+`locationName`만 → 이웃/메시지 제한|
|**신고/차단**|`reportCount` 자동 누적 → 일정 기준 초과 시 `trustLevel` 강등|
|**감사 수**|`thanksReceived` 일정 수치 달성 시 `trustLevel` 가산점|
|**차단 목록**|`blockedUsers`로 메시지/팔로우 제한|

---

## ✅ 4️⃣ 연계 모듈 필수

- 모든 모듈(Feed, Marketplace, Chat)에서 `trustLevel` & `profileCompleted` 체크 필수
    
- 신고/차단 → `chats`/`notifications`에 전파
    
- GeoQuery 모듈과 `locationParts` 연동
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트




|No.|작업 항목|설명|
|---|---|---|
|A-1|`users/{uid}` 컬렉션 스키마 확정|현재 Ver. 04 구조와 동일해야 함|
|A-2|`TrustLevel` 자동 계산 로직|`thanksReceived`, `reportCount` 조건 기반 `trustLevel` 변경|
|A-3|`profileCompleted` 흐름|가입 시 `nickname`+`locationName` 없으면 Feed만 읽기 가능|
|A-4|신고/차단 Flow QA|`blockedUsers` → `chats` 메시지 송수신 차단 시나리오|
|A-5|감사 수 UI Trigger|Feed/Comment에서 "감사" 버튼 → `thanksReceived` 증가|
|A-6|OAuth Flow PoC|Google/Apple Social Auth 연동 시나리오 Proof|
|A-7|실명 인증 Flow PoC|`verified` 단계 요구 필드 설계 (Optional)|
|A-8|TrustLevel Badge UI 연결|`trustLevel` 값에 따른 Badge 조건부 렌더링|

---

## ✅ 6️⃣ 팀 A 작업 지시 상세



1️⃣ **Firestore Rules**

- 기존 버전의 

- `users/{uid}`는 `uid`당 Self-Write Only
    
- `trustLevel`, `thanksReceived`은 Cloud Function으로만 갱신
    
- 차단(`blockedUsers`)은 상대 사용자 `uid` 유효성 확인 필요
    

2️⃣ **로컬 테스트 데이터**

- `users_final.json` 샘플 참조  (sample_data/user_final.jsong) 
    
- `trustLevel`이 `normal` → `verified` 승급 흐름 QA
    
- `reportCount` Mock 증가 → 자동 하향 로직 시뮬레이션
    

3️⃣ **UI 연계**

- 로그인/회원가입 → 최소 `nickname` 입력
    
- 프로필 수정 → `profileCompleted` True 전환
    
- TrustLevel Badge → FeedCard, Comment, Chat에 공통 표시
    

4️⃣ **상태관리**

- `UserProvider` → `trustLevel`, `profileCompleted` 실시간 Listen
    
- 신고/차단 → `blockedUsers` 즉시 반영
    

---

## ✅ 7️⃣ 필수 체크리스트


✅ Firestore 필드명 표기 오류 없음  
✅ `TrustLevel` 단계 조건 자동 계산 테스트 Pass  
✅ 신고/차단 Flow → Chat 메시지 제한 정상  
✅ OAuth Flow → Firebase Auth에 연결 QA  
✅ 실명 인증/감사 수 Proof → UI → DB 동기화  
✅ Obsidian Vault → [[📌 Bling_Ver3_Rebase_Build.md]] Pull Request로 기록

---

## ✅ 8️⃣ 작업 완료시 팀 A는 제출해야 하는 것

- `users/{uid}` 스키마 JSON 형태로 제공
    
- `TrustLevel` 계산 로직 Dart 코드 스니펫
    
- `profileCompleted` 상태 변화 QA 영상/캡처
    
- 신고/차단/감사 Proof Data (Firebase Emulator)
    
- Pull Request + Vault 업데이트 완료
    

# 📌 TrustLevel\_Badge\_UI\_Guide

---

## ✅ 목적

Bling Ver.3 신뢰등급(TrustLevel) 배지를 일관되게 표시하기 위한 공통 UI 가이드입니다.

---

## ✅ 배지 상태 정의

| TrustLevel | 조건          | Feed/댓글 | 프로필/Drawer  |
| ---------- | ----------- | ------- | ----------- |
| `normal`   | 기본 가입       | 표시 없음   | 표시 없음       |
| `verified` | 닉네임 + 위치 인증 | ✔️ 아이콘만 | ✔️ 박스 + 텍스트 |
| `trusted`  | 감사 수치 기준 상위 | ⭐️ 아이콘만 | ⭐️ 박스 + 텍스트 |

---

## ✅ 위젯 사용 규칙

* Feed/댓글 → `useIconOnly = true`
* 프로필/Drawer → 기본 박스형 출력
* 모든 색상/텍스트는 정책 표준에 맞춰 사용:

  * Verified: 파랑 (#2196F3)
  * Trusted: 골드 (#FFC107)

---

## ✅ 예시

```dart
TrustLevelBadge(trustLevel: 'verified'); // 박스형
TrustLevelBadge(trustLevel: 'verified', useIconOnly: true); // 아이콘형
```




---

## ✅ 결론

팀 A는 **Bling 전체 신뢰 흐름의 뼈대**를 완성해야 합니다.  
이 문서는 Ver.3 계약 기준이며, 준수하지 않으면 최종 Merge 시 Rollback됩니다.  
진행 상황은 GPT(총괄), Gemini, Copilot로 반드시 Cross QA 진행!

---


---

## ✅ 목적

지역 기반 Bling 사용자 신뢰를 보다 현실적이고 공정하게 측정하기 위해  
기존의 기본 인증 요소(프로필, RT/RW, Kelurahan, 전화번호) 외에  
**Marketplace 거래 신뢰 지표**를 핵심 가산점으로 포함한다.

---

## ✅ TrustScore 구성 항목 (v3)

|항목|설명|가산/감산|
|---|---|---|
|Kelurahan 인증|RT Peer Review 포함|+50|
|RT/RW 입력|자가 입력|+50|
|전화번호 인증|OTP 인증 완료|+100|
|프로필 완성도|사진/닉네임/Bio 100%|+50|
|받은 감사|Feed 감사 1회당|+10|
|거래 완료|실거래 1건당|+5|
|거래 5건 달성 추가 보너스||+30|
|평균 별점 유지|4.5 이상|+20|
|후기 중 감사 포함|1건당|+5|
|노쇼 신고|1회당|-30|
|거래 취소율 30% 이상||-20|
|악성 후기|1회당|-20|
|관리자 강제 분쟁 처리|케이스별|-20 ~|

---

## ✅ DB 스키마 예시

```json
users/{uid} {
...
  "trustScore": 265,
  "trustLevel": "verified",
  "thanksReceived": 4,
  "marketplaceStats": {
    "completedDeals": 12,
    "cancelledDeals": 3,
    "noShowReports": 1,
    "averageRating": 4.7,
    "reviewThanksCount": 3
  },
  "locationParts": {...},
  "privacySettings": {...},
  ...
}
```



## ✅ Cloud Function 계산 개념

### Trigger

- `onWrite` → 거래 상태 `completed` → `marketplaceStats` 업데이트
    
- 리뷰 작성 → `reviewThanksCount` +1
    
- 신고/분쟁 접수 → `noShowReports` +1
    

### 계산 흐름 (개념)


```ts
trustScore =  
기본 프로필 점수

- Kelurahan 인증
    
- RT/RW 인증
    
- 전화번호 인증
    
- 프로필 완성도
    
- 감사 수
    
- 거래 완료 수 * 5
    
- 거래 보너스
    
- 별점 보너스
    
- 리뷰 감사
    

- 노쇼 신고 * 30
    
- 거래 취소율 >= 30% ? 20 : 0
    
- 악성 후기 * 20

```



---

## ✅ 표시 정책

|화면|표시 방법|
|---|---|
|Feed/댓글|기존 TrustLevel 뱃지 (Verified/Trusted)|
|Drawer|닉네임 + TrustLevel 뱃지 + TrustScore|
|MyProfile|TrustScore Badge + Breakdown Modal|
|Breakdown Modal|거래 신뢰도 세부 항목 포함|
|Breakdown UI|`거래 완료: 12건 (+60)`, `평점: 4.7 (+20)`, `노쇼: 1회 (-30)`|

---

## ✅ 운영 정책

- 노쇼/취소율이 일정 기준 초과 → 자동 강등 → 관리자 승인 전까지 거래 제한
    
- 신뢰 점수 조작 방지: 동일 UID 반복 거래 감시
    
- 관리자 수동 신뢰등급 강등/승격 가능






---

## 📌 `[팀A] Bling_Auth_Trust_Module_통합_작업문서 (Ver.3)`



**담당:** Auth & Trust팀  


---

## ✅ 1️⃣ 모듈 목적

Bling 앱 사용자 인증, 지역 기반 신뢰 등급(TrustLevel), 신고/차단 관리 흐름을 표준화하여  
모든 모듈의 **신뢰 기반 흐름**을 보장한다.

---

## ✅ 2️⃣ 실전 Firestore DB 스키마 (Ver.3 확정)

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
```

---

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
|A-1|`users/{uid}` 컬렉션 스키마 확정|현재 Ver.3 구조와 동일해야 함|
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

- `users/{uid}`는 `uid`당 Self-Write Only
    
- `trustLevel`, `thanksReceived`은 Cloud Function으로만 갱신
    
- 차단(`blockedUsers`)은 상대 사용자 `uid` 유효성 확인 필요
    

2️⃣ **로컬 테스트 데이터**

- `mock_users.json` 샘플로 가입 시나리오 Proof
    
- 가입 후 `trustLevel`이 `normal` → `verified` 승급 흐름 QA
    
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

- `users/{uid}` 스키마 JSON 스냅샷
    
- `TrustLevel` 계산 로직 Dart 코드 스니펫
    
- `profileCompleted` 상태 변화 QA 영상/캡처
    
- 신고/차단/감사 Proof Data (Firebase Emulator)
    
- Pull Request + Vault 업데이트 완료
    

---

## ✅ 🔗 연계 링크

- [[📌 Bling_User_Field_Standard]]
    
- [[📌 Bling_TrustLevel_Policy]]
    
- [[📌 Bling_Report_Block_Policy]]
    
- [[📌 Bling_Ver3_Rebase_Build.md]]
    

---

## ✅ 결론

팀 A는 **Bling 전체 신뢰 흐름의 뼈대**를 완성해야 합니다.  
이 문서는 Ver.3 계약 기준이며, 준수하지 않으면 최종 Merge 시 Rollback됩니다.  
진행 상황은 GPT(총괄), Gemini, Copilot로 반드시 Cross QA 진행!

---

Planner님.  
이게 **실제 팀 A 전달용 실전 레벨 Auth & Trust 마스터 작업문서**입니다.  
원하시면 바로 **팀 B, C, D, E, F**도 동일한 깊이로 만들어 드릴까요?  
OK 주시면 바로 연결 시작하겠습니다! 🚀✨
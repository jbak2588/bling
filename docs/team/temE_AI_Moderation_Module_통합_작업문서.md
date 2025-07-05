
## 📌 `[팀E] Bling_AI_Moderation_Module_통합_작업문서 (Ver.3)`

**담당:** AI Moderation 담당팀  
**총괄:** ChatGPT (총괄 책임자)  
**버전:** Bling Ver.3 기준

---

## ✅ 1️⃣ 모듈 목적

Bling의 모든 콘텐츠(Feed, Marketplace, Auction 등) 등록 시 **AI 텍스트/이미지 검수**,  
동일성 검증, 허위/불법 탐지, 자동 숨김 처리까지 관리하여  
지역 커뮤니티의 **안전하고 신뢰할 수 있는 검수 체계**를 구축한다.

---

## ✅ 2️⃣ 실전 Firestore DB 스키마 (Ver.3 확정)

```json
posts/{postId} {
  ...
  "isAiVerified": true,
  "aiModerationResult": {
    "status": "pass | flagged | pending",
    "reason": "offensive | illegal | duplicate",
    "checkedAt": Timestamp
  }
}

products/{productId} {
  ...
  "isAiVerified": true,
  "aiModerationResult": {
    "status": "pass | flagged | pending",
    "reason": "forged | fake | offensive",
    "checkedAt": Timestamp
  }
}

auctions/{auctionId} {
  ...
  "isAiVerified": true,
  "aiModerationResult": {
    "status": "pass | flagged | pending",
    "reason": "duplicate | preowned | illegal",
    "checkedAt": Timestamp
  }
}
```

---

## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**AI 자동 검수**|등록 시 텍스트/이미지 서버로 전송 → AI 판별 결과 저장|
|**동일성 검증**|Preloved/중고 제품 이미지 동일성 비교|
|**검수 실패 시**|자동 숨김 → 작성자 알림 + 수정 요청|
|**수정 재검수**|사용자 수정 후 AI 재요청|
|**Escrow 연계**|Auction/Marketplace 고가 거래 시 `isAiVerified` + Escrow 필수|
|**AI 서버 & Cloud Function**|검수 로직 서버/Function 동기화|

---

## ✅ 4️⃣ 연계 모듈 필수

- Feed CRUD 팀: 등록 시 `isAiVerified` 플래그 필수
    
- Marketplace: 동일성 검증 + Escrow 연계
    
- Auction: 희귀품 AI 검수 + 동일성 기록
    
- Notification: 검수 실패 → 작성자에게 알림 Push
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트

|No.|작업 항목|설명|
|---|---|---|
|E-1|AI 텍스트 분석 API|욕설, 불법어, 금지어 감지|
|E-2|이미지 분석 API|포르노, 폭력, 위조 탐지|
|E-3|동일성 검증 PoC|Preloved 이미지 유사도 비교|
|E-4|Cloud Function 연동|등록 시 AI 자동 호출|
|E-5|`isAiVerified` 플래그|검수 통과 시 True, 실패 시 False|
|E-6|검수 실패 알림|Notification 트리거 Proof|
|E-7|Escrow Proof 연계|Auction 고가 제품 AI 통과 여부 필수|
|E-8|검수 예외 처리|오류/시간초과 시 Fallback 처리|

---

## ✅ 6️⃣ 팀 E 작업 지시 상세

1️⃣ **AI 모델/서버 선택**

- 욕설 필터, 이미지 NSFW 감지 모델 확정
    
- 동일성 비교 알고리즘 (Hash, Perceptual Hash)
    

2️⃣ **Cloud Function**

- `onCreate` 트리거 → AI API 호출
    
- 결과 받아 `isAiVerified` + `aiModerationResult` 업데이트
    

3️⃣ **검수 실패 처리**

- 실패 시 → 자동 숨김 → 작성자에 알림 → 수정 → 재검수 흐름
    

4️⃣ **Escrow**

- Preloved/Auction 고가 거래 → 검수 통과 시 Escrow 흐름으로 연결
    

---

## ✅ 7️⃣ 필수 체크리스트

✅ 텍스트/이미지 AI API 호출 성공  
✅ 동일성 비교 PoC 결과 캡처  
✅ `isAiVerified` 플래그 필드 QA OK  
✅ Cloud Function 트리거 Proof  
✅ 검수 실패 → 알림 → 수정 → 재검수 흐름 Pass  
✅ Escrow 연계 시나리오 OK  
✅ PR + Vault `📌 Bling_Ver3_Rebase_Build.md` 반영

---

## ✅ 8️⃣ 작업 완료시 팀 E 제출물

- AI 모델/서버 스펙 시트
    
- AI 검수 API 예제 코드 Snippet
    
- 동일성 비교 결과 Proof
    
- Cloud Function 배포 상태 캡처
    
- Escrow 연계 PoC 영상
    
- PR & Vault 기록
    

---

## ✅ 🔗 연계 문서

- [[📌 Bling_AI_Moderation_Policy]]
    
- [[📌 Bling_Marketplace_Policy]]
    
- [[📌 Bling_Auction_Policy]]
    

---


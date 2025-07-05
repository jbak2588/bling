
---

## 📌 `[팀B] Bling_Feed_CRUD_Module_통합_작업문서 (Ver.3)`

**담당:** Feed & CRUD팀  
**총괄:** ChatGPT (총괄책임자)  
**버전:** Bling Ver.3 기준

---

## ✅ 1️⃣ 모듈 목적

Bling 앱의 **Local Feed, Marketplace, Auction 등** 모든 게시물 흐름의 **등록/조회/수정/삭제(CRUD)** + 댓글/좋아요/찜 상호작용을 **공통화/표준화**한다.

---

## ✅ 2️⃣ 실전 Firestore DB 스키마 (Ver.3 확정)

```json
posts/{postId} {
  "postId": "자동 UUID",
  "userId": "작성자 UID",
  "title": "제목",
  "body": "본문 내용",
  "category": "lostFound | market | auction 등",
  "tags": ["태그1", "태그2"],
  "images": ["URL1", "URL2"],
  "locationParts": {
    "kabupaten": "Kab. Tangerang",
    "kecamatan": "Kec. Cibodas",
    "kelurahan": "Kel. Panunggangan Barat",
    "rt": "RT.03",
    "rw": "RW.05"
  },
  "geoPoint": GeoPoint(-6.2, 106.8),
  "likesCount": 0,
  "commentsCount": 0,
  "viewsCount": 0,
  "isAiVerified": false,
  "status": "active | deleted | sold",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}

posts/{postId}/comments/{commentId} {
  "commentId": "UUID",
  "userId": "작성자 UID",
  "body": "댓글 내용",
  "likesCount": 0,
  "isSecret": false,
  "parentCommentId": "대댓글용",
  "createdAt": Timestamp
}
```

---

## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**Post CRUD**|등록/수정/삭제 시 `userId`와 권한 필수|
|**댓글/대댓글**|`parentCommentId`로 트리 구조 관리|
|**좋아요**|`likesCount` 실시간 반영|
|**찜(Wishlist)**|`users/{uid}/wishlist` 하위에 참조|
|**AI 검수**|`isAiVerified` → AI 모듈 결과 반영|
|**상태**|Draft → Published → Deleted → Sold|

---

## ✅ 4️⃣ 연계 모듈 필수

- `trustLevel` 조건 → 게시물 등록 권한 제한
    
- GeoQuery → `locationParts` & `geoPoint` 사용
    
- 신고/차단 → FeedCard/댓글 숨김 처리 연계
    
- AI 모듈 → `isAiVerified` 필드로 검수 결과 저장
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트

|No.|작업 항목|설명|
|---|---|---|
|B-1|`posts` 컬렉션 구조 최종화|필드 누락/오타 없는지 검수|
|B-2|CRUD Form Validator|제목/본문/금지어 제한|
|B-3|이미지 업로드 최대 10장|Firestore Storage 연계|
|B-4|Infinite Scroll|Feed/Paging 로직 Proof|
|B-5|댓글/대댓글 트리 로직|`parentCommentId` QA|
|B-6|좋아요/찜 동작|`likesCount` & `wishlist` 연계|
|B-7|Draft 상태 QA|작성 중 임시저장, 복원|
|B-8|AI 검수 연계|`isAiVerified` 로직 연동 테스트|

---

## ✅ 6️⃣ 팀 B 작업 지시 상세

1️⃣ **권한**

- `userId` 불일치 시 수정/삭제 차단
    
- Draft는 작성자 본인만 확인 가능
    

2️⃣ **필수 Validator**

- 제목 길이 제한 (최대 100자)
    
- 금지어 필터 (욕설/불법 단어)
    

3️⃣ **Infinite Scroll**

- Lazy Load, Skeleton Loader
    

4️⃣ **찜**

- `users/{uid}/wishlist` 하위에 `postId` 배열 저장
    

5️⃣ **AI 연동**

- AI 모듈에서 `isAiVerified` True/Fake 흐름 QA
    

---

## ✅ 7️⃣ 필수 체크리스트

✅ Firestore 필드 표기 오류 없음  
✅ 댓글 트리 QA Pass  
✅ 좋아요/찜 동기화 OK  
✅ Draft 저장/복원 시나리오 Pass  
✅ GeoQuery 흐름과 위치 필드 일치  
✅ PR + Vault `📌 Bling_Ver3_Rebase_Build.md` 반영

---

## ✅ 8️⃣ 작업 완료시 팀 B 제출물

- `posts` JSON Snapshot
    
- 댓글 트리 Proof 스크린샷
    
- Infinite Scroll 동작 영상
    
- AI 검수 연동 결과 캡처
    
- PR & Vault 기록
    

---

## ✅ 🔗 연계 문서

- [[📌 Bling_Local_Feed_Policy]]
    
- [[📌 Bling_Auction_Policy]]
    
- [[📌 Bling_Marketplace_Policy]]
    
    

---




---

## 📌 `[팀C] Bling_Chat_Notification_Module_통합_작업문서 (Ver.3)`

**담당:** Chat & Notification 팀  
**총괄:** ChatGPT (총괄 책임자)  
**버전:** Bling Ver.3 기준

---

## ✅ 1️⃣ 모듈 목적

Bling의 **1:1 채팅**, **Marketplace/Feed 문의**, **실시간 알림(FCM/앱 내)** 전 기능을  
공통화하여 **모든 모듈에서 재사용 가능한 채팅/알림 엔진**으로 설계한다.

---

## ✅ 2️⃣ 실전 Firestore DB 스키마 (Ver.3 확정)

```json
chats/{chatId} {
  "chatId": "자동 UUID",
  "participants": ["uid1", "uid2"],
  "lastMessage": "마지막 메시지",
  "unreadCounts": {
    "uid1": 1,
    "uid2": 0
  },
  "createdAt": Timestamp
}

chats/{chatId}/messages/{messageId} {
  "messageId": "UUID",
  "senderId": "보낸사람 UID",
  "body": "메시지 본문",
  "imageUrl": "선택 이미지",
  "createdAt": Timestamp,
  "status": "sent | failed | read"
}

notifications/{notifId} {
  "notifId": "UUID",
  "fromUserId": "발신자 UID",
  "toUserId": "수신자 UID",
  "type": "comment | like | chat | RT_notice",
  "message": "알림 내용",
  "relatedId": "관련 Post ID",
  "read": false,
  "timestamp": Timestamp,
  "priority": "high | normal"
}
```

---

## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**1:1 채팅**|Feed/Marketplace/FindFriend 등 전 모듈 동일 구조 사용|
|**알림**|`notifications` 컬렉션 + FCM Token 동기|
|**차단/신뢰레벨 가드**|`trustLevel` ≥ verified만 채팅 허용|
|**읽음 상태**|`unreadCounts` 필드 기반|
|**중복방 방지**|`participants` 배열 기준 중복 체크|
|**신고/차단**|차단 시 메시지 수발신 Block|

---

## ✅ 4️⃣ 연계 모듈 필수

- Auth & Trust: `blockedUsers`, `trustLevel` 가드
    
- Feed/Marketplace: 문의 채팅 연결
    
- Notification 모듈: 댓글/좋아요/RT Pengumuman
    
- Firebase FCM 연동 필수
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트

|No.|작업 항목|설명|
|---|---|---|
|C-1|`chats` 컬렉션 스키마 QA|필드/중복 체크|
|C-2|중복방 방지 로직|동일 participants 배열 → 기존 채팅방 리턴|
|C-3|메시지 전송 로직|전송 실패 Retry, 상태 `sent|
|C-4|읽음 처리 흐름|`unreadCounts` 실시간 반영|
|C-5|차단 상태 처리|`blockedUsers` 참조 → 송수신 제한|
|C-6|Notification 구조 표준화|알림 유형별 `type` 구조화|
|C-7|FCM Token 관리|FCM Token 갱신, 수신 테스트|
|C-8|RT 공지 / 공용 Notice|`priority: high` 공지 Push Flow Proof|

---

## ✅ 6️⃣ 팀 C 작업 지시 상세

1️⃣ **메시지 상태 관리**

- 전송 성공 → `sent`
    
- 실패 → `failed` → 자동 Retry
    
- 수신자 읽음 → `read`
    

2️⃣ **중복방 방지**

- `participants` 배열로 쿼리 → 있으면 기존 채팅방 사용
    

3️⃣ **차단 가드**

- 송/수신자 `blockedUsers` 포함 시 `send` API Block
    

4️⃣ **Notification**

- 댓글/좋아요 → Feed팀에서 Trigger → `notifications`에 기록 → FCM Push
    

5️⃣ **RT 공지**

- RT Pengumuman → `priority: high` → 읽음 처리까지 Flow QA
    

---

## ✅ 7️⃣ 필수 체크리스트

✅ Firestore 구조 & 필드명 정확  
✅ 중복방 방지 시나리오 Pass  
✅ 전송 실패 → Retry Proof  
✅ 읽음 상태 동기화 (내/상대 unreadCount)  
✅ 차단 가드 실전 QA  
✅ FCM Token 갱신 흐름 문제 없음  
✅ RT 공지 → 알림 → 읽음 흐름 Pass  
✅ PR + Vault `📌 Bling_Ver3_Rebase_Build.md` 반영

---

## ✅ 8️⃣ 작업 완료시 팀 C 제출물

- `chats` & `notifications` JSON Snapshot
    
- 중복방 방지 Proof 스크린샷/영상
    
- 전송 실패 → Retry 동작 캡처
    
- RT 공지 Push Proof
    
- PR & Vault 기록
    

---

## ✅ 🔗 연계 문서

- [[📌 Bling_Chat_Policy]]
    
- [[📌 Bling_Notifications_Policy]]
    
- [[📌 Bling_TrustLevel_Policy]]
    
    

---


# 3_25. 알림 정책
# Notification_Policy

---

## ✅ Notification 정책 개요

Bling은 Keluharan(Kel.)  로컬 슈퍼앱으로,  실시간 Push 알림과 In-App 알림을 통해  
지역 피드, Marketplace, 채팅, 이웃 요청 등  **모든 핵심 모듈과 사용자를 연결**합니다.

---

## ✅ 핵심 알림 트리거

| 모듈          | 트리거 예시        |
| ----------- | ------------- |
| Feed        | 내 글 댓글/좋아요    |
| Marketplace | 상품 문의, 거래 제안  |
| Find Friend | 이웃 요청 승인/거절   |
| Club        | 새로운 멤버 가입, 공지 |
| Jobs        | 지원자 메시지       |
| Auction     | 입찰 업데이트, 낙찰   |
| POM         | 댓글, 좋아요       |
| TrustLevel  | 등급 변경 알림      |

---

## ✅ 기술 구조

- Firebase Cloud Messaging (FCM) 기반
    
- Flutter `firebase_messaging` 연동
    
- App Foreground → In-App 알림 처리
    
- App Background → Push Notification
    

---

## ✅ 사용자 설정

- 사용자별 알림 ON/OFF 스위치
    
- 카테고리별 구독 설정:
    
    - Feed 알림 수신 여부
        
    - Marketplace 거래 알림
        
    - 친구찾기/이웃 요청 알림
        
    - 광고/프로모션 알림 (선택)
        

---

## ✅ Firestore 연계

| 컬렉션                         | 설명                  |
| --------------------------- | ------------------- |
| `notifications`             | 개별 알림 기록            |
| `users/{uid}/notifications` | 사용자별 읽음/미확인 상태 저장   |
| `chats`                     | Chat 알림은 별도 Trigger |

---

## ✅ UI/UX 규칙

- 알림 Badge → BottomNav / AppBar 표시
    
- 새 알림 → 알림 리스트 상단
    
- 읽음 처리 → 클릭 시 `isRead` → true
    
- 중요 알림 → AppBar 강조 표시
    

---

## ✅ 연계 문서

- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    
- [[2_02. Project_FolderTree]]
    

---

## ✅ 결론

Bling Notification은  Keluharan(Kel.)  기반 지역성과  
모듈별 실시간 연결성을 유지하는 **핵심 UX**로,  
Firebase Cloud Messaging과 연동하여 안정적으로 관리됩니다.


### ✅ 구성 핵심

- Push + In-App 알림 기술 흐름 → Firebase 기준
    
- 사용자가 직접 알림 카테고리별 설정 가능
    
- `notifications` 컬렉션 구조 간단 표로 정리
    
- [[21]], [[33]]로 User 필드/TrustLevel 연계 안내


# 9_30. Notifications_탭_현지화_구성안
# 🔔 Bling_Notifications_탭_현지화_구성안

## ✅ 목적

Bling 앱의 Notifications(알림) 탭은  
인도네시아 Keluharan(Kec.) 지역 기반 커뮤니티 특성에 맞게  
단순 번역이 아닌 RT Pengumuman(지역 공지)와 WhatsApp 공유 흐름까지 통합한  
현지화 설계안이다.

---

## 🧩 주요 알림 유형

| 유형 | 설명 | 트리거                   |
| ----------------- | ----------- | --------------------- |
| 💬 Komentar | 내 글/댓글에 댓글 | Post/Comment          |
| ❤️ Suka | 좋아요 발생 | Post/Comment          |
| 🧑‍🤝‍🧑 Tetangga | 이웃 요청/즐겨찾기 | Neighbors             |
| 📦 Pasar | 거래/문의 | Marketplace           |
| 📢 RT Pengumuman | Ketua RT 공지 | Keluharan(Kec.) Admin |
| ⚠️ Laporan | 신고/처리 결과 | Admin                 |
| 📬 Pesan | 개인 메시지 | Messages              |

---

## 🛠️ Firestore 알림 구조 예시

```json
users/{uid}/notifications/{notifId} {
  "type": "rt_announcement",
  "fromUserId": "ketuaRT123",
  "message": "Kerja bakti minggu ini",
  "relatedId": "rt_event",
  "timestamp": "...",
  "read": false,
  "priority": "high"
}
```

---

## ✅ 연계되는 user 필드 구조

| 필드명 | 역할                                    |
|--------|------|
| `uid` | 사용자 ID                                |
| `nickname` | 알림 메시지에 표시될 이름                        |
| `locationName` | Keluharan(Kec.) 기준 알림 대상 구분           |
| `trustLevel` | 특정 알림 유형(예: RT Pengumuman 전송 권한)      |
| `notificationSettings` | 알림 수신 여부: 댓글/좋아요/RT Pengumuman on/off |
| `blockedUsers` | 차단 사용자로부터 알림 차단                       |
| `readNotifications[]` | 읽은 알림 ID 저장 (옵션)                      

---

## 🔗 user 예시 JSON

```json
{
  "uid": "abc123",
  "nickname": "Dina",
  "locationName": "RW 05 - Bekasi",
  "trustLevel": "verified",
  "notificationSettings": {
    "comments": true,
    "likes": true,
    "rtPengumuman": true,
    "market": true
  },
  "blockedUsers": ["xyz456"],
  "readNotifications": ["notifId1", "notifId2"]
}
```

---

## 📌 현지화 핵심 특징

| 특징 | 설명                                          |
|------|------|
| RT Pengumuman | Kelurahan(Kec.)  공지 알림 상단 고정                |
| WhatsApp CTA | 알림 클릭 시 “WA로 공유” 가능                         |
| 관심사 연동 | 사용자 관심사 태그 기반 맞춤 알림                         |
| 우선순위 | 시스템 공지 & RT Pengumuman은 항상 `priority: high` 

---

## 📁 파일 구성 제안

| 파일명 | 설명 |
|--------|------|
| `notifications_screen.dart` | 알림 메인 |
| `notification_tile.dart` | 개별 알림 |
| `notification_model.dart` | 데이터 모델 |
| `notification_service.dart` | 생성/저장/읽음 처리 |
| `notification_settings_screen.dart` | 사용자 알림 설정 |
| `rt_announcement_manager.dart` | RT Pengumuman 전용 처리 |

---

## 📎 연결 문서

- [[Bling_TrustLevel_정책_설계안]]
- [[21. Bling_User_Field_표준]]
- [[RT Pengumuman 연동 흐름]]

---

## ✅ 결론

| 평가 | 내용                            |
|------|------|
| 지역성 | Keluharan(Kec.) 중심 지역 알림      |
| 참여성 | WhatsApp 공유 연계                |
| 필드 구조 | `user` 컬렉션에 알림 설정/차단/읽음 상태 저장 |
| UX | 단순 알림을 넘어서 참여형 흐름으로 강화        



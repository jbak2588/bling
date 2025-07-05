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


# 9_37. 신고 & 차단 정책
# 27. Bling_Report_Block_Policy

---

## ✅ 신고 & 차단 정책 개요

Bling은 Kelurahan(Kec.) 기반 신뢰 커뮤니티를 유지하기 위해  
사용자 간 신고(Report)와 차단(Block) 시스템을 제공합니다.  
이 흐름은 TrustLevel 자동 하향과 직접 연동됩니다.

---

## ✅ 신고 트리거

|대상|예시|
|---|---|
|Feed|욕설, 허위 게시물|
|Marketplace|허위 매물, 사기 의심|
|Find Friend|부적절 프로필, 스팸|
|POM|부적절 영상|
|Auction|낙찰 후 연락 두절|
|Chat|욕설, 협박, 스팸|

---

## ✅ Firestore 구조

|컬렉션|필드|
|---|---|
|`reports`|`reporterId`, `targetId`, `targetType`(post, comment, user), `reason`, `createdAt`|
|`users/{uid}`|`reportCount`, `blockList[]`|

- 신고 접수 시 `reportCount` 자동 증가
    
- 일정 기준 이상 → TrustLevel 자동 하향 ([[3_18_2. TrustLevel_Policy]])
    

---

## ✅ 차단(Block) 흐름

- 사용자는 다른 사용자를 직접 차단 가능
    
- 차단 시 `blockList[]`에 UID 저장
    
- 차단 상태:
    
    - 피드 댓글 숨김
        
    - 채팅/DM 불가
        
    - 친구찾기/이웃추천 제외
        

---

## ✅ 자동화 로직 예시

```dart
void handleReport(User user) {
  user.reportCount += 1;
  if (user.reportCount >= 3 && user.trustLevel == 'trusted') {
    user.trustLevel = 'verified';
  } else if (user.reportCount >= 5 && user.trustLevel == 'verified') {
    user.trustLevel = 'normal';
  }
}
```


## ✅ 사용자 권리

- 허위 신고 방지를 위해 반복 허위 신고자는 관리자 경고 후 차단 가능
    
- 신고 내역은 본인이 삭제할 수 없음
    

---

## ✅ 연계 문서

- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---

## ✅ 결론

Bling의 신고/차단 정책은 Kelurahan(Kec.) 기반 신뢰 구조를 유지하며,  
TrustLevel과 자동 연계되어 **커뮤니티 안전망**을 제공합니다.



### ✅ 구성 핵심

- 신고 대상/차단 대상 → 모듈별 사례로 정리
    
- `reports` 컬렉션 + User 필드 연계 (`reportCount`, `blockList[]`)
    
- TrustLevel 자동 하향 흐름 간단 로직 포함
    
- Obsidian 링크: [[21]], [[33]] 로 연결


# 9_39. 커뮤니티 가이드라인
# 30. Bling_Community_Guideline

---

## ✅ 커뮤니티 가이드라인 개요

Bling은 Kelurahan(Kec.)  기반 지역 커뮤니티로,  
모든 사용자가 **신뢰와 존중을 바탕으로 안전하게 활동**할 수 있도록  
다음 운영 원칙을 따릅니다.

---

## ✅ 기본 원칙

|항목| 설명                                                 |
|---|---|
|1️⃣ 실명성| Kelurahan(Kec.) 인증을 통한 신뢰 기반 유지                    |
|2️⃣ 존중| 지역 주민 간 비방, 욕설, 혐오 표현 금지                           |
|3️⃣ 안전| 허위 정보, 불법 거래, 사기 방지                                |
|4️⃣ 공유| 나눔/거래/소통은 정직하게                                     |
|5️⃣ 신고| 위반 시 누구나 신고 가능 ([[27. Bling_Report_Block_Policy]]) |

---

## ✅ 금지 사항

|항목|예시|
|---|---|
|불법 콘텐츠|불법 거래, 무허가 서비스 홍보|
|사칭 행위|타인 이름/프로필 도용|
|혐오 발언|인종/성별/종교 차별|
|성인물|노골적 음란물, 불법 촬영물|
|스팸|무단 광고, 도배|

---

## ✅ 신뢰 등급 연계

- 위반 시 [[3_18_2. TrustLevel_Policy]]에 따라 자동으로 등급 하향
    
- 허위 신고는 반복 시 신고자 TrustLevel 감점
    

---

## ✅ 신고/차단 흐름

- Feed, Marketplace, Club 등 모든 모듈에서 신고 가능
    
- 신고 접수 시 관리자가 내용 확인 후 조치
    
- 차단 시 해당 사용자 게시물/채팅 숨김
    

---

## ✅ 위반 시 조치

|단계|조치|
|---|---|
|경고|경미한 위반|
|제한|일시적 기능 제한 (글쓰기/채팅)|
|차단|계정 정지 또는 영구 탈퇴 처리|

---

## ✅ 연계 문서

- [[27. Bling_Report_Block_Policy]]
    
- [[3_18_2. TrustLevel_Policy]]
    
- [[22. Bling_Privacy_Policy]]
    

---

## ✅ 결론

Bling은 Kelurahan(Kec.)  기반의 지역 신뢰 커뮤니티로,  
**가이드라인 준수 → 신뢰도 유지 → 안전한 슈퍼앱**을 목표로 운영됩니다.



### ✅ 구성 핵심

- 지역 커뮤니티 원칙 → 실명성 + 존중 + 안전 + 공유
    
- 금지 항목 구체 예시 포함
    
- 신고/차단/TrustLevel 하향 로직과 직접 연계
    
- [[27]], [[33]] 링크로 흐름 통일



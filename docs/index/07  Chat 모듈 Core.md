# 3_21. users {uid}
users/{uid}

**1. Firestore `users/{uid}` 최종 필드 구조:**

| 필드명                | 데이터 타입         | 설명                                      | 근거 문서                    |
| ------------------ | -------------- | --------------------------------------- | ------------------------ |
| `uid`              | `String`       | Firebase Authentication UID             | my_profile_screen_설계안.md |
| `nickname`         | `String`       | 앱에서 사용할 공개 닉네임                          |                          |
| `email`            | `String`       | 로그인 시 사용하는 이메일                          |                          |
| `photoUrl`         | `String`       | 프로필 사진 이미지 URL                          |                          |
| `bio`              | `String`       | 자기소개 (선택)                               |                          |
| `trustLevel`       | `String`       | 신뢰등급 ('regular', 'verified', 'trusted') |                          |
| `locationName`     | `String`       | 대표 위치명 (예: RW 05 - Panunggangan)        |                          |
| `locationParts`    | `Map`          | 상세 주소 (rt, rw, kelurahan 등)             |                          |
| `geoPoint`         | `GeoPoint`     | 지도 검색을 위한 좌표값                           |                          |
| `interests`        | `List<String>` | 관심사 태그 배열                               |                          |
| `privacySettings`  | `Map`          | 개인정보 공개 설정 (지도 노출 동의 등)                 |                          |
| `profileCompleted` | `Boolean`      | 프로필 필수 정보 입력 여부 (지연된 활성화용)              |                          |
| `createdAt`        | `Timestamp`    | 계정 생성일                                  |                          |

```dart
// lib/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String trustLevel;
  final String? locationName;
  // locationParts, privacySettings 등 Map 타입 필드 추가
  final List<String>? interests;
  final bool profileCompleted;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.trustLevel,
    this.locationName,
    this.interests,
    required this.profileCompleted,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: data['uid'] ?? '',
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      trustLevel: data['trustLevel'] ?? 'regular',
      locationName: data['locationName'],
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,
      profileCompleted: data['profileCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
```


# 5_29. Location_계층형_카테고리_구성 1
# 🗂️ Bling_Location_계층형_카테고리_구성.md

## ✅ 목적

Bling 프로젝트는  Keluharan(Kel.) 기반 지역 SNS 특성상  
위치 정보의 신뢰성과 검색 효율성을 동시에 만족시키기 위해  
**RT/RW(옵션) → Kelurahan → Kecamatan → Kabupaten**의 계층형 카테고리 구조를 표준으로 적용한다.

---

## 🔑 계층 구조

| 단계             | 예시                  |
| -------------- | ------------------- |
| RT[]           | RT.03               |
| RW[]           | RW.05               |
| Kelurahan      | Panunggangan Barat  |
| Kecamatan      | Cibodas             |
| Kabupaten/Kota | Kabupaten Tangerang |
| Province       | Banten              |

---

## 🗂️ Firestore 구조 예시

```plaintext
kecamatan/{kecamatanId}
  kelurahan/{kelurahanId}
    rw/{rwId}
      rt/{rtId}
        posts/{postId}
```

또는

```plaintext
posts/{postId}
  필드:
    rt: RT.03
    rw: RW.05
    kelurahan: Panunggangan Barat
    kecamatan: Cibodas
    kabupaten: Kabupaten Tangerang
    province: Banten
```

---

## 📌 게시물 필드 구조

| 필드명 | 값 | 설명 |
|--------|-----|------|
| rt | RT.03 | RT |
| rw | RW.05 | RW |
| kelurahan | Panunggangan Barat | Kelurahan |
| kecamatan | Cibodas | Kecamatan |
| kabupaten | Kabupaten Tangerang | Kabupaten |
| province | Banten | Provinsi |
| locationName | RT.03/RW.05 - Panunggangan Barat, Kec. Cibodas | 표기 |
| location | GeoPoint | 반경 쿼리용 |

---

## 🔍 쿼리 흐름 예시

| 시나리오                 | 쿼리                                        |
| -------------------- | ----------------------------------------- |
| 내 Keluharan(Kec.) 글만 | 옵션 `where rt == 'RT.03' && rw == 'RW.05'` |
| Kelurahan 단위         | `where kelurahan == 'Panunggangan Barat'` |
| Kecamatan 단위         | `where kecamatan == 'Cibodas'`            |

---

## ✅ 데이터 입력 정책

1️⃣ **Kelurahan(Kec.) 는 사용자가 직접 선택 (RT/RW 옵션)**  
2️⃣ **Kelurahan, Kecamatan은 GPS Reverse Geocode로 자동 파악**  
3️⃣ **Kabupaten/Kota, Province는 자동 저장**

---

## 🔗 카테고리 혼합 구조

| 필드 | 예시 |
|------|------|
| category | lostFound, market, announcement 등 |
| rt, rw, kelurahan, kecamatan | 위치 계층 필드 |

---

## 📌 활용 예시

- Kelurahan(Kec.) 기반 커뮤니티 피드 → **내 동네**
- Kecamatan 기반 → **Nearby Feed**
- Kabupaten 단위 → **행정단위별 통계**

---

## 📂 **실제 Post 구조 샘플**

```
json

{
  "postId": "abc123",
  "userId": "uid123",
  "title": "잃어버린 강아지를 찾습니다",
  "body": "...",
  "category": "lostFound",           // 고정 카테고리
  "tags": ["강아지", "RT05"],         // 사용자 자유 태그
  "rt": "RT.03",
  "rw": "RW.05",
  "kelurahan": "Panunggangan Barat",
  "kecamatan": "Cibodas",
  "kabupaten": "Kabupaten Tangerang",
  "province": "Banten",
  "location": GeoPoint
}

```


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



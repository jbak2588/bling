# 2_99. Bling 공통 기능(로직) 카테고리 (필수) 1 1

---

## ✅ 📌 Bling 공통 기능(로직) 카테고리 (필수)

|구분| 설명                                                                 |
|---|---|
|**등록 (Create)**| 글/상품/경매/구인공고/클럽/쇼츠 등 새 데이터 Firestore에 저장                           |
|**수정 (Update)**| 작성한 글/상품/프로필/공고 내용 변경                                              |
|**조회 (Read)**| 목록/상세/필터링/반경 검색                                                    |
|**삭제 (Delete)**| 내가 쓴 글/상품/공고/댓글 삭제                                                 |
|**댓글 + 대댓글 (Comment + Reply)**| Feed/Shorts/Club 내 댓글/대댓글                                          |
|**채팅 (Chat)**| 1:1 메시지 (Feed, Marketplace, Find Friend 등)                         |
|**Wishlist (찜)**| 상품/게시물/상점 등 찜/북마크/좋아요                                              |
|**좋아요 (Like)**| 게시글/댓글/쇼츠 좋아요, 찜과 별도로 카운트                                          |
|**신고/차단 (Report/Block)**| 사용자/게시글/댓글 신고, 사용자 차단                                              |
|**알림 (Notification)**| 실시간 푸시 & In-App 알림                                                 |
|**검색/필터 (Search/Filter)**| 키워드, 위치, 카테고리, 해시태그 필터                                             |
|**TrustLevel/인증 흐름**|  Keluharan(Kel.)  인증/실명/활동 신뢰등급 자동 로직                              |
|**프로필/Privacy 제어**| 내 정보 공개범위, 지도 노출 여부                                                |
|**Opt-in/Opt-out**| 지도 공개/데이팅 프로필/히트맵 동의/철회                                            |
|**다국어 처리 (i18n)**| `.json` Key 관리, `easy_localization`                                |
|**AI 검수**| 이미지/텍스트/영상 AI 태깅 & 필터링                                             |
|**통계/카운트**| 조회수, 댓글수, 좋아요수, 신뢰점수 등 자동 카운팅                                      |
|**활동 히스토리**| `users/{uid}/` 하위 컬렉션 (`posts`, `comments`, `wishlist`, `chats` 등) |

---

## ✅ 📌 Planner님이 언급한 핵심 흐름 요약

✔️ CRUD (등록/수정/조회/삭제) ➜ **기본 뼈대**

✔️ 채팅, 댓글, 찜 ➜ **상호작용 핵심**

✔️ TrustLevel, 신고/차단, Privacy ➜ **안전/신뢰 핵심**

✔️ AI 검수 ➜ **질관리 핵심**

✔️ 알림 ➜ **사용자 연결성 핵심**

---

## ✅ 🔑 결론

Planner님 말씀처럼 실제 Bling은  
“**CRUD + 상호작용(댓글/찜/좋아요/채팅) + TrustLevel + 알림 + AI 검수**”  
이 5대 공통 흐름으로 모든 Feature가 재활용가능.

---

## ✅ 📌 Bling 공통 모듈화 예시

---

### 🗂️ 1️⃣ `core/` : _전역 공통 로직/데이터 규칙_

```plaintext
lib/
 ├── core/
 │    ├── constants/           # 앱 공통 상수, 컬러, 카테고리
 │    │    ├── app_colors.dart
 │    │    ├── app_categories.dart
 │    │    ├── trust_level.dart
 │    │    └── app_strings.dart (기본 고정 텍스트)
 │    ├── models/              # 전역 데이터 모델
 │    │    ├── user_model.dart
 │    │    ├── post_model.dart
 │    │    ├── product_model.dart
 │    │    ├── comment_model.dart
 │    │    ├── chat_model.dart
 │    │    ├── notification_model.dart
 │    │    └── trust_log_model.dart
 │    ├── utils/               # 공통 Helper & Validator
 │    │    ├── firestore_helpers.dart
 │    │    ├── geo_helpers.dart
 │    │    ├── trust_level_utils.dart
 │    │    ├── ai_check_utils.dart
 │    │    ├── validators.dart
 │    │    └── i18n_helper.dart
 │    ├── services/            # 외부 연계 서비스 로직
 │    │    ├── firebase_service.dart
 │    │    ├── notification_service.dart
 │    │    ├── chat_service.dart
 │    │    ├── report_service.dart
 │    │    ├── ai_moderation_service.dart
 │    │    └── analytics_service.dart
```

---

### 🗂️ 2️⃣ `shared/` : _반복 UI, Controller, 공통 위젯_

```plaintext
lib/
 ├── features/
 │    ├── shared/
 │    │    ├── controllers/                # 공용 상태 관리자
 │    │    │    ├── locale_controller.dart
 │    │    │    ├── auth_controller.dart
 │    │    │    ├── notification_controller.dart
 │    │    │    ├── chat_controller.dart
 │    │    │    ├── wishlist_controller.dart
 │    │    │    └── trustlevel_controller.dart
 │    │    ├── widgets/                    # 공통 위젯
 │    │    │    ├── custom_button.dart
 │    │    │    ├── custom_dialog.dart
 │    │    │    ├── confirm_modal.dart
 │    │    │    ├── icon_badge.dart
 │    │    │    ├── profile_avatar.dart
 │    │    │    └── loading_spinner.dart
 │    │    ├── guards/                     # 인증/권한 가드
 │    │    │    ├── trustlevel_guard.dart
 │    │    │    ├── message_permission_guard.dart
 │    │    │    ├── blocklist_guard.dart
 │    │    │    └── ai_verified_guard.dart
```

---

## ✅ 🔑 실무 포인트

✔️ **`core/`는 데이터 + 서비스 로직**

- Dart 모델, Firestore 쿼리 Helper, AI 검수 로직, TrustLevel 자동계산 전부 여기 포함.
    

✔️ **`shared/`는 공통 UI + 상태관리 + 조건 가드**

- 반복되는 버튼, 프로필 위젯, 권한 제한 모듈, Locale/Notification 전역 Controller.
    

---

## ✅ 🔍 예시 흐름

- ✔️ `features/local_news` → `PostModel`(core/models) → `firestore_helpers.dart`로 쿼리
    
- ✔️ `features/post` → `validators.dart` → 작성폼 유효성 체크
    
- ✔️ `features/chat` → `chat_service.dart` → Firestore 채팅방 생성
    
- ✔️ `features/marketplace` → `wishlist_controller.dart`로 찜 기능
    
- ✔️ TrustLevel 조건 → `trustlevel_guard.dart`로 메시지 권한 차단
    

---

## ✅ 📎 확장성

필요하다면 `services/` 아래에:

- WhatsApp 공유 모듈 (`share_service.dart`)
    
- 반경 검색 전용 모듈 (`geo_query_service.dart`)
    

같이 붙여서 **실무에서 모듈 쪼갤 수 있음**.

---

## ✅ 결론

이렇게 하면 Bling의 모든 Feature는:

- **CRUD + 댓글 + 찜 + 채팅 + 신고 + 알림 + TrustLevel + AI 검수**  
    ➡️ 전부 `core/`와 `shared/`에서 재사용 ➜ **코드 중복 0%**.
    

---

```json
{
    "lib": {
        "core": {
            "constants": [
                "app_colors.dart",
                "app_categories.dart",
                "trust_level.dart",
                "app_strings.dart"
            ],
            "models": [
                "user_model.dart",
                "post_model.dart",
                "product_model.dart",
                "comment_model.dart",
                "chat_model.dart",
                "notification_model.dart",
                "trust_log_model.dart"
            ],
            "utils": [
                "firestore_helpers.dart",
                "geo_helpers.dart",
                "trust_level_utils.dart",
                "ai_check_utils.dart",
                "validators.dart",
                "i18n_helper.dart"
            ],
            "services": [
                "firebase_service.dart",
                "notification_service.dart",
                "chat_service.dart",
                "report_service.dart",
                "ai_moderation_service.dart",
                "analytics_service.dart"
            ]
        },
        "features": {
            "shared": {
                "controllers": [
                    "locale_controller.dart",
                    "auth_controller.dart",
                    "notification_controller.dart",
                    "chat_controller.dart",
                    "wishlist_controller.dart",
                    "trustlevel_controller.dart"
                ],
                "widgets": [
                    "custom_button.dart",
                    "custom_dialog.dart",
                    "confirm_modal.dart",
                    "icon_badge.dart",
                    "profile_avatar.dart",
                    "loading_spinner.dart"
                ],
                "guards": [
                    "trustlevel_guard.dart",
                    "message_permission_guard.dart",
                    "blocklist_guard.dart",
                    "ai_verified_guard.dart"
                ]
            }
        }
    }
}
```


# 3_21. users {uid} 1
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


# 5_32. Privacy_Map_정책 1
# 🗺️ Privacy_Map_정책.md

---

## ✅ 목적

Bling는 Kelurahan(Kec.) 기반 슈퍼앱으로,
위치 정보(지도 기반 히트맵)와 사용자 개인정보 보호를 동시에 보장해야 합니다.

---

## ✅ 지도 기능

- Kelurahan(Kec.)  기반 사용자 밀집도 HeatMap
- 좌표 직접 노출 불가
- 지도 기반 범위: Kelurahan → Kecamatan → Kabupaten → Province
- Opt-in: 사용자 동의 후 노출

---

## ✅ 옵트인 & Privacy Center

- "지도에 내 이름/프로필 표시 허용" 옵션 제공
- 동의 철회 즉시 히트맵/검색에서 제외
- `users/{uid}` → `privacySettings` 필드
- 개인정보센터 메뉴:  Keluharan(Kel.) , Geo, TrustLevel 동의 상태 관리

---

## ✅ 법적 기준

- 인도네시아 PDP 법 준수
- KTP 직접 촬영/전체 저장 금지
- Kelurahan(Kec.)  인증은 공공 주소 인증만 허용

---

## ✅ 결론

블링 지도 기능은 **히트맵 + 옵트인 + Privacy Center**로
안전성과 지역성을 모두 유지합니다.


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



# 2_99. Bling 공통 기능(로직) 카테고리 (필수) 1 1 1

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


# 7_04. Bling_Marketplace_Policy
# 

---

## ✅ Marketplace 개요

Bling Marketplace는 Keluharan(Kec.) 기반으로 운영되는  
**중고 & 신상품 거래 + AI 검수** 로컬 마켓입니다.  
Nextdoor의 Feed 구조와는 달리 **판매와 거래**가 중심이며,  
1:1 채팅, 찜(Wishlist), 신뢰등급 연계가 핵심입니다.

---

## ✅ 주요 기능

| 기능            | 상태                                                                                                         |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| 중고물품 등록       | ✔️ 초기 버전 완성                                                                                                |
| 카테고리 구조       | ✔️ Firestore 컬렉션 + CSV 설계                                                                                  |
| 상품 상세         | ✔️ 이미지, 설명, 가격 필드                                                                                          |
| 좋아요/찜         | ✔️ `likesCount` 필드, Wishlist 연계 예정                                                                         |
| 조회수           | ✔️ `viewsCount` 필드                                                                                         |
| 1:1 채팅        | ✔️ `chats` 컬렉션 연동                                                                                          |
| AI 검수         | ❌ 기획 완료, 모듈 미구현                                                                                            |
| TrustLevel 연계 | ❌ 판매자 신뢰등급 연동 예정                                                                                           |
| 다국어 카테고리      | ✔️ assets<br>       ├── lang<br>       │   ├── en.json<br>       │   ├── id.json<br>       │   └── ko.json |

---

## ✅ Firestore 구조

|컬렉션|필드|
|---|---|
|`products`|`title`, `description`, `images[]`, `price`, `likesCount`, `viewsCount`, `isAiVerified`, `chatCount`|
|위치|`latitude`, `longitude`, `address`|
|상태|`status` (`selling`, `sold`)|
|소유자|`userId`, `userName`|
|카테고리|`categories` → `name_en`, `name_id`, `parentId`, `order`|
|채팅|`chats/{chatId}/messages` → `participants[]`, `lastMessage`|

---

## ✅ AI 검수 상태

- `isAiVerified` 필드만 존재
    
- 이미지 허위 여부, 중복 매물 탐지 기능 미구현
    
- 추후 AI 태깅, 라벨링 자동화 예정
    
# Preloved Item AI 검수 안전거래 플로우 (보완)

### 📌 등록 흐름 요약

사용자는 새상품/중고상품 등록 시 반드시 "Preloved Item AI 검수 안전거래 등록" 옵션을 선택할 수 있다.

- 일반 등록: 빠른 등록, 수수료 없음
    
- AI 검수 등록: AI 품질 검수, 동일성 확인, 에스크로 안전보장, 상단 노출, 소정의 수수료 발생
    

### ✅ 판매자 흐름

1. 등록 버튼 → 위치 인증 (GPS)
    
2. 일반/AI 등록 선택 탭 → 각 설명 및 수수료 고지
    
3. AI 검수 등록 선택 시 이미지 업로드 → AI 품질 분석 → 수정 권고 반영
    
4. 필수 사진/폼 자동 생성 → 사용자 입력/동의 → 최종 Firestore 저장 (`isAiVerified: true`)
    
5. AI 등록 상품은 최신순 상단 + 배지 노출
    

### ✅ 구매자 흐름

1. AI 검수 Preloved Item 선택 → 10% 선입금 예약 → PG사 에스크로 연동
    
2. 구매자 신뢰도/위치 이력 확인 → 예약 차단 로직 포함
    
3. 현장 인수 시 동일성 검증 (다중 각도 사진 AI 비교)
    
4. 동일성 일치 시 잔금 입금 → 거래 성사 → 에스크로 해제
    
5. 동일성 불일치 시 수수료 일부 차감 후 잔액 환불

![[Pasted image 20250702155122.png]]

### ✅ 연계 구조

- Firestore: `products` 컬렉션 `isAiVerified` 필드, `status`
    
- PG사 API: 예약, 선입금, 잔금 관리
    
- AI 서버: 이미지 품질 검수, 동일성 분석
    

### ✅ 결론

Bling Marketplace는 일반 중고등록과 달리 "Preloved Item AI 검수 안전거래"를 통해 믿을 수 있는 안전 거래를 제공합니다. 사용자 신뢰 점수, 위치 인증, 동일성 재검증까지 한 번에 반영됩니다.






---

## ✅ TODO & 개선

1️⃣ `users/{uid}/wishlist` 구조 설계 → 좋아요/찜 내역 저장  
2️⃣ `users/{uid}/products` → 판매 히스토리 연동  
3️⃣ AI 이미지 검수 모듈 연계  
4️⃣ 카테고리 다국어 JSON 연결  
5️⃣ TrustLevel → 판매자 신뢰도 & 리뷰 연동

---

-  `products` 컬렉션 필드 최종 표준화 (`isAiVerified` 포함)
    
-  AI 이미지 검수 로직 설계 & 연계
    
-  거래 상태(`selling`/`sold` / reserverd / hide ) 변경 UI 완료
    
-  가격 협상 옵션 및 필드 (`negotiable`) 테스트
    
## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[6_03. Bling_Local_Feed_Policy & To-Do 목록]]
    
- [[4_21. User_Field_Standard]] → User ID, 위치 필드 연결
- [[3_18_2. TrustLevel_Policy]] → 판매자 신뢰 등급 조건
- Firestore: `products`, `users/{uid}/wishlist`

---

## ✅ 결론

Bling Marketplace는 **중고/신상품 거래, AI 검수, 신뢰등급 구조**를 하나로 결합한  
**Keluharan(Kec.) 기반 로컬 마켓 허브**입니다.  
기본 등록/상세/채팅은 완성되어 있으며, TrustLevel/Wishlist/AI 모듈로  
고도화가 진행됩니다.


# 7_06. product_model.dart

// lib/core/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 앱의 Marketplace 상품에 대한 표준 데이터 모델 클래스입니다.
/// Firestore의 'products' 컬렉션 문서 구조와 1:1로 대응됩니다.
class ProductModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String categoryId;
  final int price;
  final bool negotiable; // 가격 협상 가능 여부
  final String? condition; // 'new', 'used' 등 상품 상태
  final String status; // 'selling', 'reserved', 'sold' 등 거래 상태

  final String? locationName;
  final Map<String, dynamic>? locationParts;
  final GeoPoint? geoPoint;

  final bool isAiVerified; // AI 검수 여부
  final int likesCount;
  final int chatsCount;
  final int viewsCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.categoryId,
    required this.price,
    this.negotiable = false,
    this.condition,
    this.status = 'selling',
    this.locationName,
    this.locationParts,
    this.geoPoint,
    this.isAiVerified = false,
    this.likesCount = 0,
    this.chatsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore 문서로부터 ProductModel 객체를 생성합니다.
  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      categoryId: data['categoryId'] ?? '',
      price: data['price'] ?? 0,
      negotiable: data['negotiable'] ?? false,
      condition: data['condition'],
      status: data['status'] ?? 'selling',
      locationName: data['locationName'],
      locationParts: data['locationParts'] != null
          ? Map<String, dynamic>.from(data['locationParts'])
          : null,
      geoPoint: data['geoPoint'],
      isAiVerified: data['isAiVerified'] ?? false,
      likesCount: data['likesCount'] ?? 0,
      chatsCount: data['chatsCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// ProductModel 객체를 Firestore에 저장하기 위한 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'price': price,
      'negotiable': negotiable,
      'condition': condition,
      'status': status,
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'isAiVerified': isAiVerified,
      'likesCount': likesCount,
      'chatsCount': chatsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

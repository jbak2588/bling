
---


# 📌 Bling FindFriend Module Feature Spec (최종)

---

## ✅ 목적

- Bling 앱의 3번째 컨텐츠 `FindFriends` 기능을 정식으로 구성.
- 지역 기반 공개 프로필 / 친구찾기 / 연인찾기 요소를 안전하게 제공.
- `My Bling` 내 `Friends` 영역과 연결.
- **Follow는 게시물/피드 전용이며, 친구 요청/매칭과는 전혀 관계 없음.**

---

## ✅ 폴더 구조 (실제 프로젝트 기준)

```

/lib/core  
├─ models/  
│ ├─ user_model.dart  
│ ├─ findfriend_model.dart

/lib/features/findfriend  
├─ repositories/  
│ ├─ findfriend_repository.dart

├─ screens/  
│ ├─ findfriends_screen.dart  
│ ├─ findfriend_profile_form.dart  
│ ├─ findfriend_profile_detail.dart  
│ ├─ friend_requests_screen.dart // ✅ 친구 요청 관리용

````

---

## ✅ 모델 : `findfriend_model.dart`

### 필수 필드

- `userId`
- `nickname`
- `profileImages[]` (최소 1장, 최대 10장)
- `location`
- `interests[]`
- `ageRange`
- `gender`
- `bio`
- `isDatingProfile` (연인찾기 모드 On/Off)
- `isNeighborVerified`
- `trustLevel`

> 🔑 `Follow` 상태는 게시물 전용. 친구요청 상태는 `/match_requests`로 관리.

```dart
class FindFriend {
  final String userId;
  final String nickname;
  final List<String> profileImages;
  final String? location;
  final List<String>? interests;
  final String? ageRange;
  final String? gender;
  final String? bio;
  final bool isDatingProfile;
  final bool isNeighborVerified;
  final int trustLevel;

  FindFriend({...});
  factory FindFriend.fromDoc(...) {...}
  Map<String, dynamic> toJson() {...}
}
````

---

## ✅ 친구 요청 & 자동 매칭 핵심 흐름

| 단계             | 설명                                                                                                                                        |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| 1️⃣ 리스트 노출     | `findfriends_screen.dart`에서 내 프로필 조건이 완성되면 주변 카드 리스트 출력   (따라서 findfriend_screen.dart 첫 화면은 주변 친구 리스트를 보기 위해서는 내 프로필 등록이 먼저라는 안내화면이어야 함 ) |
| 2️⃣ 좋아요(친구 요청) | 각 카드에서 `좋아요` 또는 `친구 신청` 버튼 → `/match_requests` 컬렉션에 상태 저장                                                                                 |
| 3️⃣ 상대 수락/거절   | 상대방은 `friend_requests_screen.dart` 에서 `수락` 또는 `거절`                                                                                        |
| 4️⃣ 자동 매칭 & 채팅 | 수락 시 `/chats` 컬렉션에 1:1 채팅방 자동 생성                                                                                                          |
| 5️⃣ 좋아요 관리     | `나를 좋아요한 사람`, `내가 좋아요한 사람` → `match_requests` 상태별 필터링으로 제공                                                                                |

## ✅ 📌 ✔️ 첫 화면 안내 문구 예시

아래 문구 예시는 **앱 화면 다국어 키로 쓰기 좋게** 짧고 직관적으로 적어드립니다.

---

### ✅ 기본 안내 문구 (한글)

> “주변 친구 리스트를 보려면 내 프로필을 먼저 등록해주세요.”

**보조 문구:**

> “프로필을 작성하면 관심사와 지역 기반으로 내 주변 이웃과 친구를 찾을 수 있어요.”

**버튼:**

> `[프로필 등록하기]`

---

### ✅ 영어 버전 (i18n)

> “Complete your profile to see nearby friends.”

**보조 문구:**

> “Add your age, gender, location, interests, and at least one photo to find friends in your area.”

**버튼:**

> `[Create My Profile]`

---

### ✅ 추천 다국어 키 구조

findfriend.intro.title: "주변 친구 리스트를 보려면 내 프로필을 먼저 등록해주세요."
findfriend.intro.subtitle: "프로필을 작성하면 관심사와 지역 기반으로 내 주변 이웃과 친구를 찾을 수 있어요."
findfriend.intro.button: "프로필 등록하기"

findfriend.intro.title.en: "Complete your profile to see nearby friends."
findfriend.intro.subtitle.en: "Add your age, gender, location, interests, and at least one photo to find friends in your area."
findfriend.intro.button.en: "Create My Profile"

id.json도  추가바람. 


---

## ✅ Firestore 구조

- `/users` → `findfriend` 필드 포함 (`profileImages[]`, `ageRange` 등)
    
- `/match_requests`
    
    - `fromUserId`
        
    - `toUserId`
        
    - `status` : `pending` | `accepted` | `rejected`
        
    - `createdAt`
        
- `/chats` → 기존 구조 재활용
    
- `/follows` → **게시물/피드 전용 팔로우** (FindFriend와 무관)
    

---

## ✅ 리포지토리 : `findfriend_repository.dart`

- **Create/Update** : 내 FindFriend 프로필 등록/수정
    
- **Read** : 주변 사용자 리스트 스트림 (GEO 쿼리 포함 예정)
    
- **Delete** : Soft Delete (`isDatingProfile` → false)
    
- **친구 요청**
    
    - `sendFriendRequest(fromUserId, toUserId)`
        
    - `acceptFriendRequest(requestId)`
        
    - `getLikedMe(userId)` (나를 좋아요한 사람)
        
    - `getILiked(userId)` (내가 좋아요한 사람)
        
    - `createChatRoom(userId1, userId2)` (수락 시 자동 채팅 생성)
        

```dart
class FindFriendRepository {
  Future<void> saveProfile(FindFriend profile) {...}
  Stream<List<FindFriend>> getNearbyFriends() {...}
  Future<void> deleteProfile(String userId) {...}

  Future<void> sendFriendRequest(String fromUserId, String toUserId) {...}
  Future<void> acceptFriendRequest(String requestId) {...}
  Stream<List<FindFriend>> getLikedMe(String userId) {...}
  Stream<List<FindFriend>> getILiked(String userId) {...}
  Future<void> createChatRoom(String userId1, String userId2) {...}
}
```

---

## ✅ 스크린

### `findfriends_screen.dart`

- 주변 이웃/친구 카드 리스트 출력.
    
- `좋아요`(친구 요청) 버튼 포함.
    
- GEO 쿼리/TrustLevel/관심사 매칭 필터링 포함 예정.
    

### `findfriend_profile_form.dart`

- 내 프로필 등록 & 수정 Form.
    
- 필수: `ageRange`, `gender`, `location`, `interests[]`, `profileImages[]` ≥ 1.
    
- 저장 시 Firestore `/users`에 병합.
    

### `findfriend_profile_detail.dart`

- 타인 프로필 상세 페이지.
    
- `좋아요(친구 요청)` 버튼 표시.
    
- 팔로우 버튼 제거 → Follow는 FindFriend 흐름과 분리.
    

### `friend_requests_screen.dart` **(신규)**

- 받은 요청 리스트 (`status: pending`)
    
- 수락/거절 버튼 → 수락 시 자동 채팅 생성
    
- 내가 보낸 요청 목록 → 상태 확인 가능
    

---

## ✅ 게이트 조건

- 내 `FindFriendProfile` 완성되지 않으면 카드 리스트 접근 차단.
    
- `My Bling` → `Edit Friend Profile`로 유도.
    
- 하루 친구 요청 최대 3건 제한 → Abuse 방지.
    
- 수락 시 FCM 알림 발송.
    

---

## ✅ i18n

- 모든 Label/Text는 `Design Guide + i18n 규칙.md` 참조.
    
- 버튼/상태 텍스트 다국어 키 관리 필수.
    

---

## ✅ 개발자 주의사항

- `Follow`는 게시물/피드 전용 → 친구 요청 로직과 절대 혼용 금지.
    
- Firestore Security Rule: `/users/{uid}`, `/match_requests` 권한 별도 관리.
    
- GEO 쿼리/Matching Score 로직은 별도 Proof 예정.
    

---

## ✅ 릴리즈 조건 (MVP)

- 내 프로필 등록/수정/삭제 100% 작동
    
- 주변 카드 리스트 조회 + GEO 필터링 작동
    
- `좋아요(친구 요청)` → 수락/거절 → 자동 채팅 연동
    
- `나를 좋아요한 사람`, `내가 좋아요한 사람` 목록 출력
    
- Follow와 친구요청/매칭 흐름 분리 완료
    

---

## 🔑 결론

> **FindFriend = 프로필 → 좋아요 → 수락 → 자동 매칭 → 채팅**
> 
> > **Follow = 피드/포스트 전용 구독 알림**

---


## **최소 체크리스트**

✔️ **조건 게이트 흐름**: “내 프로필 없으면 리스트 차단 → 안내 문구 → 프로필 작성으로 이동” → OK  
✔️ **좋아요 흐름**: `/match_requests` 컬렉션 구조와 상태값, 하루 제한까지 명시 → OK  
✔️ **자동 채팅**: 수락 시 `/chats` 자동 생성 → OK  
✔️ **Follow = 게시물 전용** 강조 → OK  
✔️ **FCM 알림**: 수락 시 발송 → OK  
✔️ **보조 스크린 (받은 요청/보낸 요청)**: `friend_requests_screen.dart`로 커버 → OK  
✔️ **Security & Abuse 제한 조건**: 하루 3건 제한, Security Rule 별도 → OK


// ✅ Example: 조건 검증 if 예시
// if (profile.ageRange == null || profile.profileImages.isEmpty) { showIntroScreen(); }



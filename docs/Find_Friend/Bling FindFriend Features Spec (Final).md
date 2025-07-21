# 📌 Bling FindFriend Features Spec (Final)

작성일: 2025-07-14  
작성자: Planner

---

## ✅ 1️⃣ 진입 조건 및 프로필 등록 흐름

### 🔹 진입 조건

- user_model `isDatingProfile == false`일 경우, 추가 정보 입력 화면으로 이동
    

### 🔹 추가 입력 필드

|필드|필수 여부|설명|
|---|---|---|
|age|✅|실제 나이 (표시 및 상대 필터용)|
|ageRange|✅|친구찾기 허용 나이대 범위 (예: "25-34")|
|findfriend_profileImages[]|✅|추가 이미지 (최소 1장, 최대 9장)|

### 🔹 기존 정보 Display (수정 불가)

- nickname
    
- bio
    
- locationName (Kab 단위)
    

### 🔹 저장 시 동작

- 위 3개 필드 완료 시 저장 버튼 활성화
    
- user_model 업데이트:
    
    - isDatingProfile = true
        
    - age, ageRange
        
    - findfriend_profileImages[]
        

## ✅ 2️⃣ FindFriend 리스트 조회 조건

|조건|설명|
|---|---|
|isDatingProfile == true|친구찾기 활성화 유저만 조회|
|neighborhoodVerified == true|위치 인증된 유저 (Kab 단위 필터)|
|locationParts.kab 기준|동일 Kab 단위 내에서 노출|

## ✅ 3️⃣ 프로필 노출 필드 (카드)

|필드|용도|
|---|---|
|nickname|이름|
|age|나이|
|locationName (Kab)|지역 표시|
|profileImageUrl + findfriend_profileImages[]|대표 + 추가 이미지|
|trustLevel|신뢰등급 표시|

## ✅ 4️⃣ 좋아요 (Like) 기능

|동작|제한/규칙|
|---|---|
|1인당 1회|재요청 불가, 취소 가능|
|취소 시 -1|다시 +1 가능|
|카운트 저장|각 프로필 별 likeCount|
|My Bling 에서 내가 좋아요 누른 리스트 조회 가능|likesGiven[] 저장|

## ✅ 5️⃣ 친구 요청 (Friend Request)

|요청|수락/거절|
|---|---|
|1:1 요청|요청 상태 저장 (pending, accepted, rejected)|
|수락 시|자동 채팅방 생성 (chats/{chatId})|
|거절 시|상태 변경 (rejected), 재요청 불가|
|My Bling 에서 받은 요청, 수락한 요청 리스트 조회 가능|friendRequests[], friends[]|

## ✅ 6️⃣ My Bling 리스트 구분

|구분|기준 필드|
|---|---|
|내가 좋아요 누른 사람|likesGiven[]|
|받은 친구 요청 (대기중)|friendRequests[] (pending)|
|수락한 친구|friends[]|
|받은 좋아요|likesReceived[]|

## ✅ 7️⃣ user_model 관련 필드 예시

```json
{
  "isDatingProfile": true,
  "age": 33,
  "ageRange": "25-34",
  "gender": "male",
  "findfriend_profileImages": ["url1", "url2"],
  "likesGiven": ["user123", "user456"],
  "likesReceived": ["user789"],
  "friendRequests": [
    { "from": "user123", "status": "pending" },
    { "from": "user456", "status": "accepted" }
  ],
  "friends": ["user456"],
  "likeCount": 3
}
```

## ✅ 8️⃣ 프로세스 UX 흐름 요약

```plaintext
1️⃣ isDatingProfile == false
 → 추가정보 입력 (age, ageRange, images)
 → 저장 시 isDatingProfile == true

2️⃣ isDatingProfile == true
 → 지역(Kab) 기반 유저 리스트 노출
 → 프로필 상세 (like, 친구요청 가능)

3️⃣ 좋아요 or 친구요청 진행
 → 좋아요는 중복 불가 (취소/재요청 가능)
 → 친구요청 수락 시 1:1 채팅 자동 생성
```

## ✅ 9️⃣ 권장 DB 관리 구조

|항목|이유|
|---|---|
|likes|Firestore 별도 collection으로 관리 추천|
|friendRequest|별도 collection 추천|
|user_model에는 ID만 유지|구조 단순화 유지|

## ✅ 10️⃣ 파일 구조 (예시)

```
features/find_friends/
├── screens/
│   ├── find_friends_screen.dart        // 리스트 조회, 내 위치 기반 카드 노출
│   ├── findfriend_form_screen.dart     // 최초 프로필 등록 (isDatingProfile == false)
│   ├── findfriend_edit_screen.dart     // 내 프로필 수정 (추가 이미지, age, ageRange)
├── widgets/
│   ├── findfriend_card.dart            // 유저 카드 구성 요소 (닉네임, 나이, 지역, 이미지 등)
```

### 🔹 findfriend_edit_screen.dart 추가 요구사항

- 내 프로필에서 **"리스트에 내 프로필 노출하지 않기"** 토글 추가 (isVisibleInList: true/false)
    
- 토글이 off일 경우, find_friends_screen.dart에서는 해당 유저 제외
    

## ✅ 결론

이 스펙을 기준으로 Bling FindFriend 기능을 전면 구현하며, 기존 matchProfile, findfriend 구조는 폐기한다.
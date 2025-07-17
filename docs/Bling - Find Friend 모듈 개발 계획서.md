Planner님을 위한 **Bling 앱 – Find Friend 모듈 개발 계획서** 초안을 Obsidian 호환 `.md` 형식으로 아래와 같이 구성했습니다.  
실제 모듈 분리, 우선순위, 역할 분담이 가능하도록 **기능별 태스크 분해 + 역할 할당 + 파일 경로 제안**을 포함했습니다.

---

### 📄 `FindFriend_모듈_개발_계획서.md`


# 🧩 Bling - Find Friend 모듈 개발 계획서  
> 작성일: 2025-07-12  
> 작성자: Planner  
> 대상 모듈: `features/find_friends/`  
> 참조 문서: [[FindFriend_기능_설계_초안]], [[AI 모더레이션 시스템 설계]], [[TrustLevel 정책 정의]]

---

## ✅ 1. 모듈 목적

- Bling 사용자 간 **신뢰 기반 친구 연결** 기능 제공  
- 동네 인증 + AI 필터링 + 관심사 기반 매칭 UX 구축  
- 핵심 가치는 "친구만을 위한 안전한 연결" (Non-romantic only)

---

## 🧱 2. 기능 구조 분해 (Feature Breakdown)

| 기능명           | 설명                                | 주요 파일                            | 상태       |
| ------------- | --------------------------------- | -------------------------------- | -------- |
| 친구 탐색 화면      | 지역 기반 사용자 리스트 + 필터 UI             | `find_friends_screen.dart`       | 🟡 진행 중  |
| 프로필 상세 보기     | 프로필 정보 확인 + 친구 요청                 | `findfriend_profile_detail.dart` | ✅ 완료     |
| 프로필 작성/수정     | 내 친구찾기 프로필 등록                     | `findfriend_profile_form.dart`   | ✅ 완료     |
| 친구 요청/수락      | Firebase write (friend status 관리) | `friend_requests_screen.dart`    | 🟡 진행 중  |
| 친구 목록 조회      | 친구목록 리스트 UI + 1:1 채팅 연결           | 신규 필요: `my_friends_screen.dart`  | 🔲 미착수   |
| AI 메시지 필터링    | 불건전 접근 자동 차단                      | `ai_message_guard.dart` (신규)     | 🔲 미착수   |
| TrustLevel 연동 | 동네 인증 + TrustBadge 반영             | `trust_level_badge.dart`         | 🟢 연결 필요 |

---

## 🧩 3. 개발 우선순위 (Phase Roadmap)

### 🔹 Phase 1 – MVP
- [x] 내 프로필 등록/수정 (Form)
- [x] 프로필 상세 보기
- [ ] 친구 탐색 리스트 + 필터 UI
- [ ] 친구 요청/수락/거절 처리
- [ ] Firestore 모델 정비 (`findfriend_profiles/`, `users/{uid}/friends[]`)

### 🔹 Phase 2 – 친구 관리
- [ ] 친구 목록 화면 추가 (`my_friends_screen.dart`)
- [ ] 친구 삭제 / 차단 기능
- [ ] 1:1 채팅 진입 구조 연결 (chat_room_model 연동)

### 🔹 Phase 3 – 고급 기능
- [ ] AI 메시지 필터링 (욕설/데이트 목적 감지)
- [ ] 프로필 감정 분석 기반 매칭 (선택형)
- [ ] 지역 외 사용자 허용 범위 설정 (radius 필터)

---

## 🧠 4. 연동 모델 정의

- `findfriend_model.dart`  
  → 성별, 연령대, 관심사, 활동 유형 등 포함  

- `user_model.dart`  
  → `trustLevel`, `neighborhoodVerified`, `profileImageUrl` 확장 고려  

---

## 🛠️ 5. 개발 파일 구조 제안

```

features/  
└── find_friends/  
├── screens/  
│ ├── find_friends_screen.dart  
│ ├── findfriend_profile_detail.dart  
│ ├── findfriend_profile_form.dart  
│ ├── friend_requests_screen.dart  
│ └── my_friends_screen.dart <- 신규 예정  
├── data/  
│ └── findfriend_repository.dart  
├── widgets/  
│ ├── friend_card.dart <- 리스트 카드 UI 분리  
│ └── trust_level_badge.dart  
└── services/  
└── ai_message_guard.dart <- AI 필터링용 (신규)

```

---

## 🧑‍💻 6. 역할 분담 제안 (예시)

| 담당      | 역할                         |
| ------- | -------------------------- |
| Planner | 기능 흐름 기획 + UX 시나리오 문서화     |
| ChatGPT | 구조 설계 / DB 설계 / 코드 템플릿 제공  |
| Copilot | 위젯 구현 / Firestore 연결 로직 작성 |
| Gemini  | AI 필터링 문장 분석 알고리즘 보조       |

---

## 📎 7. 관련 TODO

- [ ] 사용자 DB 정리: `gender`, `trustLevel`, `verifiedNeighborhood` 정규화
- [ ] 기본 프로필 이미지 URL 매핑 (pravatar API 사용)
- [ ] 친구 요청 시 중복 방지 로직 추가
- [ ] "차단된 사용자" 관리 리스트 생성

---

## 🔗 연관 문서 링크

- [[FindFriend_기능_설계_초안]]
- [[Firestore 데이터 모델 정의]]
- [[AI 모더레이션 시스템 설계]]
- [[Chat 모듈 구조 초안]]



- `my_friends_screen.dart` 코드 템플릿
    
- `findfriend_repository.dart` 내 친구 상태 처리 함수
    
- `ai_message_guard.dart` 설계 및 구현 예시
    

# Find Friend Feature SPEC (v1 Draft)

## 1. Purpose
지역 기반 신뢰형 친구/연결 기능 제공 (과도한 데이팅 이미지 배제, 안전 UX 강조).

## 2. User Stories
- 사용자는 반경 n km 이내 사용자 카드 리스트를 본다.
- 관심 있는 사용자에게 친구 요청을 보낼 수 있다 (일일 요청 제한).
- 상대가 수락하면 1:1 채팅방이 자동 생성된다.
- 거절되면 리스트에서 제외되어 스팸 감소.

## 3. Key Components
- 카드 리스트 & 거리 계산 (Haversine)
- 친구 요청/수락/거절 흐름
- TrustLevel 뱃지 & 인증 표시
- 제한/차단 & 신고

## 4. Data Model (요약)
```
/users { profile fields, interests[], geo, trustLevel, verifiedFlags }
/match_requests { fromUid, toUid, status(pending|accepted|rejected), createdAt }
/chats { participants[], lastMessage, createdAt }
```
프로필 확장: 성별, 연령대, 취미 태그, 소개문.

## 5. System Logic
1. 리스트: geo index 기반 radius 필터
2. 요청 insert 시 중복(기존 pending/accepted) 차단
3. 수락 → transaction: 요청 상태 update + chat room 생성
4. 거절 → 요청 status 변경 & 추천 제외
5. 요청 제한: 일일 카운터 또는 Cloud Function rate 문서

## 6. Technical Architecture
- Flutter: cards (ListView/Grid), detail sheet
- Firestore: users / match_requests / chats
- Cloud Functions: rate-limit, auto cleanup stale requests
- Cloud Messaging: 매칭/수락 push

## 7. Monetization
- 기본 무료 (일일 요청 제한)
- 유료: 요청 슬롯 확장, 상단 노출(Boost), 관심 표시 초과 해제

## 8. Roadmap
Now: 기본 프로필/요청/수락
Next: 친구 목록 화면, 차단, AI 욕설 필터
Later: 스와이프 UI, 음성 프로필, 감정 분석 매칭

## 9. Open Questions
- 인증(셀카/신분) 도입 시 개인정보 보관 정책?
- radius 동적 확장 로직(사용자 밀도 낮을 때)?

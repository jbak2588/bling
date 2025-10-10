# Local News Feature SPEC (v1 Draft)

## 1. Purpose
지역 뉴스 / 공공 공지 / 커뮤니티 소식을 한 곳에서 제공하여 신뢰성 높은 지역 정보 허브를 형성.

## 2. User Stories
- 사용자는 동네 행정 공지와 주민 소식을 최신순으로 본다.
- 관리자/기관 계정은 고정 공지(핀) 기능으로 상단 노출한다.
- 시스템은 외부 뉴스 소스를 주기적으로 수집/요약해 자동 게시한다.

## 3. Key Components
- 고정 공지 (유료 or 권한 계정)
- 자동 수집 뉴스 카드 (RSS/API)
- 사용자 일반 소식 & 신고/스팸 필터

## 4. Data Model (요약)
Collections:
```
/news_posts { id, type(gov|public|auto|personal), title, body, images[], region, authorRef, pinned, createdAt, expiresAt }
/users { roles[], trustLevel }
```
자동 수집 메타: `/news_sources` (source URL, lastFetchedAt).

## 5. System Logic
1. 권한 기반 업로드 (기관/관리자 무제한, 일반 사용자 제한)
2. Cloud Function 스케줄러가 외부 소스 → 임시 파싱 → 검증 → `/news_posts` insert
3. 만료 처리: `expiresAt` 지난 문서는 숨김

## 6. Technical Architecture
- Flutter: lazy list + pin 구간 구분
- Firestore: posts / sources / user roles
- Cloud Functions: fetch, summarize, expire hide

## 7. Monetization
- Pinned slot 구매(1/7/30일)
- 강조 테두리/색상 업그레이드
- 키워드 검색 상단 광고

## 8. Roadmap
Now: 기본 CRUD + 핀 + 신고
Next: AI 요약 카드, 감정/주제 태깅
Later: 지도 기반 필터, 다국어 요약

## 9. Open Questions
- 외부 뉴스 저작권/인용 표기 표준?
- 자동 요약 실패 fallback 전략?

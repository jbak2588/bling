# Architecture Overview (Draft)

## Vision & Mission (요약)
- Vision: 지역 사회를 안전하고 신뢰 있게 연결하는 동남아 최고의 커뮤니티 플랫폼
- Mission: 지역 정보/자원 연결 · 소상공인 지원 · AI로 신뢰 문제 해결 · 따뜻한 소셜 경험

## Core Differentiators
1. AI 검수 기반 중고 거래 + 예약금 보증
2. 생활 밀착 8+ 메뉴 통합 (뉴스, 친구, 모임, 상점, 구직, 중고, 분실물 등)
3. 위치 기반 노출 알고리즘
4. 저진입 소상공인 광고 모델
5. 현지화된 UI/UX & 다국어

## High-Level Modules
- main / navigation
- marketplace (AI 검수 예정)
- local_news
- find_friend
- lost_and_found
- chat / notification
- trust & moderation
- jobs / stores / auction / pom / real_estate (확장)

## Data Layer Principles
- Firestore 컬렉션 규칙: 기능 단위 prefix, TTL 필드(expire) 사용
- Cloud Functions: 정기 수집/정리, rate-limit, AI 호출 백엔드
- Storage: 이미지/미디어 버킷 분리(`public/`, `secure/` 고려)

## Roadmap Snapshot (예)
Now: i18n 안정화 & 핵심 피처 0.9
Next: OpenAI 분석 모듈 도입, Finalize UX 개선
Later: ML 추천/매칭 고도화, 다국가 확장, 광고 플랫폼화

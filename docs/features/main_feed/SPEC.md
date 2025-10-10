# Main Feed Feature SPEC (v1 Draft)

## 1. Purpose & Scope
지역 기반 사용자 활동(Local News, Lost & Found 강조, Marketplace 일부 안전 공지 등)을 가중치 기반으로 혼합 노출하여 앱 진입 시 체류시간과 재방문을 극대화하는 기본 홈 피드.
범위: 읽기/스크롤/새로고침/부분 개인화/스폰서 슬롯. (작성/댓글/신고는 각 기능 모듈에서 정의되며 피드는 소비/정렬 레이어.)

## 2. User Stories
- 사용자는 앱 실행 즉시 최신 / 인기 / 내 근처 게시물 혼합을 본다.
- 사용자는 스크롤 끝 근처에서 자동으로 다음 페이지가 사전 로드되어 끊김 없는 경험을 가진다.
- 새 게시물 생성 후(내 글) 상단에 즉시 반영된다(Optimistic Insert).
- 위치(내 동네 / 근처) 토글로 거리 기반 필터 전환 가능.
- 특정 카테고리(예: Lost & Found) 강조 배지를 통해 빠르게 식별한다.
- 스폰서(프로모션) 카드가 과도하지 않게 일정 간격(예: 1/N)으로 노출된다.
- 신고/차단한 사용자 콘텐츠는 다시 보이지 않는다.

## 3. Feed Composition & Ranking
### 3.1 후보 Pool
- 최근 24~48h Local News (지역 필터)
- Lost & Found (활성 & HUNTED 가중치)
- Marketplace 안전 공지 / 시스템 공지 (낮은 빈도 고정 슬롯)

### 3.2 기본 가중치 시그널 (초안)
Signal | 설명 | 초기 Weight (예시)
-------|------|----------------
Freshness | 게시 시점 역가중 | 0.30
Distance | 내 위치와의 거리(geohash bucket) | 0.20
Engagement | 조회/클릭/댓글/반응 지표 | 0.20
TrustLevel | 작성자 신뢰 단계 | 0.10
Category Boost | 전략적 강조(Lost & Found,HUNTED) | 0.10
Author Diversity | 동일 작성자 연속 억제 | 0.05
Negative Feedback | 숨김/신고 감점 | -0.40

Pseudo Score: `score = Σ(weight_i * normalized(signal_i))` 후 안정화(sqrt/ logistic) 적용.

### 3.3 Personalization (Phase 2)
- 사용자 상호작용 히스토리(카테고리별 dwell time, 클릭) 피드백 루프 반영.
- Cold Start: distance + freshness + category diversity 기본값.

### 3.4 Sponsored Slot 규칙
- 최소 스크롤 10개 컨텐츠 당 1개 이하
- 광고와 유사 카테고리 콘텐츠 연속 배치 금지
- Score 계산 후 위치 삽입(re-ranking) 방식

## 4. Data Model
Raw Sources (각 모듈):
```
/posts { id, type(local_news|lost_found|system), userId, text, media[], region, geoHash, createdAt, metrics { views, clicks, comments, reactions }, trustLevel }
/lost_items {...} (필요 시 posts로 projection)
/system_notices { id, audienceFilter, message, createdAt, expiresAt }
/user_hidden { uid, targetPostIds[] }
/user_block { uid, blockedUserIds[] }
/sponsored_feed_items { id, campaignId, targeting, budget, weight }
```
Materialized/Cache (선택):
```
/feed_entries_{regionShard}/{docId} { postRef, score, decayAt }
```

## 5. System Logic
1. Fetch Phase: region + time window 기준 소스 컬렉션 쿼리.
2. Filter Phase: 숨김/차단/만료/카테고리 정책 제거.
3. Feature Extraction: distance, freshness, engagement normalization.
4. Scoring: weight 합산 + penalty 적용.
5. Diversity: 동일 작성자 연속 > 2 방지 (swap or downweight).
6. Sponsored Injection: 사전 정의 간격/타겟 매칭 후 삽입.
7. Pagination: Cursor = (score, createdAt, id) 삼중 키 → 안정적 순서.
8. Realtime Update: 새 게시물 또는 반응 폭증 시 상위 재계산(부분 invalidate).

## 6. Technical Architecture
- Client: Flutter `FeedController` → `FeedRepository` (fetchPage, refresh, injectLocalDraft).
- Backend: (Phase 1) Pure client aggregation + Firestore queries.
- Phase 2: Cloud Function batch scorer → materialized `feed_entries_*` 컬렉션.
- Caching: In-memory LRU + optimistic append.
- Indexing: geoHash + createdAt 복합 인덱스, metrics 업데이트는 배치/서브컬렉션.

## 7. Moderation & Safety Hooks
- 신고/숨김: `user_hidden`, `user_block` 반영 필터 단계.
- TrustLevel < threshold → 가중치 일부 제한.
- Negative feedback(신고율) 상승 → penalty 누적 필드.

## 8. Monetization
- Sponsored feed items (CPM/노출 캠페인) → campaign 서버 로직 별도.
- Feature Boost (Lost & Found HUNTED, Marketplace 긴급 공지) = category boost weight.
- Later: Dynamic pricing for slot priority.

## 9. Roadmap
Now: Client-side scoring (freshness + distance 기본) / infinite scroll / basic filters.
Next: Engagement metric 수집 & incremental scoring / sponsored slot 삽입 / diversity control.
Later: Materialized feed, personalization feedback loop, lightweight ML CTR predictor.

## 10. Risks & Mitigations
Risk | 설명 | 대응
-----|------|----
Cold Start 빈약 | 초기 데이터 부족 | Distance + Freshness fallback
Firestore 비용 급증 | 다중 쿼리 | Materialized feed 단계 도입
광고 과다 반감 | 사용자 이탈 | 슬롯 비율 상한 강제
조작(engagement gaming) | 봇/클릭 팜 | 이상치 필터 + trust penalty
Latency (다수 쿼리) | 스크롤 지연 | 병렬 fetch + prefetch

## 11. Open Questions
- feed_entries materialization 시점 (주기 vs 이벤트 기반)?
- Sponsored slot 회피(‘광고 건너뛰기’) UX 도입 여부?
- Engagement metrics 실시간 vs 배치 업데이트 tradeoff?

## 12. Metrics (Success KPIs)
- F1: 첫 화면 가시 컨텐츠 로딩 < 1200ms
- D1 Retention uplift vs control
- Scroll Depth 평균
- Lost & Found 반환/해결 전환율 (피드 노출 기여)

## 13. Implementation Plan (Incremental)
Phase | 목표 | 범위
------|------|-----
P1 | Freshness+Distance 정렬 | 클라이언트 계산
P2 | Engagement 반영 + Sponsored | 부분 재계산, slot 규칙
P3 | Materialized Feed | Cloud Function scorer
P4 | Personalization | 사용자 피드백 모델

---
Source Inputs to merge:
- `index/010  Post 모듈.md`
- 백서 섹션 (Posts / Feed 관련)
- 위치 검색 규칙 문서

## Implementation Status (초기 평가)
항목 | 상태 | 메모
-----|------|-----
Feed Aggregation | 미구현 | 모듈별 컨텐츠 조합 로직 없음
Ranking Signals | 미구현 | 가중치/피드백 수집 필요
Personalization | 미구현 | cold-start 전략 미정
Sponsored Posts | 미구현 | 정책/표시 규칙 필요
Caching/Prefetch | 미구현 | 스크롤 성능 TBD

## TODO
- [ ] feed_entries 개념 정의 (union vs denormalized)
- [ ] 기본 랭킹 신호 목록(User distance, freshness, engagement) 작성
- [ ] cold-start(지역 + 글로벌 인기) 전략 문서화
- [ ] 스폰서 슬롯 삽입 규칙(비율/간격)
- [ ] Prefetch & pagination 설계
- [ ] Moderation hook (숨김/신고 반영) 연결
 - [ ] Diversity control (저자 반복 방지)
 - [ ] Sponsored inventory supply side 설계
 - [ ] Metrics 수집 batch → near-real pipeline 옵션 비교
 - [ ] Phase 분할별 WIP 깃 태그 전략 문서화

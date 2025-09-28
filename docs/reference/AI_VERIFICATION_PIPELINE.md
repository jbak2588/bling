# AI Verification Pipeline (Marketplace & Media)

## 1. Purpose
Marketplace 상품(이미지/설명)과 Lost & Found, Real Estate 등 주요 모듈의 제출 콘텐츠를 자동 검수/분류/리스크 감지하여 사기 감소와 품질 향상.

## 2. Scope (Phase Split)
Phase | 기능 | 설명
------|------|----
P1 | 기본 카테고리 분류 | OpenAI / Vision Tag → 내부 카테고리 매핑
P1 | 가격 범위 추천 | 히스토리 단순 통계 + outlier 감지
P2 | 위조/위험 키워드 탐지 | 텍스트 임베딩 + 위험 사전
P2 | 이미지 중복/금지품목 | Perceptual Hash + 금지 패턴
P3 | 다중모듈 확대 | Jobs/Clubs 특정 게시 검수
P3 | ML Fine-tune | 내부 수집 라벨 기반 재학습

## 3. High-Level Flow
1. User Draft 저장 (status=draft)
2. User 요청 → Verification Trigger (Function enqueue)
3. Function: 이미지 다운/리사이즈 → AI API 호출
4. Response: classification / riskScore / priceSuggest
5. Persist: `/ai_checks` doc 업데이트 → listing.status=pending_ai → ok 시 active
6. 실패/오류: 재시도 카운터, UI 재요청 안내

## 4. Data Structures
```
/ai_checks {
  listingId,
  type: 'marketplace',
  imageRefs: [],
  categoryPredictions: [{label, score}],
  riskScore: number,
  priceSuggested: {min, max, median},
  flags: { counterfeit?: bool, adult?: bool, violence?: bool },
  status: pending|ok|fail,
  attempts: number,
  createdAt, updatedAt
}
```
Aux: `/ai_fail_queue` for manual inspection.

## 5. API Integration (Initial)
- OpenAI Vision (multi-image) + system prompt → category & risk hints
- Pricing: simple historical median (Firestore aggregation) fallback if model low confidence
- Timeout: 20s; retry up to 2 (exponential backoff)

## 6. Scoring & Thresholds
Metric | 의미 | 처리
------|------|----
riskScore > 0.8 | 고위험 | fail + manual flag
adult flag | 민감 | blur or reject (정책 결정)
priceSuggest null | 부족 데이터 | 사용자 수동 입력 유지
confidence < 0.5 | 불확실 | 재시도 / 수동 승인 옵션

## 7. Error Handling
Case | 전략
-----|-----
API Timeout | retry (max2) → fail 기록
Invalid Image | fail + UI 교체 안내
Quota Exceeded | degrade: skip AI → manual approve
Partial Success (price only) | 부분 결과 반영 + warning

## 8. Security & Privacy
- 원본 이미지는 Storage 제한 경로 + 공개 경로와 분리
- AI 요청 로그 minimal fields (no user PII)
- 재현 디버깅: `ai_checks/{id}` snapshot

## 9. Observability
Log | 목적
----|----
`verification_start` | 큐 처리 시간 측정
`verification_result` | category / latency / flags
`verification_fail` | 오류 유형 분포

Cloud Metrics Dashboard: success %, avg latency, riskScore 분포.

## 10. Extensibility
- Generic interface: `verifyContent(type, payload)` → strategy map
- Add module: implement adapter returning normalized `VerificationResult`
- Switch provider: strategy injection (OpenAI -> Vertex AI)

## 11. Roadmap
Now: Marketplace 이미지+설명 기본 카테고리/가격 추천
Next: Risk flags + Lost & Found 이미지 중복 검사
Later: Fine-tune + incremental learning + multi-lingual prompt 최적화

## 12. Open Questions
- 수동 승인 UI (관리자 대시보드) 시점?
- 가격 추천 insufficient 데이터 기준 임계값?
- Blur vs Reject 정책(성인/폭력) 확정?

## 13. TODO
- [ ] OpenAI Vision 호출 래퍼 Dart/Cloud Function
- [ ] 카테고리 라벨 매핑표 작성
- [ ] 가격 히스토리 aggregation Function
- [ ] riskScore 산식(키워드 vs 이미지 flags) 문서화
- [ ] observability 대시보드 쿼리 템플릿
- [ ] 수동 승인 관리자 컬렉션 설계

# Marketplace Feature SPEC (v1 Draft)

## 1. Purpose
지역 기반 중고 거래를 AI 검수 + 예약금(에스크로) 구조로 안전하게 수행하는 핵심 상거래 모듈. 신뢰/사기 방지와 품질 보증을 통해 타 플랫폼 대비 차별화.

## 2. User Stories
- 사용자는 상품 등록 시 사진 + 카테고리 + 상태 입력 후 AI 검수 요청을 보낸다.
- AI 검수 결과(품목 카테고리/상태/시세 범위)를 확인하고 승인 후 게시한다.
- 구매자는 예약금(Deposit) 결제 → 아이템 홀드 → 인수 시 Finalize → 잔금 정산 / 환불.
- 판매자/구매자는 거래 진행 중 채팅으로 조율한다.
- 분쟁 발생 시 신고/증빙 업로드 후 플랫폼 중재.

## 3. Key Components
- Listing 작성 & 이미지 업로드
- AI Verification (품목 분류, 위조/리스크 신호 감지, 가격 범위 추천)
- Escrow / Reservation (예약금 결제 후 아이템 상태 잠금)
- Finalize & Dispute Flow
- Category & Search / Filter (거리, 가격, 카테고리)

## 4. Data Model (요약)
```
/listings { id, sellerUid, title, desc, category, price, status(draft|pending_ai|active|reserved|sold|cancelled), images[], region, createdAt }
/ai_checks { listingId, resultJson, status(pending|ok|fail), riskScore, priceSuggested }
/reservations { id, listingId, buyerUid, depositAmount, status(pending|active|released|refunded), createdAt }
/disputes { id, listingId, raisedBy, reason, evidenceImages[], status }
/payments { id, reservationId, providerRef, amount, type(deposit|final|refund), createdAt }
```
파생 지표: `/analytics/listing_daily` (조회수, 클릭수, 예약전환율).

## 5. System Logic
1. Listing Draft 저장 → AI 검수 트리거 → `ai_checks` 완료 후 listing.status=active 전환.
2. 예약금 결제 성공 → reservation 생성 + listing.status=reserved.
3. Finalize: 판매자/구매자 모두 확인 → escrow release → status=sold.
4. Dispute: finalize 전에 raise → 증빙 수집 → 관리자가 수동 결정 (refund or continue) → 로그 기록.
5. 만료/비활성: 일정 기간 거래 안 되면 archived.

## 6. Technical Architecture
- Flutter: Form + gallery + state machine (draft→active→reserved→sold).
- Firestore: listings / ai_checks / reservations / disputes.
- Cloud Functions:
	- AI 호출 래퍼 (OpenAI or Vision API) → 결과 저장
	- Reservation payment webhooks 처리
	- Timeout/만료 관리 (예약 미결제/미최종화)
	- Dispute SLA 타이머
- Storage: 원본/리사이즈 이미지 (후처리: 품질/EXIF 제거)

## 7. Monetization
- Escrow 수수료(거래액 %) / 예약금 고정 수수료
- Listing 업그레이드(상단 고정, 강조 테두리)
- 빠른 검수(우선 AI Queue) 유료 옵션
- 결제 파트너 수수료 리베이트

## 8. Roadmap
Now: 기본 listing CRUD + AI 검수 구조 초안 + 예약금 흐름(수동 mock)
Next: 실제 결제 연동(Xendit/Midtrans), Dispute UI, 자동 가격 추천 고도화
Later: 추천 피드(개인화), 배치 딜, 번들 결제, 다국가 통화 지원

## 9. Implementation Status (현재 코드 대비)
항목 | 상태 | 메모
-----|------|-----
Listing CRUD | 부분 | 기본 UI 존재, 상태머신 단순
AI Verify Pipeline | 미구현 | OpenAI 호출 래퍼 필요
Reservation/Escrow | 미구현 | 결제/트리거 없음
Finalize State Machine | 부분 | 무한 로딩 이슈 분석됨
Dispute Handling | 미구현 | 컬렉션/Flow 미정
Analytics | 미구현 | 추후 Cloud Function 집계

## 10. TODO
- [ ] AI 검수 서비스 인터페이스 정의(OpenAI / Vision)
- [ ] listing 상태 enum 정규화 + Transition Guard
- [ ] 예약금 결제 프로토타입 (mock provider)
- [ ] finalize 타임아웃 + 재시도/에러 메시지
- [ ] Dispute 컬렉션 & 관리자 판정 로직
- [ ] 가격 추천 모델/룰 정의 (카테고리별 Min/Max)
- [ ] 이미지 업로드 후 썸네일/압축 파이프라인
- [ ] 로그/모니터링 (Cloud Logging tag)

## 11. Open Questions
- 가격 추천 실패 시 fallback UX?
- 복수 예약 금지 vs 대기열 허용?
- Escrow 분리 계좌(virtual account) 필요 여부?

Sources: 백서 marketplace, 기존 index 문서, 실서비스 계획.

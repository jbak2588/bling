# Auction Feature SPEC (v1 Draft)

## 1. Purpose
희소/프리미엄 품목을 경쟁 입찰 형태로 거래하여 거래 단가/참여도를 높이고 Marketplace 수익 다각화.

## 2. User Stories
- 판매자는 경매 시작가/즉시구매가/종료시간 설정 후 등록.
- 사용자는 실시간 현재가를 보고 수동 또는 최대가(Proxy Bid)를 설정.
- 종료 시 최고가 입찰자에게 낙찰 알림 → 결제/에스크로 전환.
- 판매자는 경매 중 취소 제한(입찰 존재 시 불가).
- 사용자는 관심 경매 watchlist 추가.

## 3. Key Components
- Auction Listing & Lifecycle
- Bidding (Proxy 자동입찰 로직)
- Countdown & Realtime Update (listen)
- Anti-sniping(연장) 옵션
- Settlement (Marketplace escrow 연계)

## 4. Data Model (요약)
```
/auctions { id, sellerUid, title, desc, images[], startPrice, buyNowPrice, currentPrice, endAt, status(scheduled|running|ended|cancelled), createdAt }
/bids { id, auctionId, bidderUid, amount, maxAutoBid, createdAt }
/watchlist { uid, auctionIds[] } (또는 /users/{uid}/auction_watch/{auctionId})
```
추가 지표: bidCount, lastBidAt.

## 5. System Logic
1. 경매 start 시 status=running, currentPrice=startPrice.
2. Bid 제출 → maxAutoBid 비교 → currentPrice 계산 (2nd price 개념 변형 가능).
3. 종료 1분 내 새 입찰 발생 & anti-sniping 활성 → endAt += N분.
4. endAt 도달 & 더 이상 입찰 없음 → status=ended, 승자 확정 → escrow flow.
5. buyNowPrice 사용 시 즉시 종료.

## 6. Technical Architecture
- Firestore: auctions / bids (auctionId index)
- Cloud Functions: schedule start/end, anti-sniping 연장, settlement trigger
- Realtime: snapshot listeners for bid updates
- Fraud Checks: rapid bid spike / 동일 사용자 다중계정 탐지

## 7. Monetization
- 낙찰 금액 수수료(%)
- 강조/추천 슬롯
- Proxy Auto-bid 기능 무료 vs 유료 credit?

## 8. Roadmap
Now: 기본 모델/생명주기 설계
Next: Proxy bid & anti-sniping 구현, watchlist
Later: 실시간 WebSocket 최적화, 통계 대시보드, 사기 탐지 ML

## 9. Implementation Status
항목 | 상태 | 메모
-----|------|-----
Auction CRUD | 미구현 | listing 확장 필요
Bid Logic | 미구현 | proxy 계산 함수 필요
Anti-sniping | 미구현 | end 연장 rule
Settlement | 미구현 | escrow 공용
Watchlist | 미구현 | user subcollection
Fraud Detection | 미구현 | heuristic → ML

## 10. TODO
- [ ] 컬렉션/인덱스 설계 상세화
- [ ] Proxy bid 알고리즘 설계 & 단위 테스트
- [ ] Anti-sniping 연장 파라미터 결정
- [ ] Settlement 연계 플로우 정의
- [ ] Watchlist UI/데이터 모델 확정
- [ ] Fraud rule(속도/금액 변동) 1차 휴리스틱
- [ ] 관리자 취소/중단 프로세스 정의

## 11. Open Questions
- Buy Now 활성 시 수수료 차등?
- Proxy bid 최대 상한 제한?
- Anti-sniping 연장 횟수 제한?

Sources: 백서 + 확장 아이디어.

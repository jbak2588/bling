# Lost & Found Feature SPEC (v1 Draft)

## 1. Purpose
분실/습득 정보를 신속 공유하여 반환율을 높이고 커뮤니티 실효성을 증대. HUNTED(현상금) 모델로 참여/재노출 활성.

## 2. User Stories
- 사용자는 분실 또는 습득 게시물을 유형과 위치/설명/사진과 함께 등록한다.
- HUNTED 옵션(유료)을 선택하여 배지와 상단 강조 노출을 구매한다.
- 기간이 지난 게시물은 자동 숨김 → 연장 결제 가능.
- 습득자는 보관 위치/연락 수단을 제공하고 분실자는 채팅/전화로 연결.
- 신고 시스템으로 허위 게시물을 필터링.

## 3. Key Components
- Post Types: lost / found
- Expiry & Renewal (7일 기본, 30일/연장 유료)
- HUNTED Badge & 강조 스타일
- Map/List Hybrid View
- Reporting & Trust 기록 반영

## 4. Data Model (요약)
```
/lost_items { id, type(lost|found), title, desc, region, approxLocationText, images[], contactType, bountyAmount, hunted(bool), status(active|expired|resolved), createdAt, expiresAt, reporterUid }
/reports { refType:'lost_item', refId, reporterUid, reason, createdAt }
```
보상 지급 확인 필드 후보: `bountyReleasedAt`.

## 5. System Logic
1. 등록 시 기본 만료일 = now + 7d (또는 30d 선택).
2. Cloud Scheduler: expiresAt < now → status=expired.
3. 연장 결제 → expiresAt += 30d.
4. HUNTED: hunted=true → 홈/지도 우선 노출 정렬 가중치.
5. 신고 누적 threshold → 자동 숨김 & 관리자 리뷰 큐.

## 6. Technical Architecture
- Flutter: 탭(분실/습득) + 지도/리스트 토글.
- Firestore: lost_items / reports / user trust updates.
- Cloud Functions: expiry sweep, report threshold action.
- Storage: 이미지 업로드.

## 7. Monetization
- 연장 결제
- HUNTED 강조 배지
- 지도 강조 핀 스타일(색상/크기)

## 8. Roadmap
Now: 기본 CRUD + 리스트 뷰
Next: 지도 연동 + HUNTED 강조 + 신고 자동 룰
Later: AI 이미지 유사 매칭, QR 스티커 통합, 보상 지급 추적

## 9. Implementation Status
항목 | 상태 | 메모
-----|------|-----
CRUD/Form | 미구현 | placeholder 단계
Expiry Function | 미구현 | scheduler 필요
HUNTED 강조 | 미구현 | ranking rule 필요
Map View | 미구현 | google_maps plugin
Reporting | 부분 | 공용 신고 모듈 재사용 예정
AI 유사매칭 | 미구현 | 후순위

## 10. TODO
- [ ] Firestore 스키마 확정 및 security rules 초안
- [ ] 등록 폼 + 유형 전환 UI
- [ ] Expiry Cloud Function + 테스트
- [ ] HUNTED 정렬 weight 실험
- [ ] 신고 threshold & 숨김 로직 구현
- [ ] 지도/리스트 전환 상태관리
- [ ] 연장 결제 플로우 (공용 결제 모듈 재사용)
- [ ] AI 유사 이미지 탐색 조사

## 11. Open Questions
- HUNTED 배지 가격 정책?
- 허위 신고 방지를 위한 trust penalty 기준?
- resolved 상태 정의(분실물 반환 증빙 절차)?

Sources: 백서 4.1 섹션.

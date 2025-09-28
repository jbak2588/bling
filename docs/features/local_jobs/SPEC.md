# Local Jobs Feature SPEC (v1 Draft)

## 1. Purpose
지역 단기/파트타임 및 소규모 고용 기회를 빠르게 연결하여 지역 경제 활성화와 사용자 체류 증가를 지원.

## 2. User Stories
- 고용자는 채용 공고(직무, 급여범위, 근무유형, 위치)를 게시.
- 지원자는 간단 프로필(기술/경력) 또는 첨부파일 없이 In-App Application 제출.
- 고용자는 지원 목록에서 상태(검토중 → 인터뷰 → 합격/거절) 변경.
- 마감일 도래 또는 채용 완료 시 공고는 자동 비활성(archived) 처리.
- Promoted Job 은 목록 상단 또는 피드 강조.

## 3. Job Lifecycle
State | 설명
------|----
draft | 작성 중 저장
active | 모집 중
paused | 일시 중지 (노출 X)
filled | 채용 완료
expired | 마감일 경과 (자동)
archived | 수동/정책 아카이브

Transition 규칙:
- draft -> active (필수 필드 충족)
- active -> paused (고용자)
- active -> filled (선발자 확정)
- active -> expired (deadline < now)
- expired/filled -> archived (N일 후)

## 4. Data Model
```
/jobs { id, employerUid, title, description, payType(hourly|fixed|range), payMin, payMax, location, region, category, skills[], deadline, state, createdAt, promoted(bool), promotionEndAt, applicantCount, verificationStatus(unverified|pending|verified) }
/job_applications { id, jobId, applicantUid, coverText, createdAt, status(pending|review|interview|accepted|rejected|withdrawn), lastUpdatedAt }
/job_employer_verification { employerUid, docs[], status, requestedAt, reviewedAt }
```
Indexes: jobs by region+state+deadline, job_applications by jobId+status.

## 5. Application Flow
1. 지원 제출(pending)
2. 고용자 열람 → review
3. 인터뷰 대상 → interview
4. 선발 → accepted (다른 pending 자동 rejected 선택적)
5. 지원자 withdraw → withdrawn (상태 고정)

## 6. Business Verification
- 제출 서류: 사업자등록증(사진), 연락처, 위치 증빙.
- 단계: unverified → pending → verified.
- Verified 시: Job 상단 뱃지 + 노출 Boost(가중치 +w).

## 7. Ranking / Listing Rules
기본 정렬: promoted > (verified weight) > freshness(decay) > applicantCount(적정 범위 내 가중치).
신고/숨김: 공용 moderation 필터.

## 8. Monetization
- Promoted Job (기간제 상단 고정)
- Featured Category 묶음(패키지)
- 향후: 지원자 연락처 공개 credit 모델 검토

## 9. Technical Architecture
- Firestore collections 위 정의.
- Cloud Functions:
	- deadline monitor → expired 전환
	- promotionEndAt 도달 → promoted=false
	- filled/expired 후 retention 기간 지나면 archived
	- employer verification OCR/metadata 체크(외부 API 협의)
- Client: `JobsRepository` (listJobs, applyToJob, updateApplicationStatus, promoteJob).

## 10. Analytics Metrics
- Apply Conversion Rate (views→applications)
- Time to Fill (created→filled)
- Verified vs Unverified apply rate
- Promotion uplift CTR

## 11. Roadmap
Now: 기본 공고 + 지원 CRUD + 만료 처리
Next: Verification + Promotion + Ranking weight 튜닝
Later: Skill matching 추천(간단 TF-IDF → ML), Interview scheduling, Credit 모델

## 12. Risks & Mitigations
Risk | 설명 | 대응
-----|------|----
허위/사기 공고 | 사용자 피해 | Verification + 신고 임계값 제한
과도한 Promotion 남용 | UX저해 | 상단 슬롯 비율 제한
지원 스팸 | DB팽창 | 1일/지원자 제한 + 중복 검증
데이터 민감성 | 개인정보 이슈 | 최소 필드 저장/Retention 정책

## 13. Open Questions
- pay range 비공개 옵션 지원 여부?
- accepted 처리 시 자동 reject 범위 정책?
- verification 재검증 주기?

---
Sources: 백서 해당 부분, 참조 자료 8.

## Implementation Status
항목 | 상태 | 메모
-----|------|-----
Job Posting | 미구현 | listing 변형 가능성
Application Flow | 미구현 | 첨부파일/메시지 구조 미정
Business Verification | 미구현 | 문서 업로드 정책 필요
Promoted Job | 미구현 | monetize 전략 미정

## TODO
- [ ] /jobs 컬렉션 필드 정의
- [ ] /applications 상태 다이어그램
- [ ] Verification 요구 서류 목록
- [ ] Promoted ranking weight
- [ ] 만료(Expiry) & 자동 아카이브 로직
 - [ ] promotionEndAt 스케줄러
 - [ ] verification status update Function
 - [ ] ranking weight 실험(AB) 파라미터 문서화
 - [ ] skill tag 입력 UX
 - [ ] analytics 지표 이벤트 명세

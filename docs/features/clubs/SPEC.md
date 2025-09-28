# Clubs (Group) Feature SPEC (v1 Draft)

## 1. Purpose
공통 관심사/위치 기반 소규모 커뮤니티 공간 제공. 지역 신뢰 네트워크를 강화하고 재방문/체류를 증가시키는 중추 모듈.

## 2. User Stories
- 사용자는 새로운 클럽(지역러닝, 반려동물, 자전거 등)을 생성하고 소개/규칙을 작성한다.
- 사용자는 가입 신청(즉시 혹은 승인형)을 통해 멤버가 된다.
- 관리자는 규칙 위반 게시물을 숨기거나 멤버를 경고/추방한다.
- 모더레이터는 신고 큐를 처리하고 태그를 정리한다.
- 클럽은 Featured(홈 상단 섹션)로 승격될 수 있다(관리자 또는 유료).

## 3. Lifecycle
State | 설명
------|----
draft | 생성 중 (미완성)
active | 정상 운영
restricted | 위반 누적으로 제한 (일부 기능 비활성)
archived | 활동 없음/관리자 결정으로 아카이브

Transition 규칙:
- draft -> active (필수 필드 + 최소 멤버 1 = owner)
- active -> restricted (신고/위반 score >= threshold)
- restricted -> active (정정 기간 경과 + 재검토)
- active/restricted -> archived (비활성 X일)

## 4. Data Model
```
/clubs { id, name, description, coverImage, region, category, visibility(public|invite|private), joinPolicy(auto|approval), state, createdAt, ownerUid, memberCount, ruleVersion, violationScore }
/club_members { clubId_userId, clubId, userId, role(owner|admin|mod|member), joinedAt, status(active|banned|pending) }
/club_posts { id, clubId, authorUid, content, media[], createdAt, metrics { comments, reactions }, hidden(bool) }
/club_reports { id, clubId, targetType(post|member), targetId, reporterUid, reason, status(pending|actioned), createdAt }
/club_featured { clubId, priority, startAt, endAt }
```
Indexes: club_members by clubId, role; club_posts by clubId+createdAt.

## 5. Roles & Permissions (요약)
Action | Owner | Admin | Mod | Member | Guest
-------|-------|-------|-----|--------|------
Edit Club Profile | Y | Y | - | - | -
Approve Join | Y | Y | Y | - | -
Post Content | Y | Y | Y | Y | -
Hide/Unhide Post | Y | Y | Y | - | -
Ban Member | Y | Y | - | - | -
Feature Request | Y | Y | - | - | -
Delete Club | Y | - | - | - | -

## 6. Moderation Flow
1. 회원/컨텐츠 신고 → `club_reports` 저장(status=pending).
2. 모더레이터 혹은 관리자 목록 보기(필터 pending).
3. Action: hide post / warn / ban / dismiss.
4. 누적 violationScore 증가 → threshold 도달 시 state=restricted.
5. Cron/Function: inactivity 체크 후 archived 전환 후보 태깅.

## 7. Featured Clubs
- 목적: 신규/활성 커뮤니티 노출, 유료 승격.
- 기준: memberCount, 최근 activityScore, violationScore < limit.
- 삽입 위치: 메인 피드 상단 섹션(수평 스크롤).

## 8. Technical Architecture
- Firestore: 위 스키마 기반. Cloud Function for:
	- violationScore update
	- inactivity detection
	- featured 기간 만료 처리
- Client: `ClubRepository` (join/leave/moderate), `ClubFeedController` (pagination), optimistic posting.
- Caching: club meta LRU, posts incremental load.

## 9. Monetization
- Featured slot 유료 승격(기간제)
- Private premium club (구독) → 후속 단계
- 광고 삽입(클럽 내부 상단 소형 배너) 검토

## 10. Roadmap
Now: CRUD + 가입/탈퇴 + 기본 게시
Next: Moderation workflow + featured 노출 + violationScore
Later: Subscription / Premium gating, analytics dashboard, AI 모더레이션(욕설/스팸)

## 11. Risks & Mitigations
Risk | 설명 | 대응
-----|------|----
스팸/광고성 클럽 | 품질 저하 | 초기 승인형 + violationScore
모더레이터 부족 | 신고 처리 지연 | role delegation 쉬운 UI
과도한 폐쇄형 증가 | 확장성 저하 | visibility 비율 모니터링
데이터 비용 증가 | 게시물/신고 테이블 팽창 | TTL/archive 정책

## 12. Open Questions
- featured 우선순위 산식 세부 값?
- private club 초대 흐름(링크 vs 코드)?
- AI 모더레이션 1차 도입 범위(욕설/이미지?)

---
Sources: 백서 (모임/클럽), `index/012  Find Friend & Club & Jobs & etc 모듈.md`, 참조 자료 8.

## Implementation Status
항목 | 상태 | 메모
-----|------|-----
Club CRUD | 미구현 | 스키마 필요
Membership Roles | 미구현 | admin/mod/member 정의 필요
Moderation Tools | 미구현 | 공용 신고 모듈 활용 예정
Premium/Featured | 미구현 | 수익 모델 미정

## TODO
- [ ] /clubs, /club_members 스키마 초안
- [ ] 권한 계층/역할 전환 플로우
- [ ] 게시/댓글 재사용 여부 결정(post vs 전용)
- [ ] Featured 노출 우선순위 알고리즘
- [ ] Moderation queue 연동
 - [ ] violationScore 누적 함수 & 임계값 정의
 - [ ] inactivity cron 스펙
 - [ ] featured 만료 처리 로직
 - [ ] role delegation UI 플로우 다이어그램
 - [ ] AI 모더레이션 파일터 1차 후보 조사

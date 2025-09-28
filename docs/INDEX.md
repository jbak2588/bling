# Bling Documentation Index

## Structure

```
docs/
  INDEX.md
  migration/DOC_PATH_MAPPING.md
  features/
    local_news/ (Local News / Berita Lokal) 
    find_friend/
  reference/
  policies/
  devlog/
  _sensitive/ (검토 후 삭제 예정 민감/임시 자료)
  deprecated/ (이관 전 임시 보관)
```

## Feature Specs
| Feature | Path | Summary |
|---------|------|---------|
| Local News | `features/local_news/SPEC.md` | 지역 뉴스/공지 게시 + 자동 수집 + 고정 공지 |
| Find Friend | `features/find_friend/SPEC.md` | 지역 기반 친구/연결 매칭 시스템 |
| Marketplace | `features/marketplace/SPEC.md` | AI 검수 + 예약금 에스크로 기반 거래 |
| Lost & Found | `features/lost_and_found/SPEC.md` | 분실/습득 + HUNTED 강조 노출 |
| Auction | `features/auction/SPEC.md` | 희소 품목 경쟁 입찰 & anti-sniping |
| Main Feed | `features/main_feed/SPEC.md` | 지역 혼합 피드 랭킹 & 스폰서 슬롯 |
| Clubs | `features/clubs/SPEC.md` | 관심사 커뮤니티 그룹/역할/모더레이션 |
| Local Jobs | `features/local_jobs/SPEC.md` | 지역 채용/지원/검증/프로모션 |
| Local Store | `features/local_store/SPEC.md` | 소상공인 스토어 프로필 & 상품 카탈로그 |
| POM | `features/pom/SPEC.md` | (TBD) 추후 정의 예정 |
| Real Estate | `features/real_estate/SPEC.md` | 부동산 매물/검증/리드 수익 모델 |

## Feature Implementation Matrix (Snapshot)
Status Legend: ✅ 구현, 🟡 부분, ❌ 미구현

| Feature | CRUD/Core | Advanced Logic | Monetization | AI/Verification | Notes |
|---------|-----------|----------------|-------------|-----------------|-------|
| Local News | 🟡 | ❌ | ❌ | ❌ | 기본 게시 일부만 |
| Find Friend | 🟡 | 🟡 | ❌ | ❌ | 매칭 로직 확장 필요 |
| Marketplace | 🟡 | ❌ | ❌ | ❌ | AI/에스크로 미구현 |
| Lost & Found | ❌ | ❌ | ❌ | ❌ | 초기 스키마 단계 |
| Auction | ❌ | ❌ | ❌ | ❌ | 생명주기 전부 미구현 |
| Main Feed | ❌ | ❌ | ❌ | ❌ | 클라이언트 스코어 예정 |
| Clubs | ❌ | ❌ | ❌ | ❌ | 역할/모더레이션 전부 필요 |
| Local Jobs | ❌ | ❌ | ❌ | ❌ | 검증/프로모션 미정 |
| Local Store | ❌ | ❌ | ❌ | ❌ | 구독 티어 설계 필요 |
| POM | ❌ | ❌ | ❌ | ❌ | 개념 정의 미완 |
| Real Estate | ❌ | ❌ | ❌ | ❌ | Geo/검증 스펙 필요 |

Matrix는 `SPEC.md` Implementation Status 표와 동기화 예정.

## Reference Docs
| Doc | Path | Purpose |
|-----|------|---------|
| Architecture Overview | `reference/ARCHITECTURE_OVERVIEW.md` | 비전/모듈/상위 개요 |
| Design & i18n Guide | `reference/DESIGN_GUIDE.md` | UI/UX + 다국어 가이드 템플릿 |
| AI Verification Pipeline | `reference/AI_VERIFICATION_PIPELINE.md` | Marketplace 등 AI 검수 플로우 |
| Security Rules Overview | `reference/SECURITY_RULES_OVERVIEW.md` | Firestore 규칙 개요 & 상태 전이 |

## Policy Docs
| Doc | Path | Purpose |
|-----|------|---------|
| Terms & Policies | `policies/TERMS_AND_POLICIES.md` | 서비스 이용 약관/콘텐츠/분쟁 정책 초안 |
| Privacy & Location | `policies/PRIVACY_AND_LOCATION.md` | 위치·개인정보 수집/표시/보호 정책 |

## Migration
기존 산재 문서 → `migration/DOC_PATH_MAPPING.md` 에 old -> new 매핑 기록.

## Sensitive / Deprecated
민감(키/토큰/로그/백업) 파일은 `_sensitive/` 이동 후 검토/삭제. 기능 가치 낮은 레거시는 `deprecated/`.

## Conventions
* 모든 Feature 문서는 `SPEC.md` (필수) + 필요 시 `DATA_MODEL.md` / `ROADMAP.md`.
* 커밋 시 문서 변경은 PR 설명에 변경 범위/의도 요약.

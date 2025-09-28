# Real Estate Feature SPEC (Placeholder v0)

Sections: Purpose, User Stories (list property, search filters), Data Model (/properties, /property_inquiries), Verification Logic, Monetization (premium placement), Roadmap.
Sources: 백서, 참조 자료.

## Implementation Status
항목 | 상태 | 메모
-----|------|-----
Property Listing | 미구현 | 필수 필드/이미지/위치
Filtering/Map | 미구현 | geo index 전략 필요
Doc Verification | 미구현 | 민감 문서 처리
Lead Fee Model | 미구현 | CPM vs Lead 과금

## TODO
- [ ] /properties 스키마 & 인덱스
- [ ] geohash or lat/lng 설계
- [ ] 문서 업로드/암호화 정책
- [ ] 과금 모델 결정 & A/B 기준
- [ ] 지도 클러스터링 & 캐싱 전략

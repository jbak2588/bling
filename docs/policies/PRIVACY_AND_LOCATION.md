# Privacy & Location Policy (v1 Draft)

Source: `5  지역-위치-개인정보.md` + 위치 표기/검색 가이드 + Security Overview.

## 1. 위치 데이터 수집 목적
- 지역 기반 피드 정렬 및 근처 사용자 추천
- 분실물/거래 안전(거리 계산, 사기 방지 패턴)
- 통계/운영 (집계 수준, 개인 재식별 불가)

## 2. 최소 수집 & 데이터 필드
저장 계층 | 필드 | 용도
---------|------|----
정밀(비공개) | GeoPoint (lat,lng) | 반경/거리 계산
행정 계층 | rt,rw,kelurahan,kecamatan,kabupaten,province | 필터/검색/표시
표시 문자열 | locationName | UI 축약/캐시
가공 지표 | geohash(precision N) | 쿼리 범위

## 3. 저장 & 보존 기간
유형 | 기간 | 비고
----|------|----
계정 위치 프로필 | 업데이트시 이전 덮어쓰기 | 이력 미보존(기본)
게시물 위치 | 게시물 유지 동안 | 삭제/익명화 정책
로그(접속 IP/Geo 추정) | 90일 | 보안 감사
분석 집계 | 12개월 | 개별 식별자 제거

## 4. 사용(노출) 범위
공개 UI는 Kelurahan/Kecamatan 단위 축약만 노출 (정밀 GeoPoint 비노출). HeatMap은 집계 버킷 ≥ k 사용자 이상 조건 하에 렌더.

## 5. 거리 기반 필터 로직 개요
1. 사용자 기준 geohash prefix 매칭 → 1차 후보
2. 필요 시 haversine 정확 거리 재평가
3. UI 반경 옵션 (예: 1km/3km/전체) → 내부 지침서 weight 조정

## 6. 사용자 제어 & 동의
- 최초 위치 사용: OS 권한 + In-app 동의 체크박스
- 설정: 위치 정밀도(정밀/행정단위만) 전환
- 철회: 동의 철회 시 정밀 GeoPoint 제거 후 행정 필드만 유지
- 지도 히트맵 Opt-in 별도 플래그

## 7. 보안 & 위변조 방지
- 모든 위치 write 시 서버 재검증(Reverse Geocode 캐싱) → 행정 계층 canonical화
- 비정상 패턴(짧은 시간 다수 위치 점프) → trust penalty
- Firestore Rules: region 필드는 user.profile.region 과 일치 필요
- 전송: TLS; 저장: GeoPoint 직접 암호화는 현재 범위 밖 (재식별 위험 낮음) 단 고위험 국가 론칭 시 재평가

## 8. 재식별 위험 완화
- HeatMap 최소 버킷 크기
- 분석 export 시 geohash precision 축소
- 개인 활동 로그 장기 보존 금지

## 9. 제3자 / 외부 공유
- 법적 요구/사고 조사 외 제공 없음
- 광고 타게팅: 위치는 구(행정) 단위 이상으로만 공유

## 10. 사용자 권리
- 열람: 내 프로필 위치 필드
- 수정: 앱 설정에서 갱신 (일 5회 제한 권고)
- 삭제: 계정 삭제 절차 → 위치 필드 제거/익명화

## 11. 감사 & 로깅
이벤트 | 목적
-------|----
location_update | 빈도/오남용 탐지
heatmap_opt_change | 통계 추적
geo_anomaly_flag | 변칙 탐지

## 12. Open Questions
- 위치 이력(이동 경로) 비저장 정책 유지 vs 선택적 opt-in 필요?
- Geo 암호화(K-Anonymity) 적용 시점?
- 연 1회 Privacy Transparency Report 공개 범위?

## 13. TODO
- [ ] Reverse Geocode 캐시 정책 문서화
- [ ] HeatMap 최소 버킷 `k` 값 결정
- [ ] Opt-out 처리 시 백필/정규화 함수 구현
- [ ] geo_anomaly 탐지 기준(threshold) 정의
- [ ] 데이터 보존 Retention batch job 스펙

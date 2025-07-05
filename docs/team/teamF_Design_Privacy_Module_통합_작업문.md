

## 📌 `[팀F] Bling_Design_Privacy_Module_통합_작업문서 (Ver.3)`

**담당:** Design & Privacy 담당팀  
**총괄:** ChatGPT (총괄 책임자)  
**버전:** Bling Ver.3 기준

---

## ✅ 1️⃣ 모듈 목적

Bling의 전반적 **디자인 가이드**, **브랜드 일관성**, **다국어(i18n)**,  
**개인정보 공개/비공개 설정(Privacy Center)** 정책을 관리하여  
모든 팀이 **일관된 UI/UX, 컬러, 텍스트 표준**을 공유할 수 있도록 한다.

---

## ✅ 2️⃣ 실전 i18n & Privacy 구조 예시 (Ver.3 기준)

```json
// assets/lang/en.json
{
  "feed.post.title": "Title",
  "feed.post.body": "Content",
  "user.profile.trustLevel": "Trust Level",
  "settings.privacy.profilePublic": "Public Profile",
  "settings.privacy.mapVisible": "Show on Map",
  "settings.privacy.datingProfile": "Dating Profile Active"
}
```

```json
// Firestore users/{uid}
"privacySettings": {
  "isProfilePublic": true,
  "isMapVisible": false,
  "isDatingProfileActive": false
}
```

---

## ✅ 3️⃣ 핵심 정책 요약

|정책|내용|
|---|---|
|**i18n**|`easy_localization` + `.json` 파일 (en, id, ko)|
|**Key Naming**|`feature.component.property` 패턴 통일|
|**Theme**|Primary/Secondary Color, Font, Icon 일관성|
|**Privacy Center**|프로필/지도/데이팅 공개 여부 사용자가 직접 설정|
|**TrustLevel Badge**|신뢰 등급별 Badge 색상/스타일 표준화|
|**Dark/Light Mode**|다크모드/라이트모드 토글 UX 포함|

---

## ✅ 4️⃣ 연계 모듈 필수

- Auth & Trust: TrustLevel Badge 스타일 공유
    
- Feed/Marketplace/Chat: 개인정보 공개 범위 (`privacySettings`) 반영
    
- i18n: 모든 텍스트 Key → 공통 JSON 관리
    

---

## ✅ 5️⃣ 담당 팀 핵심 TODO 리스트

|No.|작업 항목|설명|
|---|---|---|
|F-1|i18n JSON 구조 최종화|en.json / id.json / ko.json|
|F-2|Key Naming Rule|`feature.component.property` QA|
|F-3|ThemeData 확정|컬러팔레트, 폰트, 아이콘|
|F-4|TrustLevel Badge 디자인|normal/verified/trusted Badge SVG|
|F-5|Privacy Toggle|ProfilePublic/MapVisible/DatingProfile|
|F-6|다크/라이트 모드 QA|전환 시 색상/폰트 테스트|
|F-7|Brand Guide Draft|로고, App Icon, Splash, Font Guide|
|F-8|Localization Proof|번역 Key 누락 QA|

---

## ✅ 6️⃣ 팀 F 작업 지시 상세

1️⃣ **i18n**

- 모든 텍스트 Key → JSON으로 관리
    
- Key 중복/누락 확인
    

2️⃣ **Theme**

- Primary(주색), Secondary(포인트색), Accent 정의
    
- 폰트 Weight, Size 표준화
    
- 아이콘 세트 일관성 유지
    

3️⃣ **TrustLevel Badge**

- `normal`: Gray
    
- `verified`: Blue
    
- `trusted`: Gold/Green
    

4️⃣ **Privacy**

- ProfilePublic, MapVisible, DatingProfile → 토글/스위치 UX
    

5️⃣ **Dark Mode**

- 색상 대비, 아이콘 반전 테스트
    

---

## ✅ 7️⃣ 필수 체크리스트

✅ i18n JSON 키 누락 없음  
✅ ThemeData Flutter QA Pass  
✅ Badge SVG 디자인 적용  
✅ Privacy Toggle DB Sync OK  
✅ Dark/Light Mode 전환 Proof  
✅ Brand Guide 파일 Vault 반영  
✅ PR + Vault `📌 Bling_Ver3_Rebase_Build.md` 기록

---

## ✅ 8️⃣ 작업 완료시 팀 F 제출물

- en.json / id.json / ko.json 샘플
    
- Key Naming 가이드 `.md`
    
- ThemeData 스니펫
    
- TrustLevel Badge SVG 시안
    
- Privacy Toggle UX 캡처
    
- 다크모드 QA 캡처
    
- Brand Guide PDF or Figma 링크
    
- PR & Vault 기록
    

---

## ✅ 🔗 연계 문서

- [[📌 Bling_Design_Guide]]
    
- [[📌 Bling_Localization_Policy]]
    
- [[📌 Bling_Privacy_Policy]]
    

---

# 1_01. Design_Guide

---

## ✅ Design Guide 개요

Bling은 Keluharan(Kel.) 기반 지역 슈퍼앱으로,  
**Carousell의 깔끔함**과 **Gojek의 로컬 감성 컬러톤**을 결합해  
**믿을 수 있고 직관적인 지역 커뮤니티 UI/UX**를 지향합니다.

---

## 📌 핵심 톤 & 목표

- Kelurahan(Kel.) 기반 Nextdoor + Gojek 런처 UX
    
- Carousell의 깔끔함 + Gojek의 신뢰 컬러
    
- Singkatan 주소 표기 원칙 포함
    
- TrustLevel & AI 검수 뱃지 시각화 가이드 포함
    

---

## ✅ 컬러 팔레트

|용도|HEX|
|---|---|
|Primary|#00A66C (Gojek Green)|
|Secondary|#FF6B00 (Bling Orange)|
|TrustLevel Verified|#00A66C|
|TrustLevel Trusted|#007E4F|
|AI Verified|#2196F3|
|Background|#FFFFFF|
|Surface|#F8F8F8|
|Text Primary|#212121|
|Text Secondary|#616161|
|Success|#4CAF50|
|Warning|#FFC107|
|Error|#E53935|

---

## ✅ 폰트 가이드

| 용도       | 폰트                     | 크기                   |
| -------- | ---------------------- | -------------------- |
| Headline | Inter / SF Pro Display | 20~24sp              |
| SubTitle | Inter / SF Pro Display | 16~18sp              |
| Body     | Inter / SF Pro Text    | 14~16sp              |
| Caption  | Inter / SF Pro Text    | 12sp                 |
| Button   | Inter Semi-Bold        | 14sp                 |
| Inter /  | SF Pro Display         | Roboto Thin fallback |

- ✅ **Inter**: Carousell과 비슷한 느낌, 가볍고 깔끔
    
- ✅ iOS fallback: `SF Pro`
    
- ✅ Android fallback: `Roboto Thin`
    

---

## ✅ 아이콘 & 버튼 스타일

- 아이콘: Lucide Icons or Material Symbols Outlined → 얇고 깔끔
    
- 버튼 스타일:
    
    - Primary → Filled (#00A66C)
        
    - Secondary → Outline (#00A66C, 1.5px)
        
    - Disabled → 40% 투명도
        
    - Floating Action Button → Secondary Color (#FF6B00)

    - 모든 Form 화면의 저장/확인 버튼은 Fixed Bottom Button 스타일을 따른다.
        

---

## ✅ 곡률 & 간격

- 카드/버튼 모서리: 12dp
    
- 카드 패딩: 16dp
    
- 요소 간 마진: 8~12dp
    

---

## ✅ 다크/라이트 모드

- Flutter `ThemeData`로 모드 자동 스위칭
    
- Primary/Secondary 컬러는 유지
    
- 텍스트 대비는 충분히 확보 (WCAG 준수)
    
---

## ✅ 곡률 & 간격

- 카드/버튼 모서리: 12dp
    
- 카드 패딩: 16dp
    
- 요소 간 마진: 8~12dp
    

---

## ✅ Singkatan 표기 가이드

- 모든 위치 라벨: Singkatan 적용 → Kel., Kec., Kab., Prov.
    
- DropDown 선택 예시: Kab. Tangerang → Kec. Cibodas → Kel. Panunggangan Barat → RT.03/RW.05
    
- Label 스타일: `TextSecondary` 색상 + Location Icon (Outlined)

---
## ✅ TrustLevel & AI Verified 뱃지 가이드

|   |   |   |
|---|---|---|
|상태|컬러|아이콘|
|Normal|Gray|없음/기본 아바타|
|Verified|Gojek Green|Shield/Check Badge|
|Trusted|Deep Green|Shield/Star Badge|
|AI Verified|Light Blue|AI Chip/Verified Badge|

- Feed/Post/Marketplace Card에 상태별 Badge 표시
    
- MyProfile 화면 상단에 TrustLevel 상태 강조
    

---

## ✅ 런처 탭 & 상징 컬러

|   |   |   |
|---|---|---|
|모듈|상징 아이콘|상징 컬러|
|Feed|Newspaper|Primary Green|
|Marketplace|Storefront|Orange|
|Find Friend|Favorite/PersonAdd|Green|
|Club|Group|Primary Green|
|Jobs|Work|Deep Green|
|Local Shops|Store Mall Directory|Orange|
|Auction|Gavel|Deep Green|
|POM(Shorts)|Star/Video|Light Blue|

---

## ✅ 다크/라이트 모드 & 접근성

- Flutter `ThemeData`로 모드 자동 스위칭
    
- WCAG 대비 준수
    
- Primary/Secondary 컬러 유지


---


## ✅ Figma & 코드 연계

- Figma → Design Token → `theme.dart`
    
- `theme.dart`에 컬러/폰트 전역 관리
    
- `google_fonts` 패키지로 `Inter` 로드
    
- 다국어 Key → `easy_localization` JSON 연동
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[1_14. UIUX_Guide]]
- 
- [[1_02. Localization_Policy]]
    
- [[4_21. User_Field_Standard]]
    
- [[3_18_2. TrustLevel_Policy]]
    

---

## ✅ 결론

이 Design Guide는 Bling 슈퍼앱의 **Kelurahan 기반 지역 신뢰 구조, Singkatan 주소, TrustLevel/AI 상태**를 시각적으로 반영하는 실전 표준입니다.


# 1_02. Localization_Policy


---

## ✅ 다국어(Localization) 개요

Bling은 인도네시아 Keluharan(Kel.) 기반 슈퍼앱으로,  
영어(EN), 인도네시아어(ID) 등 다국어 지원이 필수입니다.  
Flutter `easy_localization` 또는 `intl` 패키지를 활용해  
**일관된 JSON Key 관리와 다국어 빌드 안정성**을 유지합니다.

---

## ✅ 폴더 & 파일 구조

| 항목    | 설명                                                                                                                  |
| ----- | ------------------------------------------------------------------------------------------------------------------- |
| 폴더 경로 | assets<br>├── icons<br>│   └── google_logo.png<br>├── lang<br>│   ├── en.json<br>│   ├── id.json<br>│   └── ko.json |
| 파일명   | ISO 639-1 코드 사용: `en.json`, `id.json`, `ko.json`                                                                    |
| 키명 규칙 | `feature.component.property` 패턴                                                                                     |
| 공통 키  | `common.xxx` 구조로 관리                                                                                                 |
| 변수    | `{variable}` 사용                                                                                                     |

---

## ✅ 키명 예시

| 올바른 예 | 잘못된 예 |
|------------|------------|
| `login.googleButton.text` | `login_google_button_text` |
| `feed.post.title` | `postTitle` |
| `common.button.save` | `saveButton` |

---

## ✅ JSON Nested 구조 예시

```json
{
  "_metadata": {
    "version": "v0.3",
    "lastUpdated": "2025-07-01"
  },
  "common": {
    "ok": "OK",
    "cancel": "Cancel"
  },
  "login": {
    "title": "Welcome to Bling",
    "googleButton": {
      "text": "Sign in with Google"
    }
  }
}
````

---

## ✅ TODO & QA 규칙

- 번역 미완 → `{TODO}` 텍스트로 표시
    
- 빌드시 `{TODO}` 존재 시 경고
    
- QA 시 누락 키 자동 스캔
    

---

## ✅ Figma 연계

- 디자이너와 개발자, 번역가가 동일 키명 사용
    
- 디자인 키맵 `design_keymap.md` 별도 관리 권장
    
- Figma → Flutter → JSON 흐름 정리
    

---

## ✅ 협업 워크플로우

1️⃣ 새 Key 추가 → GitHub PR 설명 필수  
2️⃣ Reviewer → JSON 키명 규칙 확인  
3️⃣ Release Note → 추가/삭제된 Key 기록  
4️⃣ Obsidian → 다국어 정책 버전 기록

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[4_21. User_Field_Standard]]
    

---

## ✅ 결론

Bling의 다국어 정책은  
**ISO 표준, JSON Key 규칙, 변수, 메타 정보**까지 포함해  
**안전하고 반복 가능한 글로벌 서비스 운영**을 목표로 합니다.



### ✅ 핵심 정리
- ISO 639-1 표준 → 파일명 통일 (`en.json`, `id.json`)
- `feature.component.property` → 키명 일관성
- `{TODO}` → QA 자동화 연계
- Figma~Flutter~Repo 전체 워크플로 반영

---




# 1_14. UIUX_Guide

---

## ✅ UI/UX Guide 개요

Bling은 Keluharan(Kel.) 기반 지역 슈퍼앱으로,  
Nextdoor의 피드 구조와 Gojek 런처 UX를  
하나로 통합해 **일관된 사용자 흐름과 직관적 인터페이스**를 목표로 합니다.

---

## ✅ 메인 레이아웃 구성

- **상단 AppBar**
    
    - 좌측: 사용자 프로필 아이콘 (Drawer 열기)
        
    - 중앙: My Town GEO 드롭다운 (Kabupaten → Kecamatan → Keluharan → 옵션 : RT/RW 리트스 정렬)
        
    - 우측: 언어 변경 아이콘
        
- **상단 슬라이드 탭**
    
    - Main Feed | Local News | Marketplace | Find Friend | Club | Jobs | Local Shops | Auction | POM
        
- **메인 Feed**
    
    - 최신 글 + 인기 글 우선 노출
        
- **왼쪽 Drawer**
    
    - Profile, Chat, Bookmark, Community, Jobs, Settings, Logout
        
- **하단 BottomNavigationBar**
    
    - Home | Search | (+) 글쓰기 | Chat | Notifications | My Page
        

---

## ✅ 주요 컴포넌트 규칙

- **FeedCard**: 제목, 이미지, 카테고리 Badge
    
- **Comment Bubble**: 닉네임 + TrustLevel 뱃지
    
- **Chat Bubble**: 좌/우 정렬
    
- **FloatingActionButton**: (+) 글쓰기 전용 강조
    

---

## ✅ 반응형 & 접근성

- Mobile: 1 Column
    
- Tablet: 2 Column
    
- 최소 터치 영역: 48dp 이상
    
- 명도 대비: WCAG AA 이상 준수
    

---

## ✅ 마이크로 인터랙션

- 좋아요: Heart Beat Animation
    
- 댓글 입력: Smooth Slide Up
    
- Chat 알림: Badge + Vibration
    

---

## ✅ 사용자 흐름 시나리오

1️⃣ 신규 유저 → Keluharan 인증 → 기본 프로필 작성  
2️⃣ Local Feed 진입 → 관심사 선택 → Find Friend 추천  
3️⃣ 관심사 기반 이웃 연결 → 채팅 → Club 참여 → Marketplace 확장

---

## ✅ Flutter 적용 가이드

- AppBar, Drawer: `Scaffold.drawer` + `AppBar.leading`
    
- 슬라이드 탭: `TabBar` + `TabBarView`
    
- Feed: `ListView` + `StreamBuilder`
    
- BottomNav: `BottomNavigationBar` + `FloatingActionButton`
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[1_01. Design_Guide]]
    

---

## ✅ 결론

Bling UI/UX Guide는  
Keluharan 기반 사용자 흐름**, **슬라이드 런처 UX**,  
**신뢰도 기반 개인화**를 하나로 묶어  
인도네시아 로컬 슈퍼앱의 UX 표준을 만듭니다.



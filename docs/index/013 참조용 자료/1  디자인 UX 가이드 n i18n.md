# 1_01. Design_Guide

---

## ✅ Design Guide 개요

Bling은 Keluharan(Kel.) 기반 지역 슈퍼앱으로,  
**Carousell의 깔끔함**과 **Gojek의 로컬 감성 컬러톤**을 결합해  
**믿을 수 있고 직관적인 지역 커뮤니티 UI/UX**를 지향합니다.

---

## ✅ 핵심 목표

- 깔끔하고 가벼운 레이아웃
    
- 로컬 친화적 컬러
    
- TrustLevel과 지역성 강조
    
- iOS/Android에서 동일한 일관성 유지
    

---

## ✅ 컬러 팔레트

|용도|HEX|
|---|---|
|Primary|#00A66C (Gojek Green 느낌)|
|Secondary|#FF6B00 (기존 Bling Orange 유지)|
|Background|#FFFFFF|
|Surface|#F8F8F8|
|Text Primary|#212121|
|Text Secondary|#616161|
|Success|#4CAF50|
|Warning|#FFC107|
|Error|#E53935|

---

## ✅ 폰트 가이드

|용도|폰트|크기|
|---|---|---|
|Headline|Inter / SF Pro Display|20~24sp|
|SubTitle|Inter / SF Pro Display|16~18sp|
|Body|Inter / SF Pro Text|14~16sp|
|Caption|Inter / SF Pro Text|12sp|
|Button|Inter Semi-Bold|14sp|

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

## ✅ Figma & 코드 연계

- Figma → Design Token 연동
    
- `theme.dart`에 컬러/폰트 전역 관리
    
- `google_fonts` 패키지로 `Inter` 로드
    
- Copilot/Dart → 자동 Theme 적용
    

---

## ✅ 연계 문서

- [[2_01. Bling_Project_Overview]]
    
- [[2_04. Bling_MainScreen_Structure]]
    
- [[1_14. UIUX_Guide]]
    

---

## ✅ 결론

Bling Design Guide는  
**깔끔한 Carousell 톤 + Gojek 컬러 + 지역성 강조**를 결합한  
인도네시아 로컬 슈퍼앱에 최적화된 **신뢰 기반 디자인 표준**입니다.


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
    
    - New Feed | Local News | Marketplace | Find Friend | Club | Jobs | Local Shops | Auction | POM
        
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
2️⃣ Local News 진입 → 관심사 선택 → Find Friend 추천  
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


# 1_35. Icons 및 Button 요소들
다음은 Flutter에서 사용하는 **아이콘 및 버튼 요소들을 Obsidian 문서에 정리할 수 있는 전용 템플릿**입니다. 화면별 명세서와 실제 사용 예제를 함께 제공하므로, 빠몽님이 기획문서와 연동해서 관리하기 좋습니다.

---

## 📄 Obsidian 템플릿: `flutter_ui_components.md`

https://fonts.google.com/icons
# 📱 Flutter UI 아이콘 및 버튼 정리

이 문서는 앱 내에서 사용되는 아이콘(`Icons`, `CupertinoIcons`)과 버튼(`ElevatedButton`, `TextButton` 등)의 종류와 용도를 화면 단위로 정리합니다.

## ✅ 문서 작성 가이드

- 각 화면 단위로 구분
- 아이콘/버튼 위젯 이름 + 설명 + Flutter 명칭 명시
- 필요시 iOS 대응 여부 함께 기재

---

## 📂 화면별 UI 컴포넌트 정리

### 🏠 HomeScreen (`/home`)

#### 📌 사용 아이콘

| 위치 | 기능 | Flutter 명칭 | iOS 대응 (Cupertino) | 비고 |
|------|------|--------------|----------------------|------|
| AppBar 좌측 | 위치 변경 | `Icons.location_on` | `CupertinoIcons.location_solid` | 지역명 표시 옆 |
| AppBar 우측 | 알림 | `Icons.notifications` | `CupertinoIcons.bell` | 알림 badge 가능 |

#### 🔘 사용 버튼

| 위치 | 버튼 기능 | 위젯 | 설명 |
|------|-----------|------|------|
| 하단 FAB | 글쓰기 | `FloatingActionButton` | `Icons.add` 포함, `/post/create` 이동 |
| 피드 항목 내부 | 좋아요 | `IconButton(Icons.favorite_border)` | 눌렀을 때 `Icons.favorite`로 변경 |

---

### ✍️ CreatePostScreen (`/post/create`)

#### 📌 사용 아이콘

| 위치 | 기능 | Flutter 명칭 | 비고 |
|------|------|--------------|------|
| 사진 첨부 | 이미지 선택 | `Icons.photo_library` | 갤러리 열기 |
| 카메라 | 즉시 촬영 | `Icons.camera_alt` | 권한 필요 |

#### 🔘 사용 버튼

| 위치 | 버튼 기능 | 위젯 | 설명 |
|------|-----------|------|------|
| 하단 | 게시 | `ElevatedButton` | 글 작성 완료 후 피드로 돌아감 |
| 하단 | 취소 | `TextButton` | 글쓰기 취소 및 뒤로가기 |

---

### 👤 ProfileScreen (`/profile`)

#### 📌 사용 아이콘

| 위치 | 기능 | Flutter 명칭 | 비고 |
|------|------|--------------|------|
| 상단 | 설정 이동 | `Icons.settings` | `/settings` 이동 |
| 사용자 사진 옆 | 편집 | `Icons.edit` | 프로필 편집 |

#### 🔘 사용 버튼

| 위치 | 기능 | 위젯 | 설명 |
|------|------|------|------|
| 로그아웃 | 계정 종료 | `OutlinedButton` | 로그아웃 기능 실행 |

---

## 🧩 버튼 스타일 통일 가이드 (디자인 가이드 기준)

| 버튼 종류 | 사용 위치 예시 | 스타일 기준 |
|-----------|----------------|-------------|
| `ElevatedButton` | 주요 액션 (제출, 확인) | 색상: Primary, Radius: 8dp |
| `TextButton` | 보조 액션 (취소, 뒤로) | 폰트만 강조 |
| `OutlinedButton` | 설정, 로그아웃 | 테두리 강조용 |
| `FloatingActionButton` | 글쓰기, 채팅 등 주요 FAB | `Icons.add`, `Icons.chat` 등 포함 |

---

## ✨ 향후 업데이트 예정

- 커스텀 아이콘셋 정의 (`assets/icons/`)
- 상태 기반 아이콘 전환 예시 (like, follow 등)
- 버튼 비활성화 상태 정의



## 🧪 사용 예제 (실제 Dart 코드 매핑)

```dart
// 글쓰기 화면 버튼 예시
ElevatedButton(
  onPressed: () {
    submitPost();
  },
  child: Text("게시"),
)

// 하단 FAB 예시
FloatingActionButton(
  onPressed: () {
    Navigator.pushNamed(context, '/post/create');
  },
  child: Icon(Icons.add),
)

// 설정 버튼 (아이콘)
IconButton(
  icon: Icon(Icons.settings),
  onPressed: () {
    Navigator.pushNamed(context, '/settings');
  },
)
```

---

## 🧭 빠몽(기획자) 할 일 요약

-  위 템플릿을 Obsidian의 `📁 UI 컴포넌트 명세` 폴더에 생성
    
-  각 화면 단위로 실제 사용 아이콘과 버튼 명세 추가
    
-  디자이너/개발자에게 Obsidian 문서 공유 → UX 기준 통일
    
----






# 1_50. theme.dart


```dart
// 📌 Bling theme.dart (보완 버전)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlingTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00A66C), // Gojek Green
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00A66C),
      secondary: const Color(0xFFFF6B00), // Bling Orange
    ),
    textTheme: TextTheme(
      headline1: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline6: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyText1: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      bodyText2: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black54,
      ),
      caption: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.black45,
      ),
      button: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      buttonColor: const Color(0xFF00A66C),
    ),
  );

  // ✅ TrustLevel 뱃지 컬러
  static const Color trustLevelVerified = Color(0xFF00A66C); // Verified Green
  static const Color trustLevelTrusted = Color(0xFF007E4F); // Trusted Deep Green

  // ✅ AI Verified 뱃지 컬러
  static const Color aiVerified = Color(0xFF2196F3); // Light Blue

  // ✅ Singkatan Label 스타일 (주소 텍스트 색상)
  static const Color locationLabel = Color(0xFF616161); // Text Secondary
}

// ✅ 사용 예시:
// MaterialApp(
//   theme: BlingTheme.lightTheme,
//   home: MyHomePage(),
// )
```




# 1_99. 📌 Bling 인도네시아 주소 표기 & DropDown 정책
# 📌 Bling 인도네시아 주소 표기 & DropDown 정책 (Ver.0.4)

## ✅ Singkatan(약어) 표기 원칙

모든 화면 주소 표기는 인도네시아 공공 행정 표준 Singkatan(약어)을 사용합니다.

- Kecamatan → Kec.
    
- Kelurahan → Kel.
    
- Kabupaten → Kab.
    
- Provinsi → Prov.
    

예시:  
Kel. Panunggangan Barat, Kec. Cibodas, Kab. Tangerang, Prov. Banten

---

## ✅ 단계별 DropDown 흐름 (검색 & 등록)

1️⃣ 검색/등록 시작: **Kabupaten/Kota** 선택 (예: Kab. Tangerang)

2️⃣ 선택 단계:

- Kabupaten/Kota 선택 시 → 연관 Kecamatan 리스트 로드
    
- Kecamatan 선택 시 → Kelurahan 리스트 로드
    
- Kelurahan 선택 시 → RT/RW 리스트 제공 (옵션)
    

3️⃣ RT/RW:

- 필수 아님 (사용자가 원하는 경우에만 세부 선택)
    
- 등록/검색 설정에서 옵션으로 선택 가능
    

4️⃣ 저장 구조:

- `locationParts` 필드에 단계별로 Singkatan 표기로 저장
    
- `locationName`은 Singkatan을 포함한 풀 스트링으로 구성
    

Firestore 저장 예시:

```json
{
  "locationParts": {
    "kabupaten": "Kab. Tangerang",
    "kecamatan": "Kec. Cibodas",
    "kelurahan": "Kel. Panunggangan Barat",
    "rt": "RT.03",
    "rw": "RW.05"
  },
  "locationName": "Kel. Panunggangan Barat, Kec. Cibodas, Kab. Tangerang"
}
```

---

## ✅ Feed & 모든 게시물 쿼리 구조 변경

- 기본 쿼리: `kabupaten` 기준으로 시작
    
- 단계별 옵션: `kecamatan` → `kelurahan` → RT/RW 리스트 정렬 옵션
    
- RT/RW Equal 쿼리는 선택 시에만 활성화
    
- 반경 검색은 GeoPoint + geohash 유지
    

Firestore 쿼리 예시:

```dart
query
  .where('kabupaten', isEqualTo: 'Kab. Tangerang')
  .where('kecamatan', isEqualTo: 'Kec. Cibodas')
  .where('kelurahan', isEqualTo: 'Kel. Panunggangan Barat')
  .where('rt', isEqualTo: 'RT.03') // 옵션
  .where('rw', isEqualTo: 'RW.05') // 옵션
```

---

## ✅ 적용 대상 문서 링크

- `📌 Bling_Project_Overview`
    
- `📌 Bling_User_Field_Standard`
    
- `📌 Bling_Local_Feed_Policy`
    
- `📌 Bling_TrustLevel_Policy`
    
- `📌 Bling_Development_Roadmap`



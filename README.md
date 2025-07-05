# 🚀 Bling- Keluharan 기반 슈퍼앱 프로젝트

---

## ✅ 프로젝트 개요

bling는 인도네시아의 Kuluhara 기반 Nextdoor형 커뮤니티와  
Gojek 스타일 런처 UX를 결합한 **하이브리드 로컬 앱**입니다.

---

## ✅ 핵심 컨셉

- Keluhara 기반 신뢰등급 (TrustLevel)
- 지역 피드(Warga Feed)
- 중고/신상품 마켓플레이스 + AI 검수
- 친구찾기/데이팅 (Cari Teman)
- Klub(동호회), Lowongan(구인), Toko Lokal(소상공인)
- Lelang(경매), POM(지역 쇼츠)
- 다국어(Localization) + AppBar GEO 범위 설정

## ✅ 폴더 구조    2025년 7월 4일 Ver 0.4 기준

llib
├── api_keys.dart
├── core
│   ├── constants
│   │   └── app_categories.dart
│   ├── models
│   │   ├── comment_model.dart
│   │   ├── feed_item_model.dart
│   │   ├── page_data.dart
│   │   ├── post_category_model.dart
│   │   ├── post_model.dart
│   │   ├── product_model.dart
│   │   ├── reply_model.dart
│   │   └── user_model.dart
│   └── utils
│       └── address_formatter.dart
├── features
│   ├── admin
│   │   └── screens
│   │       └── data_uploader_screen.dart
│   ├── auction
│   │   └── screens
│   │       └── auction_screen.dart
│   ├── auth
│   │   └── screens
│   │       ├── auth_gate.dart
│   │       ├── login_screen.dart
│   │       ├── profile_edit_screen.dart
│   │       └── signup_screen.dart
│   ├── categories
│   │   ├── domain
│   │   │   └── category.dart
│   │   └── screens
│   │       ├── parent_category_screen.dart
│   │       └── sub_category_screen.dart
│   ├── chat
│   │   ├── domain
│   │   │   ├── chat_message.dart
│   │   │   ├── chat_room.dart
│   │   │   └── chat_utils.dart
│   │   └── screens
│   │       ├── chat_list_screen.dart
│   │       └── chat_room_screen.dart
│   ├── clubs
│   │   └── screens
│   │       └── clubs_screen.dart
│   ├── community
│   │   └── screens
│   │       └── community_screen.dart
│   ├── feed
│   │   ├── data
│   │   │   └── feed_repository.dart
│   │   ├── screens
│   │   │   ├── feed_screen.dart
│   │   │   └── local_feed_screen.dart
│   │   └── widgets
│   │       └── post_card.dart
│   ├── find_friends
│   │   └── screens
│   │       └── find_friends_screen.dart
│   ├── jobs
│   │   └── screens
│   │       └── jobs_screen.dart
│   ├── local_news
│   │   └── screens
│   │       └── local_news_screen.dart
│   ├── local_stores
│   │   └── screens
│   │       └── local_stores_screen.dart
│   ├── location
│   │   └── screens
│   │       ├── location_search_screen.dart
│   │       ├── location_setting_screen.dart
│   │       └── neighborhood_prompt_screen.dart
│   ├── main_screen
│   │   └── home_screen.dart
│   ├── marketplace
│   │   ├── domain
│   │   │   └── product_model.dart
│   │   ├── screens
│   │   │   ├── marketplace_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   ├── product_edit_screen.dart
│   │   │   └── product_registration_screen.dart
│   │   └── widgets
│   │       └── product_card.dart
│   ├── my_bling
│   │   ├── screens
│   │   │   └── my_bling_screen.dart
│   │   └── widgets
│   │       ├── user_bookmark_list.dart
│   │       ├── user_post_list.dart
│   │       └── user_product_list.dart
│   ├── pom
│   │   └── screens
│   │       └── pom_screen.dart
│   ├── post
│   │   ├── screens
│   │   │   ├── create_post_screen.dart
│   │   │   └── post_detail_screen.dart
│   │   └── widgets
│   │       ├── comment_input_field.dart
│   │       ├── comment_list_view.dart
│   │       ├── reply_input_field.dart
│   │       └── reply_list_view.dart
│   ├── real_estate
│   │   └── screens
│   │       └── real_estate_screen.dart
│   └── shared
│       └── controllers
│           └── locale_controller.dart
├── firebase_options.dart
├── main.dart
├── pubspec.yaml
├── README.md
├── docs
│   ├── index
│   │   ├── 00  Mainscreen & 런처 & Tab & Drawer QA.md
│   │   ├── 01  프로젝트 개요 & 폴더트리.md
│   │   ├── 010  Feed(Post) 모듈.md
│   │   ├── 011  Marketplace 모듈.md
│   ├── 012  Find Friend & Club & Jobs & etc 모듈.md
│   ├── 013 참조용 자료
│   │   │   ├── 0. 작업 지침!.md
│   │   │   ├── 1  디자인 UX 가이드 n i18n.md
│   │   │   ├── 10  개발 로드맵 & 체크리스트.md
│   │   │   ├── 12. 약관 & 법적 정책.md
│   │   │   ├── 2  프로젝트 개요 & 메인 구조.md
│   │   │   ├── 3  사용자 DB & 신뢰 등급.md
│   │   │   ├── 4  사용자 화면 & 마이페이지.md
│   │   │   ├── 5  지역-위치-개인정보.md
│   │   │   ├── 6  피드 (Local News).md
│   │   │   ├── 7  Marketplace.md
│   │   │   ├── 8  Frind-Club-Jobs-Shops-Auciton-POM.md
│   │   │   ├── 9  Notification - 신고 - 커뮤니티.md
│   │   │   └── Pasted image 20250701221455.png
│   │   ├── 02  Design Guide + i18n.md
│   │   ├── 03  User 필드 & TrustLever & 프로필정책.md
│   │   ├── 04  주소 DropDwon & Singkatan.md
│   │   ├── 05  공통 Helper & Service & Validator.md
│   │   ├── 06  MyProfile & 활동 히스토리 Scaffold.md
│   │   ├── 07  Chat 모듈 Core.md
│   │   ├── 08  Notification 모듈 Core.md
│   │   ├── 09  신고 & 차단 & Privacy Guard.md
│   │   ├── Bling App 개발 일지 (2025년 7월 4일).md
│   │   ├── Bling_Location_GeoQuery_Structure.md
│   │   ├── 전체_프로젝트_팀별_공통_공지문.md
│   │   ├── 피드 관련 위치 검색 규칙과 예시.md
│   │   └── 📌 Bling_Team_ToDo_QA_Index.md
│   ├── team
│   │   ├── TeamA__Auth_Trust_module_통합 작업문서.md
│   │   ├── teamB_Feed_CRUD_Module_통합 작업문서.md
│   │   ├── teamC_Chat & Notification 모듈_통합 작업문서.md
│   │   ├── teamD_GeoQuery_Location_Module_통합_작업문서.md
│   │   ├── teamF_Design_Privacy_Module_통합_작업문.md
│   │   └── temE_AI_Moderation_Module_통합_작업문서.md
│   └── templates 
└── assets
    ├── data
    │   └── sample_posts.json
    ├── icons
    │   └── google_logo.png
    ├── lang
    │   ├── en.json
    │   ├── en_old.json
    │   ├── id.json
    │   ├── id_old.json
    │   ├── ko.json
    │   └── ko_old.json
    └── sounds
        └── send_sound.mp3




## ✅ 핵심 Firestore 컬렉션

| 컬렉션             | 설명          |
| --------------- | ----------- |
| `posts`         | Local Feed  |
| `products`      | Marketplace |
| `shorts`        | POM 쇼츠      |
| `auctions`      | 옥션          |
| `jobs`          | 구인 구직       |
| `shops`         | Local shops |
| `clubs`         | 모임/동호회      |
| `users`         | 사용자 정보      |
| `chats`         | 채팅          |
| `notifications` | 알림          |


## ✅ 주요 정책 문서

- 📄 0. 작업 지침!.md
- 📄 1. 디자인 UX 가이드 & i18n.md
- 📄 2. 프로젝트 개요 & 메인 구조.md
- 📄 3. 사용자 화면 & 마이페이지.md
- 📄 4. 사용자 DB & 신뢰 등급.md
- 📄 5. 지역-위치-개인정보.md
- 📄 6. 피드 (Local Feed).md
- 📄 7. Marketplace.md
- 📄 8. Frind-Club-Jobs-Shops-Auciton-POM.md
- 📄 9. Notification - 신고 - 커뮤니티.md
- 📄 Bling_Location_GeoQuery_Structure
- 📄 피드 관련 위치 검색 규칙과 예시
---

## ✅ 다국어

assets
├── lang
│   ├── en.json
│   ├── id.json
│   └── ko.json
├── icons
│   └── google_logo.png
lib

---

## ✅ DevOps & AI 협업

- **GPT**:  문서제작
- **Gemini**: 코드 밎 구조 설계
- **Copilot**: Dart 자동완성, VSCode 연동
- 모든 `.md` 정책은 GitHub Repo에서 버전 관리

---

## ✅ 협업 규칙

- PR: 구조 변경 시 `.md` 동기화 필수
- Issue: 구조 변경 사전 공유 필수
- 디자인: `/design/` Figma 링크 연계
- Token Limit 대비 Obsidian + GPT 연계 유지

---

## 🚀 Ver.0.3 → Ver.1.0 목표

Bling 은 Ver.09에서 구조 통합을 마치고  
Ver.1.0에서는 실 서비스 론칭을 목표로 합니다.


# 🚀 Bling- RT/RW 기반 슈퍼앱 프로젝트

---

## ✅ 프로젝트 개요

Ayo는 인도네시아의 RT/RW 기반 Nextdoor형 커뮤니티와  
Gojek 스타일 런처 UX를 결합한 **하이브리드 로컬 슈퍼앱**입니다.

---

## ✅ 핵심 컨셉

- RT/RW 기반 신뢰등급 (TrustLevel)
- 지역 피드(Warga Feed)
- 중고/신상품 마켓플레이스 + AI 검수
- 친구찾기/데이팅 (Cari Teman)
- Klub(동호회), Lowongan(구인), Toko Lokal(소상공인)
- Lelang(경매), POM(지역 쇼츠)
- 다국어(Localization) + AppBar GEO 범위 설정

## ✅ 폴더 구조    2025년 7월 1일 Ver 0.4 기준

lib
├── api_keys.dart
├── core
│   ├── constants
│   │   └── app_categories.dart
│   └── models
│       ├── comment_model.dart
│       ├── feed_item_model.dart
│       ├── page_data.dart
│       ├── post_category_model.dart
│       ├── post_model.dart
│       ├── product_model.dart
│       ├── reply_model.dart
│       └── user_model.dart
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
│   │       ├── comment_input_field.dart
│   │       ├── comment_list_view.dart
│   │       ├── post_card.dart
│   │       ├── reply_input_field.dart
│   │       └── reply_list_view.dart
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
│   │       ├── neighborhood_prompt_screen.dart
│   │       └── neighborhood_prompt_screen_old.dart
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
│   │   └── screens
│   │       └── my_bling_screen.dart
│   ├── pom
│   │   └── screens
│   │       └── pom_screen.dart
│   ├── post
│   │   └── screens
│   │       ├── create_post_screen.dart
│   │       └── post_detail_screen.dart
│   ├── real_estate
│   │   └── screens
│   │       └── real_estate_screen.dart
│   └── shared
│       └── controllers
│           └── locale_controller.dart
├── firebase_options.dart
├── main.dart
│ 
assets
├── data
│   └── sample_posts.json
├── icons
│   └── google_logo.png
├── lang
│   ├── en.json
│   ├── id.json
│   └── ko.json
├──  sounds
│   └── send_sound.mp3
pubspec.yaml





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
- 📄 10. 개발 로드맵 & 체크리스트.md
- 📄 11. 분석 및 수익화.md
- 📄 12. 약관 및 법적 정책.md

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

- **GPT**: 구조 설계 및 표준화
- **Gemini**: 코드 Diff 및 대안 검증
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

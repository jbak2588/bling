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

## 📍 Privacy: Location Display Guidelines

- Do not display a user's detailed street address (`locationParts['street']`) or their full `locationName` in feed/list/card UI without explicit user consent.
- In feed or summary views, only show administrative area names and abbreviate them for privacy and consistency: use `kel.`, `kec.`, `kab.`, `prov.`.
- Store both `locationName` (full address) and `locationParts` ({prov,kab,kec,kel,street,rt,rw}) in Firestore but respect user privacy when rendering summaries.

These rules are intended to reduce accidental exposure of precise location data in public-facing lists and cards. Developers should follow `LocationHelper.cleanName` to normalize admin names before display or indexing.

## ✅ 폴더 구조    2025년 12월 1일 Ver 2.0 기준

lib
├── api_keys.dart
├── core
│   ├── constants
│   │   ├── app_categories.dart
│   │   ├── app_links.dart
│   │   └── app_tags.dart
│   ├── models
│   │   ├── bling_location.dart
│   │   ├── chat_message_model.dart
│   │   ├── chat_room_model.dart
│   │   ├── comment_model.dart
│   │   ├── feed_item_model.dart
│   │   ├── push_prefs_model.dart
│   │   ├── reply_model.dart
│   │   └── user_model.dart
│   ├── services
│   │   ├── location_search_service.dart
│   │   └── notification_service.dart
│   ├── theme
│   │   └── grab_theme.dart
│   └── utils
│       ├── address_formatter.dart
│       ├── localization_utils.dart
│       ├── location_helper.dart
│       ├── logging
│       │   └── logger.dart
│       ├── popups
│       │   └── snackbars.dart
│       └── upload_helpers.dart
├── features
│   ├── admin
│   │   ├── models
│   │   │   └── ai_case_model.dart
│   │   └── screens
│   │       ├── admin_product_detail_screen.dart
│   │       ├── admin_screen.dart
│   │       ├── ai_audit_screen.dart
│   │       ├── ai_case_detail_screen.dart
│   │       ├── data_fix_screen.dart
│   │       ├── data_uploader_screen.dart
│   │       ├── deletion_requests_screen.dart
│   │       ├── report_detail_screen.dart
│   │       └── report_list_screen.dart
│   ├── auction
│   │   ├── data
│   │   │   └── auction_repository.dart
│   │   ├── models
│   │   │   ├── auction_category_model.dart
│   │   │   ├── auction_model.dart
│   │   │   └── bid_model.dart
│   │   ├── screens
│   │   │   ├── auction_detail_screen.dart
│   │   │   ├── auction_screen.dart
│   │   │   ├── create_auction_screen.dart
│   │   │   └── edit_auction_screen.dart
│   │   └── widgets
│   │       └── auction_card.dart
│   ├── auth
│   │   └── screens
│   │       ├── auth_gate.dart
│   │       ├── email_verification_screen.dart
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── splash_screen.dart
│   ├── boards
│   │   ├── models
│   │   │   ├── board_chat_room_model.dart
│   │   │   ├── board_model.dart
│   │   │   └── board_thread_model.dart
│   │   └── screens
│   │       └── kelurahan_board_screen.dart
│   ├── categories
│   │   ├── constants
│   │   │   └── category_icons.dart
│   │   ├── data
│   │   │   ├── category_admin_repository.dart
│   │   │   ├── category_repository.dart
│   │   │   └── firestore_category_repository.dart
│   │   ├── domain
│   │   │   └── category.dart
│   │   ├── screens
│   │   │   ├── category_admin_screen.dart
│   │   │   ├── parent_category_screen.dart
│   │   │   └── sub_category_screen.dart
│   │   └── services
│   │       └── category_sync_service.dart
│   ├── chat
│   │   ├── data
│   │   │   └── chat_service.dart
│   │   ├── domain
│   │   │   ├── chat_message.dart
│   │   │   └── chat_utils.dart
│   │   └── screens
│   │       ├── chat_list_screen.dart
│   │       └── chat_room_screen.dart
│   ├── clubs
│   │   ├── data
│   │   │   └── club_repository.dart
│   │   ├── docs
│   │   │   └── 6.1 Groups _ Grup Komunitas _ 지역 모임 (V2.0)[업데이트 11월2일].md
│   │   ├── models
│   │   │   ├── club_comment_model.dart
│   │   │   ├── club_member_model.dart
│   │   │   ├── club_model.dart
│   │   │   ├── club_post_model.dart
│   │   │   └── club_proposal_model.dart
│   │   ├── screens
│   │   │   ├── club_detail_screen.dart
│   │   │   ├── club_member_list.dart
│   │   │   ├── club_post_detail_screen.dart
│   │   │   ├── club_proposal_detail_screen.dart
│   │   │   ├── clubs_screen.dart
│   │   │   ├── create_club_post_screen.dart
│   │   │   ├── create_club_screen.dart
│   │   │   └── edit_club_screen.dart
│   │   └── widgets
│   │       ├── club_card.dart
│   │       ├── club_member_card.dart
│   │       ├── club_post_card.dart
│   │       ├── club_post_list.dart
│   │       └── club_proposal_card.dart
│   ├── find_friends
│   │   ├── data
│   │   │   └── find_friend_repository.dart
│   │   ├── devlog_n_docs
│   │   │   ├── DevLog_ Bling 앱 개선 작업 (Job 0 - 45).md
│   │   │   ├── 동네 친구 (Find Friends _ Cari Teman Lokal) V.21 2025년11월7일버전.md
│   │   │   └── 💎 블링 '동네 친구' (Find Friends) 기능 개편 기획안 (v2).md
│   │   ├── models
│   │   ├── screens
│   │   │   ├── find_friend_detail_screen.dart
│   │   │   └── find_friends_screen.dart
│   │   └── widgets
│   │       └── findfriend_card.dart
│   ├── jobs
│   │   ├── constants
│   │   │   └── job_categories.dart
│   │   ├── data
│   │   │   ├── job_repository.dart
│   │   │   └── talent_repository.dart
│   │   ├── models
│   │   │   ├── job_model.dart
│   │   │   └── talent_model.dart
│   │   ├── screens
│   │   │   ├── create_job_screen.dart
│   │   │   ├── create_quick_gig_screen.dart
│   │   │   ├── create_talent_screen.dart
│   │   │   ├── edit_talent_screen.dart
│   │   │   ├── job_detail_screen.dart
│   │   │   ├── jobs_screen.dart
│   │   │   ├── select_job_type_screen.dart
│   │   │   └── talent_detail_screen.dart
│   │   └── widgets
│   │       ├── job_card.dart
│   │       └── talent_card.dart
│   ├── local_news
│   │   ├── data
│   │   │   └── local_news_repository.dart
│   │   ├── devlog_docs
│   │   │   └── Bling 프로젝트 DevLog (작업 세션 요약) 2025년 10월 30일.md
│   │   ├── models
│   │   │   ├── post_category_model.dart
│   │   │   └── post_model.dart
│   │   ├── screens
│   │   │   ├── create_local_news_screen.dart
│   │   │   ├── edit_local_news_screen.dart
│   │   │   ├── local_news_detail_screen.dart
│   │   │   ├── local_news_screen.dart
│   │   │   └── tag_search_result_screen.dart
│   │   ├── utils
│   │   │   └── tag_recommender.dart
│   │   └── widgets
│   │       ├── comment_input_field.dart
│   │       ├── comment_list_view.dart
│   │       ├── post_card.dart
│   │       ├── reply_input_field.dart
│   │       └── reply_list_view.dart
│   ├── local_stores
│   │   ├── data
│   │   │   └── shop_repository.dart
│   │   ├── models
│   │   │   ├── shop_model.dart
│   │   │   └── shop_review_model.dart
│   │   ├── screens
│   │   │   ├── create_shop_screen.dart
│   │   │   ├── edit_shop_screen.dart
│   │   │   ├── local_stores_screen.dart
│   │   │   └── shop_detail_screen.dart
│   │   └── widgets
│   │       └── shop_card.dart
│   ├── location
│   │   ├── providers
│   │   │   └── location_provider.dart
│   │   └── screens
│   │       ├── location_filter_screen.dart
│   │       └── neighborhood_prompt_screen.dart
│   ├── lost_and_found
│   │   ├── data
│   │   │   └── lost_and_found_repository.dart
│   │   ├── models
│   │   │   └── lost_item_model.dart
│   │   ├── screens
│   │   │   ├── create_lost_item_screen.dart
│   │   │   ├── edit_lost_item_screen.dart
│   │   │   ├── lost_and_found_screen.dart
│   │   │   └── lost_item_detail_screen.dart
│   │   └── widgets
│   │       └── lost_item_card.dart
│   ├── main_feed
│   │   ├── data
│   │   │   └── feed_repository.dart
│   │   ├── screens
│   │   │   └── main_feed_screen.dart
│   │   └── widgets
│   │       ├── auction_thumb.dart
│   │       ├── club_thumb.dart
│   │       ├── find_friend_thumb.dart
│   │       ├── job_thumb.dart
│   │       ├── local_store_thumb.dart
│   │       ├── lost_item_thumb.dart
│   │       ├── pom_thumb.dart
│   │       ├── post_thumb.dart
│   │       ├── product_thumb.dart
│   │       ├── real_estate_thumb.dart
│   │       └── together_thumb.dart
│   ├── main_screen
│   │   ├── home_screen.dart
│   │   └── main_navigation_screen.dart
│   ├── marketplace
│   │   ├── data
│   │   │   ├── ai_case_repository.dart
│   │   │   └── product_repository.dart
│   │   ├── devlog_n_docs
│   │   │   ├── 2025년 10월 19일 일요일 블링 AI 검수 시스템 V2.0 개발 계획.md
│   │   │   ├── 2025년 10월 21일 화요일 AI 검수 V2.1 동적 증거 보강 시스템 개발 계획 리스트.md
│   │   │   ├── 4. Pre-Loved Items _ 중고물품 거래 (V3.0) 11월16일버전.docx
│   │   │   ├── 4. Pre-Loved Items _ 중고물품 거래 (V3.0) 11월16일버전.md
│   │   │   ├── 4. Pre-Loved Items _ 중고물품 거래 기획서 11월 11일버전.docx
│   │   │   ├── AI 검수 엔진 리팩토링 및 안정화 DevLog V3 11월 16일버전.docx
│   │   │   ├── AI 검수 엔진 리팩토링 및 안정화 DevLog V3 11월 16일버전.md
│   │   │   ├── Bling App  AI 검수 시스템 V2 초기 버전 개발 성공 DevLog.md
│   │   │   └── Marketplace AI 기능 개발일지 (DevLog)-25년 11월 11일.docx
│   │   ├── models
│   │   │   └── product_model.dart
│   │   ├── screens
│   │   │   ├── ai_evidence_suggestion_screen.dart
│   │   │   ├── ai_final_report_screen.dart
│   │   │   ├── ai_takeover_screen.dart
│   │   │   ├── marketplace_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   ├── product_edit_screen.dart
│   │   │   └── product_registration_screen.dart
│   │   ├── services
│   │   │   └── ai_verification_service.dart
│   │   └── widgets
│   │       ├── ai_report_viewer.dart
│   │       ├── ai_verification_badge.dart
│   │       └── product_card.dart
│   ├── my_bling
│   │   ├── screens
│   │   │   ├── account_privacy_screen.dart
│   │   │   ├── app_info_screen.dart
│   │   │   ├── blocked_users_screen.dart
│   │   │   ├── my_bling_screen.dart
│   │   │   ├── notification_settings_screen.dart
│   │   │   ├── profile_edit_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── widgets
│   │       ├── user_bookmark_list.dart
│   │       ├── user_friend_list.dart
│   │       ├── user_post_list.dart
│   │       └── user_product_list.dart
│   ├── notifications
│   │   ├── menu
│   │   └── screens
│   │       └── notification_list_screen.dart
│   ├── pom
│   │   ├── data
│   │   │   └── pom_repository.dart
│   │   ├── models
│   │   │   ├── pom_comment_model.dart
│   │   │   └── pom_model.dart
│   │   ├── screens
│   │   │   ├── create_pom_screen.dart
│   │   │   ├── pom_edit_screen.dart
│   │   │   ├── pom_pager_screen.dart
│   │   │   └── pom_screen.dart
│   │   └── widgets
│   │       ├── pom_card.dart
│   │       ├── pom_comments_sheet.dart
│   │       ├── pom_feed_list.dart
│   │       └── pom_player.dart
│   ├── real_estate
│   │   ├── constants
│   │   │   └── real_estate_facilities.dart
│   │   ├── data
│   │   │   └── room_repository.dart
│   │   ├── models
│   │   │   ├── room_filters_model.dart
│   │   │   └── room_listing_model.dart
│   │   ├── screens
│   │   │   ├── create_room_listing_screen.dart
│   │   │   ├── edit_room_listing_screen.dart
│   │   │   ├── real_estate_screen.dart
│   │   │   ├── room_detail_screen.dart
│   │   │   └── room_list_screen.dart
│   │   └── widgets
│   │       └── room_card.dart
│   ├── shared
│   │   ├── controllers
│   │   │   └── locale_controller.dart
│   │   ├── grab_widgets.dart
│   │   ├── screens
│   │   │   └── image_gallery_screen.dart
│   │   └── widgets
│   │       ├── address_map_picker.dart
│   │       ├── app_bar_icon.dart
│   │       ├── author_profile_tile.dart
│   │       ├── bling_icon.dart
│   │       ├── clickable_tag_list.dart
│   │       ├── custom_tag_input_field.dart
│   │       ├── image_carousel_card.dart
│   │       ├── inline_search_chip.dart
│   │       ├── mini_map_view.dart
│   │       ├── shared_map_browser.dart
│   │       └── trust_level_badge.dart
│   ├── together
│   │   ├── data
│   │   │   └── together_repository.dart
│   │   ├── models
│   │   │   ├── together_post_model.dart
│   │   │   └── together_ticket_model.dart
│   │   ├── screens
│   │   │   ├── create_together_screen.dart
│   │   │   ├── edit_together_screen.dart
│   │   │   ├── ticket_scan_screen.dart
│   │   │   ├── together_detail_screen.dart
│   │   │   └── together_screen.dart
│   │   └── widgets
│   │       ├── place_search.dart
│   │       ├── together_card.dart
│   │       ├── together_section.dart
│   │       └── user_ticket_list.dart
│   └── user_profile
│       └── screens
│           ├── profile_setup_screen.dart
│           └── user_profile_screen.dart
├── firebase_options.dart
└── main.dart
assets
├── data
├── icons
│   ├── google_logo.png
│   ├── ico_auction.svg
│   ├── ico_community.svg
│   ├── ico_friend_3d_deep.svg
│   ├── ico_job.svg
│   ├── ico_lost_item.svg
│   ├── ico_news.svg
│   ├── ico_pom.svg
│   ├── ico_real_estate.svg
│   ├── ico_secondhand.svg
│   ├── ico_store.svg
│   ├── ico_together.svg
│   └── ms
├── lang
│   ├── en.json
│   ├── id.json
│   └── ko.json
└── sounds
    └── send_sound.mp3

pubspec.yaml
functions-v2
├── index.js
├── node_modules
├── package-lock.json
├── package.json
└── pglite-debug.log
├── pubspec.yaml
└── README.md


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

## ✅ 개발 환경 & 실행 방법

1. 의존성 설치

```bash
flutter pub get
```

2. Android/iOS 에뮬레이터를 실행하거나 실제 기기를 연결한 후 앱을 구동합니다.

```bash
flutter run
```

3. Google Maps API 키를 `lib/api_keys.dart`에 정의해야 합니다. 파일 예시는 다음과 같습니다.

```dart
class ApiKeys {
  static const googleApiKey = 'YOUR_GOOGLE_API_KEY';
}
```

4. `sample_data/serviceAccountKey.json`을 준비한 뒤 샘플 데이터를 업로드합니다.

```bash
node sample_data/upload_data.js
```

5. Cloud Functions는 `functions-v2` 폴더에서 다음과 같이 실행하거나 배포합니다.

```bash
cd functions-v2
npm install
npm run serve      # 로컬 에뮬레이터
# 배포 시
npm run deploy
```

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

## 📌 Location Filter Usage (개발자 가이드)

이 프로젝트는 지역 기반 필터링을 위해 두 가지 레이어를 사용합니다:

- 서버/Firestore 단계: `locationParts`(prov, kab, kec, kel)로 범위를 좁히는 쿼리를 먼저 수행합니다. 예: `where('locationParts.prov', isEqualTo: 'Banten')`.
- 클라이언트 최종 필터링: 정확한 반경 필터링 및 정렬은 `geoPoint`를 이용해 클라이언트에서 `LocationHelper.getDistanceBetween(...)`으로 계산합니다. 이는 Firestore에서 지원하지 않는 반경 쿼리의 정확도를 보완합니다.

권장 패턴 (예):

```dart
// 1) LocationProvider에서 admin 필터를 얻음
final filter = locationProvider.adminFilter; // {prov, kab, kec, kel}

// 2) 초기 Firestore 쿼리 (범위 좁히기)
Query productsQuery = FirebaseFirestore.instance.collection('products');
if (filter['prov'] != null) productsQuery = productsQuery.where('locationParts.prov', isEqualTo: filter['prov']);
if (filter['kab'] != null) productsQuery = productsQuery.where('locationParts.kab', isEqualTo: filter['kab']);

// 3) fetch and client-side radius filter/sort
final snapshot = await productsQuery.get();
final items = snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
final center = userModel.geoPoint; // 사용자의 GeoPoint
final nearby = items
  .map((p) => MapEntry(p, LocationHelper.getDistanceBetween(center.latitude, center.longitude, p.geoPoint.latitude, p.geoPoint.longitude)))
  .where((e) => e.value <= selectedRadiusKm)
  .toList()
  ..sort((a, b) => a.value.compareTo(b.value));

// 이후 nearby.map((e) => e.key) 로 표시
```

메모:
- `LocationHelper.cleanName(...)`로 행정구역명을 정규화하면 인덱스와 필터 일관성이 높아집니다.
- 서버-side `orderBy`와 `where` 조합은 Firestore composite index를 요구할 수 있으므로 콘솔 안내에 따라 인덱스를 추가하세요.

## 🔎 Search Bar & `inline_search_chip()` 사용 가이드

여러 피드/검색 화면에서 일관된 검색 UX를 위해 `inline_search_chip()`과 간단한 검색바 로직을 사용합니다. 주요 패턴은 다음과 같습니다:

- `TextEditingController`로 검색어를 관리합니다.
- `ValueNotifier<bool>` 또는 `State`로 검색바의 활성(보이기/숨기기) 상태를 토글합니다.
- `inline_search_chip()`은 현재 활성 필터(태그/카테고리)를 인라인으로 보여주고, 탭하면 해당 필터를 적용하거나 제거할 수 있습니다.

간단한 예제 (피드 화면 내):

```dart
class ExampleFeedHeader extends StatefulWidget {
  final ValueNotifier<bool> searchNotifier = ValueNotifier(false);
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar 내 검색 토글 버튼
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => searchNotifier.value = !searchNotifier.value,
            ),
            // inline chips
            inline_search_chip(context, tags: activeTags, onRemove: (t) => removeTag(t)),
          ],
        ),

        // 검색바: 노티파이어에 따라 표시/숨김
        ValueListenableBuilder<bool>(
          valueListenable: searchNotifier,
          builder: (_, visible, __) {
            return visible
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(hintText: 'search.placeholder'.tr()),
                      onSubmitted: (q) => applySearch(q),
                    ),
                  )
                : SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
```

팁:
- `inline_search_chip()`은 active filter 배열을 받아 렌더링하고 삭제 콜백을 제공합니다. 피드 목록의 쿼리 함수는 이 태그 목록을 파라미터로 받아 Firestore 쿼리를 구성하세요.
- 검색 입력은 debounce(예: 300ms)하여 불필요한 쿼리를 줄이십시오.

---



// lib/features/main_screen/home_screen.dart
/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: 메인 화면의 AppBar, 슬라이드 탭, Drawer, BottomNavigationBar, 주요 컴포넌트(FeedCard, Comment Bubble, Chat Bubble, FAB 등) 구조와 반응형/애니메이션/접근성 정책
/// - 실제 코드 기능: 다양한 피드/카드/모듈 위젯을 통합하여 메인 홈 화면을 구성, 각 기능별 화면 import, 반응형 UI 및 다양한 카드/버블/버튼 구현
/// - 비교: 기획의 주요 컴포넌트와 구조가 실제 코드에서 위젯/화면으로 세분화되어 구현됨. 접근성/애니메이션 등은 일부 위젯에서 적용됨
///
/// [상세 분석 및 코멘트]
/// 1. AppBar에 전달되는 주요 파라미터
///   - userModel: 사용자 맞춤 정보(프로필, 신뢰등급 등) 제공, 지역 기반 서비스와 연동
///   - activeLocationFilter: Kab/Kec/Kel 등 다양한 지역 단위로 필터링, "My Town" 드롭다운에 직접 반영
///   - onIconTap: 기능별 아이콘 클릭 시 화면 전환, 네비게이션 UX와 연결
///   → AppBar는 개인화·지역화·서비스 접근성의 핵심 진입점
///
/// 2. My Town의 다변화
///   - 단순 텍스트가 아닌 드롭다운으로 Kab/Kec/Kel 등 다양한 지역 단위 선택 가능
///   - 사용자의 활동 범위 세밀 조정, 모든 기능(피드/마켓/친구찾기 등)과 연동
///   - 다국어 지원과 결합되어 현지화 및 글로벌 확장성 강화
///
/// 3. locationParts의 Kab 필터 최초 적용 이유
///   - Kab(카부파텐)은 인도네시아 지역 서비스의 핵심 단위, 생활권 정보 탐색에 최적
///   - DB 구조와 연동되어 데이터 일관성·검색 효율성 향상
///   - 향후 광고·프로모션·추천 등 수익화 전략에 직접 활용 가능
///
/// [제안 및 결론]
/// - AppBar 파라미터 설계는 지역 기반 슈퍼앱의 UX/데이터 구조와 직결, 개인화·지역화·수익화 모두 강화
/// - Kab 필터 도입은 사용자 경험과 비즈니스 전략 모두에서 매우 중요한 결정
/// - 향후 개선: 지역 단위별 추천·광고·커뮤니티 연계, UI/UX(지도 시각화, 애니메이션 등) 강화, 데이터 기반 KPI/Analytics 연동
/// - Todo: 통합 피드 스크롤 다운 후 즉시 화면 맨 위로 이동 기능 필요
/// 2025-10-31 (작업 19, 20, 27):
///   - [Phase 5] '하이퍼로컬 슈퍼 앱' 전략에 맞춰 아이콘 그리드(`menuItems`) 순서 재배치 (1.소식, 2.일자리, 3.분실물...).
///   - [Phase 6] 통합 검색 UI 리팩토링:
///     - `BlingSearchDelegate` 및 `showSearch` 관련 코드 모두 제거.
///     - 검색칩(`_searchChip`)이 `main_navigation_screen`의 `onSearchChipTap` 콜백을 직접 호출하도록 단순화.
/// ============================================================================
library;

/**
 * [2025-11-06] 작업 내역 및 변경 설명
 *
 * 1. 홈 그리드 UI 2차 개편 적용
 *    - 기존 GrabIconTile 기반에서 InkWell + Container + SvgPicture/아이콘 조합으로 변경
 *    - 아이콘 박스에 흰색 배경, 그림자, 둥근 모서리 적용
 *    - SVG 아이콘 지원을 위해 flutter_svg 패키지 import 및 사용
 *    - 기존 onTap 라우팅 로직은 그대로 유지
 *    - GrabIconTile 관련 import 제거
 *
 * 2. 코드 스타일 및 경고 대응
 *    - withOpacity 사용 부분을 withValues(alpha: )로 변경 필요 (Flutter 3.22+)
 *      → 현재 일부 위치에서 withOpacity가 남아있으므로, 반드시 withValues(alpha: )로 교체해야 함
 *      → 예시: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
 *    - 관련 경고: 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss
 *
 * 3. 기타
 *    - flutter_svg 패키지는 pubspec.yaml에 이미 선언되어 있음
 *    - 불필요한 import 및 주석 정리
 *
 * [변경자] GitHub Copilot
 */
// (파일 내용...)

// import removed: GrabIconTile no longer used in v2 grid UI

import 'package:bling_app/core/models/feed_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/main_feed/data/feed_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';

// 모든 card 위젯과 그에 필요한 model들을 import 합니다.

// ▼▼▼▼▼ [개편] 신규 썸네일 및 상세 화면 import ▼▼▼▼▼
// ▼▼▼▼▼ [개편] 1 단계: Product 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/main_feed/widgets/post_thumb.dart';

// ▼▼▼▼▼ [개편] 2 단계: Product 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/main_feed/widgets/product_thumb.dart';
// ▼▼▼▼▼ [개편] 3단계: Club Post 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/main_feed/widgets/club_thumb.dart';
// ▼▼▼▼▼ [개편] 4단계: Find Friend 썸네일 및 모델 import ▼▼▼▼▼
// UserModel은 이미 core/models에서 import 되어 있음
import 'package:bling_app/features/main_feed/widgets/find_friend_thumb.dart';
// ▼▼▼▼▼ [개편] 5단계: Job 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/features/main_feed/widgets/job_thumb.dart';
// ▼▼▼▼▼ [개편] 6단계: Local Store 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/main_feed/widgets/local_store_thumb.dart';
// ▼▼▼▼▼ [개편] 7단계: Auction 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/main_feed/widgets/auction_thumb.dart';

// ▼▼▼▼▼ [개편] 8단계: POM 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/features/main_feed/widgets/pom_thumb.dart';
// ▼▼▼▼▼ [개편] 9단계: Lost & Found 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/main_feed/widgets/lost_item_thumb.dart';
// ▼▼▼▼▼ [개편] 10단계: Real Estate 썸네일 및 모델 import ▼▼▼▼▼
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/main_feed/widgets/real_estate_thumb.dart';

import 'package:provider/provider.dart'; // PomThumb에서 UserModel 접근 위해

// 아이콘 그리드에서 사용할 각 기능별 화면을 import 합니다.
import 'package:bling_app/features/local_news/screens/local_news_screen.dart';
import 'package:bling_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:bling_app/features/clubs/screens/clubs_screen.dart';
import 'package:bling_app/features/find_friends/screens/find_friends_screen.dart';
import 'package:bling_app/features/jobs/screens/jobs_screen.dart';
import 'package:bling_app/features/local_stores/screens/local_stores_screen.dart';
import 'package:bling_app/features/auction/screens/auction_screen.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:bling_app/features/lost_and_found/screens/lost_and_found_screen.dart';
import 'package:bling_app/features/real_estate/screens/real_estate_screen.dart';

import 'package:flutter_svg/flutter_svg.dart'; // 2차 버전 UI(SVG) 렌더링을 위해 추가
// ✅ [검색] 검색 네비게이션은 상위(main_navigation_screen)가 전담

class MenuItem {
  final IconData? icon; // 기존 IconData 지원
  final String? svg; // 신규: SVG 에셋 경로
  final String labelKey;
  final Widget screen;
  MenuItem({this.icon, this.svg, required this.labelKey, required this.screen})
      : assert(
            icon != null || svg != null, 'Either icon or svg must be provided');
}

class HomeScreen extends StatelessWidget {
  // 섹션 헤더 타이틀 + NEW 배지 공통 위젯
  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    final theme = Theme.of(context);
    final onSurface90 = theme.colorScheme.onSurface.withValues(alpha: 0.90);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            titleKey.tr(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: onSurface90,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: 'common.new'.tr(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'common.new'.tr(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // (2) 검색 칩 위젯 헬퍼 - 디자인/텍스트 최신화

  // 접근성 대응: textScalerOf 기반 스케일 추출 유틸
  double effectiveTextScale(BuildContext context, {double basis = 16}) {
    final s = MediaQuery.textScalerOf(context);
    return s.scale(basis) / basis;
  }

  // 공통 View all 버튼 스타일
  ButtonStyle _viewAllButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: theme.colorScheme.primary,
      textStyle: theme.textTheme.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  final UserModel? userModel;
  final Map<String, String?>? activeLocationFilter;
  final Function(Widget, String) onIconTap;

  // ✅ [신규] 시나리오 2 (피드 내 검색 활성화)를 위한 Notifier
  final ValueNotifier<AppSection?>? searchNotifier;
  // ✅ [스크롤 위치 보존] ScrollController 파라미터 추가
  final ScrollController controller;

  final List<FeedItemModel> allFeedItems;
  final int currentIndex;

  const HomeScreen({
    required this.controller, // ✅ 생성자에 추가
    super.key,
    required this.userModel,
    required this.activeLocationFilter,
    required this.onIconTap,
    this.searchNotifier, // ✅ 생성자에 Notifier 추가
    this.allFeedItems = const [],
    this.currentIndex = 0,
  });

  // SVG 아이콘 경로 기본 폴더
  static const String _iconsPath = 'assets/icons';

  static final List<MenuItem> menuItems = [
    // 1. localNews (동네소식)
    MenuItem(
        svg: '$_iconsPath/ico_news.svg',
        labelKey: 'main.tabs.localNews',
        screen: const LocalNewsScreen()),
    // 2. jobs (구인구직)
    MenuItem(
        svg: '$_iconsPath/ico_job.svg',
        labelKey: 'main.tabs.jobs',
        screen: const JobsScreen()),
    // 3. lostAndFound (분실물찾기)
    MenuItem(
        svg: '$_iconsPath/ico_lost_item.svg',
        labelKey: 'main.tabs.lostAndFound',
        screen: const LostAndFoundScreen()),
    // 4. marketplace (중고거래)
    MenuItem(
        svg: '$_iconsPath/ico_secondhand.svg',
        labelKey: 'main.tabs.marketplace',
        screen: const MarketplaceScreen()),
    // 5. localStores (동네업체)
    MenuItem(
        svg: '$_iconsPath/ico_store.svg',
        labelKey: 'main.tabs.localStores',
        screen: const LocalStoresScreen()),
    // 6. clubs (모임)
    MenuItem(
        svg: '$_iconsPath/ico_community.svg',
        labelKey: 'main.tabs.clubs',
        // Placeholder only for routing metadata; real screen is built in onTap
        screen: const Placeholder()),
    // 7. findFriends (친구찾기)
    MenuItem(
        svg: '$_iconsPath/ico_friend_3d_deep.svg',
        labelKey: 'main.tabs.findFriends',
        screen: const FindFriendsScreen()),
    // 8. realEstate (부동산)
    MenuItem(
        svg: '$_iconsPath/ico_real_estate.svg',
        labelKey: 'main.tabs.realEstate',
        screen: const RealEstateScreen()),
    // 9. auction (경매)
    MenuItem(
        svg: '$_iconsPath/ico_auction.svg',
        labelKey: 'main.tabs.auction',
        screen: const AuctionScreen()),
    // 10. pom (숏폼)
    MenuItem(
        svg: '$_iconsPath/ico_pom.svg',
        labelKey: 'main.tabs.pom',
        screen: const PomScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    // ===== 반응형 그리드/타일 사이즈 계산 (textScalerOf 사용) =====
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final double tsFactor = effectiveTextScale(context); // ≈ textScaleFactor
    final String lang = context.locale.languageCode; // 'id' | 'ko' | 'en'
    final bool longLabelLang = (lang == 'id');

    // 5열 사용 조건: 화면폭 충분 + 텍스트가 너무 크지 않음(언어별 임계값)
    final bool force4 = width < 360 || tsFactor > (longLabelLang ? 1.10 : 1.15);
    final int gridCount = force4 ? 4 : 5;

    // SliverPadding/간격 기준으로 셀 폭 계산
    const double outerPad = 16; // 좌우 패딩
    const double crossGap = 8; // 열 간격
    final double tileWidth =
        (width - (outerPad * 2) - (crossGap * (gridCount - 1))) / gridCount;

    // 타일 높이: 5열일 때 낮게, 긴 라벨/큰 글자면 여유 +2dp
    double tileHeight = gridCount == 5 ? 98 : 104;
    if (longLabelLang) tileHeight += 2;
    if (tsFactor > 1.15) tileHeight += 2;

    final double childAspectRatio = tileWidth / tileHeight;

    return CustomScrollView(
      controller: controller,
      slivers: [
        // ❌ [작업 47] _searchChip 호출 제거 (컴파일 에러 원인)

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          sliver: SliverGrid.count(
            crossAxisCount: gridCount,
            crossAxisSpacing: crossGap,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
            children: menuItems.map((item) {
              // 홈그리드 1차 버전 코드 니펫
              /*
              return GrabIconTile(
                  compact: gridCount == 5,
                  icon: item.icon,
                  svgAsset: item.svg,
                  label: item.labelKey.tr(),
                  onTap: () {
                    // ⬇️ 기존 onTap 로직 그대로 (절대 수정 X)
                    if (userModel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('user.notLoggedIn'.tr())),
                      );
                      return;
                    }
                    final screen = item.screen;
                    late Widget nextScreen;
                    if (screen is LocalNewsScreen) {
                      nextScreen = LocalNewsScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier,
                      );
                    } else if (screen is MarketplaceScreen) {
                      // Marketplace now supports inline search chip
                      nextScreen = MarketplaceScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (item.labelKey == 'main.tabs.clubs') {
                      // Clubs: uses an external TabController via a local DefaultTabController wrapper
                      nextScreen = DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (ctx) => ClubsScreen(
                            userModel: userModel,
                            locationFilter: activeLocationFilter,
                            autoFocusSearch: false,
                            searchNotifier: searchNotifier,
                            tabController: DefaultTabController.of(ctx),
                          ),
                        ),
                      );
                    } else if (screen is FindFriendsScreen) {
                      // FindFriends now supports inline search chip
                      nextScreen = FindFriendsScreen(
                          userModel: userModel,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is JobsScreen) {
                      // Jobs now supports inline search chip
                      nextScreen = JobsScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is LocalStoresScreen) {
                      // Local Stores now supports inline search chip
                      nextScreen = LocalStoresScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is AuctionScreen) {
                      // Auction now supports inline search chip
                      nextScreen = AuctionScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is PomScreen) {
                      // POM now supports inline search chip
                      nextScreen = PomScreen(
                          userModel: userModel,
                          initialPoms: null,
                          initialIndex: 0,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is LostAndFoundScreen) {
                      // Lost & Found now supports inline search chip
                      nextScreen = LostAndFoundScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else if (screen is RealEstateScreen) {
                      // RealEstate now supports inline search chip
                      nextScreen = RealEstateScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier);
                    } else {
                      nextScreen = screen;
                    }
                    onIconTap(nextScreen, item.labelKey);
                  },
                );
              */

              // 홈그리드 2차 버전 코드 니펫 시작

              // [작업] 변수 선언(final textStyle, minTextHeight)을 InkWell builder 함수 시작 부분으로 이동
              final textStyle = (gridCount == 5
                      ? Theme.of(context).textTheme.labelSmall
                      : Theme.of(context).textTheme.bodySmall)
                  ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                height: 1.1, // 줄간격
              );

              final minTextHeight = (textStyle?.fontSize ?? 12.0) *
                  (textStyle?.height ?? 1.1) *
                  2;

              // 1. 탭 로직 (기존 onIconTap 로직을 InkWell의 onTap으로 이동)
              return InkWell(
                onTap: () {
                  // ⬇️ 기존 onTap 로직 그대로 (절대 수정 X)
                  if (userModel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('user.notLoggedIn'.tr())),
                    );
                    return;
                  }
                  final screen = item.screen;
                  late Widget nextScreen;
                  if (screen is LocalNewsScreen) {
                    nextScreen = LocalNewsScreen(
                      userModel: userModel,
                      locationFilter: activeLocationFilter,
                      autoFocusSearch: false,
                      searchNotifier: searchNotifier,
                    );
                  } else if (screen is MarketplaceScreen) {
                    // Marketplace now supports inline search chip
                    nextScreen = MarketplaceScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (item.labelKey == 'main.tabs.clubs') {
                    // Clubs: uses an external TabController via a local DefaultTabController wrapper
                    nextScreen = DefaultTabController(
                      length: 2,
                      child: Builder(
                        builder: (ctx) => ClubsScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: searchNotifier,
                          tabController: DefaultTabController.of(ctx),
                        ),
                      ),
                    );
                  } else if (screen is FindFriendsScreen) {
                    // FindFriends now supports inline search chip
                    nextScreen = FindFriendsScreen(
                        userModel: userModel,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is JobsScreen) {
                    // Jobs now supports inline search chip
                    nextScreen = JobsScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is LocalStoresScreen) {
                    // Local Stores now supports inline search chip
                    nextScreen = LocalStoresScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is AuctionScreen) {
                    // Auction now supports inline search chip
                    nextScreen = AuctionScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is PomScreen) {
                    // POM now supports inline search chip
                    nextScreen = PomScreen(
                        userModel: userModel,
                        initialPoms: null,
                        initialIndex: 0,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is LostAndFoundScreen) {
                    // Lost & Found now supports inline search chip
                    nextScreen = LostAndFoundScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else if (screen is RealEstateScreen) {
                    // RealEstate now supports inline search chip
                    nextScreen = RealEstateScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: searchNotifier);
                  } else {
                    nextScreen = screen;
                  }
                  onIconTap(nextScreen, item.labelKey);
                },
                borderRadius:
                    BorderRadius.circular(12.0), // 탭 효과를 위한 둥근 모서리 (조정값)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2-1. 아이콘을 감싸는 흰색/그림자 박스
                    Container(
                      width: tileWidth * 0.999, // 타일 폭의 62% (조정값)
                      height: tileWidth * 0.999, // 정사각형 (조정값)
                      decoration: BoxDecoration(
                        color: Colors.white, // 2. 아이콘 박스 배경색 흰색
                        borderRadius: BorderRadius.circular(
                            16.0), // 3. 띄어진 느낌을 위한 둥근 모서리 (조정값)
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: 0.08), // 3. 띄어진 느낌을 위한 그림자 (연하게)
                            blurRadius: 10.0, // 3. 그림자 부드럽게 (조정값)
                            offset: Offset(0, 4), // 3. 그림자 위치 (아래쪽)
                          ),
                        ],
                      ),
                      // 아이콘과 박스 테두리 사이 여백 (조정값)
                      // GrabIconTile의 compact 모드(5열) 여부에 따라 패딩 조정
                      padding: EdgeInsets.all(gridCount == 5 ? 10.0 : 12.0),
                      child: item.svg != null
                          ? SvgPicture.asset(
                              // SVG 렌더링
                              item.svg!,
                              width: double.infinity,
                              height: double.infinity,
                              // 1. 그림자 삭제 (SvgPicture는 기본적으로 그림자 없음)
                            )
                          : Icon(
                              // IconData 폴백
                              item.icon,
                              size: 28.0, // (조정값)
                              color: Theme.of(context).primaryColor, // (임의의 색상)
                            ),
                    ),
                    SizedBox(
                        height: gridCount == 5
                            ? 4.0 // 5열 (조정값 6.0 -> 4.0)
                            : 6.0), // 4열 (조정값 8.0 -> 6.0) // 1.4px 오버플로우 수정
                    Container(
                      height: minTextHeight, // 텍스트 2줄 높이로 고정
                      alignment: Alignment
                          .topCenter, // 1줄 텍스트가 (2줄 높이 박스) 상단 중앙에 정렬되도록
                      child: Text(
                        item.labelKey.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 2, // 2줄까지 허용
                        overflow: TextOverflow.ellipsis,
                        style: textStyle, // 미리 정의한 스타일 적용
                      ),
                    ),
                  ],
                ),
              );
              // 홈그리드 2차 버전 코드 니펫 끝
            }).toList(),
          ),
        ),
        const SliverToBoxAdapter(
            child: Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5))),

        // ▼▼▼▼▼ [개편] 1단계: 기존 통합 피드를 삭제하고, Post 캐러셀 섹션으로 교체 ▼▼▼▼▼
        _buildPostCarousel(context),

        // ▼▼▼▼▼ [개편] 5단계: Job 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildJobCarousel(context),

        // ▼▼▼▼▼ [개편] 9단계: Lost & Found 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildLostAndFoundCarousel(context),

        // ▼▼▼▼▼ [개편] 2단계: Product 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildProductCarousel(context),

        // ▼▼▼▼▼ [개편] 6단계: Local Store 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildLocalStoreCarousel(context),

        // ▼▼▼▼▼ [개편] 3단계: Club 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildClubCarousel(context),

        // ▼▼▼▼▼ [개편] 4단계: Find Friend 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildFindFriendCarousel(context),

        // ▼▼▼▼▼ [개편] 7단계: Auction 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildAuctionCarousel(context),

        // ▼▼▼▼▼ [개편] 10단계: Real Estate 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildRealEstateCarousel(context),

        // ▼▼▼▼▼ [개편] 8단계: POM 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildPomCarousel(context),
      ],
    );
  }

  /// [개편] 1단계: 로컬뉴스(Post) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildPostCarousel(BuildContext context) {
    // FeedRepository 인스턴스화 (HomeScreen이 StatelessWidget이므로)
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Post 최신 20개를 가져옵니다. (MD 요구사항 "최신 20개")
      future: feedRepository.fetchLatestPosts(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션 (높이만 차지)
          // (MD 요구사항 "스켈레톤/플레이스홀더로 깨짐 인상 방지")
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final posts = snapshot.data!
            .map((item) => PostModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더 (MD: "모두 보기" 버튼은 선택사항)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child:
                            _buildSectionTitle(context, 'main.tabs.localNews')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = LocalNewsScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.localNews');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀 (MD: 2. 표준 썸네일 고정 크기 (220x240)
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16), // MD: 섹션 좌우 패딩 16
                  primary: false, // MD: 중첩 스크롤
                  shrinkWrap: true, // MD: 중첩 스크롤
                  clipBehavior: Clip.none, // MD: 오버플로우 방지
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == posts.length - 1)
                              ? 0
                              : 12), // MD: 카드 간격 12
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: PostThumb(
                        post: posts[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 2단계: 마켓플레이스(Product) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildProductCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Product 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestProducts(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final products = snapshot.data!
            .map((item) => ProductModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(
                            context, 'main.tabs.marketplace')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = MarketplaceScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.marketplace');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == products.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: ProductThumb(
                        product: products[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 3단계: 클럽(Club Post) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildClubCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Club Post 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestClubPosts(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final clubPosts = snapshot.data!
            .map((item) => ClubPostModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(context, 'main.tabs.clubs')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = DefaultTabController(
                          length: 2,
                          child: Builder(
                            builder: (ctx) => ClubsScreen(
                              userModel: userModel,
                              locationFilter: activeLocationFilter,
                              tabController: DefaultTabController.of(ctx),
                            ),
                          ),
                        );
                        onIconTap(nextScreen, 'main.tabs.clubs');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: clubPosts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == clubPosts.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: ClubThumb(
                        post: clubPosts[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 4단계: 친구찾기(Find Friend) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildFindFriendCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 최신 사용자 20명을 가져옵니다.
      future: feedRepository.fetchLatestFindFriends(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final users = snapshot.data!
            .map((item) => UserModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(
                            context, 'main.tabs.findFriends')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = FindFriendsScreen(
                          userModel: userModel,
                        );
                        onIconTap(nextScreen, 'main.tabs.findFriends');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    // FindFriendThumb에 현재 사용자 정보(userModel) 전달
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == users.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: FindFriendThumb(
                        user: users[index],
                        currentUserModel: userModel,
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 5단계: 구인/구직(Job) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildJobCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Job 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestJobs(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final jobs = snapshot.data!
            .map((item) => JobModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(context, 'main.tabs.jobs')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = JobsScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.jobs');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == jobs.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: JobThumb(
                        job: jobs[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 6단계: 동네 업체(Local Store) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildLocalStoreCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Shop 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestShops(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final shops = snapshot.data!
            .map((item) => ShopModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(
                            context, 'main.tabs.localStores')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = LocalStoresScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.localStores');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == shops.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: LocalStoreThumb(
                        shop: shops[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 7단계: 경매(Auction) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildAuctionCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Auction 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestAuctions(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final auctions = snapshot.data!
            .map((item) => AuctionModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child:
                            _buildSectionTitle(context, 'main.tabs.auction')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = AuctionScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.auction');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: auctions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == auctions.length - 1) ? 0 : 12),
                      // ✅ [Final Fix] onIconTap 콜백 전달
                      child: AuctionThumb(
                        auction: auctions[index],
                        onIconTap: onIconTap,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 8단계: 숏폼(POM) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김, 4.재생 정책
  ///
  Widget _buildPomCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 POM 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestPoms(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290, // 썸네일 240 + 헤더/패딩 50
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. MD요구사항 "6. 빈 섹션 처리": 데이터가 없으면 섹션 자체를 숨김
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // 3. FeedItemModel 리스트를 PomModel 리스트로 변환 (전체 목록 전달용)
        final allShorts = snapshot.data!
            .map((item) => PomModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 4. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          // Provider를 통해 userModel을 PomThumb 위젯 트리에 제공
          child: Provider.value(
            value: userModel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4-1. 섹션 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: _buildSectionTitle(context, 'main.tabs.pom')),
                      TextButton(
                        style: _viewAllButtonStyle(context),
                        onPressed: () {
                          if (userModel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('main.errors.loginRequired'.tr())),
                            );
                            return;
                          }
                          final nextScreen = PomScreen(
                            userModel: userModel,
                            locationFilter: activeLocationFilter,
                            initialPoms: null,
                            initialIndex: 0,
                          );
                          onIconTap(nextScreen, 'main.tabs.pom');
                        },
                        child: Text('common.viewAll'.tr()),
                      ),
                    ],
                  ),
                ),
                // 4-2. 가로 캐러셀
                SizedBox(
                  height: 240, // MD: 표준 썸네일 고정 크기 (220x240)
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    primary: false,
                    shrinkWrap: true,
                    clipBehavior: Clip.none,
                    itemCount: allShorts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            right: (index == allShorts.length - 1) ? 0 : 12),
                        // PomThumb에 전체 목록과 현재 인덱스 전달
                        child: PomThumb(
                          short: allShorts[index],
                          allShorts: allShorts,
                          currentIndex: index,
                          onIconTap: onIconTap,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// [개편] 9단계: 분실/습득(Lost & Found) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildLostAndFoundCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 LostItem 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestLostItems(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. 빈 섹션 처리
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final lostItems = snapshot.data!
            .map((item) => LostItemModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(
                            context, 'main.tabs.lostAndFound')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = LostAndFoundScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.lostAndFound');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: lostItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == lostItems.length - 1) ? 0 : 12),
                      child: LostItemThumb(
                          item: lostItems[index], onIconTap: onIconTap),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [개편] 10단계: 부동산(Real Estate) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김
  ///
  Widget _buildRealEstateCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 RoomListing 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestRoomListings(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중: 스켈레톤 섹션
          return SliverToBoxAdapter(
            child: Container(
              height: 290,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // 2. 빈 섹션 처리
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final rooms = snapshot.data!
            .map((item) => RoomListingModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // 3. 데이터가 있을 경우: 섹션 헤더 + 가로 캐러셀
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3-1. 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildSectionTitle(
                            context, 'main.tabs.realEstate')),
                    TextButton(
                      style: _viewAllButtonStyle(context),
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = RealEstateScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
                        );
                        onIconTap(nextScreen, 'main.tabs.realEstate');
                      },
                      child: Text('common.viewAll'.tr()),
                    )
                  ],
                ),
              ),
              // 3-2. 가로 캐러셀
              SizedBox(
                height: 240, // 표준 썸네일 고정 크기 (220x240)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index == rooms.length - 1) ? 0 : 12),
                      child: RealEstateThumb(
                          room: rooms[index], onIconTap: onIconTap),
                    );
                  },
                ),
              ),
              // ✅ 캐러셀과 FAB 간섭 방지용 여백 추가 (MD 요구사항)
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
  // ▲▲▲▲▲ [개편] 1, 2단계 완료 ▲▲▲▲▲
}

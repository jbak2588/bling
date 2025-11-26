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
 *
 * 3. 기타
 *    - flutter_svg 패키지는 pubspec.yaml에 이미 선언되어 있음
 *    - 불필요한 import 및 주석 정리
 *
 * [변경자] GitHub Copilot
 */
// [작업 이력: 0-3]
// - (Job 0) 'GrabIconTile' UI 수정: 그림자 제거, 흰색 배경 및 BoxShadow 적용.
// - (Job 1) Column 오버플로우(1.4px) 해결을 위해 SizedBox 높이 조정.
// - (Job 2) 2줄 라벨로 인한 아이콘 상단 밀림 현상 해결 (Container 높이 고정).
// - (Job 3) 'children' 내 'final' 변수 선언으로 인한 컴파일 에러 수정 (변수 선언 위치 이동).
// (파일 내용...)

// import removed: GrabIconTile no longer used in v2 grid UI

import 'package:bling_app/core/models/feed_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/main_feed/data/feed_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:bling_app/features/main_screen/main_navigation_screen.dart'; // no longer used here

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
import 'dart:math' as math;
import 'package:visibility_detector/visibility_detector.dart'; // ✅ Lazy Loading

// Sections enum used by SectionLoader
enum AppSection {
  posts,
  product,
  job,
  lostAndFound,
  localStore,
  club,
  findFriend,
  auction,
  realEstate,
  pom,
}

// Global per-section Future cache to persist across rebuilds/navigation
final Map<AppSection, Future<List<FeedItemModel>>?> _sectionFutureCache = {};

/// Lightweight section loader that triggers a preload when the detector
/// becomes visible and then renders the provided builder with the
/// optional preload Future.
class SectionLoader extends StatefulWidget {
  final AppSection section;
  final Future<List<FeedItemModel>>? Function()? preloadFactory;
  final Widget Function(Future<List<FeedItemModel>>? preload) builder;

  const SectionLoader({
    super.key,
    required this.section,
    required this.builder,
    this.preloadFactory,
  });

  @override
  State<SectionLoader> createState() => _SectionLoaderState();
}

class _SectionLoaderState extends State<SectionLoader> {
  Future<List<FeedItemModel>>? _future;
  bool _triggered = false;

  void _onVisible() {
    if (_triggered) return;
    _triggered = true;
    setState(() {
      // Consult global cache first so the same Future is reused across
      // widget unmounts/rebuilds (prevents re-fetch when returning to screen).
      final cached = _sectionFutureCache[widget.section];
      if (cached != null) {
        _future = cached;
      } else {
        _future = widget.preloadFactory?.call();
        _sectionFutureCache[widget.section] = _future;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_triggered) {
      return widget.builder(_future);
    }

    return SliverToBoxAdapter(
      child: VisibilityDetector(
        key: Key('visibility-${widget.section}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.01) _onVisible();
        },
        child: const SizedBox(height: 1),
      ),
    );
  }
}

class MenuItem {
  final IconData? icon; // 기존 IconData 지원
  final String? svg; // 신규: SVG 에셋 경로
  final String labelKey;
  final Widget screen;
  final AppSection? section; // ✅ Lazy Loading용 섹션 키 추가
  MenuItem(
      {this.icon,
      this.svg,
      required this.labelKey,
      required this.screen,
      this.section})
      : assert(
            icon != null || svg != null, 'Either icon or svg must be provided');
}

class HomeScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? activeLocationFilter;
  final Function(Widget, String) onIconTap;
  // ✅ [신규] 시나리오 2 (피드 내 검색 활성화)를 위한 Notifier
  final ValueNotifier<bool>? searchNotifier;
  // ✅ [스크롤 위치 보존] ScrollController 파라미터 추가
  final ScrollController controller;

  const HomeScreen({
    required this.controller,
    super.key,
    required this.userModel,
    required this.activeLocationFilter,
    required this.onIconTap,
    this.searchNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final FeedRepository _feedRepository = FeedRepository();

  // ✅ Lazy Loading Futures (null = Not Loaded)
  Future<List<FeedItemModel>>? _localNewsFuture;
  Future<List<FeedItemModel>>? _jobsFuture;
  Future<List<FeedItemModel>>? _lostItemsFuture;
  Future<List<FeedItemModel>>? _productsFuture;
  Future<List<FeedItemModel>>? _shopsFuture;
  Future<List<FeedItemModel>>? _clubPostsFuture;
  Future<List<FeedItemModel>>? _usersFuture;
  Future<List<FeedItemModel>>? _auctionsFuture;
  Future<List<FeedItemModel>>? _realEstateFuture;
  Future<List<FeedItemModel>>? _pomsFuture;

  // 5개 + 더보기 카드
  static const int _previewLimit = 5;

  @override
  bool get wantKeepAlive => true; // 상태 유지

  @override
  void initState() {
    super.initState();
    // 초기 실행 시 상단 2개만 로딩
    _localNewsFuture = _feedRepository.fetchLatestPosts(limit: _previewLimit);
    _jobsFuture = _feedRepository.fetchLatestJobs(limit: _previewLimit);
  }

  // 섹션 데이터 로드 트리거
  void _loadSectionData(AppSection section) {
    if (_isSectionLoadingOrLoaded(section)) return;
    setState(() {
      switch (section) {
        case AppSection.posts:
          _localNewsFuture =
              _feedRepository.fetchLatestPosts(limit: _previewLimit);
          break;
        case AppSection.job:
          _jobsFuture = _feedRepositorySafeFetch(
              _feedRepository.fetchLatestJobs(limit: _previewLimit));
          break;
        case AppSection.lostAndFound:
          _lostItemsFuture =
              _feedRepository.fetchLatestLostItems(limit: _previewLimit);
          break;
        case AppSection.product:
          _productsFuture =
              _feedRepository.fetchLatestProducts(limit: _previewLimit);
          break;
        case AppSection.localStore:
          _shopsFuture = _feedRepository.fetchLatestShops(limit: _previewLimit);
          break;
        case AppSection.findFriend:
          _usersFuture =
              _feedRepository.fetchLatestFindFriends(limit: _previewLimit);
          break;
        case AppSection.club:
          _clubPostsFuture = _feedRepositorySafeFetch(
              _feedRepository.fetchLatestClubPosts(limit: _previewLimit));
          break;
        case AppSection.realEstate:
          _realEstateFuture =
              _feedRepository.fetchLatestRoomListings(limit: _previewLimit);
          break;
        case AppSection.auction:
          _auctionsFuture =
              _feedRepository.fetchLatestAuctions(limit: _previewLimit);
          break;
        case AppSection.pom:
          _pomsFuture = _feedRepository.fetchLatestPoms(limit: _previewLimit);
          break;
      }
    });
  }

  // 작은 helper to avoid analyzer warning when using different repository calls inline
  Future<List<FeedItemModel>>? _feedRepositorySafeFetch(
          Future<List<FeedItemModel>>? f) =>
      f;

  bool _isSectionLoadingOrLoaded(AppSection section) {
    switch (section) {
      case AppSection.posts:
        return _localNewsFuture != null;
      case AppSection.product:
        return _productsFuture != null;
      case AppSection.job:
        return _jobsFuture != null;
      case AppSection.lostAndFound:
        return _lostItemsFuture != null;
      case AppSection.localStore:
        return _shopsFuture != null;
      case AppSection.findFriend:
        return _usersFuture != null;
      case AppSection.club:
        return _clubPostsFuture != null;
      case AppSection.realEstate:
        return _realEstateFuture != null;
      case AppSection.auction:
        return _auctionsFuture != null;
      case AppSection.pom:
        return _pomsFuture != null;
    }
  }

  // 전체 새로고침
  Future<void> _refreshAll() async {
    setState(() {
      _localNewsFuture = _feedRepository.fetchLatestPosts(limit: _previewLimit);
      _jobsFuture = _feedRepository.fetchLatestJobs(limit: _previewLimit);
      _lostItemsFuture = null;
      _productsFuture = null;
      _shopsFuture = null;
      _clubPostsFuture = null;
      _usersFuture = null;
      _auctionsFuture = null;
      _realEstateFuture = null;
      _pomsFuture = null;
    });
  }

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

  // SVG 아이콘 경로 기본 폴더
  static const String _iconsPath = 'assets/icons';

  static final List<MenuItem> menuItems = [
    // 1. localNews (동네소식)
    MenuItem(
        svg: '$_iconsPath/ico_news.svg',
        labelKey: 'main.tabs.localNews',
        screen: const LocalNewsScreen(),
        section: AppSection.posts),
    // 2. jobs (구인구직)
    MenuItem(
        svg: '$_iconsPath/ico_job.svg',
        labelKey: 'main.tabs.jobs',
        screen: const JobsScreen(),
        section: AppSection.job),
    // 3. lostAndFound (분실물찾기)
    MenuItem(
        svg: '$_iconsPath/ico_lost_item.svg',
        labelKey: 'main.tabs.lostAndFound',
        screen: const LostAndFoundScreen(),
        section: AppSection.lostAndFound),
    // 4. marketplace (중고거래)
    MenuItem(
        svg: '$_iconsPath/ico_secondhand.svg',
        labelKey: 'main.tabs.marketplace',
        screen: const MarketplaceScreen(),
        section: AppSection.product),
    // 5. localStores (동네업체)
    MenuItem(
        svg: '$_iconsPath/ico_store.svg',
        labelKey: 'main.tabs.localStores',
        screen: const LocalStoresScreen(),
        section: AppSection.localStore),
    // 6. clubs (모임)
    MenuItem(
        svg: '$_iconsPath/ico_community.svg',
        labelKey: 'main.tabs.clubs',
        // Placeholder only for routing metadata; real screen is built in onTap
        screen: const Placeholder(),
        section: AppSection.club),
    // 7. findFriends (친구찾기)
    MenuItem(
        svg: '$_iconsPath/ico_friend_3d_deep.svg',
        labelKey: 'main.tabs.findFriends',
        screen: const FindFriendsScreen(),
        section: AppSection.findFriend),
    // 8. realEstate (부동산)
    MenuItem(
        svg: '$_iconsPath/ico_real_estate.svg',
        labelKey: 'main.tabs.realEstate',
        screen: const RealEstateScreen(),
        section: AppSection.realEstate),
    // 9. auction (경매)
    MenuItem(
        svg: '$_iconsPath/ico_auction.svg',
        labelKey: 'main.tabs.auction',
        screen: const AuctionScreen(),
        section: AppSection.auction),
    // 10. pom (숏폼)
    MenuItem(
        svg: '$_iconsPath/ico_pom.svg',
        labelKey: 'main.tabs.pom',
        screen: const PomScreen(),
        section: AppSection.pom),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // KeepAlive

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

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: CustomScrollView(
        controller: widget.controller,
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
                // 홈그리드 2차 버전 코드 니펫 시작
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

                final iconBoxSize =
                    math.min(tileWidth * 0.999, tileHeight * 0.68);

                return InkWell(
                  onTap: () {
                    if (widget.userModel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('user.notLoggedIn'.tr())),
                      );
                      return;
                    }
                    final screen = item.screen;
                    late Widget nextScreen;
                    if (screen is LocalNewsScreen) {
                      nextScreen = LocalNewsScreen(
                        userModel: widget.userModel,
                        locationFilter: widget.activeLocationFilter,
                        autoFocusSearch: false,
                        searchNotifier: widget.searchNotifier,
                      );
                    } else if (screen is MarketplaceScreen) {
                      nextScreen = MarketplaceScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (item.labelKey == 'main.tabs.clubs') {
                      nextScreen = DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (ctx) => ClubsScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter,
                            autoFocusSearch: false,
                            searchNotifier: widget.searchNotifier,
                            tabController: DefaultTabController.of(ctx),
                          ),
                        ),
                      );
                    } else if (screen is FindFriendsScreen) {
                      nextScreen = FindFriendsScreen(
                          userModel: widget.userModel,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is JobsScreen) {
                      nextScreen = JobsScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is LocalStoresScreen) {
                      nextScreen = LocalStoresScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is AuctionScreen) {
                      nextScreen = AuctionScreen(
                          userModel: widget.userModel,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is PomScreen) {
                      nextScreen = PomScreen(
                          userModel: widget.userModel,
                          initialPoms: null,
                          initialIndex: 0,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is LostAndFoundScreen) {
                      nextScreen = LostAndFoundScreen(
                          userModel: widget.userModel,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else if (screen is RealEstateScreen) {
                      nextScreen = RealEstateScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter,
                          autoFocusSearch: false,
                          searchNotifier: widget.searchNotifier);
                    } else {
                      nextScreen = screen;
                    }
                    widget.onIconTap(nextScreen, item.labelKey);
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(gridCount == 5 ? 10.0 : 12.0),
                        child: item.svg != null
                            ? SvgPicture.asset(
                                item.svg!,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Icon(
                                item.icon,
                                size: 28.0,
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                      SizedBox(height: gridCount == 5 ? 4.0 : 6.0),
                      Container(
                        height: minTextHeight,
                        alignment: Alignment.topCenter,
                        child: Text(
                          item.labelKey.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SliverToBoxAdapter(
              child:
                  Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5))),

          // Lazy-loaded sections using new Lazy wrapper
          // Local News (posts)
          _buildLazySection(
            context: context,
            section: AppSection.posts,
            future: _localNewsFuture,
            childBuilder: (preload) => _buildPostCarousel(context, preload),
          ),

          // Jobs
          _buildLazySection(
            context: context,
            section: AppSection.job,
            future: _jobsFuture,
            childBuilder: (preload) => _buildJobCarousel(context, preload),
          ),

          // Lost & Found
          _buildLazySection(
            context: context,
            section: AppSection.lostAndFound,
            future: _lostItemsFuture,
            childBuilder: (preload) =>
                _buildLostAndFoundCarousel(context, preload),
          ),

          // Marketplace (product)
          _buildLazySection(
            context: context,
            section: AppSection.product,
            future: _productsFuture,
            childBuilder: (preload) => _buildProductCarousel(context, preload),
          ),

          // Local Stores
          _buildLazySection(
            context: context,
            section: AppSection.localStore,
            future: _shopsFuture,
            childBuilder: (preload) =>
                _buildLocalStoreCarousel(context, preload),
          ),

          // Clubs
          _buildLazySection(
            context: context,
            section: AppSection.club,
            future: _clubPostsFuture,
            childBuilder: (preload) => _buildClubCarousel(context, preload),
          ),

          // Find Friends
          _buildLazySection(
            context: context,
            section: AppSection.findFriend,
            future: _usersFuture,
            childBuilder: (preload) =>
                _buildFindFriendCarousel(context, preload),
          ),

          // Auction
          _buildLazySection(
            context: context,
            section: AppSection.auction,
            future: _auctionsFuture,
            childBuilder: (preload) => _buildAuctionCarousel(context, preload),
          ),

          // Real Estate
          _buildLazySection(
            context: context,
            section: AppSection.realEstate,
            future: _realEstateFuture,
            childBuilder: (preload) =>
                _buildRealEstateCarousel(context, preload),
          ),

          // POM
          _buildLazySection(
            context: context,
            section: AppSection.pom,
            future: _pomsFuture,
            childBuilder: (preload) => _buildPomCarousel(context, preload),
          ),
        ],
      ),
    );
  }

  // ✅ Lazy Section Wrapper
  Widget _buildLazySection({
    required BuildContext context,
    required AppSection section,
    required Future<List<FeedItemModel>>? future,
    required Widget Function(Future<List<FeedItemModel>>?) childBuilder,
  }) {
    return SliverToBoxAdapter(
      child: VisibilityDetector(
        key: Key('section_${section.toString()}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 &&
              !_isSectionLoadingOrLoaded(section)) {
            _loadSectionData(section);
          }
        },
        child: future == null
            ? _buildLoadingPlaceholder() // 로딩 전 플레이스홀더
            : childBuilder(future), // 로딩 시작 후 (Future 전달)
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 240,
      alignment: Alignment.center,
      child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildViewMoreCard(
      BuildContext context, Widget nextScreen, String labelKey) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => widget.onIconTap(nextScreen, labelKey),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 160,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.more_horiz,
                  size: 32,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(height: 8),
              Text('common.viewMore'.tr(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ [수정] Future를 파라미터로 받도록 변경
  Widget _buildPostCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future =
        preload ?? _feedRepository.fetchLatestPosts(limit: _previewLimit);

    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => PostModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = LocalNewsScreen(
                        userModel: widget.userModel,
                        locationFilter: widget.activeLocationFilter,
                      );
                      widget.onIconTap(nextScreen, 'main.tabs.localNews');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        LocalNewsScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter),
                        'main.tabs.localNews');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: PostThumb(
                      post: items[index],
                      onIconTap: widget.onIconTap,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestProducts(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => ProductModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child:
                          _buildSectionTitle(context, 'main.tabs.marketplace')),
                  TextButton(
                    style: _viewAllButtonStyle(context),
                    onPressed: () {
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = MarketplaceScreen(
                        userModel: widget.userModel,
                        locationFilter: widget.activeLocationFilter,
                      );
                      widget.onIconTap(nextScreen, 'main.tabs.marketplace');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        MarketplaceScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter),
                        'main.tabs.marketplace');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: ProductThumb(
                        product: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClubCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ??
        _feedRepositorySafeFetch(
            _feedRepository.fetchLatestClubPosts(limit: 20));
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => ClubPostModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (ctx) => ClubsScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter,
                            tabController: DefaultTabController.of(ctx),
                          ),
                        ),
                      );
                      widget.onIconTap(nextScreen, 'main.tabs.clubs');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        DefaultTabController(
                            length: 2,
                            child: ClubsScreen(
                                userModel: widget.userModel,
                                locationFilter: widget.activeLocationFilter,
                                tabController:
                                    DefaultTabController.of(context))),
                        'main.tabs.clubs');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: ClubThumb(
                        post: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFindFriendCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestFindFriends(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => UserModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child:
                          _buildSectionTitle(context, 'main.tabs.findFriends')),
                  TextButton(
                    style: _viewAllButtonStyle(context),
                    onPressed: () {
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen =
                          FindFriendsScreen(userModel: widget.userModel);
                      widget.onIconTap(nextScreen, 'main.tabs.findFriends');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        FindFriendsScreen(userModel: widget.userModel),
                        'main.tabs.findFriends');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: FindFriendThumb(
                        user: items[index],
                        currentUserModel: widget.userModel,
                        onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJobCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestJobs(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => JobModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = JobsScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter);
                      widget.onIconTap(nextScreen, 'main.tabs.jobs');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        JobsScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter),
                        'main.tabs.jobs');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: JobThumb(
                        job: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocalStoreCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestShops(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => ShopModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child:
                          _buildSectionTitle(context, 'main.tabs.localStores')),
                  TextButton(
                    style: _viewAllButtonStyle(context),
                    onPressed: () {
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = LocalStoresScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter);
                      widget.onIconTap(nextScreen, 'main.tabs.localStores');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        LocalStoresScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter),
                        'main.tabs.localStores');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: LocalStoreThumb(
                        shop: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuctionCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ??
        _feedRepositorySafeFetch(
            _feedRepository.fetchLatestAuctions(limit: 20));
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => AuctionModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _buildSectionTitle(context, 'main.tabs.auction')),
                  TextButton(
                    style: _viewAllButtonStyle(context),
                    onPressed: () {
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen =
                          AuctionScreen(userModel: widget.userModel);
                      widget.onIconTap(nextScreen, 'main.tabs.auction');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        AuctionScreen(userModel: widget.userModel),
                        'main.tabs.auction');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: AuctionThumb(
                        auction: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPomCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestPoms(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final allShorts = snapshot.data!
            .map((item) => PomModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Provider.value(
          value: widget.userModel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        if (widget.userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = PomScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter,
                          initialPoms: null,
                          initialIndex: 0,
                        );
                        widget.onIconTap(nextScreen, 'main.tabs.pom');
                      },
                      child: Text('common.viewAll'.tr()),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  primary: false,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  itemCount: (allShorts.length < _previewLimit)
                      ? allShorts.length
                      : allShorts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == allShorts.length) {
                      return _buildViewMoreCard(
                          context,
                          PomScreen(
                              userModel: widget.userModel,
                              locationFilter: widget.activeLocationFilter),
                          'main.tabs.pom');
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                          right: (index ==
                                  ((allShorts.length < _previewLimit)
                                      ? allShorts.length - 1
                                      : allShorts.length))
                              ? 0
                              : 12),
                      child: PomThumb(
                          short: allShorts[index],
                          allShorts: allShorts,
                          currentIndex: index,
                          onIconTap: widget.onIconTap),
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

  Widget _buildLostAndFoundCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ?? _feedRepository.fetchLatestLostItems(limit: 20);
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => LostItemModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen =
                          LostAndFoundScreen(userModel: widget.userModel);
                      widget.onIconTap(nextScreen, 'main.tabs.lostAndFound');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        LostAndFoundScreen(userModel: widget.userModel),
                        'main.tabs.lostAndFound');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: LostItemThumb(
                        item: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRealEstateCarousel(BuildContext context,
      [Future<List<FeedItemModel>>? preload]) {
    final future = preload ??
        _feedRepositorySafeFetch(
            _feedRepository.fetchLatestRoomListings(limit: 20));
    return FutureBuilder<List<FeedItemModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!
            .map((item) => RoomListingModel.fromFirestore(
                item.originalDoc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child:
                          _buildSectionTitle(context, 'main.tabs.realEstate')),
                  TextButton(
                    style: _viewAllButtonStyle(context),
                    onPressed: () {
                      if (widget.userModel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('main.errors.loginRequired'.tr())),
                        );
                        return;
                      }
                      final nextScreen = RealEstateScreen(
                          userModel: widget.userModel,
                          locationFilter: widget.activeLocationFilter);
                      widget.onIconTap(nextScreen, 'main.tabs.realEstate');
                    },
                    child: Text('common.viewAll'.tr()),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                primary: false,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemCount: (items.length < _previewLimit)
                    ? items.length
                    : items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return _buildViewMoreCard(
                        context,
                        RealEstateScreen(
                            userModel: widget.userModel,
                            locationFilter: widget.activeLocationFilter),
                        'main.tabs.realEstate');
                  }
                  return Padding(
                    padding: EdgeInsets.only(
                        right: (index ==
                                ((items.length < _previewLimit)
                                    ? items.length - 1
                                    : items.length))
                            ? 0
                            : 12),
                    child: RealEstateThumb(
                        room: items[index], onIconTap: widget.onIconTap),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

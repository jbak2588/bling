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
library;

import 'package:bling_app/features/shared/grab_widgets.dart';

import 'package:bling_app/core/models/feed_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/main_feed/data/feed_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/main_feed/widgets/pom_thumb.dart';

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

class MenuItem {
  final IconData icon;
  final String labelKey;
  final Widget screen;
  MenuItem({required this.icon, required this.labelKey, required this.screen});
}

class HomeScreen extends StatelessWidget {
  // (2) 검색 칩 위젯 헬퍼 - 디자인/텍스트 최신화
  Widget _searchChip(VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'main.search.chipPlaceholder'.tr(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 접근성 대응: textScalerOf 기반 스케일 추출 유틸
  double effectiveTextScale(BuildContext context, {double basis = 16}) {
    final s = MediaQuery.textScalerOf(context);
    return s.scale(basis) / basis;
  }

  final UserModel? userModel;
  final Map<String, String?>? activeLocationFilter;
  final Function(Widget, String) onIconTap;

  final List<FeedItemModel> allFeedItems;
  final int currentIndex;

  const HomeScreen({
    super.key,
    required this.userModel,
    required this.activeLocationFilter,
    required this.onIconTap,
    this.allFeedItems = const [],
    this.currentIndex = 0,
    required this.onSearchChipTap,
  });

  final VoidCallback? onSearchChipTap;

  static final List<MenuItem> menuItems = [
    MenuItem(
        icon: Icons.newspaper_outlined,
        labelKey: 'main.tabs.localNews',
        screen: const LocalNewsScreen()),
    MenuItem(
        icon: Icons.storefront_outlined,
        labelKey: 'main.tabs.marketplace',
        screen: const MarketplaceScreen()),
    MenuItem(
        icon: Icons.groups_outlined,
        labelKey: 'main.tabs.clubs',
        screen: const ClubsScreen()),
    MenuItem(
        icon: Icons.favorite_border_outlined,
        labelKey: 'main.tabs.findFriends',
        screen: const FindFriendsScreen()),
    MenuItem(
        icon: Icons.work_outline,
        labelKey: 'main.tabs.jobs',
        screen: const JobsScreen()),
    MenuItem(
        icon: Icons.store_mall_directory_outlined,
        labelKey: 'main.tabs.localStores',
        screen: const LocalStoresScreen()),
    MenuItem(
        icon: Icons.gavel_outlined,
        labelKey: 'main.tabs.auction',
        screen: const AuctionScreen()),
    MenuItem(
        icon: Icons.star_outline,
        labelKey: 'main.tabs.pom',
        screen: const PomScreen()),
    MenuItem(
        icon: Icons.help_outline,
        labelKey: 'main.tabs.lostAndFound',
        screen: const LostAndFoundScreen()),
    MenuItem(
        icon: Icons.house_outlined,
        labelKey: 'main.tabs.realEstate',
        screen: const RealEstateScreen()),
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

    // ✅ 탭 전환 콜백 준비: 주입받았으면 그걸 쓰고, 없으면 기존 플레이스홀더로 Fallback
    final VoidCallback? searchAction = onSearchChipTap;

    return CustomScrollView(
      slivers: [
        // ✅ AppBar 바로 아래, 얇은 검색 칩만 노출(입력은 Search 탭에서)
        SliverToBoxAdapter(child: _searchChip(searchAction)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          sliver: SliverGrid.count(
            crossAxisCount: gridCount,
            crossAxisSpacing: crossGap,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
            children: menuItems.map((item) {
              return GrabIconTile(
                compact: gridCount == 5,
                icon: item.icon,
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
                        locationFilter: activeLocationFilter);
                  } else if (screen is MarketplaceScreen) {
                    nextScreen = MarketplaceScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is ClubsScreen) {
                    nextScreen = ClubsScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is FindFriendsScreen) {
                    nextScreen = FindFriendsScreen(userModel: userModel);
                  } else if (screen is JobsScreen) {
                    nextScreen = JobsScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is LocalStoresScreen) {
                    nextScreen = LocalStoresScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is AuctionScreen) {
                    nextScreen = AuctionScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is PomScreen) {
                    nextScreen = PomScreen(
                        userModel: userModel,
                        initialShorts: null,
                        initialIndex: 0);
                  } else if (screen is LostAndFoundScreen) {
                    nextScreen = LostAndFoundScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else if (screen is RealEstateScreen) {
                    nextScreen = RealEstateScreen(
                        userModel: userModel,
                        locationFilter: activeLocationFilter);
                  } else {
                    nextScreen = screen;
                  }
                  onIconTap(nextScreen, item.labelKey);
                },
              );
            }).toList(),
          ),
        ),
        const SliverToBoxAdapter(
            child: Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5))),

        // ▼▼▼▼▼ [개편] 1단계: 기존 통합 피드를 삭제하고, Post 캐러셀 섹션으로 교체 ▼▼▼▼▼
        //
        _buildPostCarousel(context),
        // ▼▼▼▼▼ [개편] 3단계: Product 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildProductCarousel(context),
        // ▼▼▼▼▼ [개편] 4단계: Club 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildClubCarousel(context),
        // ▼▼▼▼▼ [개편] 5단계: Find Friend 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildFindFriendCarousel(context),
        // ▼▼▼▼▼ [개편] 6단계: Job 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildJobCarousel(context),
        // ▼▼▼▼▼ [개편] 7단계: Local Store 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildLocalStoreCarousel(context),
        // ▼▼▼▼▼ [개편] 8단계: Auction 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildAuctionCarousel(context),
        // ▼▼▼▼▼ [개편] 9단계: POM 캐러셀 섹션 추가 ▼▼▼▼▼
        _buildPomCarousel(context),
      ],
    );
  }

  /// [개편] 2단계: 로컬뉴스(Post) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.localNews".tr(), // "로컬 뉴스"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
              // 3-2. 가로 캐러셀 (MD: 5. 레이아웃/여백 가이드)
              SizedBox(
                height: 240, // MD: 2. 표준 썸네일 고정 크기 (220x240)
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
                      child: PostThumb(post: posts[index]),
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

  /// [개편] 3단계: 마켓플레이스(Product) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.marketplace".tr(), // "마켓플레이스"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
                      child: ProductThumb(product: products[index]),
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

  /// [개편] 4단계: 클럽(Club Post) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.clubs".tr(), // "클럽"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        if (userModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('main.errors.loginRequired'.tr())),
                          );
                          return;
                        }
                        final nextScreen = ClubsScreen(
                          userModel: userModel,
                          locationFilter: activeLocationFilter,
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
                      child: ClubThumb(post: clubPosts[index]),
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

  /// [개편] 5단계: 친구찾기(Find Friend) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.findFriends".tr(), // "친구찾기"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
                      child: FindFriendThumb(
                          user: users[index], currentUserModel: userModel),
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

  /// [개편] 6단계: 구인/구직(Job) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.jobs".tr(), // "구인/구직"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
                      child: JobThumb(job: jobs[index]),
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

  /// [개편] 7단계: 동네 업체(Local Store) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.localStores".tr(), // "동네 업체"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
                      child: LocalStoreThumb(shop: shops[index]),
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

  /// [개편] 8단계: 경매(Auction) 캐러셀 섹션 빌더
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
                    Text(
                      "main.tabs.auction".tr(), // "경매"
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
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
                      child: AuctionThumb(auction: auctions[index]),
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

  /// [개편] 9단계: 숏폼(POM) 캐러셀 섹션 빌더
  /// MD요구사항: 1.행 단위 가로 캐러셀, 2.최신 20개, 6.빈 섹션 숨김, 4.재생 정책
  ///
  Widget _buildPomCarousel(BuildContext context) {
    final feedRepository = FeedRepository();

    return FutureBuilder<List<FeedItemModel>>(
      // 1. Repository에서 Short 최신 20개를 가져옵니다.
      future: feedRepository.fetchLatestShorts(limit: 20),
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

        // 3. FeedItemModel 리스트를 ShortModel 리스트로 변환 (전체 목록 전달용)
        final allShorts = snapshot.data!
            .map((item) => ShortModel.fromFirestore(
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
                      Text(
                        "main.tabs.pom".tr(), // "POM"
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
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
                            initialShorts: null,
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
                            currentIndex: index),
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
  // ▲▲▲▲▲ [개편] 1, 2단계 완료 ▲▲▲▲▲
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

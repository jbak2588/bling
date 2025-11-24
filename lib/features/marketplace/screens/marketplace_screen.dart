/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/marketplace_screen.dart
/// 폐기 Purpose  : 위치 기반 필터로 상품 목록을 표시합니다.(카테코리 탭 우선, 2차 위치 필터 적용 25년11월18일)
/// User Impact   : 구매자가 주변 상품을 둘러보고 상세 페이지를 열 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/location/screens/location_filter_screen.dart
/// Data Model    : Firestore `products`를 `locationParts.prov`로 쿼리하고 `createdAt`으로 정렬합니다.
/// Location Scope: `locationFilter`를 통해 Prov→Kab/Kota→Kec→Kel 값을 지원합니다.
/// Trust Policy  : `isAiVerified` 상품만 강조하며 미검증 상품은 검토 대상입니다.
/// Monetization  : 프로모션 상품과 배너 광고를 지원하며 추후 판매 수수료가 예정되어 있습니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_marketplace`, `apply_location_filter`, `click_product`.
/// Analytics     : 쿼리 결과와 스크롤 깊이를 모니터링합니다.
/// I18N          : 키 `marketplace.error`, `marketplace.empty`, `time.*` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization, firebase_auth
/// Security/Auth : 조회는 공개이며 등록은 인증과 신뢰 점수가 필요합니다.
/// Edge Cases    : 사용자 위치가 없으면 설정 프롬프트를 표시합니다.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// ============================================================================
/// 작업 일자      : 2025-11-18
/// File          : lib/features/marketplace/screens/marketplace_screen.dart
/// Purpose       : 카테고리 탭과 위치 필터를 적용하여 상품 목록을 표시합니다.
/// User Impact   : 대분류/소분류 탭을 통해 원하는 카테고리의 상품을 쉽게 탐색할 수 있습니다.
/// Feature Links : MainNavigationScreen (앱바 타이틀 연동)
/// Data Model    : Firestore `products`, `categories_v2`
/// Notes         : '전체' 탭은 categoryParentId, 소분류 탭은 categoryId를 기준으로 쿼리합니다.
/// ============================================================================
library;

/// 아래부터 실제 코드

// import removed: category_icons is now used via BlingIcon helper
import 'package:bling_app/features/categories/data/firestore_category_repository.dart';
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/widgets/bling_icon.dart'; // ✅ BlingIcon import
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/location/providers/location_provider.dart'; // ✅ Provider
import 'package:provider/provider.dart'; // ✅ Provider
import 'dart:math' as math; // 거리 계산용

import '../models/product_model.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final UserModel? userModel;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;
  final Function(String title)? onTitleChanged;
  // final Map<String, String?>? locationFilter; // 삭제됨 (Provider 사용)

  const MarketplaceScreen({
    this.userModel,
    this.autoFocusSearch = false,
    this.searchNotifier,
    this.onTitleChanged,
    Map<String, String?>? locationFilter, // 하위 호환을 위해 남겨두되 사용 안함
    super.key,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

// ✅ [UI 개선] SliverPersistentHeader를 위한 Delegate 클래스
class _SubCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SubCategoryHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_SubCategoryHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _categoryRepo = FirestoreCategoryRepository();

  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  // '전체' 탭을 위한 가상의 Category 객체
  final Category _allCategory = const Category(
    id: 'all',
    parentId: null,
    slug: 'all',
    nameKo: '전체',
    nameId: 'Semua',
    nameEn: 'All',
    order: 0,
    active: true,
    isParent: true,
    icon: 'ms:grid_view',
  );

  late Category _selectedParent;
  Category? _selectedSub;

  @override
  void initState() {
    super.initState();
    _selectedParent = _allCategory;

    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    if (widget.searchNotifier != null) {
      _externalSearchListener = () {
        if (widget.searchNotifier!.value == true) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }

    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  void _onParentTabSelected(Category category) {
    if (_selectedParent.id == category.id) return;

    setState(() {
      _selectedParent = category;
      _selectedSub = null;
    });

    if (widget.onTitleChanged != null) {
      // Always pass a key (not a translated string) so the caller can decide
      // whether to call `t[...]` or treat it as raw text. Passing translated
      // strings previously caused mismatches when the app expected an i18n key.
      final titleKey = category.id == 'all'
          ? 'main.tabs.marketplace'
          : 'category.${category.slug}';
      widget.onTitleChanged!(titleKey);
    }
  }

  void _onSubTabSelected(Category? category) {
    if (_selectedSub?.id == category?.id) return;
    setState(() {
      _selectedSub = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    // ✅ LocationProvider 구독
    final locationProvider = context.watch<LocationProvider>();

    Query<Map<String, dynamic>> buildQuery() {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      // 1. 위치 필터 (Provider 기준)
      if (locationProvider.mode == LocationSearchMode.administrative) {
        final filterEntry = locationProvider.activeQueryFilter;
        if (filterEntry != null) {
          query = query.where(filterEntry.key, isEqualTo: filterEntry.value);
        }
      } else if (locationProvider.mode == LocationSearchMode.nearby) {
        // 거리 검색일 때는 DB 부하를 낮추기 위해 Kab(혹은 prov) 레벨에서 1차 필터
        final userKab = locationProvider.user?.locationParts?['kab'];
        if (userKab != null && userKab.isNotEmpty) {
          query = query.where('locationParts.kab', isEqualTo: userKab);
        }
      }

      // 2. 상태 필터
      query = query.where('status', whereIn: ['selling', 'reserved', 'sold']);

      // 3. 카테고리 필터
      if (_selectedParent.id != 'all') {
        if (_selectedSub != null && _selectedSub!.id != 'all') {
          // 소분류 선택 시: categoryId 기준
          query = query.where('categoryId', isEqualTo: _selectedSub!.id);
        } else {
          // 대분류 선택(전체) 시: categoryParentId 기준
          query =
              query.where('categoryParentId', isEqualTo: _selectedParent.id);
        }
      }

      // [수정] 검색 쿼리 적용 (DB 기반)
      final kw = _searchKeywordNotifier.value;
      if (kw.isNotEmpty) {
        final searchToken = kw.trim().split(' ').first.toLowerCase();
        if (searchToken.isNotEmpty) {
          query = query.where('searchIndex', arrayContains: searchToken);
        }
      }

      // 4. 정렬
      query = query
          .orderBy('isAiVerified', descending: true)
          .orderBy('createdAt', descending: true);

      return query;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // [수정] 검색바를 NestedScrollView 밖으로 이동 (앱바 바로 아래 고정)
          if (_showSearchBar)
            InlineSearchChip(
              hintText: t.main.search.hint.marketplace,
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),

          Expanded(
            child: NestedScrollView(
              floatHeaderSlivers: true, // 스크롤을 살짝 올리면 앱바(탭)가 바로 나타남
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // 1. 대분류 탭 (SliverAppBar)
                  SliverAppBar(
                    pinned: false, // 스크롤 시 위로 사라짐
                    floating: true, // 스크롤 올리면 바로 나타남
                    snap: true, // 중간에 걸치지 않고 확 나타남
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    // 높이를 내용물(탭)에 맞춤.
                    toolbarHeight: 100,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildParentCategoryTabs(langCode),
                    ),
                  ),

                  // 2. 소분류 탭 (SliverPersistentHeader)
                  // 대분류가 '전체'가 아닐 때만 표시
                  if (_selectedParent.id != 'all')
                    SliverPersistentHeader(
                      pinned: true, // 소분류 탭은 상단에 고정 (선택 사항: false면 같이 사라짐)
                      delegate: _SubCategoryHeaderDelegate(
                        child: Container(
                          color: Colors.white, // 배경색 확보
                          child: _buildSubCategoryTabs(langCode),
                        ),
                        maxHeight: 110,
                        minHeight: 110,
                      ),
                    ),

                  // 검색바는 NestedScrollView 밖으로 이동했으므로 제거
                ];
              },
              body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    if (snapshot.error
                        .toString()
                        .contains('failed-precondition')) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            Text("인덱스 생성 필요: 콘솔 링크를 확인하세요.\n${snapshot.error}"),
                      ));
                    }
                    return Center(
                        child: Text(t.marketplace.error
                            .replaceAll('{error}', snapshot.error.toString())));
                  }

                  var allDocs = snapshot.data?.docs ?? [];

                  // ✅ [거리순 정렬 로직 추가]
                  if (locationProvider.mode == LocationSearchMode.nearby &&
                      locationProvider.user?.geoPoint != null) {
                    final userGeo = locationProvider.user!.geoPoint!;
                    final radiusKm = locationProvider.radiusKm;

                    // 1. 거리 필터링 & 정렬을 위해 리스트 변환
                    // (ProductModel로 변환 비용이 들지만 정확한 거리 계산을 위해 필요)
                    allDocs = allDocs.where((doc) {
                      final pGeo = (doc.data()['geoPoint'] as GeoPoint?);
                      if (pGeo == null) return false;
                      final dist = _calculateDistance(userGeo.latitude,
                          userGeo.longitude, pGeo.latitude, pGeo.longitude);
                      return dist <= radiusKm;
                    }).toList();

                    // 2. 거리순 정렬
                    allDocs.sort((a, b) {
                      final geoA = (a.data()['geoPoint'] as GeoPoint);
                      final geoB = (b.data()['geoPoint'] as GeoPoint);
                      final distA = _calculateDistance(userGeo.latitude,
                          userGeo.longitude, geoA.latitude, geoA.longitude);
                      final distB = _calculateDistance(userGeo.latitude,
                          userGeo.longitude, geoB.latitude, geoB.longitude);
                      return distA.compareTo(distB);
                    });
                  }

                  allDocs = _applyStatusRules(allDocs);

                  // 검색은 DB 기반(정렬/필터링)으로 처리하므로 클라이언트 사이드 키워드 필터는 제거.

                  if (allDocs.isEmpty) {
                    final isNational =
                        locationProvider.mode == LocationSearchMode.national;
                    if (!isNational) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(t.marketplace.empty,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Text(t.search.empty.checkSpelling,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.map_outlined),
                                label: Text(t.search.empty.expandToNational),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                ),
                                onPressed: () => context
                                    .read<LocationProvider>()
                                    .setMode(LocationSearchMode.national),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(t.marketplace.empty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ));
                  }

                  return ListView.separated(
                    // NestedScrollView 내부 리스트는 padding top 0 권장
                    padding: EdgeInsets.zero,
                    itemCount: allDocs.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) {
                      final product =
                          ProductModel.fromFirestore(allDocs[index]);
                      return ProductCard(
                        key: ValueKey(product.id),
                        product: product,
                      );
                    },
                  );
                },
              ), // StreamBuilder
            ), // NestedScrollView
          ), // Expanded
        ],
      ), // Column
    );
  }

  Widget _buildParentCategoryTabs(String langCode) {
    return StreamBuilder<List<Category>>(
      stream: _categoryRepo.watchParents(activeOnly: true),
      builder: (context, snapshot) {
        final categories = [_allCategory, ...(snapshot.data ?? [])];

        return Container(
          height: 100, // increased to fit icon tile + 2-line label
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedParent.id == cat.id;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildTabItem(cat, isSelected, langCode, () {
                  _onParentTabSelected(cat);
                }, isSub: false),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryTabs(String langCode) {
    return StreamBuilder<List<Category>>(
      stream: _categoryRepo.watchSubs(_selectedParent.id, activeOnly: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          return const SizedBox.shrink();
        }

        final allSub = _allCategory.copyWith(
          id: 'all',
          nameKo: '전체',
          nameEn: 'All',
          nameId: 'Semua',
          icon: 'ms:apps',
        );

        final subCategories = [allSub, ...(snapshot.data ?? [])];

        if (snapshot.data == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 76, child: Center(child: CircularProgressIndicator()));
        }

        return Container(
          height: 110, // give a bit more room for subcategory labels
          color: const Color(0xFFF9F9F9),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final cat = subCategories[index];
              final isSelected = (index == 0 &&
                      (_selectedSub == null || _selectedSub!.id == 'all')) ||
                  (_selectedSub?.id == cat.id);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildTabItem(cat, isSelected, langCode, () {
                  _onSubTabSelected(index == 0 ? null : cat);
                }, isSub: true),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
      Category category, bool isSelected, String langCode, VoidCallback onTap,
      {required bool isSub}) {
    final theme = Theme.of(context);

    // ✅ [UI 개선] 비활성 상태여도 회색이 아닌 '브랜드 컬러'를 유지하되, 투명도로 구분
    final color = isSelected
        ? theme.primaryColor
        : theme.primaryColor.withValues(alpha: 0.6);
    final bgColor = isSelected
        ? theme.primaryColor.withValues(alpha: 0.1)
        : Colors.transparent;
    // ✅ 텍스트 스타일: 선택시 볼드, 비선택시는 보통 폰트
    final fontWeight = isSelected ? FontWeight.w700 : FontWeight.normal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 64, // 좁은 그리드 폭
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: isSub ? 4 : 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // approximate label height (2 lines)
            final labelFontSize = isSub ? 9.0 : 9.5;
            final labelHeight =
                labelFontSize * 1.1 * 2; // fontSize * height * lines
            final spacingHeight = isSub ? 4.0 : 6.0;
            final maxTile = isSub ? 48.0 : 56.0;

            // available space for the tile considering label and spacing
            final availableForTile =
                constraints.maxHeight - labelHeight - spacingHeight;
            final tileSize = (availableForTile.isFinite && availableForTile > 0)
                ? availableForTile.clamp(24.0, maxTile)
                : maxTile.clamp(24.0, maxTile);
            final effectiveTile = tileSize > constraints.maxWidth
                ? constraints.maxWidth
                : tileSize;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon tile separated from the label
                SizedBox(
                  width: effectiveTile,
                  height: effectiveTile,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      // ✅ [UI 개선] BlingIcon 적용
                      child: BlingIcon(
                        category.effectiveIcon(forParent: !isSub),
                        size: isSub ? 22 : 26,
                        color: color,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacingHeight),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth, maxHeight: labelHeight),
                  child: Text(
                    category.displayName(langCode),
                    style: TextStyle(
                      color: color,
                      fontSize: labelFontSize,
                      fontWeight: fontWeight,
                      height: 1.1,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Haversine 공식 (km 단위 반환)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyStatusRules(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 10));

    return docs.where((doc) {
      final data = doc.data();
      final status = data['status'] as String?;
      final updatedAt = data['updatedAt'] as Timestamp?;

      if (status == 'sold') {
        if (updatedAt == null) return false;
        return updatedAt.toDate().isAfter(cutoffDate);
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    if (_externalSearchListener != null && widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    super.dispose();
  }
}

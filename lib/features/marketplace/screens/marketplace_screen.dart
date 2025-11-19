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
/// ============================================================================
library;

/// 아래부터 실제 코드
import 'package:bling_app/features/categories/constants/category_icons.dart';
import 'package:bling_app/features/categories/data/firestore_category_repository.dart';
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

import '../models/product_model.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;
  // ✅ [신규] 앱바 타이틀 변경을 위한 콜백
  final Function(String title)? onTitleChanged;

  const MarketplaceScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    this.onTitleChanged,
    super.key,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  // 리포지토리
  final _categoryRepo = FirestoreCategoryRepository();

  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  // ✅ [카테고리] 상태 관리
  // '전체' 탭을 위한 가상의 Category 객체 (ID: 'all')
  // 아이콘은 앱 디자인에 맞는 기본 아이콘 사용
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
    icon: 'ms:grid_view', // 전체보기 아이콘
  );

  // 초기값은 '전체'
  late Category _selectedParent;
  Category? _selectedSub; // null이면 해당 Parent의 '전체' 보기

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
        if (widget.searchNotifier!.value == AppSection.marketplace) {
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

  /// 카테고리 탭 클릭 핸들러
  void _onParentTabSelected(Category category) {
    if (_selectedParent.id == category.id) return;

    setState(() {
      _selectedParent = category;
      _selectedSub = null; // 대분류 변경 시 소분류 초기화
    });

    // 앱바 타이틀 변경 요청 (메인 네비게이션과 연동)
    if (widget.onTitleChanged != null) {
      final titleKey = category.id == 'all'
          ? 'main.tabs.marketplace' // 전체인 경우 기본 타이틀 키
          : null;

      // 키가 있으면 키를 전달(번역은 메인에서), 없으면 직접 표시 이름 전달
      if (titleKey != null) {
        widget.onTitleChanged!(titleKey.tr());
      } else {
        widget
            .onTitleChanged!(category.displayName(context.locale.languageCode));
      }
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
    final langCode = context.locale.languageCode;

    // Firestore 쿼리 빌더
    Query<Map<String, dynamic>> buildQuery() {
      final userProv = widget.userModel?.locationParts?['prov'];
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      // 1. 지역 필터 (Prov 레벨, 인덱스 효율을 위해)
      if (userProv != null && userProv.isNotEmpty) {
        query = query.where('locationParts.prov', isEqualTo: userProv);
      }

      // 2. 상태 필터 ('selling', 'reserved', 'sold')
      query = query.where('status', whereIn: ['selling', 'reserved', 'sold']);

      // 3. 카테고리 필터 (여기가 핵심입니다)
      if (_selectedParent.id != 'all') {
        if (_selectedSub != null && _selectedSub!.id != 'all') {
          // [Case A] 특정 소분류 선택 시 -> categoryId로 필터링
          query = query.where('categoryId', isEqualTo: _selectedSub!.id);
        } else {
          // [Case B] 대분류만 선택 시 (소분류 '전체') -> categoryParentId로 필터링
          // 등록 시 저장된 부모 ID를 활용합니다.
          query =
              query.where('categoryParentId', isEqualTo: _selectedParent.id);
        }
      }

      // 4. 정렬: AI 검증 우선 -> 최신순
      // (Firestore 인덱스가 필요할 수 있습니다. 예: categoryParentId + isAiVerified + createdAt)
      query = query
          .orderBy('isAiVerified', descending: true)
          .orderBy('createdAt', descending: true);

      return query;
    }

    return Scaffold(
      // Scaffold 배경색을 흰색으로 지정하여 탭바와 이질감 제거
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. 상단 대분류 탭 (아이콘 + 텍스트)
          _buildParentCategoryTabs(langCode),

          // 2. 하단 소분류 탭 (대분류가 '전체'가 아닐 때만 표시)
          if (_selectedParent.id != 'all') _buildSubCategoryTabs(langCode),

          // 3. 검색바 (조건부 표시)
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.marketplace'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),

          // 4. 상품 리스트
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // 인덱스 에러 힌트
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
                      child: Text('marketplace.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }

                var allDocs = snapshot.data?.docs ?? [];

                // 클라이언트 사이드 필터링 (위치 세부 + 상태)
                allDocs = _applyLocationFilter(allDocs);
                allDocs = _applyStatusRules(allDocs);

                // 검색 키워드 필터
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  allDocs = allDocs.where((d) {
                    final p = ProductModel.fromFirestore(d);
                    final hay =
                        ('${p.title} ${p.description} ${p.tags.join(' ')}')
                            .toLowerCase();
                    return hay.contains(kw);
                  }).toList();
                }

                if (allDocs.isEmpty) {
                  return Center(
                      child: Text('marketplace.empty'.tr(),
                          textAlign: TextAlign.center));
                }

                return ListView.separated(
                  itemCount: allDocs.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final product = ProductModel.fromFirestore(allDocs[index]);
                    return ProductCard(
                      key: ValueKey(product.id),
                      product: product,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 대분류 탭 빌더
  Widget _buildParentCategoryTabs(String langCode) {
    return StreamBuilder<List<Category>>(
      stream: _categoryRepo.watchParents(activeOnly: true),
      builder: (context, snapshot) {
        // '전체' 탭 + Firestore 데이터
        final categories = [_allCategory, ...(snapshot.data ?? [])];

        return Container(
          height: 84, // 탭 높이 살짝 키움
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  /// 소분류 탭 빌더
  Widget _buildSubCategoryTabs(String langCode) {
    return StreamBuilder<List<Category>>(
      // 선택된 대분류의 서브카테고리만 구독
      stream: _categoryRepo.watchSubs(_selectedParent.id, activeOnly: true),
      builder: (context, snapshot) {
        // 데이터 없으면 빈 공간
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          return const SizedBox.shrink();
        }

        // 소분류 '전체' 탭 생성 (부모 이름 + '전체')
        // 아이콘은 'ms:category' 또는 부모 아이콘 사용
        final allSub = _allCategory.copyWith(
          id: 'all',
          nameKo: '전체',
          nameEn: 'All',
          nameId: 'Semua',
          icon: 'ms:apps', // 전체보기용 다른 아이콘
        );

        final subCategories = [allSub, ...(snapshot.data ?? [])];

        // 데이터가 로딩 중이거나 실제 서브카테고리가 0개인 경우 처리
        if (snapshot.data == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 84, child: Center(child: CircularProgressIndicator()));
        }

        return Container(
          height: 84,
          color: const Color(0xFFF9F9F9), // 소분류 배경은 연한 회색으로 구분
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final cat = subCategories[index];
              // 소분류 '전체' 선택 여부: _selectedSub가 null이거나 id가 'all'
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

  /// 공통 탭 아이템 위젯 (아이콘 + 텍스트)
  Widget _buildTabItem(
      Category category, bool isSelected, String langCode, VoidCallback onTap,
      {required bool isSub}) {
    final theme = Theme.of(context);
    // 선택된 색상: 메인 컬러 / 비선택: 회색
    final color = isSelected ? theme.primaryColor : Colors.grey.shade600;
    // 배경색: 선택됨 -> 연한 메인 컬러 / 비선택 -> 투명
    final bgColor = isSelected
        ? theme.primaryColor.withValues(alpha: 0.08)
        : Colors.transparent;
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          // 선택된 경우 테두리 추가 옵션 (현재는 배경색으로 구분)
          // border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 표시
            CategoryIcons.widget(
              category.effectiveIcon(forParent: !isSub),
              size: 26,
              color: color,
            ),
            const SizedBox(height: 6),
            // 텍스트 표시
            Text(
              category.displayName(langCode),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: fontWeight,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 기존 위치 필터 로직 (유지)
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = widget.locationFilter;
    if (filter == null) return allDocs;

    String? key;
    if (filter['kel'] != null) {
      key = 'kel';
    } else if (filter['kec'] != null) {
      key = 'kec';
    } else if (filter['kab'] != null) {
      key = 'kab';
    } else if (filter['kota'] != null) {
      key = 'kota';
    } else if (filter['prov'] != null) {
      key = 'prov';
    }
    if (key == null) return allDocs;

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .toList();
  }

  // 기존 상태 필터 로직 (유지)
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

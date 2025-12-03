// ===================== DocHeader =====================
// [기획 요약]
// - 지역 상점 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shops 컬렉션 구조와 1:1 매칭, 신뢰 등급, 대표 이미지, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/연락처/영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 상점주/이용자 모두를 위한 UX 개선(리뷰/채팅/알림 등).
// =====================================================
// lib/features/local_stores/screens/local_stores_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 지역 상점 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shops 컬렉션 구조와 1:1 매칭, 신뢰 등급, 대표 이미지, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/연락처/영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 상점주/이용자 모두를 위한 UX 개선(리뷰/채팅/알림 등).
// =====================================================
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) '업종 카테고리' 필터링: 상단에 ChoiceChip 기반 칩 리스트 UI 추가.
// 2. (Task 1) '정렬' 기능: '거리순', '인기순' 정렬을 위한 DropdownButton 및 정렬 로직 추가. (Geolocator 사용)
// 3. (Task 1) '광고' 로직: 'isSponsored'가 true인 가게를 정렬과 무관하게 항상 최상단에 노출시키는 로직 추가.
// 4. (Task 6) 'Jobs' 연동: 'ShopDetailScreen'으로 'userModel'을 전달하기 위해 ShopCard에 userModel을 prop으로 전달.
// =====================================================
// lib/features/local_stores/screens/local_stores_screen.dart

import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/widgets/shop_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // [추가]
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'create_shop_screen.dart'; // [추가]
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalStoresScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const LocalStoresScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  State<LocalStoresScreen> createState() => _LocalStoresScreenState();
}

class _LocalStoresScreenState extends State<LocalStoresScreen> {
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapMode = false; // [추가] 지도 모드 상태

  List<ShopModel> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = widget.locationFilter;
    if (filter == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

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
    if (key == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .map((doc) => ShopModel.fromFirestore(doc))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }

    // ✅ [버그 수정] 키워드가 변경될 때마다 setState를 호출하여 화면을 다시 그리도록 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);

    // [추가] 카테고리 필터 초기화
    _categories.insert(0, 'all');
    _selectedCategory = _categories[0];
  }

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    // ✅ [버그 수정] 리스너 제거를 먼저 수행한 다음 notifier를 폐기합니다.
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    super.dispose();
  }

  void _externalSearchListener() {
    if (widget.searchNotifier?.value == true) {
      if (!mounted) return;
      setState(() => _showSearchBar = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
      widget.searchNotifier?.value = false;
    }
  }

  // ✅ [버그 수정] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  // [추가] 카테고리 필터 로직
  final List<String> _categories = [
    'food',
    'cafe',
    'massage',
    'beauty',
    'nail',
    'auto',
    'kids',
    'hospital',
    'etc'
  ];
  String _selectedCategory = 'all';

  // [추가] 정렬 옵션
  String _sortOption = 'default'; // 'default', 'distance', 'popular'

  // [추가] 거리 계산 함수
  double _calculateDistance(GeoPoint? shopPoint) {
    final userPoint = widget.userModel?.geoPoint;
    if (userPoint == null || shopPoint == null) return double.maxFinite;
    return Geolocator.distanceBetween(
      userPoint.latitude,
      userPoint.longitude,
      shopPoint.latitude,
      shopPoint.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ShopRepository shopRepository = ShopRepository();
    final userProvince = widget.userModel?.locationParts?['prov'];

    if (userProvince == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('localStores.setLocationPrompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    // Prepare DB-side search token (first token of search input)
    final kwToken = _searchKeywordNotifier.value.trim().toLowerCase();
    String? searchToken;
    if (kwToken.isNotEmpty) {
      final token = kwToken.split(' ').first;
      if (token.isNotEmpty) searchToken = token;
    }

    return Scaffold(
      // [추가] AppBar에 지도 토글 버튼 추가 (SliverAppBar가 아니라면 body 상단이나 부모에서 처리 필요)
      // 현재 구조상 LocalStoresScreen은 탭의 body로 쓰이므로, 상단 필터 영역 우측에 버튼 배치
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.localStores'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          // [수정] 카테고리 필터 + 지도 토글 버튼 행
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final bool isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text('localStores.categories.$category'.tr()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              // [수정] 지도/닫기 토글 버튼 (항상 노출)
              IconButton(
                icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
                onPressed: () => setState(() => _isMapMode = !_isMapMode),
                tooltip:
                    _isMapMode ? 'common.closeMap'.tr() : 'common.viewMap'.tr(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          // [추가] 정렬 옵션 UI
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: _sortOption,
                  items: [
                    DropdownMenuItem(
                        value: 'default',
                        child: Text('common.sort.default'.tr())), // 최신순
                    DropdownMenuItem(
                        value: 'distance',
                        child: Text('common.sort.distance'.tr())), // 거리순
                    DropdownMenuItem(
                        value: 'popular',
                        child: Text('common.sort.popular'.tr())), // 인기순
                  ],
                  onChanged: (value) => setState(() => _sortOption = value!),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isMapMode
                ? SharedMapBrowser<ShopModel>(
                    dataStream: shopRepository
                        .fetchShops(
                            locationFilter: widget.locationFilter,
                            searchToken: searchToken)
                        .map((snapshot) => snapshot.docs
                            .map((doc) => ShopModel.fromFirestore(doc))
                            // 간단한 필터링 (카테고리 등)은 스트림 내부나 여기서 처리 필요
                            .where((s) =>
                                _selectedCategory == 'all' ||
                                s.category == _selectedCategory)
                            .toList()),
                    locationExtractor: (shop) =>
                        shop.shopLocation?.geoPoint ?? shop.geoPoint,
                    idExtractor: (shop) => shop.id,
                    cardBuilder: (context, shop) =>
                        ShopCard(shop: shop, userModel: widget.userModel),
                    initialCameraPosition: widget.userModel?.geoPoint != null
                        ? CameraPosition(
                            target: LatLng(widget.userModel!.geoPoint!.latitude,
                                widget.userModel!.geoPoint!.longitude),
                            zoom: 14)
                        : null,
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: shopRepository.fetchShops(
                        locationFilter: widget.locationFilter,
                        searchToken: searchToken),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('localStores.error'.tr(namedArgs: {
                          'error': snapshot.error.toString()
                        })));
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      var shops = _applyLocationFilter(allDocs);

                      // [추가] 카테고리 필터 적용
                      if (_selectedCategory != 'all') {
                        shops = shops
                            .where((s) => s.category == _selectedCategory)
                            .toList();
                      }

                      // DB-side keyword filtering applied in the repository using
                      // the first token of the search input. Client-side full text
                      // filtering has been removed to rely on Firestore query.

                      // [수정] 정렬 로직
                      // [추가] 거리순 정렬
                      if (_sortOption == 'distance') {
                        shops.sort((a, b) => _calculateDistance(a.geoPoint)
                            .compareTo(_calculateDistance(b.geoPoint)));
                      } else if (_sortOption == 'popular') {
                        // (개선) 인기순 정렬 (예: 리뷰수 * 별점 + 조회수)
                        shops.sort((a, b) {
                          final double scoreA =
                              (a.reviewCount * a.averageRating) + a.viewsCount;
                          final double scoreB =
                              (b.reviewCount * b.averageRating) + b.viewsCount;
                          return scoreB.compareTo(scoreA);
                        });
                      }

                      // 'default'는 기본값 (createdAt 내림차순 - Repository에서 이미 처리됨)

                      // [추가] 스폰서 상품(광고) 을 항상 최상단으로 (정렬과 무관하게)
                      final sponsoredShops =
                          shops.where((s) => s.isSponsored).toList();
                      final normalShops =
                          shops.where((s) => !s.isSponsored).toList();
                      shops = sponsoredShops + normalShops;

                      if (shops.isEmpty) {
                        final isNational =
                            context.watch<LocationProvider>().mode ==
                                LocationSearchMode.national;
                        if (!isNational) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.storefront_outlined,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('localStores.empty'.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  const SizedBox(height: 8),
                                  Text('search.empty.checkSpelling'.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey)),
                                  const SizedBox(height: 24),
                                  // [추가] 가게 등록 유도 버튼
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_business),
                                    label:
                                        Text('localStores.create.title'.tr()),
                                    onPressed: () {
                                      if (widget.userModel != null) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (_) => CreateShopScreen(
                                              userModel: widget.userModel!),
                                        ));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'main.errors.loginRequired'
                                                        .tr())));
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.map_outlined),
                                    label: Text(
                                        'search.empty.expandToNational'.tr()),
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
                                Text('localStores.empty'.tr(),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          return ShopCard(
                              shop: shops[index], userModel: widget.userModel);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // V V V --- [수정] 상점 등록 화면으로 이동하는 로직 --- V V V
          if (widget.userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateShopScreen(userModel: widget.userModel!),
            ));
          } else {
            // 로그인하지 않은 사용자에 대한 처리
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'localStores.create.tooltip'.tr(),
        child: const Icon(Icons.add_business_outlined),
      ),
    );
  }
}

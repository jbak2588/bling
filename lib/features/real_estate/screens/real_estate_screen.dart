// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 31, 33) '직방' 모델 도입.
// 2. 이 화면을 '매물 리스트'에서 '카테고리 런처(Launcher)' 화면으로 전면 개편.
// 3. 기존 리스트/필터 로직은 'room_list_screen.dart' 파일로 이전됨.
//
// [LEGAL DISCLAIMER - 절대 삭제 금지]
// 아래 고지 문구는 각 섹션 및 화면 하단에 공통적으로 노출되어야 하며,
// 현지 법률의 미묘한 차이를 고려하되 동일한 취지를 유지해야 합니다.
// 번역 키: 'realEstate.disclaimer' (ko/en/id 모두 존재)
// =====================================================
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 5) 인도네시아 현지 수요('rumah123' 분석)를 반영하여 'Gudang'(창고) 카테고리 추가.
// =====================================================
// RealEstate launcher screen with search toggle support
// Clean StatefulWidget implementation.
// lib/features/real_estate/screens/real_estate_screen.dart

// ===================== DocHeader =====================
// [기획 요약]
// - V2.1 (2025-12-12): 부동산 메인 화면 전면 개편 (Launcher 방식 폐기 -> 통합 리스트 방식).
// - '직방' 스타일 UX 도입: 상단 카테고리 칩바 + 즉시 리스트 노출.
// - 기존 'room_list_screen.dart'의 모든 로직(필터, 지도, 리스트)을 흡수 통합.
// - 개인정보 보호: 리스트/지도에는 대략적인 위치(행정구역)만 노출하며 상세 주소는 숨김 처리.
//
// [주요 변경점]
// 1. UI 구조: AppBar -> Category Chips -> Filter Bar -> List/Map Body.
// 2. 통합 로직: 카테고리 변경 시 화면 전환 없이 즉시 데이터 필터링.
// 3. '전체(All)' 보기 모드 추가.
// =====================================================
// lib/features/real_estate/screens/real_estate_screen.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/constants/real_estate_facilities.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:bling_app/features/shared/helpers/legacy_title_extractor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:bling_app/core/constants/app_categories.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class RealEstateScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const RealEstateScreen({
    super.key,
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  final RoomRepository _repository = RoomRepository();

  // 검색 및 UI 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _isMapMode = false;
  bool _showSearchBar = false;

  // 카테고리 상태 (null 또는 'all'이면 전체 보기)
  String _selectedCategory = 'all';

  // 필터 상태
  late RoomFilters _activeFilters;
  int _filterCount = 0;

  // 카테고리별 동적 최대값 (필터 슬라이더용)
  double _categoryMaxPrice = 10000000000; // 100억 (기본값)
  double _categoryMaxArea = 1000;
  double _categoryMaxLandArea = 5000;

  @override
  void initState() {
    super.initState();
    // 초기화 시 전체(All) 기준으로 설정
    _updateDefaultsForCategory('all');
    _activeFilters = RoomFilters(
      roomType: null, // null means all
      maxPrice: _categoryMaxPrice,
      maxArea: _categoryMaxArea,
      maxLandArea: _categoryMaxLandArea,
    );

    _searchKeywordNotifier.addListener(_onKeywordChanged);
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chipOpenNotifier.value = true;
      });
    }
  }

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    super.dispose();
  }

  void _onKeywordChanged() {
    if (mounted) setState(() {});
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

  // 카테고리 변경 시 호출
  void _onCategoryChanged(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      _updateDefaultsForCategory(newCategory);

      // 필터 초기화 및 새 카테고리 적용
      _activeFilters.clear();
      _activeFilters.roomType = (newCategory == 'all') ? null : newCategory;
      _activeFilters.maxPrice = _categoryMaxPrice;
      _activeFilters.maxArea = _categoryMaxArea;
      _activeFilters.maxLandArea = _categoryMaxLandArea;
      _filterCount = 0;
    });
  }

  // 카테고리별 최대값/기본값 설정 로직
  void _updateDefaultsForCategory(String category) {
    switch (category) {
      case 'kos':
        _categoryMaxPrice = 50000000; // 5천만
        _categoryMaxArea = 100;
        _categoryMaxLandArea = 300;
        break;
      case 'apartment':
        _categoryMaxPrice = 3000000000; // 30억
        _categoryMaxArea = 300;
        _categoryMaxLandArea = 500;
        break;
      case 'house':
      case 'kontrakan':
        _categoryMaxPrice = 10000000000; // 100억
        _categoryMaxArea = 1000;
        _categoryMaxLandArea = 5000;
        break;
      case 'ruko':
      case 'kantor':
      case 'gudang':
        _categoryMaxPrice = 20000000000; // 200억
        _categoryMaxArea = 5000;
        _categoryMaxLandArea = 10000;
        break;
      default: // all or others
        _categoryMaxPrice = 20000000000;
        _categoryMaxArea = 5000;
        _categoryMaxLandArea = 10000;
        break;
    }
  }

  // 위치 필터 구성
  Map<String, String?>? _buildLocationFilter(LocationProvider provider) {
    if (provider.mode == LocationSearchMode.administrative) {
      return provider.adminFilter;
    }
    if (provider.mode == LocationSearchMode.nearby) {
      final userKab = provider.user?.locationParts?['kab'];
      if (userKab != null && userKab.isNotEmpty) {
        return {'kab': userKab};
      }
      final userProv = provider.user?.locationParts?['prov'];
      if (userProv != null && userProv.isNotEmpty) {
        return {'prov': userProv};
      }
    }
    return null; // national
  }

  // 거리 계산 (SharedMapBrowser에서 사용될 수도 있음)
  double _haversineKm(GeoPoint a, GeoPoint b) {
    const double p = 0.017453292519943295;
    final double c1 = math.cos((b.latitude - a.latitude) * p);
    final double c2 = math.cos(a.latitude * p) * math.cos(b.latitude * p);
    final double term =
        0.5 - c1 / 2 + c2 * (1 - math.cos((b.longitude - a.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(term));
  }

  List<RoomListingModel> _applyNearbyRadius(
    List<RoomListingModel> rooms,
    GeoPoint? userPoint,
    double radiusKm,
  ) {
    if (userPoint == null) return rooms;
    final filtered = <MapEntry<RoomListingModel, double>>[];
    for (final room in rooms) {
      final geo = room.geoPoint;
      if (geo == null) continue;
      final d = _haversineKm(userPoint, geo);
      if (d <= radiusKm) {
        filtered.add(MapEntry(room, d));
      }
    }
    filtered.sort((a, b) => a.value.compareTo(b.value));
    return filtered.map((e) => e.key).toList();
  }

  // 필터 개수 계산
  int _calculateFilterCount(RoomFilters filters) {
    int count = 0;
    if (filters.listingType != null) {
      count++;
    }
    if (filters.roomCount != null) {
      count++;
    }
    if (filters.bathroomCount != null) {
      count++;
    }
    if (filters.minPrice > 0 || filters.maxPrice < _categoryMaxPrice) {
      count++;
    }
    if (filters.minArea > 0 || filters.maxArea < _categoryMaxArea) {
      count++;
    }
    if (filters.minLandArea > 0 || filters.maxLandArea < _categoryMaxLandArea) {
      count++;
    }
    if (filters.furnishedStatus != null) {
      count++;
    }
    if (filters.propertyCondition != null) {
      count++;
    }
    if (filters.rentPeriod != null) {
      count++;
    }
    if (filters.depositMin > 0 || filters.depositMax < 1000000000) {
      count++;
    }
    if ((filters.floorInfoFilter ?? '').trim().isNotEmpty) {
      count++;
    }
    if (filters.kosBathroomType != null) {
      count++;
    }
    if (filters.isElectricityIncluded != null) {
      count++;
    }
    count += filters.kosRoomFacilities.length;
    count += filters.kosPublicFacilities.length;
    count += filters.apartmentFacilities.length;
    count += filters.houseFacilities.length;
    count += filters.commercialFacilities.length;
    return count;
  }

  // 필터 바텀 시트
  void _showFilterSheet() async {
    RoomFilters tempFilters = _activeFilters.copy();

    final RoomFilters? newFilters = await showModalBottomSheet<RoomFilters>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, controller) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text('realEstate.filter.title'.tr()),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                  body: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // 공통 필터 (가격, 면적 등)
                      _buildCommonFilters(setModalState, tempFilters),

                      // 카테고리별 특화 필터 (전체보기가 아닐 때만 표시)
                      if (_selectedCategory != 'all')
                        _buildSpecificFilters(setModalState, tempFilters),

                      _buildFurnishedStatusFilter(setModalState, tempFilters),
                      _buildPropertyConditionFilter(setModalState, tempFilters),
                    ],
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        TextButton(
                          child: Text('common.reset'.tr()),
                          onPressed: () => setModalState(() {
                            tempFilters.clear();
                            tempFilters.roomType = (_selectedCategory == 'all')
                                ? null
                                : _selectedCategory;
                            tempFilters.maxPrice = _categoryMaxPrice;
                            tempFilters.maxArea = _categoryMaxArea;
                            tempFilters.maxLandArea = _categoryMaxLandArea;
                          }),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          child: Text('common.apply'.tr()),
                          onPressed: () =>
                              Navigator.of(context).pop(tempFilters),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (newFilters != null) {
      setState(() {
        _activeFilters = newFilters;
        _filterCount = _calculateFilterCount(_activeFilters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // LocationProvider 구독
    final locationProvider = context.watch<LocationProvider>();
    final bool isNearbyMode =
        locationProvider.mode == LocationSearchMode.nearby;
    final GeoPoint? userPoint =
        locationProvider.user?.geoPoint ?? widget.userModel?.geoPoint;
    final double radiusKm = locationProvider.radiusKm;

    // 위치 필터 적용
    final Map<String, String?>? locationFilter =
        _buildLocationFilter(locationProvider);

    return Scaffold(
      // [수정] 메인 네비게이션과 중복되지 않도록 AppBar 최소화 또는 제거 가능하지만,
      // 여기서는 독립적인 화면으로서의 기능 유지를 위해 유지하되, 카테고리 칩과 통합 고려.
      // 보통 MainNavigationScreen에서 호출되므로 AppBar는 없음 (body만 리턴).
      // 하지만 Standalone 실행을 고려해 Scaffold 유지.
      body: Column(
        children: [
          // 1. 검색바 (InlineSearchChip)
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.realEstate'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () => setState(() {
                _showSearchBar = false;
                _searchKeywordNotifier.value = '';
              }),
            ),

          // 2. 상단 컨트롤 바 (카테고리 칩 + 필터 버튼 + 지도 토글)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // 카테고리 칩 리스트
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // '전체' 칩
                        _buildCategoryChip('all', 'common.all'.tr()),
                        // 나머지 카테고리 칩
                        ...AppCategories.realEstateCategories.map((cat) {
                          return _buildCategoryChip(
                              cat.categoryId, cat.nameKey.tr());
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 구분선
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                const SizedBox(width: 4),
                // 지도/리스트 토글
                IconButton(
                  // [수정] 지도 활성화 시 [X] 아이콘으로 변경 (UI/UX 통일)
                  icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
                  color: Theme.of(context).primaryColor,
                  tooltip: _isMapMode
                      ? 'common.closeMap'.tr()
                      : 'common.viewMap'.tr(),
                  onPressed: () => setState(() => _isMapMode = !_isMapMode),
                ),
              ],
            ),
          ),

          // 3. 필터 요약 및 버튼 (선택 사항 - 카테고리 바 아래에 배치)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // 위치 정보 표시 (Provider 연동)
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationProvider.displayTitle,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // 상세 필터 버튼
                Badge(
                  label: Text('$_filterCount'),
                  isLabelVisible: _filterCount > 0,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 32),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    icon: const Icon(Icons.tune, size: 16),
                    label: Text('common.filter'.tr(),
                        style: const TextStyle(fontSize: 13)),
                    onPressed: _showFilterSheet,
                  ),
                ),
              ],
            ),
          ),

          // 4. 메인 컨텐츠 (지도 또는 리스트)
          Expanded(
            child: _buildMainContent(
                isNearbyMode, userPoint, radiusKm, locationFilter),
          ),
        ],
      ),
      floatingActionButton: null, // FAB 제거 (등록 버튼은 하단 탭 또는 헤더로 이동됨)
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final bool isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected && _selectedCategory != id) {
            _onCategoryChanged(id);
          }
        },
        selectedColor: Theme.of(context).primaryColor.withAlpha(26),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor)
            : BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildMainContent(bool isNearbyMode, GeoPoint? userPoint,
      double radiusKm, Map<String, String?>? locationFilter) {
    // 스트림 생성 (카테고리 및 필터 적용됨)
    final stream = _repository
        .getRoomsStream(
          locationFilter: locationFilter,
          filters: _activeFilters, // _activeFilters 내부에 roomType이 포함됨
        )
        .map((rooms) => isNearbyMode
            ? _applyNearbyRadius(rooms, userPoint, radiusKm)
            : rooms);

    if (_isMapMode) {
      return SharedMapBrowser<RoomListingModel>(
        dataStream: stream,
        locationExtractor: (room) => room.geoPoint,
        idExtractor: (room) => room.id,
        titleExtractor: (room) =>
            legacyExtractTitle(room), // 개인정보 보호를 위한 Title 처리
        cardBuilder: (context, room) => RoomCard(room: room),
        thumbnailUrlExtractor: (room) =>
            (room.imageUrls.isNotEmpty) ? room.imageUrls.first : null,
        categoryIconExtractor: (room) {
          try {
            final cat = AppCategories.realEstateCategories.firstWhere(
                (c) => c.categoryId == room.type,
                orElse: () => AppCategories.realEstateCategories.first);
            return Text(cat.emoji, style: const TextStyle(fontSize: 14));
          } catch (_) {
            return null;
          }
        },
        initialCameraPosition: CameraPosition(
          target: userPoint != null
              ? LatLng(userPoint.latitude, userPoint.longitude)
              : const LatLng(-6.200000, 106.816666),
          zoom: 14,
        ),
      );
    } else {
      return StreamBuilder<List<RoomListingModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('realEstate.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }

          var rooms = snapshot.data ?? [];
          final kw = _searchKeywordNotifier.value;
          if (kw.isNotEmpty) {
            rooms = rooms
                .where((r) =>
                    (("${r.title} ${r.description} ${r.tags.join(' ')}")
                        .toLowerCase()
                        .contains(kw)))
                .toList();
          }

          if (rooms.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // 하단 탭 가림 방지
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return RoomCard(room: rooms[index]);
            },
          );
        },
      );
    }
  }

  Widget _buildEmptyState() {
    final isNational =
        context.read<LocationProvider>().mode == LocationSearchMode.national;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.house_siding_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('realEstate.empty'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[600])),
            if (!isNational) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: Text('search.empty.expandToNational'.tr()),
                onPressed: () => context
                    .read<LocationProvider>()
                    .setMode(LocationSearchMode.national),
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- 필터 빌더 메서드들 (기존 로직 재사용) ---

  Widget _buildCommonFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.form.listingType'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        Wrap(
            spacing: 8.0,
            children: ['rent', 'sale'].map((type) {
              return ChoiceChip(
                label: Text('realEstate.form.listingTypes.$type'.tr()),
                selected: tempFilters.listingType == type,
                onSelected: (selected) => setModalState(
                    () => tempFilters.listingType = selected ? type : null),
              );
            }).toList()),
        const Divider(height: 32),
        Text('realEstate.filter.priceRange'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        RangeSlider(
          values: RangeValues(tempFilters.minPrice, tempFilters.maxPrice),
          min: 0,
          max: _categoryMaxPrice,
          divisions: 50,
          labels: RangeLabels(
            NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                .format(tempFilters.minPrice),
            NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                .format(tempFilters.maxPrice),
          ),
          onChanged: (values) => setModalState(() {
            tempFilters.minPrice = values.start;
            tempFilters.maxPrice = values.end;
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rp 0", style: Theme.of(context).textTheme.bodySmall),
            Text(
                NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                    .format(_categoryMaxPrice),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSpecificFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    switch (_selectedCategory) {
      case 'kos':
        return _buildKosFilters(setModalState, tempFilters);
      case 'apartment':
        return _buildApartmentFilters(setModalState, tempFilters);
      case 'house':
      case 'kontrakan':
        return _buildHouseFilters(setModalState, tempFilters);
      case 'ruko':
      case 'kantor':
      case 'gudang':
        return _buildCommercialFilters(setModalState, tempFilters);
      default:
        return const SizedBox.shrink();
    }
  }

  // (아래 필터 메서드들은 기존 room_list_screen.dart와 동일하되, 컨텍스트에 맞게 재배치됨)
  Widget _buildKosFilters(StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.kos.bathroomType'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        Wrap(
            spacing: 8.0,
            children: ['in_room', 'out_room'].map((type) {
              return ChoiceChip(
                label: Text('realEstate.filter.kos.bathroomTypes.$type'.tr()),
                selected: tempFilters.kosBathroomType == type,
                onSelected: (selected) => setModalState(
                    () => tempFilters.kosBathroomType = selected ? type : null),
              );
            }).toList()),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('realEstate.filter.kos.electricityIncluded'.tr()),
          value: tempFilters.isElectricityIncluded ?? false,
          onChanged: (value) =>
              setModalState(() => tempFilters.isElectricityIncluded = value),
        ),
        const Divider(height: 32),
        Text('realEstate.filter.kos.roomFacilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
            setModalState,
            "kos_room",
            RealEstateFacilities.kosRoomFacilities,
            tempFilters.kosRoomFacilities),
        const SizedBox(height: 16),
        Text('realEstate.filter.kos.publicFacilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
            setModalState,
            "kos_public",
            RealEstateFacilities.kosPublicFacilities,
            tempFilters.kosPublicFacilities),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildApartmentFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.apartment.facilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
            setModalState,
            "apartment",
            RealEstateFacilities.apartmentFacilities,
            tempFilters.apartmentFacilities),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildHouseFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.house.facilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(setModalState, "house",
            RealEstateFacilities.houseFacilities, tempFilters.houseFacilities),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildCommercialFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("realEstate.filter.commercial.facilities".tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
            setModalState,
            "commercial",
            RealEstateFacilities.commercialFacilities,
            tempFilters.commercialFacilities),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildFurnishedStatusFilter(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.furnishedStatus'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        Wrap(
            spacing: 8.0,
            children:
                ['furnished', 'semi_furnished', 'unfurnished'].map((status) {
              return ChoiceChip(
                label: Text('realEstate.filter.furnishedTypes.$status'.tr()),
                selected: tempFilters.furnishedStatus == status,
                onSelected: (selected) => setModalState(() =>
                    tempFilters.furnishedStatus = selected ? status : null),
              );
            }).toList()),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildPropertyConditionFilter(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.propertyCondition'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        Wrap(
            spacing: 8.0,
            children: ['new', 'used'].map((status) {
              return ChoiceChip(
                label:
                    Text('realEstate.filter.propertyConditions.$status'.tr()),
                selected: tempFilters.propertyCondition == status,
                onSelected: (selected) => setModalState(() =>
                    tempFilters.propertyCondition = selected ? status : null),
              );
            }).toList()),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildFacilityChips(StateSetter setModalState, String i18nPrefix,
      List<String> facilityKeys, Set<String> selectedFacilities) {
    return Wrap(
      spacing: 8.0,
      children: facilityKeys.map((key) {
        return FilterChip(
          label: Text('realEstate.filter.amenities.$i18nPrefix.$key'.tr()),
          selected: selectedFacilities.contains(key),
          onSelected: (selected) => setModalState(() {
            if (selected) {
              selectedFacilities.add(key);
            } else {
              selectedFacilities.remove(key);
            }
          }),
        );
      }).toList(),
    );
  }
}

// ===================== DocHeader =====================
// [기획 요약]
// - V2.0: 매물 목록 및 상세 필터 화면. 'rumah123' 벤치마킹.
// - 'roomType'별로 필터 UI와 필터 범위를 동적으로 제공.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 6) 필터 로직 전면 수정: 기존 '주거용'/'상업용' 2분할 로직 폐기.
//    `widget.roomType`에 따른 `switch` 문을 도입하여 `_buildKosFilters`, `_buildApartmentFilters` 등
//    타입별 전용 필터 UI를 동적으로 빌드하도록 변경.
// 2. (Task 13) 'Kos' 전용 필터(욕실 타입, 전기세 등) 및 공통 필터(가구, 매물 상태) UI 추가.
// 3. (Task 20) `initState`에서 `_getDefaultsForRoomType`을 호출하여 'Kos', 'House' 등
//    타입별로 `_categoryMaxPrice`, `_categoryMaxArea` 등 동적 최대값을 설정.
// 4. (Task 20) `RangeSlider` UI 수정: 테마 기본 색상(무채색)을 사용하고,
//    슬라이더 양옆에 Min/Max 텍스트 라벨을 표시하도록 UI 개선.
// =====================================================
// lib/features/real_estate/screens/room_list_screen.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/constants/real_estate_facilities.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

/// [수정] 'rumah123' 모델에 따라 타입별 상세 필터를 제공하는 화면입니다.
/// 실제 매물 목록을 보여주고 상세 필터링하는 화면입니다.
/// (기존 real_estate_screen.dart의 로직을 이전)
class RoomListScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final String? roomType; // [필수] 'kos', 'apartment' 등
  final ValueNotifier<bool>? searchNotifier;

  const RoomListScreen({
    super.key,
    this.userModel,
    this.locationFilter,
    this.searchNotifier,
    required this.roomType,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final RoomRepository _repository = RoomRepository();

  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');

  bool _isMapMode = false;
  bool _showSearchBar = false;

  // '직방' 상세 필터 상태
  late RoomFilters _activeFilters;
  int _filterCount = 0; // 적용된 필터 개수

  // [신규] '작업 20': 카테고리별 동적 최대값
  late double _categoryMaxPrice;
  late double _categoryMaxArea;
  late double _categoryMaxLandArea;

  @override
  void initState() {
    super.initState();
    // [수정] '작업 20': roomType에 따라 동적 기본값 설정
    final defaults = _getDefaultsForRoomType(widget.roomType);
    _categoryMaxPrice = defaults.maxPrice;
    _categoryMaxArea = defaults.maxArea;
    _categoryMaxLandArea = defaults.maxLandArea;

    _activeFilters = RoomFilters(
      roomType: widget.roomType,
      maxPrice: _categoryMaxPrice, // 모델 기본값 대신 카테고리 최대값 사용
      maxArea: _categoryMaxArea,
      maxLandArea: _categoryMaxLandArea,
    );
    _filterCount = _calculateFilterCount(_activeFilters);

    _searchKeywordNotifier.addListener(_onKeywordChanged);
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
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

  /// [신규] '작업 20': roomType별 기본 최대값 반환
  ({double maxPrice, double maxArea, double maxLandArea})
      _getDefaultsForRoomType(String? roomType) {
    switch (roomType) {
      case 'kos':
        return (maxPrice: 50000000, maxArea: 100, maxLandArea: 300); // 5천만
      case 'apartment':
        return (maxPrice: 3000000000, maxArea: 300, maxLandArea: 500); // 30억
      case 'house':
      case 'kontrakan':
        return (
          maxPrice: 10000000000,
          maxArea: 1000,
          maxLandArea: 5000
        ); // 100억
      default: // ruko, kantor, gudang, etc
        return (
          maxPrice: 20000000000,
          maxArea: 5000,
          maxLandArea: 10000
        ); // 200억
    }
  }

  void _onKeywordChanged() {
    if (mounted) setState(() {});
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

  // '직방' 상세 필터 BottomSheet 표시
  void _showFilterSheet() async {
    // [작업 30 수정] tempFilters를 StatefulBuilder 밖에서 생성
    RoomFilters tempFilters = _activeFilters.copy();

    final RoomFilters? newFilters = await showModalBottomSheet<RoomFilters>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
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
                      // [신규] roomType별로 공통+특화 필터를 순서대로 렌더링
                      Builder(builder: (context) {
                        final commonFilters =
                            _buildCommonFilters(setModalState, tempFilters);
                        final specificFilters =
                            _buildSpecificFilters(setModalState, tempFilters);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonFilters,
                            specificFilters,
                            _buildFurnishedStatusFilter(
                                setModalState, tempFilters),
                            _buildPropertyConditionFilter(
                                setModalState, tempFilters),
                          ],
                        );
                      }),

                      const Divider(height: 32),

                      // [수정] 카테고리(roomType)는 이미 선택되었으므로 필터에서 비활성화(읽기 전용)
                      Text('realEstate.form.typeLabel'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          'kos',
                          'apartment',
                          'kontrakan',
                          'house', // [추가]
                          'ruko',
                          'kantor',
                          'etc'
                        ].map((type) {
                          return ChoiceChip(
                            label: Text('realEstate.form.roomTypes.$type'.tr()),
                            selected: tempFilters.roomType == type,
                            // 이미 선택된 카테고리는 변경 불가 (선택 효과 없음)
                            onSelected: (selected) {},
                          );
                        }).toList(),
                      ),
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
                            // [수정] '작업 20': 카테고리별 동적 기본값으로 리셋
                            tempFilters.roomType = widget.roomType;
                            tempFilters.maxPrice = _categoryMaxPrice;
                            tempFilters.maxArea = _categoryMaxArea;
                            tempFilters.maxLandArea = _categoryMaxLandArea;
                          }),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          child: Text('common.apply'.tr()),
                          onPressed: () =>
                              Navigator.of(context).pop(tempFilters), // 적용
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
        // [작업 29 수정] 필터 개수 계산 로직 적용
        _filterCount = _calculateFilterCount(_activeFilters);
      });
    }
  }

  // [작업 29] 활성화된 필터 개수를 계산하는 함수
  int _calculateFilterCount(RoomFilters filters) {
    int count = 0;
    // roomType은 기본 필터이므로 카운트에서 제외
    // 공통
    if (filters.listingType != null) count++; // 임대/매매
    if (filters.roomCount != null) count++; // 침실
    if (filters.bathroomCount != null) count++; // 욕실
    // [수정] '작업 20': 카테고리 최대값 기준 비교
    if (filters.minPrice > 0 || filters.maxPrice < _categoryMaxPrice) count++;
    if (filters.minArea > 0 || filters.maxArea < _categoryMaxArea) count++;
    if (filters.minLandArea > 0 || filters.maxLandArea < _categoryMaxLandArea) {
      count++;
    }
    if (filters.furnishedStatus != null) count++; // 가구
    if (filters.propertyCondition != null) count++; // 매물상태

    // 임대용
    if (filters.rentPeriod != null) count++; // 임대기간

    // 상업용
    // [수정] '작업 20': 보증금 최대값 10억
    if (filters.depositMin > 0 || filters.depositMax < 1000000000) {
      count++; // 보증금
    }
    if ((filters.floorInfoFilter ?? '').trim().isNotEmpty) count++; // 층수정보

    // Kos
    if (filters.kosBathroomType != null) count++;
    if (filters.isElectricityIncluded != null) count++;
    count += filters.kosRoomFacilities.length;
    count += filters.kosPublicFacilities.length;

    // 기타 타입
    count += filters.apartmentFacilities.length;
    count += filters.houseFacilities.length;
    count += filters.commercialFacilities.length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 'Kos', 'Apartment' 등 카테고리 이름 표시
        title: Text('realEstate.form.roomTypes.${widget.roomType}'.tr()),
        actions: [
          IconButton(
            icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
            onPressed: () => setState(() => _isMapMode = !_isMapMode),
            tooltip:
                _isMapMode ? 'common.closeMap'.tr() : 'common.viewMap'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          // InlineSearchChip (기존 real_estate_screen.dart와 동일)
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

          // '직방' 상세 필터 버튼 (기존 real_estate_screen.dart와 동일)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Badge(
                  label: Text('$_filterCount'),
                  isLabelVisible: _filterCount > 0,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: Text('common.filter'.tr()),
                    onPressed: _showFilterSheet,
                  ),
                ),
              ],
            ),
          ),

          // 매물 목록: 지도 모드일 때는 SharedMapBrowser 사용
          Expanded(
            child: _isMapMode
                ? SharedMapBrowser<RoomListingModel>(
                    dataStream: _repository.getRoomsStream(
                      locationFilter: widget.locationFilter,
                      filters: _activeFilters,
                    ),
                    locationExtractor: (room) => room.geoPoint,
                    idExtractor: (room) => room.id,
                    cardBuilder: (context, room) => RoomCard(room: room),
                    initialCameraPosition: widget.userModel?.geoPoint != null
                        ? CameraPosition(
                            target: LatLng(widget.userModel!.geoPoint!.latitude,
                                widget.userModel!.geoPoint!.longitude),
                            zoom: 14)
                        : null,
                  )
                : StreamBuilder<List<RoomListingModel>>(
                    stream: _repository.fetchRooms(
                      locationFilter: widget.locationFilter,
                      filters: _activeFilters,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'realEstate.error'.tr(namedArgs: {
                              'error': snapshot.error.toString()
                            }),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('realEstate.empty'.tr(),
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
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                      icon: const Icon(Icons.map_outlined),
                                      label: Text(
                                          'search.empty.expandToNational'.tr()),
                                      onPressed: () => context
                                          .read<LocationProvider>()
                                          .setMode(
                                              LocationSearchMode.national)),
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
                                Text('realEstate.empty'.tr(),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      }

                      var rooms = snapshot.data!;
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
                                  Icon(Icons.search_off,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text('realEstate.empty'.tr(),
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
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                      icon: const Icon(Icons.map_outlined),
                                      label: Text(
                                          'search.empty.expandToNational'.tr()),
                                      onPressed: () => context
                                          .read<LocationProvider>()
                                          .setMode(
                                              LocationSearchMode.national)),
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
                                Text('realEstate.empty'.tr(),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomCard(room: room);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // [작업 25 수정] FAB 삭제
      floatingActionButton: null,
    );
  }

  // [신규] Task 38: 공통 필터 (가격, 면적, 거래유형)
  Widget _buildCommonFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 매물 유형 (임대/매매) ---
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
          }).toList(),
        ),
        const Divider(height: 32),

        // --- 가격 범위 ---
        Text('realEstate.filter.priceRange'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        RangeSlider(
          values: RangeValues(tempFilters.minPrice, tempFilters.maxPrice),
          min: 0,
          max: _categoryMaxPrice, // [수정] 동적 최대값
          divisions: 50, // 50 구간
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
        // [신규] '작업 20': 슬라이더 Min/Max 텍스트
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

        // --- 면적 범위 ---
        Text('realEstate.filter.areaRange'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        RangeSlider(
          values: RangeValues(tempFilters.minArea, tempFilters.maxArea),
          min: 0,
          max: _categoryMaxArea, // [수정] 동적 최대값
          divisions: 20, // 20 구간
          labels: RangeLabels('${tempFilters.minArea.round()} m²',
              '${tempFilters.maxArea.round()} m²'),
          onChanged: (values) => setModalState(() {
            tempFilters.minArea = values.start;
            tempFilters.maxArea = values.end;
          }),
        ),
        // [신규] '작업 20': 슬라이더 Min/Max 텍스트
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("0 m²", style: Theme.of(context).textTheme.bodySmall),
            Text("${_categoryMaxArea.round()} m²",
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const Divider(height: 32),

        // --- 임대 기간 (listingType이 'rent'일 때만) ---
        if (tempFilters.listingType == 'rent') ...[
          const SizedBox(height: 8),
          Text('realEstate.filter.rentPeriod'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8.0,
            children: ['daily', 'monthly', 'yearly'].map((period) {
              return ChoiceChip(
                label: Text('realEstate.filter.rentPeriods.$period').tr(),
                selected: tempFilters.rentPeriod == period,
                onSelected: (selected) => setModalState(
                    () => tempFilters.rentPeriod = selected ? period : null),
              );
            }).toList(),
          ),
          const Divider(height: 32),
        ],

        // --- 토지 면적 (Kos 제외) ---
        if (widget.roomType != 'kos') ...[
          Text('realEstate.filter.landAreaRange'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values:
                RangeValues(tempFilters.minLandArea, tempFilters.maxLandArea),
            min: 0,
            max: _categoryMaxLandArea, // [수정] 동적 최대값
            divisions: 20,
            labels: RangeLabels('${tempFilters.minLandArea.round()} m²',
                '${tempFilters.maxLandArea.round()} m²'),
            onChanged: (values) => setModalState(() {
              tempFilters.minLandArea = values.start;
              tempFilters.maxLandArea = values.end;
            }),
          ),
          // [신규] '작업 20': 슬라이더 Min/Max 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0 m²", style: Theme.of(context).textTheme.bodySmall),
              Text("${_categoryMaxLandArea.round()} m²",
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Divider(height: 32),
        ],

        // --- 방/욕실 수 (Kos 제외) ---
        if (widget.roomType != 'kos') ...[
          Text('realEstate.form.rooms'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8.0,
            children: [1, 2, 3, 4].map((roomCountValue) {
              return ChoiceChip(
                label: Text(roomCountValue == 4 ? '4+' : '$roomCountValue'),
                selected: tempFilters.roomCount == roomCountValue,
                onSelected: (selected) => setModalState(() =>
                    tempFilters.roomCount = selected ? roomCountValue : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('realEstate.form.bathrooms'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 8.0,
            children: [1, 2, 3, 4].map((count) {
              return ChoiceChip(
                label: Text(count == 4 ? '4+' : '$count'),
                selected: tempFilters.bathroomCount == count,
                onSelected: (selected) => setModalState(
                    () => tempFilters.bathroomCount = selected ? count : null),
              );
            }).toList(),
          ),
          const Divider(height: 32),
        ],
      ],
    );
  }

  // [신규] 타입별 특화 필터 빌더
  Widget _buildSpecificFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    switch (widget.roomType) {
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

  // [신규] 'Kos' (방 임대) 전용 필터
  Widget _buildKosFilters(StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 욕실 타입 ---
        Text('realEstate.filter.kos.bathroomType'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8.0,
          children: ['in_room', 'out_room'].map((type) {
            return ChoiceChip(
              label: Text('realEstate.filter.kos.bathroomTypes.$type').tr(),
              selected: tempFilters.kosBathroomType == type,
              onSelected: (selected) => setModalState(
                  () => tempFilters.kosBathroomType = selected ? type : null),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // --- 전기세 포함 ---
        SwitchListTile(
          title: Text('realEstate.filter.kos.electricityIncluded'.tr()),
          value: tempFilters.isElectricityIncluded ?? false,
          onChanged: (value) =>
              setModalState(() => tempFilters.isElectricityIncluded = value),
        ),
        const Divider(height: 32),

        // --- 방 시설 ---
        Text('realEstate.filter.kos.roomFacilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
          setModalState,
          "kos_room", // [신규] JSON 키 접두사
          RealEstateFacilities.kosRoomFacilities, // 'ac', 'bed', 'closet' 등
          tempFilters.kosRoomFacilities,
        ),
        const Divider(height: 32),

        // --- 공용 시설 ---
        Text('realEstate.filter.kos.publicFacilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
          setModalState,
          "kos_public", // [신규] JSON 키 접두사
          RealEstateFacilities
              .kosPublicFacilities, // 'kitchen', 'living_room' 등
          tempFilters.kosPublicFacilities,
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [수정] 'Apartment' 전용 필터
  Widget _buildApartmentFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 아파트 시설 ---
        Text('realEstate.filter.apartment.facilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
          setModalState,
          "apartment", // [신규] JSON 키 접두사
          RealEstateFacilities
              .apartmentFacilities, // 'pool', 'gym', 'security' 등
          tempFilters.apartmentFacilities,
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [신규] 'Rumah' (주택) 전용 필터
  Widget _buildHouseFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 주택 시설 ---
        Text('realEstate.filter.house.facilities'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
          setModalState,
          "house", // [신규] JSON 키 접두사
          RealEstateFacilities.houseFacilities, // 'carport', 'garden', 'pam' 등
          tempFilters.houseFacilities,
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [신규] Task 38: 상업용 필터 (Ruko, Kantor)
  Widget _buildCommercialFilters(
      StateSetter setModalState, RoomFilters tempFilters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [신규] '작업 26': Copilot이 지적한 누락된 상업용 시설 블록 추가
        // --- 상업용 시설 ---
        Text("realEstate.filter.commercial.facilities".tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildFacilityChips(
          setModalState,
          "commercial", // JSON 키 접두사
          RealEstateFacilities
              .commercialFacilities, // 'parking_area', 'security_24h' 등
          tempFilters.commercialFacilities,
        ),
        const Divider(height: 32),

        // --- 보증금 범위 ---
        Text('realEstate.filter.depositRange'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        RangeSlider(
          values: RangeValues(tempFilters.depositMin, tempFilters.depositMax),
          min: 0,
          max: 1000000000, // [수정] '작업 20': 1 Miliar (10억)
          divisions: 50,
          labels: RangeLabels(
            NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                .format(tempFilters.depositMin),
            NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                .format(tempFilters.depositMax),
          ),
          onChanged: (values) => setModalState(() {
            tempFilters.depositMin = values.start;
            tempFilters.depositMax = values.end;
          }),
        ),
        // [신규] '작업 20': 슬라이더 Min/Max 텍스트
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rp 0", style: Theme.of(context).textTheme.bodySmall),
            Text(
                NumberFormat.compactSimpleCurrency(locale: 'id_ID')
                    .format(1000000000),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey(
                    'depositMin_${tempFilters.depositMin.toStringAsFixed(0)}'),
                initialValue: tempFilters.depositMin.round().toString(),
                decoration: InputDecoration(
                  labelText: 'realEstate.filter.depositMin'.tr(),
                  suffixText: 'Rp',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setModalState(() {
                  final v = double.tryParse(value) ?? 0;
                  // [수정] '작업 20': 최대값 변경
                  final clamped = v.clamp(0, 1000000000).toDouble();
                  tempFilters.depositMin = clamped <= tempFilters.depositMax
                      ? clamped
                      : tempFilters.depositMax;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: ValueKey(
                    'depositMax_${tempFilters.depositMax.toStringAsFixed(0)}'),
                initialValue: tempFilters.depositMax.round().toString(),
                decoration: InputDecoration(
                  labelText: 'realEstate.filter.depositMax'.tr(),
                  suffixText: 'Rp',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setModalState(() {
                  final v = double.tryParse(value) ?? 0;
                  // [수정] '작업 20': 최대값 변경
                  final clamped = v.clamp(0, 1000000000).toDouble();
                  tempFilters.depositMax = clamped >= tempFilters.depositMin
                      ? clamped
                      : tempFilters.depositMin;
                }),
              ),
            ),
          ],
        ),
        const Divider(height: 32),

        // --- 층수/층 정보 텍스트 ---
        Text('realEstate.filter.floorInfo'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'realEstate.form.floorInfoHint'.tr(),
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: (tempFilters.floorInfoFilter ?? '').trim().isEmpty
                ? null
                : IconButton(
                    tooltip: 'realEstate.filter.clearFloorInfo'.tr(),
                    icon: const Icon(Icons.clear),
                    onPressed: () => setModalState(() {
                      tempFilters.floorInfoFilter = '';
                    }),
                  ),
          ),
          key: ValueKey('floor_${(tempFilters.floorInfoFilter ?? '')}'),
          initialValue: tempFilters.floorInfoFilter ?? '',
          onChanged: (value) => setModalState(() {
            tempFilters.floorInfoFilter = value;
          }),
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [신규] '가구 상태' 필터 (공통)
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
              onSelected: (selected) => setModalState(
                  () => tempFilters.furnishedStatus = selected ? status : null),
            );
          }).toList(),
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [신규] '매물 상태' 필터 (공통)
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
              label: Text('realEstate.filter.propertyConditions.$status').tr(),
              selected: tempFilters.propertyCondition == status,
              onSelected: (selected) => setModalState(() =>
                  tempFilters.propertyCondition = selected ? status : null),
            );
          }).toList(),
        ),
        const Divider(height: 32),
      ],
    );
  }

  // [신규] 시설 선택 칩 위젯 (재사용)
  Widget _buildFacilityChips(
      StateSetter setModalState,
      String i18nPrefix, // [수정] JSON 키 접두사
      List<String> facilityKeys,
      Set<String> selectedFacilities) {
    return Wrap(
      spacing: 8.0,
      children: facilityKeys.map((key) {
        return FilterChip(
          // [수정] 올바른 JSON 키 구조 (예: amenities.kos_room.ac)
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

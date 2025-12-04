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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/screens/room_list_screen.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapMode = false; // [추가] 지도 모드 토글

  @override
  void initState() {
    super.initState();
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
    _searchKeywordNotifier.addListener(_onKeywordChanged);
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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'type': 'kos',
        'icon': Icons.night_shelter_outlined,
        'labelKey': 'realEstate.form.roomTypes.kos'
      },
      {
        'type': 'apartment',
        'icon': Icons.apartment_outlined,
        'labelKey': 'realEstate.form.roomTypes.apartment'
      },
      {
        'type': 'kontrakan',
        'icon': Icons.house_siding_outlined,
        'labelKey': 'realEstate.form.roomTypes.kontrakan'
      },
      {
        'type': 'house',
        'icon': Icons.house_outlined,
        'labelKey': 'realEstate.form.roomTypes.house'
      },
      {
        'type': 'ruko',
        'icon': Icons.storefront_outlined,
        'labelKey': 'realEstate.form.roomTypes.ruko'
      },
      {
        'type': 'gudang',
        'icon': Icons.warehouse_outlined,
        'labelKey': 'realEstate.form.roomTypes.gudang'
      },
      {
        'type': 'kantor',
        'icon': Icons.business_center_outlined,
        'labelKey': 'realEstate.form.roomTypes.kantor'
      },
      {
        'type': 'etc',
        'icon': Icons.more_horiz_outlined,
        'labelKey': 'realEstate.form.roomTypes.etc'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        // [수정] 메인 타이틀('Ibu Kost') 중복 방지
        // 대신 지도 보기 기능을 안내하는 힌트 텍스트를 표시
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'realEstate.viewMapHint'.tr(), // "지도에서 전체 매물 확인하기"
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // [수정] 지도 아이콘이 X(닫기) 버튼으로 토글됨
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
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.realEstate'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          Expanded(
            child: _isMapMode
                ? SharedMapBrowser<RoomListingModel>(
                    // When opening the full-map view from the launcher, pass
                    // explicit nulls so the map shows ALL available listings
                    // independent of the launcher context's filters.
                    dataStream: RoomRepository().getRoomsStream(
                      locationFilter: null,
                      // [중요] 필터 간섭 방지를 위해 명시적으로 null 전달
                      filters: null,
                    ),
                    locationExtractor: (room) => room.geoPoint,
                    idExtractor: (room) => room.id,
                    titleExtractor: (room) =>
                        (room as dynamic).title ?? (room as dynamic).name,
                    cardBuilder: (context, room) => RoomCard(room: room),
                    initialCameraPosition: widget.userModel?.geoPoint != null
                        ? CameraPosition(
                            target: LatLng(widget.userModel!.geoPoint!.latitude,
                                widget.userModel!.geoPoint!.longitude),
                            zoom: 14)
                        : null,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(
                        context,
                        icon: category['icon'] as IconData,
                        label: (category['labelKey'] as String).tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RoomListScreen(
                                userModel: widget.userModel,
                                locationFilter: widget.locationFilter,
                                roomType: category['type'] as String,
                                searchNotifier: widget.searchNotifier,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'realEstate.disclaimer'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600], height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore room_listings 컬렉션 구조와 1:1 매칭, 이미지, 가격, 편의시설 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/가격/편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// - 임대인/임차인 모두를 위한 UX 개선(채팅/알림/편의시설 등).
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 22) '직방' 핵심 필터 (Gap 2) 구현.
// 2. 'RoomFilters' (신규 모델) 상태 변수 추가.
// 3. '_showFilterSheet': '가격', '면적', '방 개수', '매물 유형' 등 상세 필터를 설정하는 BottomSheet UI 구현.
// 4. 'StreamBuilder': 'fetchRooms' 호출 시 'RoomFilters'를 전달하여 상세 필터링된 목록을 표시.
// 5. (Task 24) [버그 수정] 'RoomFilters' 클래스를 외부 파일로 분리하여 순환 참조 에러 해결.
// 6. (Task 25, 27) [UI 정리] 중복되는 'FloatingActionButton' 및 구(舊) 위치 필터(_openFilter) 코드 제거.
// 7. (Task 26) [버그 수정] 'easy_localization' 번역 키 누락으로 인한 '_Map' 타입 에러 (JSON 파일 수정 필요).
// =====================================================
// lib/features/real_estate/screens/real_estate_screen.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart'; // [추가] 순환 참조 해결

// [수정] StatelessWidget -> StatefulWidget으로 변경
class RealEstateScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const RealEstateScreen(
      {this.userModel,
      this.locationFilter, // [추가]
      this.autoFocusSearch = false,
      this.searchNotifier,
      super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  // [추가] '직방' 상세 필터 상태
  RoomFilters _activeFilters = RoomFilters();
  int _filterCount = 0; // 적용된 필터 개수

  @override
  void initState() {
    super.initState();

    // 전역 검색 시트에서 진입한 경우 자동 표시 + 포커스
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // 피드 내부 하단 검색 아이콘 → 검색칩 열기
    if (widget.searchNotifier != null) {
      _externalSearchListener = () {
        if (widget.searchNotifier!.value == AppSection.realEstate) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }
  }

  int _calculateFilterCount(RoomFilters filters) {
    int count = 0;

    // 기본값이 아닌 경우 카운트 증가
    if (filters.listingType != null) count++;
    if (filters.roomType != null) count++;
    if (filters.roomCount != null) count++;
    // 가격 범위가 기본값(0 ~ 50M)이 아닌 경우
    if (filters.minPrice > 0 || filters.maxPrice < 50000000) count++;
    // 면적 범위가 기본값(0 ~ 100)이 아닌 경우
    if (filters.minArea > 0 || filters.maxArea < 100) count++;

    return count;
  }

  // ✅ 메모리 누수 방지를 위해 리스너/노티파이어 정리
  @override
  void dispose() {
    if (widget.searchNotifier != null && _externalSearchListener != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.dispose();
    super.dispose();
  }

  // [추가] '직방' 상세 필터 BottomSheet 표시
  void _showFilterSheet() async {
    // [수정] tempFilters를 StatefulBuilder 밖에서 '먼저' 생성합니다.
    // 이렇게 하면 setModalState가 호출되어도 tempFilters가 리셋되지 않습니다.
    RoomFilters tempFilters = _activeFilters.copy();

    final RoomFilters? newFilters = await showModalBottomSheet<RoomFilters>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8, // 시트 높이
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
                      // --- 매물 유형 (임대/매매) ---
                      Text('realEstate.form.listingType'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8.0,
                        children: ['rent', 'sale'].map((type) {
                          return ChoiceChip(
                            label:
                                Text('realEstate.form.listingTypes.$type'.tr()),
                            selected: tempFilters.listingType == type,
                            onSelected: (selected) => setModalState(() =>
                                tempFilters.listingType =
                                    selected ? type : null),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 32),

                      // --- 방 유형 (Kos/Kontrakan/Sewa) ---
                      Text('realEstate.form.typeLabel'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8.0,
                        children: ['kos', 'kontrakan', 'sewa'].map((type) {
                          return ChoiceChip(
                            label: Text('realEstate.form.roomTypes.$type'.tr()),
                            selected: tempFilters.roomType == type,
                            onSelected: (selected) => setModalState(() =>
                                tempFilters.roomType = selected ? type : null),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 32),

                      // --- 가격 범위 ---
                      Text('realEstate.filter.priceRange'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      RangeSlider(
                        values: RangeValues(
                            tempFilters.minPrice, tempFilters.maxPrice),
                        min: 0,
                        max: 50000000, // 50 Juta
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
                      const Divider(height: 32),

                      // --- 면적 범위 ---
                      Text('realEstate.filter.areaRange'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      RangeSlider(
                        values: RangeValues(
                            tempFilters.minArea, tempFilters.maxArea),
                        min: 0,
                        max: 100, // 100 m²
                        divisions: 20,
                        labels: RangeLabels('${tempFilters.minArea.round()} m²',
                            '${tempFilters.maxArea.round()} m²'),
                        onChanged: (values) => setModalState(() {
                          tempFilters.minArea = values.start;
                          tempFilters.maxArea = values.end;
                        }),
                      ),
                      const Divider(height: 32),

                      // --- 방 개수 ---
                      Text('realEstate.form.rooms'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8.0,
                        children: [1, 2, 3, 4].map((count) {
                          // 4는 4+
                          return ChoiceChip(
                            label: Text(count == 4 ? '4+' : '$count'),
                            selected: tempFilters.roomCount == count,
                            onSelected: (selected) => setModalState(() =>
                                tempFilters.roomCount =
                                    selected ? count : null),
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
                          onPressed: () =>
                              setModalState(() => tempFilters.clear()),
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
        _filterCount = _calculateFilterCount(_activeFilters);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final RoomRepository roomRepository = RoomRepository();

    return Scaffold(
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
          // 위치 필터 UI는 메인 네비게이션(AppBar)에서 처리합니다.
          // [추가] '직방' 상세 필터 버튼
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 상세 필터 버튼
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
          Expanded(
            child: StreamBuilder<List<RoomListingModel>>(
              // [수정] 활성화된 필터를 Stream에 전달
              stream: roomRepository.fetchRooms(
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
                      'realEstate.error'
                          .tr(namedArgs: {'error': snapshot.error.toString()}),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('realEstate.empty'.tr()));
                }

                var rooms = snapshot.data!;
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  rooms = rooms
                      .where((r) =>
                          (('${r.title} ${r.description} ${r.amenities.join(' ')} ${r.tags.join(' ')}')
                              .toLowerCase()
                              .contains(kw)))
                      .toList();
                }

                if (rooms.isEmpty) {
                  return Center(child: Text('realEstate.empty'.tr()));
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
      floatingActionButton: null,
    );
  }
}

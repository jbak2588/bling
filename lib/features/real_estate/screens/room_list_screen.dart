// lib/features/real_estate/screens/room_list_screen.dart
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/models/room_filters_model.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// '직방' 모델의 카테고리(예: 'Kos')를 선택한 후,
/// 실제 매물 목록을 보여주고 상세 필터링하는 화면입니다.
/// (기존 real_estate_screen.dart의 로직을 이전)
class RoomListScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final String? roomType; // [필수] 'kos', 'apartment' 등

  const RoomListScreen({
    super.key,
    this.userModel,
    this.locationFilter,
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

  // '직방' 상세 필터 상태
  late RoomFilters _activeFilters;
  int _filterCount = 0; // 적용된 필터 개수

  @override
  void initState() {
    super.initState();
    // 부모(런처)로부터 받은 roomType으로 필터 초기화
    _activeFilters = RoomFilters(roomType: widget.roomType);
    _filterCount = _calculateFilterCount(_activeFilters);

    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
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
                      // [수정] 카테고리(roomType)는 이미 선택되었으므로 필터에서 비활성화(읽기 전용)
                      Text('realEstate.form.typeLabel'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          'kos',
                          'apartment',
                          'kontrakan',
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
                      const Divider(height: 32),

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
                        children: [1, 2, 3, 4].map((roomCountValue) {
                          // 4는 4+
                          return ChoiceChip(
                            label: Text(
                                roomCountValue == 4 ? '4+' : '$roomCountValue'),
                            selected: tempFilters.roomCount == roomCountValue,
                            onSelected: (selected) => setModalState(() =>
                                tempFilters.roomCount =
                                    selected ? roomCountValue : null),
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
                            // [수정] roomType은 리셋되면 안 됨
                            tempFilters.roomType = widget.roomType;
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
    if (filters.listingType != null) count++;
    if (filters.roomCount != null) count++;
    if (filters.minPrice > 0 || filters.maxPrice < 50000000) count++;
    if (filters.minArea > 0 || filters.maxArea < 100) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 'Kos', 'Apartment' 등 카테고리 이름 표시
        title: Text('realEstate.form.roomTypes.${widget.roomType}'.tr()),
      ),
      body: Column(
        children: [
          // InlineSearchChip (기존 real_estate_screen.dart와 동일)
          InlineSearchChip(
            hintText: 'main.search.hint.realEstate'.tr(),
            openNotifier: _chipOpenNotifier,
            onSubmitted: (kw) =>
                _searchKeywordNotifier.value = kw.trim().toLowerCase(),
            onClose: () {},
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

          // 매물 목록 (기존 real_estate_screen.dart와 동일)
          Expanded(
            child: StreamBuilder<List<RoomListingModel>>(
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
      // [작업 25 수정] FAB 삭제
      floatingActionButton: null,
    );
  }
}

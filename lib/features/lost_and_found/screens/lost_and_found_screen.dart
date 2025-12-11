// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore lost_and_found 컬렉션 구조와 1:1 매칭, 이미지, 위치, 현상금 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/현상금 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// - 분실자/습득자 모두를 위한 UX 개선(채팅/알림/현상금 등).
// =====================================================
// lib/features/lost_and_found/screens/lost_and_found_screen.dart

import 'dart:math' as math;
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/location/providers/location_provider.dart'; // ✅ Provider Import
import 'package:provider/provider.dart'; // ✅ Provider Import
// repository import intentionally removed — using direct Firestore query for search
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// provider and location_provider already imported above

class LostAndFoundScreen extends StatefulWidget {
  final UserModel? userModel;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const LostAndFoundScreen({
    super.key,
    this.userModel,
    // this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String?> _tabFilters = [null, 'lost', 'found'];

  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapMode = false;

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

  List<LostItemModel> _applyNearbyRadius(
    List<LostItemModel> items,
    GeoPoint? userPoint,
    double radiusKm,
  ) {
    if (userPoint == null) return items;
    final filtered = <MapEntry<LostItemModel, double>>[];
    for (final item in items) {
      final geo = item.geoPoint;
      if (geo == null) continue;
      final d = _calculateDistance(
          userPoint.latitude, userPoint.longitude, geo.latitude, geo.longitude);
      if (d <= radiusKm) {
        filtered.add(MapEntry(item, d));
      }
    }
    filtered.sort((a, b) => a.value.compareTo(b.value));
    return filtered.map((e) => e.key).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabFilters.length, vsync: this);

    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // If an external search notifier is provided, listen and ensure the search
    // bar is rendered and opened when the notifier toggles.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipOpenNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
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

  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Prepare first-token search token for DB-side filtering
    final kw = _searchKeywordNotifier.value.trim().toLowerCase();
    String? searchToken;
    if (kw.isNotEmpty) {
      final token = kw.split(' ').first;
      if (token.isNotEmpty) searchToken = token;
    }

    // ✅ LocationProvider 구독
    final locationProvider = context.watch<LocationProvider>();
    final bool isNearbyMode =
        locationProvider.mode == LocationSearchMode.nearby;
    final GeoPoint? userPoint = locationProvider.user?.geoPoint;
    final double radiusKm = locationProvider.radiusKm;
    final Map<String, String?>? locationFilter =
        _buildLocationFilter(locationProvider);
    final repository = LostAndFoundRepository();

    return PopScope(
      canPop: !_isMapMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _isMapMode = false);
      },
      child: Scaffold(
        // Render search bar and TabBar+toggle regardless of map mode so
        // users can switch tabs or close the map while it's expanded.
        body: Column(
          children: [
            if (_showSearchBar)
              InlineSearchChip(
                hintText: 'main.search.hint.lostAndFound'.tr(),
                openNotifier: _chipOpenNotifier,
                onSubmitted: (kw) {
                  _searchKeywordNotifier.value = kw.trim().toLowerCase();
                },
                onClose: () {
                  setState(() => _showSearchBar = false);
                  _searchKeywordNotifier.value = '';
                },
              ),
            // TabBar + map toggle always visible per UI rule
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(text: 'lostAndFound.tabs.all'.tr()),
                      Tab(text: 'lostAndFound.tabs.lost'.tr()),
                      Tab(text: 'lostAndFound.tabs.found'.tr()),
                    ],
                    onTap: (index) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: Icon(_isMapMode ? Icons.close : Icons.map_outlined),
                    tooltip: _isMapMode
                        ? 'common.closeMap'.tr()
                        : 'common.viewMap'.tr(),
                    onPressed: () => setState(() => _isMapMode = !_isMapMode),
                  ),
                ),
              ],
            ),
            // Main content: map or list
            Expanded(
              child: _isMapMode
                  ? (() {
                      // 초기 지도 중심 좌표 결정: LocationProvider 우선순위 사용
                      final LatLng initialMapCenter = (() {
                        try {
                          if (locationProvider.mode ==
                                  LocationSearchMode.nearby &&
                              locationProvider.user?.geoPoint != null) {
                            final gp = locationProvider.user!.geoPoint!;
                            return LatLng(gp.latitude, gp.longitude);
                          }
                          if (locationProvider.user?.geoPoint != null) {
                            final gp = locationProvider.user!.geoPoint!;
                            return LatLng(gp.latitude, gp.longitude);
                          }
                          if (widget.userModel?.geoPoint != null) {
                            final gp = widget.userModel!.geoPoint!;
                            return LatLng(gp.latitude, gp.longitude);
                          }
                        } catch (_) {}
                        return const LatLng(-6.200000, 106.816666);
                      })();

                      // SharedMapBrowser 사용 주석 (분실물):
                      // - dataStream: `repository.fetchItems(...)` -> itemType(tab)에 따라 스트림 분기.
                      // - initialCameraPosition: `initialMapCenter` (locationProvider/userModel 기반 계산 로직이 위에 존재).
                      // - locationExtractor: `item.geoPoint`.
                      // - idExtractor: `item.id`.
                      // - titleExtractor: 현재는 `item.itemDescription` 을 직접 사용하고 있음.
                      //   -> 안정성을 위해 `legacyExtractTitle(item)` 사용 고려(일부 항목에 title 필드가 없음).
                      // - cardBuilder: `LostItemCard(item)`.
                      // - thumbnailUrlExtractor: item.imageUrls.first 등.
                      return SharedMapBrowser<LostItemModel>(
                        dataStream: repository
                            .fetchItems(
                              locationFilter: locationFilter,
                              // tab-aware filter
                              itemType: _tabFilters[_tabController.index],
                            )
                            .map((items) => isNearbyMode
                                ? _applyNearbyRadius(items, userPoint, radiusKm)
                                : items),
                        initialCameraPosition: CameraPosition(
                          target: initialMapCenter,
                          zoom: 14,
                        ),
                        locationExtractor: (item) => item.geoPoint,
                        idExtractor: (item) => item.id,
                        titleExtractor: (item) =>
                            item.itemDescription.isNotEmpty
                                ? item.itemDescription
                                : null,
                        cardBuilder: (context, item) =>
                            LostItemCard(item: item),
                        thumbnailUrlExtractor: (item) =>
                            (item.imageUrls.isNotEmpty)
                                ? item.imageUrls.first
                                : null,
                        categoryIconExtractor: (item) {
                          try {
                            final emoji = (item.type == 'lost') ? '❗' : '✅';
                            return Text(emoji,
                                style: const TextStyle(fontSize: 14));
                          } catch (_) {
                            return null;
                          }
                        },
                      );
                    })()
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: (() {
                        Query<Map<String, dynamic>> query = FirebaseFirestore
                            .instance
                            .collection('lost_and_found');

                        // ✅ 1. 위치 필터 적용 (Provider 기준)
                        if (locationProvider.mode ==
                                LocationSearchMode.administrative &&
                            locationProvider.activeQueryFilter != null) {
                          final filterEntry =
                              locationProvider.activeQueryFilter!;
                          query = query.where(filterEntry.key,
                              isEqualTo: filterEntry.value);
                        } else if (locationFilter != null) {
                          if (locationFilter['kel']?.isNotEmpty ?? false) {
                            query = query.where('locationParts.kel',
                                isEqualTo: locationFilter['kel']);
                          } else if (locationFilter['kec']?.isNotEmpty ??
                              false) {
                            query = query.where('locationParts.kec',
                                isEqualTo: locationFilter['kec']);
                          } else if (locationFilter['kab']?.isNotEmpty ??
                              false) {
                            query = query.where('locationParts.kab',
                                isEqualTo: locationFilter['kab']);
                          } else if (locationFilter['kota']?.isNotEmpty ??
                              false) {
                            query = query.where('locationParts.kota',
                                isEqualTo: locationFilter['kota']);
                          } else if (locationFilter['prov']?.isNotEmpty ??
                              false) {
                            query = query.where('locationParts.prov',
                                isEqualTo: locationFilter['prov']);
                          }
                        }

                        // Apply item type filter (lost/found)
                        final itemType = _tabFilters[_tabController.index];
                        if (itemType != null) {
                          query = query.where('type', isEqualTo: itemType);
                        }

                        // DB-side search token filtering
                        if (searchToken != null && searchToken.isNotEmpty) {
                          query = query.where('searchIndex',
                              arrayContains: searchToken);
                        }

                        // 3. 정렬 (서버 사이드 정렬)
                        return query
                            .orderBy('createdAt', descending: true)
                            .snapshots();
                      })(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('lostAndFound.error'.tr(namedArgs: {
                            'error': snapshot.error.toString()
                          })));
                        }

                        var docs = snapshot.data?.docs ?? [];

                        List<LostItemModel> data;

                        // ✅ 2. 거리순 정렬 및 필터링 (Nearby 모드일 때)
                        if (isNearbyMode && userPoint != null) {
                          data = docs.map(LostItemModel.fromFirestore).toList();
                          data = _applyNearbyRadius(data, userPoint, radiusKm);
                        } else {
                          data = docs.map(LostItemModel.fromFirestore).toList();
                        }
                        if (data.isEmpty) {
                          final isNational = locationProvider.mode ==
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
                                    Text('lostAndFound.emptyLocation'.tr(),
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
                                          .setMode(LocationSearchMode.national),
                                    ),
                                    // If an administrative location filter is active, offer quick reset to view all
                                    if (locationProvider.activeQueryFilter !=
                                        null) ...[
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.refresh),
                                        label: Text('common.viewAll'.tr()),
                                        onPressed: () => context
                                            .read<LocationProvider>()
                                            .setMode(
                                                LocationSearchMode.national),
                                      ),
                                    ],
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
                                  Text('lostAndFound.empty'.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
                            ),
                          );
                        }

                        // Client-side filtering removed; DB query uses `searchIndex`.

                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            // ✅ [수정] 전체 탭(index 0)일 때만 태그 표시, 나머지는 숨김
                            return LostItemCard(
                              item: item,
                              showTypeTag: _tabController.index == 0,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Haversine 공식 (Marketplace와 동일 로직)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }
}

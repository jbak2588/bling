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
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/location/providers/location_provider.dart'; // ✅ Provider Import
import 'package:provider/provider.dart'; // ✅ Provider Import
// repository import intentionally removed — using direct Firestore query for search
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
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

    return Scaffold(
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
          TabBar(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: (() {
                Query<Map<String, dynamic>> query =
                    FirebaseFirestore.instance.collection('lost_and_found');

                // ✅ 1. 위치 필터 적용 (Provider 기준)
                if (locationProvider.mode ==
                    LocationSearchMode.administrative) {
                  final filterEntry = locationProvider.activeQueryFilter;
                  if (filterEntry != null) {
                    query = query.where(filterEntry.key,
                        isEqualTo: filterEntry.value);
                  }
                } else if (locationProvider.mode == LocationSearchMode.nearby) {
                  // 거리 검색 최적화: 같은 Kab(시/군) 내에서만 1차 필터링
                  final userKab = locationProvider.user?.locationParts?['kab'];
                  if (userKab != null && userKab.isNotEmpty) {
                    query =
                        query.where('locationParts.kab', isEqualTo: userKab);
                  }
                }

                // Apply item type filter (lost/found)
                final itemType = _tabFilters[_tabController.index];
                if (itemType != null) {
                  query = query.where('type', isEqualTo: itemType);
                }

                // DB-side search token filtering
                if (searchToken != null && searchToken.isNotEmpty) {
                  query =
                      query.where('searchIndex', arrayContains: searchToken);
                }

                // 3. 정렬 (정석 복구: 서버 사이드 정렬)
                // [주의] 이 쿼리를 실행하면 콘솔에 인덱스 생성 링크가 뜹니다. 반드시 클릭하여 생성해야 합니다.
                return query.orderBy('createdAt', descending: true).snapshots();
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('lostAndFound.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }

                var docs = snapshot.data?.docs ?? [];

                List<LostItemModel> data;

                // ✅ 2. 거리순 정렬 및 필터링 (Nearby 모드일 때)
                if (locationProvider.mode == LocationSearchMode.nearby &&
                    locationProvider.user?.geoPoint != null) {
                  final userGeo = locationProvider.user!.geoPoint!;
                  final radiusKm = locationProvider.radiusKm;

                  docs = docs.where((doc) {
                    final pGeo = (doc.data()['geoPoint'] as GeoPoint?);
                    if (pGeo == null) return false;
                    final dist = _calculateDistance(userGeo.latitude,
                        userGeo.longitude, pGeo.latitude, pGeo.longitude);
                    return dist <= radiusKm;
                  }).toList();

                  docs.sort((a, b) {
                    final geoA = (a.data()['geoPoint'] as GeoPoint);
                    final geoB = (b.data()['geoPoint'] as GeoPoint);
                    final distA = _calculateDistance(userGeo.latitude,
                        userGeo.longitude, geoA.latitude, geoA.longitude);
                    final distB = _calculateDistance(userGeo.latitude,
                        userGeo.longitude, geoB.latitude, geoB.longitude);
                    return distA.compareTo(distB);
                  });

                  // Map to models after applying distance filtering/sorting
                  data = docs.map(LostItemModel.fromFirestore).toList();
                } else {
                  // Non-nearby modes: map (server already ordered by createdAt)
                  data = docs.map(LostItemModel.fromFirestore).toList();
                }
                if (data.isEmpty) {
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
                            Text('lostAndFound.empty'.tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium),
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
                              label: Text('search.empty.expandToNational'.tr()),
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
                          Text('lostAndFound.empty'.tr(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium),
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
                    return LostItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
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

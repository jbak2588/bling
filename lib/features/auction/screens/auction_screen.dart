// lib/features/auction/screens/auction_screen.dart
// Clean, single implementation for Auction screen (list + optional map view)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/core/models/user_model.dart';
// import 'package:bling_app/core/utils/location_helper.dart'; // unused, keep commented until needed
import 'package:bling_app/features/auction/models/auction_category_model.dart';
import 'package:bling_app/features/auction/models/auction_model.dart';
// AuctionDetailScreen was referenced only in the removed map view.
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AuctionScreen extends StatefulWidget {
  final UserModel? userModel;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const AuctionScreen({
    super.key,
    this.userModel,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  final AuctionRepository _repository = AuctionRepository();
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapView = false;
  String _selectedCategoryId = 'all';

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
    _searchKeywordNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    _chipOpenNotifier.dispose();
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

  Query<Map<String, dynamic>> _buildAuctionQuery(LocationProvider provider) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('auctions');

    if (provider.mode == LocationSearchMode.administrative) {
      final filterEntry = provider.activeQueryFilter;
      if (filterEntry != null) {
        query = query.where(filterEntry.key, isEqualTo: filterEntry.value);
      }
    } else if (provider.mode == LocationSearchMode.nearby) {
      final userKab = provider.user?.locationParts?['kab'];
      if (userKab != null) {
        query = query.where('locationParts.kab', isEqualTo: userKab);
      }
    }

    if (_selectedCategoryId != 'all') {
      query = query.where('category', isEqualTo: _selectedCategoryId);
    }

    return query.orderBy('endAt', descending: false);
  }

  // Note: locationFilter helper removed — repository is called with explicit
  // null filters when map mode requires showing all auctions.

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    // 초기 지도 중심 좌표 결정: LocationProvider 우선순위 사용
    final LatLng initialMapCenter = (() {
      try {
        if (locationProvider.mode == LocationSearchMode.nearby &&
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

    // [수정] PopScope 추가 (지도 모드 시 뒤로가기 제어)
    return PopScope<bool>(
      canPop: !_isMapView,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _isMapView = false);
      },
      child: Scaffold(
        // [수정] 중복 AppBar 제거 (상위 네비게이션 사용 또는 커스텀 헤더)
        body: Column(
          children: [
            if (_showSearchBar)
              InlineSearchChip(
                hintText: 'main.search.hint.auction'.tr(),
                openNotifier: _chipOpenNotifier,
                onSubmitted: (kw) =>
                    _searchKeywordNotifier.value = kw.trim().toLowerCase(),
                onClose: () => _searchKeywordNotifier.value = '',
              ),

            // [수정] 카테고리 칩 + 지도 토글 버튼을 한 줄에 배치
            Row(
              children: [
                Expanded(child: _buildCategoryChips()), // 카테고리 칩 (좌측)

                // [추가] 지도/닫기 토글 버튼 (우측 끝)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(_isMapView ? Icons.close : Icons.map_outlined),
                    tooltip: _isMapView
                        ? 'common.closeMap'.tr()
                        : 'common.viewMap'.tr(),
                    onPressed: () => setState(() => _isMapView = !_isMapView),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                // [수정] 지도 모드일 땐 쿼리 로직 분기
                stream: _isMapView
                    ? FirebaseFirestore.instance
                        .collection('auctions')
                        .orderBy('endAt')
                        .snapshots() // 지도: 전체 보기 (필터 무시)
                    : _buildAuctionQuery(locationProvider)
                        .snapshots(), // 리스트: 필터 적용
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('auctions.errors.fetchFailed'.tr()));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final auctions =
                      docs.map((d) => AuctionModel.fromFirestore(d)).toList();

                  if (auctions.isEmpty) {
                    return Center(child: Text('auctions.empty'.tr()));
                  }

                  var filtered = auctions;
                  final kw = _searchKeywordNotifier.value;
                  if (kw.isNotEmpty) {
                    filtered = filtered
                        .where((a) =>
                            ('${a.title} ${a.description} ${a.tags.join(' ')}')
                                .toLowerCase()
                                .contains(kw))
                        .toList();
                  }

                  if (_isMapView) {
                    // [수정] StreamBuilder 데이터를 그대로 재사용하거나, Repository 호출 시 null 필터 전달
                    // 위에서 이미 스트림을 분기했으므로, 여기서는 단순히 데이터를 넘겨주는 방식보다는
                    // SharedMapBrowser의 dataStream 인터페이스에 맞춰 Repository를 호출하는 것이 깔끔함.
                    return SharedMapBrowser<AuctionModel>(
                      dataStream: _repository.fetchAuctions(
                          locationFilter: null, // [중요] 전체 매물 지도 표시를 위해 null 전달
                          categoryId: null), // [중요] 카테고리 무시하고 전체 표시
                      initialCameraPosition: CameraPosition(
                        target: initialMapCenter,
                        zoom: 14,
                      ),
                      locationExtractor: (a) => a.geoPoint,
                      idExtractor: (a) => a.id,
                      cardBuilder: (ctx, a) =>
                          AuctionCard(auction: a, userModel: widget.userModel),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => AuctionCard(
                        auction: filtered[index], userModel: widget.userModel),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final all = const AuctionCategoryModel(
        categoryId: 'all', emoji: '💎', nameKey: 'categories.auction.all');
    final cats = [all, ...AppCategories.auctionCategories];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final c = cats[i];
          final selected = c.categoryId == _selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: ChoiceChip(
              label: Text('${c.emoji} ${c.nameKey.tr()}'),
              selected: selected,
              onSelected: (s) => setState(
                  () => _selectedCategoryId = s ? c.categoryId : 'all'),
            ),
          );
        },
      ),
    );
  }
}

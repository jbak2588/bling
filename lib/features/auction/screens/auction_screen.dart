// lib/features/auction/screens/auction_screen.dart
// Clean, single implementation for Auction screen (list + optional map view)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/features/shared/helpers/legacy_title_extractor.dart';
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
import 'dart:math' as math;

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

  double _haversineKm(GeoPoint a, GeoPoint b) {
    const double p = 0.017453292519943295; // pi/180
    final double c1 = math.cos((b.latitude - a.latitude) * p);
    final double c2 = math.cos(a.latitude * p) * math.cos(b.latitude * p);
    final double term =
        0.5 - c1 / 2 + c2 * (1 - math.cos((b.longitude - a.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(term));
  }

  List<AuctionModel> _applyNearbyRadius(
    List<AuctionModel> auctions,
    GeoPoint? userPoint,
    double radiusKm,
  ) {
    if (userPoint == null) return auctions;
    final filtered = <MapEntry<AuctionModel, double>>[];
    for (final a in auctions) {
      final geo = a.geoPoint;
      if (geo == null) continue;
      final d = _haversineKm(userPoint, geo);
      if (d <= radiusKm) {
        filtered.add(MapEntry(a, d));
      }
    }
    filtered.sort((a, b) => a.value.compareTo(b.value));
    return filtered.map((e) => e.key).toList();
  }

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

  Query<Map<String, dynamic>> _buildAuctionQuery(
      Map<String, String?>? locationFilter) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('auctions');

    if (locationFilter != null) {
      if (locationFilter['kel']?.isNotEmpty ?? false) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec']?.isNotEmpty ?? false) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab']?.isNotEmpty ?? false) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['kota']?.isNotEmpty ?? false) {
        query = query.where('locationParts.kota',
            isEqualTo: locationFilter['kota']);
      } else if (locationFilter['prov']?.isNotEmpty ?? false) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
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
    final bool isNearbyMode =
        locationProvider.mode == LocationSearchMode.nearby;
    final GeoPoint? userPoint =
        locationProvider.user?.geoPoint ?? widget.userModel?.geoPoint;
    final double radiusKm = locationProvider.radiusKm;

    // [Fix] 전국 모드 시 사용자 위치 폴백 방지 (null 유지)
    final Map<String, String?>? locationFilter =
        (locationProvider.mode == LocationSearchMode.national)
            ? null
            : (_buildLocationFilter(locationProvider) ??
                (widget.userModel?.locationParts
                    ?.map((key, value) => MapEntry(key, value?.toString()))));

    // 초기 지도 중심 좌표 결정: LocationProvider 우선순위 사용
    final LatLng initialMapCenter = (() {
      try {
        if (userPoint != null) {
          return LatLng(userPoint.latitude, userPoint.longitude);
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
              child: _isMapView
                  ? SharedMapBrowser<AuctionModel>(
                      dataStream: _repository
                          .fetchAuctions(
                            locationFilter: locationFilter,
                            categoryId: _selectedCategoryId == 'all'
                                ? null
                                : _selectedCategoryId,
                          )
                          .map((auctions) => isNearbyMode
                              ? _applyNearbyRadius(
                                  auctions, userPoint, radiusKm)
                              : auctions),
                      initialCameraPosition: CameraPosition(
                        target: initialMapCenter,
                        zoom: 14,
                      ),
                      locationExtractor: (a) => a.geoPoint,
                      idExtractor: (a) => a.id,
                      titleExtractor: (a) => legacyExtractTitle(a),
                      cardBuilder: (ctx, a) =>
                          AuctionCard(auction: a, userModel: widget.userModel),
                      thumbnailUrlExtractor: (a) =>
                          (a.images.isNotEmpty) ? a.images.first : null,
                      categoryIconExtractor: (a) {
                        try {
                          final cat = AppCategories.auctionCategories
                              .firstWhere(
                                  (c) => c.categoryId == (a.category ?? 'etc'),
                                  orElse: () =>
                                      AppCategories.auctionCategories.first);
                          return Text(cat.emoji,
                              style: const TextStyle(fontSize: 14));
                        } catch (_) {
                          return null;
                        }
                      },
                    )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _buildAuctionQuery(locationFilter).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('auctions.errors.fetchFailed'.tr()));
                        }
                        final docs = snapshot.data?.docs ?? [];
                        var auctions = docs
                            .map((d) => AuctionModel.fromFirestore(d))
                            .toList();

                        if (isNearbyMode) {
                          auctions =
                              _applyNearbyRadius(auctions, userPoint, radiusKm);
                        }

                        if (auctions.isEmpty) {
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
                                    Text('auctions.empty'.tr(),
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
                                Text('auctions.empty'.tr(),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ));
                        }

                        final kw = _searchKeywordNotifier.value;
                        if (kw.isNotEmpty) {
                          auctions = auctions
                              .where((a) =>
                                  ('${a.title} ${a.description} ${a.tags.join(' ')}')
                                      .toLowerCase()
                                      .contains(kw))
                              .toList();
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: auctions.length,
                          itemBuilder: (context, index) => AuctionCard(
                              auction: auctions[index],
                              userModel: widget.userModel),
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

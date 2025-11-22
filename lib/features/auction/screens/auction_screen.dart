// lib/features/auction/screens/auction_screen.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 지역 기반 프리미엄 경매, 위치 인증, 신뢰등급(TrustLevel), AI 검수 등 안전·품질 정책
///   - 실시간 입찰, 채팅, 프로필 연동, 활동 히스토리 등 상호작용 기능
///   - 카테고리/조건 기반 필터, 공지/신고/차단 등 운영 기능, KPI/Analytics, 광고/프로모션, 다국어(i18n)
///
/// 2. 실제 코드 분석
///   - 위치 기반 필터로 경매 목록 표시, Firestore auctions 컬렉션, locationParts 기반 정렬/필터
///   - 신뢰등급, AI 검수, KPI/Analytics, 다국어(i18n) 등 정책 반영, Edge case 처리
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·신뢰등급·AI 검수 등 품질·운영 기능 강화, KPI/Analytics, 광고/프로모션, 다국어(i18n) 등 실제 서비스 운영에 필요한 기능 반영
///   - 기획에 못 미친 점: 실시간 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, AI 검수·신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 실시간 입찰/채팅, 경매 상태 시각화, 신뢰등급/AI 검수 표시 강화, 지도 기반 위치 선택, 광고/프로모션 배너
///   - 수익화: 프리미엄 경매, 지역 광고, 프로모션, 추천 아이템/판매자 노출, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;

import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/auction/screens/auction_detail_screen.dart'; // ✅ [지도뷰] 1. 상세화면 import
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
// ✅ [지도뷰] 2. 구글맵 및 관련 의존성 import
// ✅ [탐색 기능] 1. AppCategories import
import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/features/auction/models/auction_category_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class AuctionScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const AuctionScreen(
      {this.userModel,
      this.locationFilter, // [추가]
      this.autoFocusSearch = false,
      this.searchNotifier,
      super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  // 위치 필터는 상위(MainNavigation)에서 주입되는 widget.locationFilter 를 직접 사용합니다.
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  bool _isMapView = false; // ✅ [지도뷰] 3. 맵/리스트 토글 상태 변수 추가
  String _selectedCategoryId = 'all'; // ✅ [탐색 기능] 2. 카테고리 상태 변수 추가

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

    // If an external search notifier is provided, listen and ensure the search
    // bar is rendered and opened when the notifier toggles.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }

    // ✅ [버그 수정 1] 키워드가 변경될 때마다 setState를 호출하여 화면을 다시 그리도록 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  // ✅ [버그 수정 1] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  // 위치 필터 UI는 상위(MainNavigation)에서 관리합니다. 이 화면에서는 상태만 초기화해 사용합니다.

  // ✅ [버그 수정 2] 메모리 누수 방지를 위해 dispose 메서드 추가
  @override
  void dispose() {
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged); // 리스너 제거
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

  @override
  Widget build(BuildContext context) {
    final AuctionRepository auctionRepository = AuctionRepository();

    return Scaffold(
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.auction'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          // [추가] 필터 관리 UI
          // ✅ [탐색 기능] 3. 카테고리 칩 리스트 빌더 추가
          _buildCategoryChips(),
          // ✅ [정리] 위치 필터 버튼 제거. 지도/리스트 토글만 유지.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                    _isMapView ? Icons.list_alt_outlined : Icons.map_outlined,
                    color: Colors.grey.shade700),
                tooltip: _isMapView
                    ? 'main.mapView.showList'.tr()
                    : 'main.mapView.showMap'.tr(),
                onPressed: () {
                  setState(() => _isMapView = !_isMapView);
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<AuctionModel>>(
              // [수정] fetchAuctions 함수에 현재 필터 상태를 전달합니다.
              stream: auctionRepository.fetchAuctions(
                  locationFilter: widget.locationFilter,
                  categoryId:
                      _selectedCategoryId), // ✅ [탐색 기능] 4. categoryId 전달
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('auctions.errors.fetchFailed'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  final isNational = context.watch<LocationProvider>().mode ==
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
                                label:
                                    Text('search.empty.expandToNational'.tr()),
                                onPressed: () => context
                                    .read<LocationProvider>()
                                    .setMode(LocationSearchMode.national)),
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
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }

                var auctions = snapshot.data!;
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  auctions = auctions
                      .where((a) =>
                          (('${a.title} ${a.description} ${a.tags.join(' ')}')
                              .toLowerCase()
                              .contains(kw)))
                      .toList();
                }

                if (auctions.isEmpty) {
                  final isNational = context.watch<LocationProvider>().mode ==
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
                                label:
                                    Text('search.empty.expandToNational'.tr()),
                                onPressed: () => context
                                    .read<LocationProvider>()
                                    .setMode(LocationSearchMode.national)),
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
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }

                // ✅ [지도뷰] 5. _isMapView 상태에 따라 리스트뷰 또는 맵뷰를 표시
                return _isMapView
                    ? _AuctionMapView(
                        key: PageStorageKey(
                            'auction_map_${widget.locationFilter?.hashCode ?? 0}'),
                        auctions: auctions,
                        userModel: widget.userModel,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.only(bottom: 80), // FAB와의 여백 확보
                        itemCount: auctions.length,
                        itemBuilder: (context, index) {
                          final auction = auctions[index];
                          return AuctionCard(
                              auction: auction,
                              userModel: widget.userModel); // userModel 전달
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ [탐색 기능] 5. 카테고리 칩 목록을 생성하는 헬퍼 위젯
  Widget _buildCategoryChips() {
    // '전체' 카테고리 모델을 동적으로 생성
    final allCategory = const AuctionCategoryModel(
      categoryId: 'all',
      emoji: '💎',
      nameKey: 'categories.auction.all', // '전체'
    );

    final categories = [allCategory, ...AppCategories.auctionCategories];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.categoryId == _selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                "${category.emoji} ${category.nameKey.tr()}",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategoryId = category.categoryId);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ✅ [지도뷰] 6. LocalNewsScreen을 참고하여 _AuctionMapView 위젯 추가

class _AuctionMapView extends StatefulWidget {
  final List<AuctionModel> auctions;
  final UserModel? userModel;

  const _AuctionMapView({
    super.key,
    required this.auctions,
    this.userModel,
  });

  @override
  State<_AuctionMapView> createState() => _AuctionMapViewState();
}

class _AuctionMapViewState extends State<_AuctionMapView> {
  final Completer<GoogleMapController> _controller = Completer();

  // 초기 카메라 위치 설정 (사용자 위치 또는 자카르타 기본값)
  CameraPosition _getInitialCameraPosition() {
    LatLng target;
    if (widget.userModel?.geoPoint != null) {
      target = LatLng(
        widget.userModel!.geoPoint!.latitude,
        widget.userModel!.geoPoint!.longitude,
      );
    } else {
      // 자카르타 기본 위치
      target = const LatLng(-6.2088, 106.8456);
    }
    return CameraPosition(target: target, zoom: 12);
  }

  // 경매 목록으로부터 마커 세트 생성
  Set<Marker> _createMarkers() {
    final Set<Marker> markers = {};
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    for (final auction in widget.auctions) {
      if (auction.geoPoint != null) {
        // 경매가 종료되었는지 확인
        final bool isEnded = auction.endAt.toDate().isBefore(DateTime.now());

        markers.add(Marker(
          markerId: MarkerId(auction.id),
          position: LatLng(
            auction.geoPoint!.latitude,
            auction.geoPoint!.longitude,
          ),
          // 종료된 경매는 회색으로 표시
          icon: isEnded
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: auction.title,
            snippet: isEnded
                ? 'auctions.card.ended'.tr()
                : currencyFormat.format(auction.currentBid),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AuctionDetailScreen(
                    auction: auction,
                    userModel: widget.userModel,
                  ),
                ),
              );
            },
          ),
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final markers = _createMarkers();

    return GoogleMap(
      initialCameraPosition: _getInitialCameraPosition(),
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      markers: markers,
      // 지도에 내 위치 표시 (userModel이 있는 경우)
      myLocationEnabled: widget.userModel?.geoPoint != null,
      myLocationButtonEnabled: true,
      // 지도 타입 (일반)
      mapType: MapType.normal,
      // 줌 제어 버튼 활성화
      zoomControlsEnabled: true,
    );
  }
}

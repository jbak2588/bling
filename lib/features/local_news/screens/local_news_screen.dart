/// ============================================================================
/// Bling 문서헤더
/// 모듈         : 로컬 뉴스(동네 소식)
/// 파일         : lib/features/local_news/screens/local_news_screen.dart
/// 목적         : 사용자의 위치 기반으로 동네 소식 게시글을 조회하고, 태그별로 분류된 게시글 목록을 제공합니다. (카테고리 -> 태그로 변경됨)
/// 사용자 가치  : 사용자는 자신의 지역 소식을 빠르게 확인하고, 다양한 태그별로 정보를 얻을 수 있습니다.
/// 연결 기능    : lib/features/local_news/screens/create_local_news_screen.dart;
///               lib/features/local_news/screens/edit_local_news_screen.dart
/// 데이터 모델  : 게시글(PostModel)에는 작성자, 내용, 태그, 위치 정보, 생성일, 이미지 등이 포함됩니다.
/// 위치 범위    : 사용자의 위치 정보(시/군/구/동 등)를 기반으로 게시글을 필터링합니다.
///
/// ============================================================================///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - (DevLog: "대답:81" 기반) Keluharan 기반 동네 소통 피드, 태그 시스템 도입.
///
/// 2. 실제 코드 분석
///   - 사용자 위치 기반(Local)으로 피드 필터링, ✅ 태그별 분류, 글 작성/수정/조회 기능
///   - 데이터 모델(PostModel)에 위치 정보, ✅ 태그, 신뢰등급 등 포함
///   - 위치 필터(시/군/구/동 등)와 연동, 신뢰등급(TrustLevel) 적용
///   - 광고/커뮤니티 연계, 다국어(i18n) 지원, 신고/공지글 관리 등
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 현지화·사용자 경험 강화, 신고/공지글 관리 등 서비스 운영 기능 반영
///   - 기획에 못 미친 점: AI 자동 태그 추천(진행중), Marketplace 연동, 1:1 채팅 등 일부 기능 미구현
///
/// 4. 개선 제안
///   - UI/UX: 태그별 색상/아이콘, 위치 기반 추천, 피드 정렬/필터 강화, 지도 기반 위치 선택, 활동 히스토리/신뢰등급 변화 시각화
///   - 수익화: 지역 광고, 프로모션, 추천글/상품 노출, 프리미엄 기능 연계, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
/// ============================================================================
/// 2025-10-31 (작업 1):
///   - [Phase 2] '하이브리드 기획안' 1단계(태그 시스템) 적용.
///   - 기존 'AppCategories' 기반 TabBar를 'AppTags.localNewsTags' 기반으로 교체.
///   - Firestore 쿼리를 'category' 필드 대신 'tags' 필드 (arrayContains)로 변경.
///   - 'showInFilter' 필드 부재로 인한 컴파일 에러를 'filterableTagIds' 목록으로 대체.
/// ============================================================================

library;
// 아래부터 실제 코드

import 'dart:async';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/helpers/legacy_title_extractor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';
import 'package:bling_app/features/shared/widgets/shared_map_browser.dart'; // [추가] 공용 지도 위젯
import 'dart:math' as math;

// ✅ [롤백] 카테고리 상수 import 복구
import '../../../core/constants/app_categories.dart';
// ✅ [태그 시스템] 신규 태그 사전 import (필요시 유지)
// AppTags import removed: currently unused after category rollback
import '../widgets/post_card.dart';
// 'local_news_detail_screen.dart' import removed: detail screen is navigated
// to from PostCard; keep import minimal to avoid unused import lint.

class LocalNewsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  // 검색 UX 옵션
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const LocalNewsScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with TickerProviderStateMixin {
  // ... 이 클래스의 모든 코드는 원본과 동일하게 유지됩니다 ...
  late final TabController _tabController;
  bool _isMapView = false;
  // 인라인 검색 칩 제어 및 키워드 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  // external search listener removed; chip will use widget.searchNotifier
  // 검색바 표시 여부 (칩 자체를 완전히 숨기기 위함)
  bool _showSearchBar = false;

  // ✅ [롤백] 카테고리 ID 목록으로 복구
  late final List<String> _categoryIds;

  // late final List<Widget> _tabViews;
  late final List<Widget> _listTabViews;
  late final List<Widget> _mapTabViews;

  @override
  void initState() {
    super.initState();

    // ✅ [롤백] AppCategories 기반 탭 구성
    // 'all' + 정의된 카테고리 ID들
    _categoryIds = [
      'all',
      ...AppCategories.postCategories.map((c) => c.categoryId)
    ];

    _tabController = TabController(length: _categoryIds.length, vsync: this);

    // ✅ 2. 카테고리 기반 탭 뷰 생성
    _listTabViews = _categoryIds.map((catId) {
      return _FeedListView(
        key: PageStorageKey('list_view_$catId'),
        categoryId: catId, // ✅ 복구
        userModel: widget.userModel,
        locationFilter: widget.locationFilter,
        searchKeywordListenable: _searchKeywordNotifier,
      );
    }).toList();

    _mapTabViews = _categoryIds.map((catId) {
      return _FeedMapView(
        key: PageStorageKey('map_view_$catId'),
        categoryId: catId, // ✅ 복구
        userModel: widget.userModel,
        locationFilter: widget.locationFilter,
        searchKeywordListenable: _searchKeywordNotifier,
      );
    }).toList();

    // 검색 UX: 자동 포커스 요청 (전역 시트에서 진입한 경우)
    if (widget.autoFocusSearch) {
      _showSearchBar = true; // 처음엔 검색칩을 보여줌
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true; // 포커스 오픈
      });
    }

    // widget.searchNotifier will be passed directly to the InlineSearchChip below.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
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

  // 인라인 검색칩 제출 처리
  void _onSearchSubmitted(String keyword) {
    final kw = keyword.trim().toLowerCase();
    _searchKeywordNotifier.value = kw; // 빈 문자열도 허용 (검색 초기화)
  }

  // 검색창 닫기 요청 (X 버튼)
  void _onSearchClosed() {
    if (!mounted) return;
    setState(() => _showSearchBar = false);
    // 필터도 초기화
    _searchKeywordNotifier.value = '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userModel == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('localNewsFeed.setLocationPrompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    // ✅ [태그 시스템] 탭 목록을 AppTags 기준으로 생성
    final List<Widget> tabs = [
      Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // use AppCategories' emoji for the 'all' tab (fallback safe)
              AppCategories.postCategories
                  .firstWhere((c) => c.categoryId == 'local_news',
                      orElse: () => AppCategories.postCategories.first)
                  .emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text('localNewsFeed.allCategory'.tr()), // '전체'
          ],
        ),
      ),
      // ✅ [롤백] AppCategories 기반 탭
      ...AppCategories.postCategories.map((category) {
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(category.nameKey.tr()), // 카테고리 이름
            ],
          ),
        );
      }),
    ];

    // [수정] PopScope 추가 (지도 모드일 때 뒤로가기 제어)
    return PopScope(
      canPop: !_isMapView,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _isMapView = false);
      },
      child: Scaffold(
        // [수정] appBar 속성 삭제 (타이틀 바 제거)
        body: Column(
          children: [
            // 검색칩은 요청될 때만 보이고, X(취소) 시 완전히 사라집니다.
            if (_showSearchBar)
              InlineSearchChip(
                hintText: 'main.search.hint.localNews'.tr(),
                openNotifier: _chipOpenNotifier,
                onSubmitted: _onSearchSubmitted,
                onClose: _onSearchClosed,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: const Color(0xFF00A66C),
                      unselectedLabelColor: const Color(0xFF616161),
                      indicatorColor: const Color(0xFF00A66C),
                      tabs: tabs, // ✅ 수정된 탭 리스트
                    ),
                  ),
                  // [수정] 탭 옆의 버튼을 지도/닫기 토글 버튼으로 변경
                  IconButton(
                    icon: Icon(_isMapView ? Icons.close : Icons.map_outlined,
                        color: Colors.grey.shade700),
                    onPressed: () {
                      setState(() {
                        _isMapView = !_isMapView;
                      });
                    },
                    tooltip: _isMapView
                        ? 'common.closeMap'.tr()
                        : 'common.viewMap'.tr(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                // ✅ 3. 매번 새로 생성하는 대신, initState에서 만들어 둔 _tabViews 변수를 사용합니다.
                children: _isMapView ? _mapTabViews : _listTabViews,
              ),
            ),
          ],
        ), // end Column
      ), // end Scaffold
    ); // end PopScope
  }
}

// ✅✅✅ 이 아랫부분이 핵심 수정 영역입니다 ✅✅✅

// ✅ 1. StatelessWidget을 StatefulWidget으로 변경합니다.
class _FeedListView extends StatefulWidget {
  final String categoryId; // ✅ [롤백] tagId -> categoryId
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final ValueListenable<String>? searchKeywordListenable;
  const _FeedListView(
      {super.key,
      required this.categoryId, // ✅ [롤백]
      this.userModel,
      this.locationFilter,
      this.searchKeywordListenable});

  @override
  State<_FeedListView> createState() => _FeedListViewState();
}

// ✅ 2. with AutomaticKeepAliveClientMixin을 추가합니다.
class _FeedListViewState extends State<_FeedListView>
    with AutomaticKeepAliveClientMixin {
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

  List<PostModel> _applyNearbyRadius(
    List<PostModel> posts,
    GeoPoint? userPoint,
    double radiusKm,
  ) {
    if (userPoint == null) return posts;
    final filtered = <MapEntry<PostModel, double>>[];
    for (final post in posts) {
      final geo = post.geoPoint;
      if (geo == null) continue;
      final d = _haversineKm(userPoint, geo);
      if (d <= radiusKm) {
        filtered.add(MapEntry(post, d));
      }
    }
    filtered.sort((a, b) => a.value.compareTo(b.value));
    return filtered.map((e) => e.key).toList();
  }

  // ✅ 3. wantKeepAlive를 true로 설정하여 탭이 전환되어도 이 목록의 상태를 유지시킵니다.
  @override
  bool get wantKeepAlive => true;

  // 키워드 변경 수신용 리스너와 현재 바인딩된 Listenable 참조
  VoidCallback? _kwListener;
  ValueListenable<String>? _currentKeywordListenable;

  @override
  void initState() {
    super.initState();
    _kwListener = () {
      if (mounted) setState(() {});
    };
    _currentKeywordListenable = widget.searchKeywordListenable;
    _currentKeywordListenable?.addListener(_kwListener!);
    // (카테고리 아이콘 맵 초기화는 지도 뷰 상태에서 담당합니다.)
  }

  @override
  void didUpdateWidget(covariant _FeedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchKeywordListenable != widget.searchKeywordListenable) {
      // 이전 Listenable에서 분리 후 새 Listenable에 연결
      _currentKeywordListenable?.removeListener(_kwListener!);
      _currentKeywordListenable = widget.searchKeywordListenable;
      _currentKeywordListenable?.addListener(_kwListener!);
    }
  }

  @override
  void dispose() {
    // 메모리 누수 방지: 리스너를 반드시 제거
    if (_kwListener != null) {
      _currentKeywordListenable?.removeListener(_kwListener!);
    }
    super.dispose();
  }

  // 기존 _buildQuery와 _applyLocationFilter 함수를 State 안으로 이동
  Query<Map<String, dynamic>> _buildQuery(
      Map<String, String?>? locationFilter, LocationProvider provider) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    if (provider.mode == LocationSearchMode.administrative &&
        provider.activeQueryFilter != null) {
      final active = provider.activeQueryFilter!;
      query = query.where(active.key, isEqualTo: active.value);
    } else if (locationFilter != null) {
      if (locationFilter['kel'] != null) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['kota'] != null) {
        query = query.where('locationParts.kota',
            isEqualTo: locationFilter['kota']);
      } else if (locationFilter['prov'] != null) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
    } else if (provider.mode != LocationSearchMode.national) {
      // [Fix] 전국 모드가 아닐 때만 사용자 거주지 필터 적용
      final userProv = widget.userModel?.locationParts?['prov'];
      if (userProv != null && userProv.isNotEmpty) {
        query = query.where('locationParts.prov', isEqualTo: userProv);
      }
    }

    if (widget.categoryId != 'all') {
      query = query.where('category', isEqualTo: widget.categoryId);
    }

    final kw = widget.searchKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw.isNotEmpty) {
      final searchToken = kw.split(' ').first;
      if (searchToken.isNotEmpty) {
        query = query.where('searchIndex', arrayContains: searchToken);
      }
    }
    return query.orderBy('createdAt', descending: true);
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs,
      Map<String, String?>? filter) {
    if (filter == null) return allDocs;
    String? key;
    if (filter['kel'] != null) {
      key = 'kel';
    } else if (filter['kec'] != null) {
      key = 'kec';
    } else if (filter['kab'] != null) {
      key = 'kab';
    } else if (filter['kota'] != null) {
      key = 'kota';
    } else if (filter['prov'] != null) {
      key = 'prov';
    }
    if (key == null) {
      return allDocs;
    }
    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 4. super.build(context)를 호출해야 합니다.
    super.build(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: (() {
        final provider = context.watch<LocationProvider>();
        final locationFilter = provider.mode == LocationSearchMode.national
            ? null
            : (_buildLocationFilter(provider) ?? widget.locationFilter);
        return _buildQuery(locationFilter, provider).snapshots();
      })(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('localNewsFeed.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})));
        }
        final provider = context.watch<LocationProvider>();
        final bool isNearbyMode = provider.mode == LocationSearchMode.nearby;
        final GeoPoint? userPoint =
            provider.user?.geoPoint ?? widget.userModel?.geoPoint;
        final double radiusKm = provider.radiusKm;
        final locationFilter = provider.mode == LocationSearchMode.national
            ? null
            : (_buildLocationFilter(provider) ?? widget.locationFilter);

        final allDocs = snapshot.data?.docs ?? [];
        final postsDocs = _applyLocationFilter(allDocs, locationFilter);
        var posts = postsDocs.map(PostModel.fromFirestore).toList();

        if (isNearbyMode) {
          posts = _applyNearbyRadius(posts, userPoint, radiusKm);
        }

        if (posts.isEmpty) {
          final isNational = context.watch<LocationProvider>().mode ==
              LocationSearchMode.national;
          if (!isNational) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('localNewsFeed.empty'.tr(),
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
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('localNewsFeed.empty'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(key: ValueKey(post.id), post: post);
          },
        );
      },
    );
  }
}

class _FeedMapView extends StatefulWidget {
  final String categoryId; // ✅ [롤백] tagId -> categoryId
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final ValueListenable<String>? searchKeywordListenable;
  const _FeedMapView(
      {super.key,
      required this.categoryId, // ✅ [롤백]
      this.userModel,
      this.locationFilter,
      this.searchKeywordListenable});

  @override
  State<_FeedMapView> createState() => _FeedMapViewState();
}

class _FeedMapViewState extends State<_FeedMapView> {
  VoidCallback? _kwListener;
  ValueListenable<String>? _currentKeywordListenable;
  // (카테고리 아이콘 맵은 현재 사용되지 않음)

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

  List<PostModel> _applyNearbyRadius(
    List<PostModel> posts,
    GeoPoint? userPoint,
    double radiusKm,
  ) {
    if (userPoint == null) return posts;
    final filtered = <MapEntry<PostModel, double>>[];
    for (final post in posts) {
      final geo = post.geoPoint;
      if (geo == null) continue;
      final d = _haversineKm(userPoint, geo);
      if (d <= radiusKm) {
        filtered.add(MapEntry(post, d));
      }
    }
    filtered.sort((a, b) => a.value.compareTo(b.value));
    return filtered.map((e) => e.key).toList();
  }

  @override
  void initState() {
    super.initState();
    _kwListener = () {
      if (mounted) setState(() {});
    };
    _currentKeywordListenable = widget.searchKeywordListenable;
    _currentKeywordListenable?.addListener(_kwListener!);
    // (카테고리 아이콘 맵 초기화 생략)
  }

  @override
  void didUpdateWidget(covariant _FeedMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchKeywordListenable != widget.searchKeywordListenable) {
      _currentKeywordListenable?.removeListener(_kwListener!);
      _currentKeywordListenable = widget.searchKeywordListenable;
      _currentKeywordListenable?.addListener(_kwListener!);
    }
  }

  @override
  void dispose() {
    if (_kwListener != null) {
      _currentKeywordListenable?.removeListener(_kwListener!);
    }
    super.dispose();
  }

  Future<CameraPosition> _getInitialCameraPosition() async {
    final locationProvider = context.read<LocationProvider>();
    final userPoint =
        locationProvider.user?.geoPoint ?? widget.userModel?.geoPoint;
    if (userPoint != null) {
      return CameraPosition(
          target: LatLng(userPoint.latitude, userPoint.longitude), zoom: 14);
    }

    final snapshot = await _buildInitialCameraQuery().limit(1).get();
    LatLng target;
    if (snapshot.docs.isNotEmpty &&
        snapshot.docs.first.data()['geoPoint'] != null) {
      final geoPoint = snapshot.docs.first.data()['geoPoint'] as GeoPoint;
      target = LatLng(geoPoint.latitude, geoPoint.longitude);
    } else {
      target = LatLng(
        widget.userModel?.geoPoint?.latitude ?? -6.2088,
        widget.userModel?.geoPoint?.longitude ?? 106.8456,
      );
    }
    debugPrint('[지도 디버그] 초기 카메라 위치 설정: $target');
    return CameraPosition(target: target, zoom: 14);
  }

  Query<Map<String, dynamic>> _buildInitialCameraQuery() {
    final locationProvider = context.watch<LocationProvider>();
    final locationFilter = locationProvider.mode == LocationSearchMode.national
        ? null
        : (_buildLocationFilter(locationProvider) ?? widget.locationFilter);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    if (locationProvider.mode == LocationSearchMode.administrative &&
        locationProvider.activeQueryFilter != null) {
      final active = locationProvider.activeQueryFilter!;
      query = query.where(active.key, isEqualTo: active.value);
    } else if (locationFilter != null) {
      if (locationFilter['kel'] != null) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['kota'] != null) {
        query = query.where('locationParts.kota',
            isEqualTo: locationFilter['kota']);
      } else if (locationFilter['prov'] != null) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
    } else if (locationProvider.mode != LocationSearchMode.national &&
        widget.userModel?.locationParts?['prov'] != null) {
      query = query.where('locationParts.prov',
          isEqualTo: widget.userModel!.locationParts!['prov']);
    }

    if (widget.categoryId != 'all') {
      query = query.where('category', isEqualTo: widget.categoryId);
    }
    final kw = widget.searchKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw.isNotEmpty) {
      query = query.where('tags', arrayContains: kw);
    }
    debugPrint('[지도 디버그] 카메라 위치 쿼리: ${query.parameters}');
    return query.orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> _buildAllMarkersQuery() {
    final locationProvider = context.watch<LocationProvider>();
    final locationFilter = locationProvider.mode == LocationSearchMode.national
        ? null
        : (_buildLocationFilter(locationProvider) ?? widget.locationFilter);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    if (locationProvider.mode == LocationSearchMode.administrative &&
        locationProvider.activeQueryFilter != null) {
      final active = locationProvider.activeQueryFilter!;
      query = query.where(active.key, isEqualTo: active.value);
    } else if (locationFilter != null) {
      if (locationFilter['kel'] != null) {
        query =
            query.where('locationParts.kel', isEqualTo: locationFilter['kel']);
      } else if (locationFilter['kec'] != null) {
        query =
            query.where('locationParts.kec', isEqualTo: locationFilter['kec']);
      } else if (locationFilter['kab'] != null) {
        query =
            query.where('locationParts.kab', isEqualTo: locationFilter['kab']);
      } else if (locationFilter['kota'] != null) {
        query = query.where('locationParts.kota',
            isEqualTo: locationFilter['kota']);
      } else if (locationFilter['prov'] != null) {
        query = query.where('locationParts.prov',
            isEqualTo: locationFilter['prov']);
      }
    } else if (locationProvider.mode != LocationSearchMode.national &&
        widget.userModel?.locationParts?['prov'] != null) {
      query = query.where('locationParts.prov',
          isEqualTo: widget.userModel!.locationParts!['prov']);
    }

    if (widget.categoryId != 'all') {
      query = query.where('category', isEqualTo: widget.categoryId);
    }
    final kw2 =
        widget.searchKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw2.isNotEmpty) {
      query = query.where('tags', arrayContains: kw2);
    }
    debugPrint('[지도 디버그] 마커 생성 쿼리: ${query.parameters}');
    return query.orderBy('createdAt', descending: true);
  }

  // 마커 생성 로직은 이제 SharedMapBrowser 내부에서 처리되므로 로컬 함수는 제거했습니다.

  /// local_news 카테고리(categoryId)를 지도/리스트용 아이콘으로 변환
  ///
  /// 카테고리 ID는 `AppCategories.postCategories`에서 정의된 값과 동일:
  /// - daily_life, help_share, incident_report, local_news,
  ///   daily_question, store_promo, etc
  // (기본 아이콘 휴리스틱은 삭제됨 — 이 파일은 이모지 위젯을 사용합니다.)

  // (기존 IconData 기반 헬퍼는 사용하지 않음)

  // 카테고리 ID에서 이모지 텍스트 위젯을 반환합니다.
  Widget _emojiWidgetForCategory(String categoryId) {
    final cat = AppCategories.postCategories.firstWhere(
        (c) => c.categoryId == categoryId,
        orElse: () => AppCategories.postCategories.first);
    return Text(
      cat.emoji,
      style: const TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CameraPosition>(
      future: _getInitialCameraPosition(),
      builder: (context, cameraSnapshot) {
        if (cameraSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // [수정] GoogleMap 직접 사용 -> SharedMapBrowser 사용으로 변경
        // 이로써 핀치 줌, 제스처, 줌 버튼 숨김 등의 공통 기능이 자동 적용됨
        final locationProvider = context.watch<LocationProvider>();
        final bool isNearbyMode =
            locationProvider.mode == LocationSearchMode.nearby;
        final GeoPoint? userPoint =
            locationProvider.user?.geoPoint ?? widget.userModel?.geoPoint;
        final double radiusKm = locationProvider.radiusKm;
        // When in national mode, pass null so _buildAllMarkersQuery won't apply
        // widget.locationFilter fallback.
        return SharedMapBrowser<PostModel>(
          dataStream: _buildAllMarkersQuery()
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) => PostModel.fromFirestore(doc))
                  .toList())
              .map((posts) => isNearbyMode
                  ? _applyNearbyRadius(posts, userPoint, radiusKm)
                  : posts),
          initialCameraPosition: cameraSnapshot.data ??
              const CameraPosition(target: LatLng(-6.2088, 106.8456), zoom: 11),
          locationExtractor: (post) => post.geoPoint,
          idExtractor: (post) => post.id,
          titleExtractor: (post) => legacyExtractTitle(post),
          thumbnailUrlExtractor: (post) =>
              (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
                  ? post.mediaUrl!.first
                  : null,
          categoryIconExtractor: (post) =>
              _emojiWidgetForCategory(post.category),
          cardBuilder: (context, post) =>
              PostCard(key: ValueKey(post.id), post: post),
        );
      },
    );
  }
}

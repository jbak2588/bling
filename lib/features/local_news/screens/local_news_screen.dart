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
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ❌ [태그 시스템] 기존 카테고리 import 제거
// import '../../../core/constants/app_categories.dart';
// ✅ [태그 시스템] 신규 태그 사전 import
import '../../../core/constants/app_tags.dart';
import '../widgets/post_card.dart';
import 'local_news_detail_screen.dart';

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

  // ✅ [태그 시스템] 카테고리 ID 목록 대신 태그 ID 목록으로 변경
  // (AppTags.localNewsTags 중에서 '상시 추천 태그'만 필터링)
  late final List<String> _tagIds;

  // late final List<Widget> _tabViews;
  late final List<Widget> _listTabViews;
  late final List<Widget> _mapTabViews;

  @override
  void initState() {
    super.initState();

    // ✅ [태그 시스템] '상시 추천 태그' 목록을 가져옵니다. (예: AppTags.getRecommendedTags())
    // ❌ ERROR FIX: 'showInFilter' field does not exist in TagInfo.
    // DevLog(Source 62)에 따라 AppTags.localNewsTags를 사용해야 하며,
    // 필터 탭에 표시할 주요 태그 ID 목록을 하드코딩하여 문제를 해결합니다.
    // (tag_recommender.dart의 _urgent 목록 및 주요 태그 참조)
    const List<String> filterableTagIds = [
      'power_outage',
      'water_outage',
      'traffic_control', // 'traffic_diversion' 등 app_tags.dart에 정의된 ID 사용
      'weather_warning',
      'flood_alert',
      'air_quality',
      'disease_alert',
      'community_event', // 주요 일반 태그
      'question', // 주요 일반 태그
      'daily_life', // 주요 일반 태그
    ];

    final recommendedTags = AppTags.localNewsTags
        .where((tag) => filterableTagIds.contains(tag.tagId))
        .toList();
    // 'all' (전체) + 추천 태그 ID 목록
    _tagIds = ['all', ...recommendedTags.map((t) => t.tagId)];

    _tabController = TabController(length: _tagIds.length, vsync: this);

    // ✅ 2. initState에서 탭 페이지 위젯 리스트를 '딱 한 번만' 생성합니다.
    // (category 대신 tagId 전달)
    _listTabViews = _tagIds.map((tagId) {
      return _FeedListView(
        key: PageStorageKey('list_view_$tagId'),
        tagId: tagId, // ✅ category -> tagId
        userModel: widget.userModel,
        locationFilter: widget.locationFilter,
        searchKeywordListenable: _searchKeywordNotifier,
      );
    }).toList();

    _mapTabViews = _tagIds.map((tagId) {
      return _FeedMapView(
        key: PageStorageKey('map_view_$tagId'),
        tagId: tagId, // ✅ category -> tagId
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
            const Text('📰', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('localNewsFeed.allCategory'.tr()), // '전체'
          ],
        ),
      ),
      // AppCategories 대신 AppTags에서 필터링된 태그 목록을 사용
      ...AppTags.localNewsTags
          .where((tag) => _tagIds.contains(tag.tagId)) // initState와 동일한 필터
          .map((tag) {
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tag.emoji ?? '🔹', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(tag.nameKey.tr()), // 태그 이름
            ],
          ),
        );
      }),
    ];

    return Scaffold(
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
                IconButton(
                  icon: Icon(_isMapView ? Icons.list : Icons.map_outlined,
                      color: Colors.grey.shade700),
                  onPressed: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
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
      ),
    );
  }
}

// ✅✅✅ 이 아랫부분이 핵심 수정 영역입니다 ✅✅✅

// ✅ 1. StatelessWidget을 StatefulWidget으로 변경합니다.
class _FeedListView extends StatefulWidget {
  final String tagId; // ✅ category -> tagId
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final ValueListenable<String>? searchKeywordListenable;
  const _FeedListView(
      {super.key,
      required this.tagId, // ✅ category -> tagId
      this.userModel,
      this.locationFilter,
      this.searchKeywordListenable});

  @override
  State<_FeedListView> createState() => _FeedListViewState();
}

// ✅ 2. with AutomaticKeepAliveClientMixin을 추가합니다.
class _FeedListViewState extends State<_FeedListView>
    with AutomaticKeepAliveClientMixin {
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
  Query<Map<String, dynamic>> _buildQuery() {
    // widget.userModel 과 같이 widget.을 붙여서 상위 StatefulWidget의 프로퍼티에 접근합니다.
    final userProv = widget.userModel?.locationParts?['prov'];
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');
    if (userProv != null && userProv.isNotEmpty) {
      query = query.where('locationParts.prov', isEqualTo: userProv);
    }
    // ✅ [태그 시스템] category 쿼리 대신 tag 쿼리 사용
    if (widget.tagId != 'all') {
      // query = query.where('category', isEqualTo: widget.category); // ❌ 제거
      query = query.where('tags',
          arrayContains: widget.tagId); // ✅ 'tags' 필드에 해당 tagId가 포함되어 있는지
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
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = widget.locationFilter;
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
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('localNewsFeed.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})));
        }
        final allDocs = snapshot.data?.docs ?? [];
        final postsDocs = _applyLocationFilter(allDocs);
        if (postsDocs.isEmpty) {
          return Center(child: Text('localNewsFeed.empty'.tr()));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          itemCount: postsDocs.length,
          itemBuilder: (context, index) {
            final post = PostModel.fromFirestore(postsDocs[index]);
            return PostCard(key: ValueKey(post.id), post: post);
          },
        );
      },
    );
  }
}

class _FeedMapView extends StatefulWidget {
  final String tagId; // ✅ category -> tagId
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final ValueListenable<String>? searchKeywordListenable;
  const _FeedMapView(
      {super.key,
      required this.tagId, // ✅ category -> tagId
      this.userModel,
      this.locationFilter,
      this.searchKeywordListenable});

  @override
  State<_FeedMapView> createState() => _FeedMapViewState();
}

class _FeedMapViewState extends State<_FeedMapView> {
  final Completer<GoogleMapController> _controller = Completer();
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
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');
    final filter = widget.locationFilter;

    if (filter != null) {
      if (filter['kel'] != null) {
        query = query.where('locationParts.kel', isEqualTo: filter['kel']);
      } else if (filter['kec'] != null) {
        query = query.where('locationParts.kec', isEqualTo: filter['kec']);
      } else if (filter['kab'] != null) {
        query = query.where('locationParts.kab', isEqualTo: filter['kab']);
      } else if (filter['kota'] != null) {
        query = query.where('locationParts.kota', isEqualTo: filter['kota']);
      } else if (filter['prov'] != null) {
        query = query.where('locationParts.prov', isEqualTo: filter['prov']);
      }
    } else if (widget.userModel?.locationParts?['prov'] != null) {
      query = query.where('locationParts.prov',
          isEqualTo: widget.userModel!.locationParts!['prov']);
    }

    // ✅ [태그 시스템] category 쿼리 대신 tag 쿼리 사용
    if (widget.tagId != 'all') {
      // query = query.where('category', isEqualTo: widget.category); // ❌ 제거
      query = query.where('tags',
          arrayContains: widget.tagId); // ✅ 'tags' 필드에 해당 tagId가 포함되어 있는지
    }
    final kw = widget.searchKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw.isNotEmpty) {
      query = query.where('tags', arrayContains: kw);
    }
    debugPrint('[지도 디버그] 카메라 위치 쿼리: ${query.parameters}');
    return query.orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> _buildAllMarkersQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    if (widget.userModel?.locationParts?['prov'] != null) {
      query = query.where('locationParts.prov',
          isEqualTo: widget.userModel!.locationParts!['prov']);
    }

    // ✅ [태그 시스템] category 쿼리 대신 tag 쿼리 사용
    if (widget.tagId != 'all') {
      // query = query.where('category', isEqualTo: widget.category); // ❌ 제거
      query = query.where('tags',
          arrayContains: widget.tagId); // ✅ 'tags' 필드에 해당 tagId가 포함되어 있는지
    }
    final kw2 =
        widget.searchKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw2.isNotEmpty) {
      query = query.where('tags', arrayContains: kw2);
    }
    debugPrint('[지도 디버그] 마커 생성 쿼리: ${query.parameters}');
    return query.orderBy('createdAt', descending: true);
  }

  Set<Marker> _createMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    debugPrint('[지도 디버그] 마커 생성을 위해 ${docs.length}개의 문서를 받았습니다.');
    final Set<Marker> markers = {};
    for (var doc in docs) {
      final post = PostModel.fromFirestore(doc);
      if (post.geoPoint != null) {
        debugPrint(
            '[지도 디버그] 핀 생성: ${post.id} at ${post.geoPoint!.latitude}, ${post.geoPoint!.longitude}');
        markers.add(Marker(
          markerId: MarkerId(post.id),
          position: LatLng(post.geoPoint!.latitude, post.geoPoint!.longitude),
          infoWindow: InfoWindow(
            title: post.title ?? post.body,
            snippet: post.locationName,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LocalNewsDetailScreen(post: post),
              ));
            },
          ),
        ));
      } else {
        debugPrint('[지도 디버그] 핀 생성 실패 (geoPoint 없음): ${post.id}');
      }
    }
    debugPrint('[지도 디버그] 총 ${markers.length}개의 마커를 생성했습니다.');
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CameraPosition>(
      future: _getInitialCameraPosition(),
      builder: (context, cameraSnapshot) {
        if (cameraSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!cameraSnapshot.hasData) {
          return GoogleMap(
              initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.2088, 106.8456), zoom: 11));
        }
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _buildAllMarkersQuery().snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              debugPrint('[지도 디버그] 게시물 데이터 로딩 중...');
              return const Center(child: CircularProgressIndicator());
            }
            if (postSnapshot.hasError) {
              debugPrint('[지도 디버그] 게시물 데이터 로딩 에러: ${postSnapshot.error}');
              return Center(child: Text('Error: ${postSnapshot.error}'));
            }
            if (!postSnapshot.hasData) {
              debugPrint('[지도 디버그] 게시물 데이터 없음.');
              return Center(child: Text('No posts found.'));
            }

            final markers = _createMarkers(postSnapshot.data!.docs);

            return GoogleMap(
              initialCameraPosition: cameraSnapshot.data!,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              markers: markers,
            );
          },
        );
      },
    );
  }
}

/// ============================================================================
/// Bling 문서헤더
/// 모듈         : 로컬 뉴스(동네 소식)
/// 파일         : lib/features/local_news/screens/local_news_screen.dart
/// 목적         : 사용자의 위치 기반으로 동네 소식 게시글을 조회하고, 카테고리별로 분류된 게시글 목록을 제공합니다.
/// 사용자 가치  : 사용자는 자신의 지역 소식을 빠르게 확인하고, 다양한 카테고리별로 정보를 얻을 수 있습니다.
/// 연결 기능    : lib/features/local_news/screens/create_local_news_screen.dart;
///               lib/features/local_news/screens/edit_local_news_screen.dart
/// 데이터 모델  : 게시글(PostModel)에는 작성자, 내용, 카테고리, 위치 정보, 생성일, 이미지 등이 포함됩니다.
/// 위치 범위    : 사용자의 위치 정보(시/군/구/동 등)를 기반으로 게시글을 필터링합니다.
///
/// ============================================================================///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - Keluharan 기반 동네 소통 피드, 주소 표기는 Singkatan(Kel., Kec., Kab.) 사용
///   - 작성자는 DropDown으로 Kabupaten → Kec. → Kel. 선택, RT/RW 옵션
///   - 카테고리별(공지, 분실물, 일상, 나눔, 안전, 주거, 유머, 기타) 분류
///   - Keluharan 인증 사용자만 글 작성 가능(TrustLevel)
///   - AI 자동 태그 추천, 댓글/좋아요/공유, 공지/신고글 상단 고정, 1:1 채팅, Marketplace 연동
///
/// 2. 실제 코드 분석
///   - 사용자 위치 기반(Local)으로 피드 필터링, 카테고리별 분류, 글 작성/수정/조회 기능
///   - 데이터 모델(PostModel)에 위치 정보, 카테고리, 신뢰등급 등 포함
///   - 위치 필터(시/군/구/동 등)와 연동, 신뢰등급(TrustLevel) 적용
///   - 광고/커뮤니티 연계, 다국어(i18n) 지원, 신고/공지글 관리 등
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 현지화·사용자 경험 강화, 신고/공지글 관리 등 서비스 운영 기능 반영
///   - 기획에 못 미친 점: AI 자동 태그 추천, Marketplace 연동, 1:1 채팅 등 일부 기능 미구현, 광고 슬롯·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 카테고리별 색상/아이콘, 위치 기반 추천, 피드 정렬/필터 강화, 지도 기반 위치 선택, 활동 히스토리/신뢰등급 변화 시각화
///   - 수익화: 지역 광고, 프로모션, 추천글/상품 노출, 프리미엄 기능 연계, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;
// 아래부터 실제 코드

import 'dart:async';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_categories.dart';
import '../widgets/post_card.dart';
import 'local_news_detail_screen.dart';

class LocalNewsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const LocalNewsScreen({this.userModel, this.locationFilter, super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with TickerProviderStateMixin {
  // ... 이 클래스의 모든 코드는 원본과 동일하게 유지됩니다 ...
  late final TabController _tabController;
  bool _isMapView = false;
  final List<String> _categoryIds = [
    'all',
    ...AppCategories.postCategories.map((c) => c.categoryId)
  ];

  late final List<Widget> _tabViews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryIds.length, vsync: this);
    // ✅ 2. initState에서 탭 페이지 위젯 리스트를 '딱 한 번만' 생성합니다.
    _tabViews = _categoryIds.map((categoryId) {
      // _isMapView 상태가 변경되어도 이 위젯들은 재사용되므로,
      // _FeedListView와 _FeedMapView가 모두 포함된 Stack을 사용하고 Visibility로 제어합니다.
      return Stack(
        children: [
          Visibility(
            // key를 사용하여 각 목록의 상태를 명확히 구분합니다.
            // key: PageStorageKey('list_view_$categoryId'),
            visible: !_isMapView,
            // maintainState: true를 추가하여 위젯이 숨겨져도 상태를 유지하도록 합니다.
            maintainState: true,
            child: _FeedListView(
              key: PageStorageKey('list_view_$categoryId'), // ✅ 여기에 추가
              category: categoryId,
              userModel: widget.userModel,
              locationFilter: widget.locationFilter,
            ),
          ),
          Visibility(
            // key: PageStorageKey('map_view_$categoryId'),

            visible: _isMapView,
            maintainState: true,
            child: _FeedMapView(
              key: PageStorageKey('map_view_$categoryId'), // ✅ 여기에 추가
              category: categoryId,
              userModel: widget.userModel,
              locationFilter: widget.locationFilter,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    final List<Widget> tabs = [
      Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📰', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('localNewsFeed.allCategory'.tr()),
          ],
        ),
      ),
      ...AppCategories.postCategories.map((category) {
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(category.nameKey.tr()),
            ],
          ),
        );
      }),
    ];

    return Scaffold(
      body: Column(
        children: [
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
                    tabs: tabs,
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
              children: _tabViews,
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
  final String category;
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const _FeedListView(
      {super.key, required this.category, this.userModel, this.locationFilter});

  @override
  State<_FeedListView> createState() => _FeedListViewState();
}

// ✅ 2. with AutomaticKeepAliveClientMixin을 추가합니다.
class _FeedListViewState extends State<_FeedListView>
    with AutomaticKeepAliveClientMixin {
  // ✅ 3. wantKeepAlive를 true로 설정하여 탭이 전환되어도 이 목록의 상태를 유지시킵니다.
  @override
  bool get wantKeepAlive => true;

  // 기존 _buildQuery와 _applyLocationFilter 함수를 State 안으로 이동
  Query<Map<String, dynamic>> _buildQuery() {
    // widget.userModel 과 같이 widget.을 붙여서 상위 StatefulWidget의 프로퍼티에 접근합니다.
    final userProv = widget.userModel?.locationParts?['prov'];
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');
    if (userProv != null && userProv.isNotEmpty) {
      query = query.where('locationParts.prov', isEqualTo: userProv);
    }
    if (widget.category != 'all') {
      query = query.where('category', isEqualTo: widget.category);
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
  final String category;
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const _FeedMapView(
      {super.key, required this.category, this.userModel, this.locationFilter});

  @override
  State<_FeedMapView> createState() => _FeedMapViewState();
}

class _FeedMapViewState extends State<_FeedMapView> {
  final Completer<GoogleMapController> _controller = Completer();

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

    if (widget.category != 'all') {
      query = query.where('category', isEqualTo: widget.category);
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

    if (widget.category != 'all') {
      query = query.where('category', isEqualTo: widget.category);
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

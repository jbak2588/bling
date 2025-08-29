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
/// 신뢰/정책    : 부적절한 게시글 신고 시 관리자에 의해 제재될 수 있습니다.
/// 수익화       : 직접적인 수익화는 없으나, 지역 광고 및 커뮤니티 활성화에 기여할 수 있습니다. 해야할일 : define local ad slots.
/// 핵심성과지표 : 게시글 작성, 조회, 신고, 카테고리별 조회수 등
/// 분석/로깅    : 게시글 작성/조회/신고 이벤트를 로깅하여 서비스 품질을 분석합니다.
/// 다국어(i18n) : 모든 UI 텍스트와 안내 메시지는 다국어 키를 통해 번역 지원됩니다.
/// 의존성       : cloud_firestore, easy_localization, google_fonts 등
/// 보안/인증    : 로그인한 사용자만 게시글 작성 및 신고가 가능합니다.
/// 엣지 케이스  : 위치 미설정, 게시글 없음, 네트워크 오류, 잘못된 카테고리 등
/// 변경 이력    : 2025-08-26 문서헤더 최초 삽입(자동)
/// 참조 문서    : docs/index/08  로컬 뉴스 모듈 Core.md
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

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_categories.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';

class LocalNewsScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const LocalNewsScreen({this.userModel, this.locationFilter, super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _categoryIds = [
    'all',
    ...AppCategories.postCategories.map((c) => c.categoryId)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryIds.length, vsync: this);
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

    // ✅ Tab 위젯 리스트를 직접 생성합니다.
    final List<Widget> tabs = [
      // '전체' 탭
      Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📰', style: TextStyle(fontSize: 18)), // 대표 이모지
            const SizedBox(width: 8),
            Text('localNewsFeed.allCategory'.tr()),
          ],
        ),
      ),
      // 나머지 카테고리 탭
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
      }).toList(),
    ];

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: const Color(0xFF00A66C),
            unselectedLabelColor: const Color(0xFF616161),
            indicatorColor: const Color(0xFF00A66C),
            indicatorWeight: 2.0,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(),
            // ✅ 생성된 tabs 리스트를 사용합니다.
            tabs: tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categoryIds.map((categoryId) {
                return _FeedCategoryList(
                  key: PageStorageKey('feed_category_$categoryId'),
                  category: categoryId,
                  userModel: widget.userModel,
                  locationFilter: widget.locationFilter,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedCategoryList extends StatelessWidget {
  final String category;
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const _FeedCategoryList(
      {super.key, required this.category, this.userModel, this.locationFilter});

  Query<Map<String, dynamic>> _buildQuery() {
    final userProv = userModel?.locationParts?['prov'];

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    if (userProv != null && userProv.isNotEmpty) {
      query = query.where('locationParts.prov', isEqualTo: userProv);
    }

    if (category != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    return query.orderBy('createdAt', descending: true);
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = locationFilter;
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
    if (key == null) return allDocs;

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
            return PostCard(post: post);
          },
        );
      },
    );
  }
}

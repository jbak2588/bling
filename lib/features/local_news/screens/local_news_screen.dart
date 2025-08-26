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
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import
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

    final List<String> tabs = [
      'localNewsFeed.allCategory'.tr(),
      ...AppCategories.postCategories.map((c) => c.nameKey.tr())
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
            tabs: tabs.map((label) => Tab(text: label)).toList(),
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

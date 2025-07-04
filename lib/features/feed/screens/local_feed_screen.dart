// lib/features/feed/screens/local_feed_screen.dart
// Bling App v0.4
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_model.dart';
import '../widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';

/// 'Local Stories' 탭에 표시될 화면입니다.
/// 카테고리 필터링과 탭별 무한 스크롤 기능이 통합된 최종 버전입니다.
class LocalFeedScreen extends StatefulWidget {
  const LocalFeedScreen({super.key});

  @override
  State<LocalFeedScreen> createState() => _LocalFeedScreenState();
}

class _LocalFeedScreenState extends State<LocalFeedScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> _tabs = [
    '전체',
    ...AppCategories.postCategories.map((c) => c.name)
  ];
  final List<String> _categoryIds = [
    'all',
    ...AppCategories.postCategories.map((c) => c.categoryId)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          // labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
 // ▼▼▼▼▼ 디자인 가이드 적용 ▼▼▼▼▼
         labelColor: const Color(0xFF00A66C), // Primary 컬러
         unselectedLabelColor: const Color(0xFF616161), // TextSecondary 컬러
         indicatorColor: const Color(0xFF00A66C),
         indicatorWeight: 2.0,
         labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
         unselectedLabelStyle: GoogleFonts.inter(),

          tabs: _tabs.map((label) => Tab(text: label)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            // [수정] 각 탭에 해당하는 위젯을 명시적으로 생성하여 가독성을 높입니다.
            children: _categoryIds.map((categoryId) {
              return _FeedCategoryList(
                // 각 탭의 스크롤 위치를 기억하기 위해 고유한 키를 부여합니다.
                key: PageStorageKey('feed_category_$categoryId'),
                category: categoryId,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 특정 카테고리의 게시물 목록을 무한 스크롤로 보여주는 위젯
class _FeedCategoryList extends StatefulWidget {
  final String category;
  const _FeedCategoryList({super.key, required this.category});

  @override
  State<_FeedCategoryList> createState() => __FeedCategoryListState();
}

class __FeedCategoryListState extends State<_FeedCategoryList>
    with AutomaticKeepAliveClientMixin {
  final List<DocumentSnapshot> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _limit = 10;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFirstPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  bool get wantKeepAlive => true; // 탭 이동 후에도 데이터와 스크롤 위치를 유지합니다.

  Future<void> _fetchFirstPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('posts');
      // '전체' 탭이 아니면, 선택된 카테고리로 데이터를 필터링합니다.
      if (widget.category != 'all') {
        query = query.where('category', isEqualTo: widget.category);
      }
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(_limit)
          .get();

      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(querySnapshot.docs);
          _lastDocument =
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
          _hasMore = querySnapshot.docs.length == _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMorePosts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('posts');
      if (widget.category != 'all') {
        query = query.where('category', isEqualTo: widget.category);
      }
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_limit)
          .get();

      if (mounted) {
        setState(() {
          _posts.addAll(querySnapshot.docs);
          _lastDocument =
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
          _hasMore = querySnapshot.docs.length == _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty && !_isLoading) {
      return const Center(child: Text('해당 카테고리에 게시물이 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchFirstPosts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = PostModel.fromFirestore(
              _posts[index] as DocumentSnapshot<Map<String, dynamic>>);
          return PostCard(post: post);
        },
      ),
    );
  }
}

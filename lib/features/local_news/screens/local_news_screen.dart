// lib/features/local_news/screens/local_news_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_model.dart';
import '../widgets/post_card.dart';

class LocalNewsScreen extends StatefulWidget {
  final UserModel? userModel;
  const LocalNewsScreen({this.userModel, super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // ✅ [다국어 수정] '전체' 탭 이름을 다국어 키로 변경합니다.
  // late final List<String> _tabs;

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
          // ✅ [다국어 수정] 위치 미설정 안내 메시지를 다국어 키로 변경합니다.
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

    return Column(
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FeedCategoryList extends StatefulWidget {
  final String category;
  final UserModel? userModel;
  const _FeedCategoryList({super.key, required this.category, this.userModel});

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
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchMorePosts();
    }
  }

  Query _buildQuery({DocumentSnapshot? startAfter}) {
    final userKabupaten = widget.userModel?.locationParts?['kab'];

    Query query = FirebaseFirestore.instance.collection('posts');

    List<String> targetLocations = [];

    if (userKabupaten == 'Tangerang' ||
        userKabupaten == 'Tangerang City' ||
        userKabupaten == 'Tangerang Selatan') {
      targetLocations = ['Tangerang', 'Tangerang City', 'Tangerang Selatan'];
    } else if (userKabupaten != null && userKabupaten.isNotEmpty) {
      targetLocations = [userKabupaten];
    }

    if (targetLocations.isNotEmpty) {
      query = query.where('locationParts.kab', whereIn: targetLocations);
    }

    if (widget.category != 'all') {
      query = query.where('category', isEqualTo: widget.category);
    }

    query = query.orderBy('createdAt', descending: true);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(_limit);
  }

  Future<void> _fetchFirstPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await _buildQuery().get();
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
      final querySnapshot = await _buildQuery(startAfter: _lastDocument).get();
      if (mounted) {
        setState(() {
          _posts.addAll(querySnapshot.docs);
          _lastDocument =
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
              querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
          _hasMore = querySnapshot.docs.length == _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty && !_isLoading) {
      return Center(
        child: RefreshIndicator(
          onRefresh: _fetchFirstPosts,
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  // ✅ [다국어 수정] 게시물 없음 안내 메시지를 다국어 키로 변경합니다.
                  child: Center(child: Text('localNewsFeed.empty'.tr())))),
        ),
      );
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

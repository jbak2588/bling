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
  final Map<String, String?>? locationFilter;
  const LocalNewsScreen({this.userModel, this.locationFilter, super.key});

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
                key: PageStorageKey('feed_category_\$categoryId'),
                category: categoryId,
                userModel: widget.userModel,
                locationFilter: widget.locationFilter,
              );
            }).toList(),
          ),
        ),
      ],
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

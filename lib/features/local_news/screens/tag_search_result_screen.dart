// lib/features/local_news/screens/tag_search_result_screen.dart
///
/// 2025-10-31 (작업 24, 27):
///   - [Phase 6] 통합 검색 UI 리팩토링.
///   - `keyword: String?` 파라미터를 받도록 확장.
///   - `StreamBuilder`에서 `FutureBuilder`로 변경.
///   - `_searchPosts` 함수를 추가하여, 'keyword'가 있을 시 'title'과 'tags' 필드를
///     동시에 쿼리하고, 결과를 클라이언트에서 병합/정렬하도록 수정.
/// ============================================================================
library;
// (파일 내용...)

// lib/features/local_news/screens/tag_search_result_screen.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ✅ Localize tag names and emojis
import 'package:bling_app/core/constants/app_tags.dart';
import 'package:bling_app/i18n/strings.g.dart';

class TagSearchResultScreen extends StatefulWidget {
  // ✅ tags 또는 keyword 둘 중 하나만 받도록 nullable로 유지
  final List<String>? tags;
  final String? keyword;

  const TagSearchResultScreen({
    super.key,
    this.tags,
    this.keyword,
  }) : assert(tags != null || keyword != null,
            'Either tags or keyword must be provided');

  @override
  State<TagSearchResultScreen> createState() => _TagSearchResultScreenState();
}

class _TagSearchResultScreenState extends State<TagSearchResultScreen> {
  late final Future<List<PostModel>> _searchFuture;

  String displayName(String tagId) {
    final info = AppTags.localNewsTags.firstWhere(
      (t) => t.tagId == tagId,
      orElse: () => const TagInfo(
        tagId: '',
        nameKey: '',
        descriptionKey: '',
      ),
    );
    if (info.tagId.isEmpty) return tagId; // fallback to raw id
    return t[info.nameKey];
  }

  String displayEmoji(String tagId) {
    final info = AppTags.localNewsTags.firstWhere(
      (t) => t.tagId == tagId,
      orElse: () => const TagInfo(
        tagId: '',
        nameKey: '',
        descriptionKey: '',
      ),
    );
    return info.emoji ?? '';
  }

  String titleForTags(List<String> tagIds) {
    if (tagIds.isEmpty) return 'Error';
    final items = tagIds.map((id) {
      final name = displayName(id);
      final emoji = displayEmoji(id);
      return emoji.isNotEmpty ? '$emoji $name' : name;
    }).toList();
    if (items.length == 1) return items.first;
    return items.join(' | ');
  }

  String getTitle() {
    if (widget.tags != null && widget.tags!.isNotEmpty) {
      return titleForTags(widget.tags!);
    }
    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      return t.search.resultsTitle.replaceAll('{keyword}', widget.keyword!);
    }
    return t.search.results;
  }

  @override
  void initState() {
    super.initState();
    _searchFuture = _searchPosts();
  }

  /// ✅ '제목'과 '태그'를 동시에 검색 (여러 쿼리 병렬 실행 후 병합)
  Future<List<PostModel>> _searchPosts() async {
    final col = FirebaseFirestore.instance.collection('posts');
    final List<Query<Map<String, dynamic>>> queries = [];

    if (widget.tags != null && widget.tags!.isNotEmpty) {
      // 태그 검색: 최대 10개까지 arrayContainsAny 사용
      queries.add(
        col.where('tags', arrayContainsAny: widget.tags!.take(10).toList()),
      );
    }

    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      final kw = widget.keyword!;
      // 제목 prefix 검색
      queries.add(
        col
            .where('title', isGreaterThanOrEqualTo: kw)
            .where('title', isLessThanOrEqualTo: '$kw\uf8ff'),
      );
      // 태그 정확 매칭 검색 (키워드를 태그로 간주)
      queries.add(
        col.where('tags', arrayContains: kw.toLowerCase()),
      );
    }

    if (queries.isEmpty) return [];

    final snapshots = await Future.wait(queries.map((q) => q.get()));

    // 중복 제거 (doc.id 기준)
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> unique = {};
    for (final snap in snapshots) {
      for (final doc in snap.docs) {
        unique[doc.id] = doc;
      }
    }

    final posts = unique.values.map((d) => PostModel.fromFirestore(d)).toList();
    // 최신순 정렬 (createdAt 내림차순)
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getTitle())),
      body: FutureBuilder<List<PostModel>>(
        future: _searchFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(t.search.empty.message),
            );
          }
          final list = snap.data ?? const <PostModel>[];
          if (list.isEmpty) {
            return Center(child: Text(t.search.empty.message));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final post = list[i];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

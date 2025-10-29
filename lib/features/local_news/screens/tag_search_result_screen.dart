// lib/features/local_news/screens/tag_search_result_screen.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ✅ Localize tag names and emojis
import 'package:bling_app/core/constants/app_tags.dart';
import 'package:easy_localization/easy_localization.dart';

class TagSearchResultScreen extends StatelessWidget {
  final List<String> tags;
  const TagSearchResultScreen({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('posts');
    final q = (tags.length == 1)
        ? col.where('tags', arrayContains: tags.first)
        : col.where('tags', arrayContainsAny: tags.take(10).toList());

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
      return info.nameKey.tr();
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
      if (tagIds.isEmpty) return '#';
      if (tagIds.length == 1) {
        final info = AppTags.localNewsTags.firstWhere(
          (t) => t.tagId == tagIds.first,
          orElse: () => const TagInfo(
            tagId: '',
            nameKey: '',
            descriptionKey: '',
          ),
        );
        final name = info.tagId.isEmpty ? tagIds.first : info.nameKey.tr();
        final emoji = info.emoji ?? '';
        // Always show as `emoji + name` without '#'
        return emoji.isNotEmpty ? '$emoji $name' : name;
      }
      // Multiple: join each as `emoji + name`
      final items = tagIds.map((id) {
        final name = displayName(id);
        final emoji = displayEmoji(id);
        return emoji.isNotEmpty ? '$emoji $name' : name;
      }).toList();
      return items.join('   ');
    }

    return Scaffold(
      appBar: AppBar(title: Text(titleForTags(tags))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('해당 태그의 글이 없습니다.'));
          }
          final docs = snap.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final doc = docs[i];
              final post = PostModel.fromFirestore(doc);
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

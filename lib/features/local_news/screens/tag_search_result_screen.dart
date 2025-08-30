// lib/features/local_news/screens/tag_search_result_screen.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TagSearchResultScreen extends StatelessWidget {
  final String tag;
  const TagSearchResultScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#$tag', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Firestore의 array-contains 쿼리를 사용하여 해당 태그를 포함하는 문서를 찾습니다.
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('tags', arrayContains: tag)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('검색 중 오류가 발생했습니다: ${snapshot.error}'));   // TODO : 다국어 작업
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('\'#$tag\' 태그가 포함된 게시물이 없습니다.'));   // TODO : 다국어 작업
          }

          final postDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: postDocs.length,
            itemBuilder: (context, index) {
              final post = PostModel.fromFirestore(postDocs[index]);
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

// lib/features/post/screens/post_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
// ▼▼▼▼▼ 위젯의 새로운 위치를 기준으로 import 경로 수정 ▼▼▼▼▼
import '../widgets/comment_input_field.dart';
import '../widgets/comment_list_view.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}
class _PostDetailScreenState extends State<PostDetailScreen> {
  // ... (initState 및 다른 모든 함수는 이전과 동일)
  bool _isLiked = false;
  late int _likesCount;
  bool _likeLoading = false;
  String? _activeReplyCommentId;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _commentCount = widget.post.commentsCount;
    _checkLiked();
    _increaseViewsCount();
  }



  void _handleCommentAdded(Map<String, dynamic> newComment) {
    setState(() => _commentCount++);
  }

  Future<void> _handleCommentDeleted() async {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    final postSnap = await postRef.get();
    if (mounted && postSnap.exists) {
      setState(() {
        _commentCount = postSnap.data()?['commentsCount'] ?? 0;
      });
    }
  }

  // 사용자가 이 게시물을 찜했는지 확인하는 함수
  Future<void> _checkLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // users 문서의 bookmarkedPostIds 배열에 이 게시물 ID가 있는지 확인
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted && doc.exists) {
      final userModel = UserModel.fromFirestore(doc);
      setState(() {
        _isLiked =
            userModel.bookmarkedPostIds?.contains(widget.post.id) ?? false;
      });
    }
  }

  // 찜하기/찜취소 로직
  Future<void> _toggleLike() async {
    if (_likeLoading) return;
    setState(() => _likeLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      setState(() => _likeLoading = false);
      return;
    }

    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      if (_isLiked) {
        // 찜 취소: 게시물의 좋아요 수 -1, 사용자 찜 목록에서 ID 제거
        await postRef.update({'likesCount': FieldValue.increment(-1)});
        await userRef.update({
          'bookmarkedPostIds': FieldValue.arrayRemove([widget.post.id])
        });
        setState(() {
          _isLiked = false;
          _likesCount--;
        });
      } else {
        // 찜하기: 게시물의 좋아요 수 +1, 사용자 찜 목록에 ID 추가
        await postRef.update({'likesCount': FieldValue.increment(1)});
        await userRef.update({
          'bookmarkedPostIds': FieldValue.arrayUnion([widget.post.id])
        });
        setState(() {
          _isLiked = true;
          _likesCount++;
        });
      }
    } finally {
      if (mounted) setState(() => _likeLoading = false);
    }
  }

  Future<void> _increaseViewsCount() async {
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    postRef.update({'viewsCount': FieldValue.increment(1)});
  }

  void _handleReplyTap(String commentId) {
    setState(() {
      _activeReplyCommentId =
          (_activeReplyCommentId == commentId) ? null : commentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    // [추가] 게시물 카테고리 정보를 찾습니다.
    final category = AppCategories.postCategories.firstWhere(
      (cat) => cat.categoryId == widget.post.category,
      orElse: () =>
          AppCategories.postCategories.firstWhere((c) => c.categoryId == 'etc'),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title ?? '게시물')),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorInfo(widget.post.userId),
                const SizedBox(height: 16),
                // [추가] 카테고리 뱃지를 표시합니다.
                Chip(
                  avatar: Text(category.emoji,
                      style: const TextStyle(fontSize: 16)),
                  label: Text(category.name),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 8),
                Text(widget.post.title ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(widget.post.body,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5)),
                const SizedBox(height: 16),
                if (widget.post.mediaUrl != null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(widget.post.mediaUrl!)),
                const Divider(height: 32),
                _buildPostStats(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CommentListView(
            postId: widget.post.id,
            postOwnerId: widget.post.userId,
            activeReplyCommentId: _activeReplyCommentId,
            onReplyTap: _handleReplyTap,
            onCommentDeleted: _handleCommentDeleted,
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CommentInputField(
              postId: widget.post.id, onCommentAdded: _handleCommentAdded),
        ),
      ),
    );
  }

  // ... (Helper 위젯들은 이전과 동일)
  Widget _buildAuthorInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final user = UserModel.fromFirestore(snapshot.data!);
          return Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nickname,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(user.locationName ?? '지역 미설정',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          );
        });
  }

  Widget _buildPostStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: _likeLoading ? null : _toggleLike,
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.grey,
            size: 20,
          ),
          label:
              Text('$_likesCount', style: const TextStyle(color: Colors.black)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${widget.post.viewsCount + 1}'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text('$_commentCount'),
          ],
        ),
      ],
    );
  }
}

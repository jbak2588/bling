// lib/features/local_news/screens/local_news_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import '../../../core/constants/app_categories.dart';
import '../models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/comment_input_field.dart';
import '../widgets/comment_list_view.dart';
import 'edit_local_news_screen.dart';


class LocalNewsDetailScreen extends StatefulWidget {
  final PostModel post;
  const LocalNewsDetailScreen({super.key, required this.post});

  @override
  State<LocalNewsDetailScreen> createState() => _LocalNewsDetailScreenState();
}

class _LocalNewsDetailScreenState extends State<LocalNewsDetailScreen> {
  final PageController _pageController = PageController();
  
  bool _isLiked = false;
  late int _likesCount;
  bool _likeLoading = false;
  String? _activeReplyCommentId;
  late int _commentCount;
  late int _thanksCount;
  bool _isThanksProcessing = false;
  late PostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _likesCount = _currentPost.likesCount;
    _commentCount = _currentPost.commentsCount;
    _thanksCount = _currentPost.thanksCount;
    _checkLiked();
    _increaseViewsCount();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshPostData() async {
    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(_currentPost.id)
        .get();
    if (postDoc.exists && mounted) {
      setState(() {
        _currentPost = PostModel.fromFirestore(postDoc);
        _likesCount = _currentPost.likesCount;
        _commentCount = _currentPost.commentsCount;
        _thanksCount = _currentPost.thanksCount;
      });
    }
  }

  void _handleCommentAdded(Map<String, dynamic> newComment) {
    setState(() => _commentCount++);
  }

  Future<void> _handleCommentDeleted() async {
    await _refreshPostData();
  }

  Future<void> _checkLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted && doc.exists) {
      final userModel = UserModel.fromFirestore(doc);
      setState(() {
        _isLiked =
            userModel.bookmarkedPostIds?.contains(_currentPost.id) ?? false;
      });
    }
  }

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
        FirebaseFirestore.instance.collection('posts').doc(_currentPost.id);
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      if (_isLiked) {
        await postRef.update({'likesCount': FieldValue.increment(-1)});
        await userRef.update({
          'bookmarkedPostIds': FieldValue.arrayRemove([_currentPost.id])
        });
        if (mounted) setState(() => _likesCount--);
      } else {
        await postRef.update({'likesCount': FieldValue.increment(1)});
        await userRef.update({
          'bookmarkedPostIds': FieldValue.arrayUnion([_currentPost.id])
        });
        if (mounted) setState(() => _likesCount++);
      }
      if (mounted) setState(() => _isLiked = !_isLiked);
    } finally {
      if (mounted) setState(() => _likeLoading = false);
    }
  }

  Future<void> _increaseViewsCount() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(_currentPost.id)
        .update({'viewsCount': FieldValue.increment(1)});
  }

  void _handleReplyTap(String commentId) {
    setState(() {
      _activeReplyCommentId =
          (_activeReplyCommentId == commentId) ? null : commentId;
    });
  }

  Future<void> _toggleThanks() async {
    if (_isThanksProcessing) return;
    setState(() => _isThanksProcessing = true);
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) {
      setState(() => _isThanksProcessing = false);
      return;
    }
    if (currentUserUid == _currentPost.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('자신의 글에는 감사를 표시할 수 없습니다.')));
      setState(() => _isThanksProcessing = false);
      return;
    }
    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(_currentPost.id);
    final authorRef =
        FirebaseFirestore.instance.collection('users').doc(_currentPost.userId);
    final thanksRef = postRef.collection('thanks').doc(currentUserUid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final thanksDoc = await transaction.get(thanksRef);
        if (thanksDoc.exists) {
          transaction
              .update(postRef, {'thanksCount': FieldValue.increment(-1)});
          transaction.update(
              authorRef, {'feedThanksReceived': FieldValue.increment(-1)});
          transaction.delete(thanksRef);
          if (mounted) setState(() => _thanksCount--);
        } else {
          transaction.update(postRef, {'thanksCount': FieldValue.increment(1)});
          transaction.update(
              authorRef, {'feedThanksReceived': FieldValue.increment(1)});
          transaction
              .set(thanksRef, {'thankedAt': FieldValue.serverTimestamp()});
          if (mounted) setState(() => _thanksCount++);
        }
      });
    } finally {
      if (mounted) setState(() => _isThanksProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final category = AppCategories.postCategories.firstWhere(
      (cat) => cat.categoryId == _currentPost.category,
      orElse: () =>
          AppCategories.postCategories.firstWhere((c) => c.categoryId == 'etc'),
    );
    final hasImages = _currentPost.mediaUrl != null && _currentPost.mediaUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPost.title ?? 'localNewsDetail.appBarTitle'.tr()),
        actions: [
          if (currentUserId != null && currentUserId == _currentPost.userId)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'localNewsDetail.menu.edit'.tr(),
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EditLocalNewsScreen(post: _currentPost),
                  ),
                );
                if (result == true) {
                  _refreshPostData();
                }
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {/* Handle menu selection */},
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                  value: 'report', child: Text('localNewsDetail.menu.report'.tr())),
              PopupMenuItem<String>(
                  value: 'share', child: Text('localNewsDetail.menu.share'.tr())),
            ],
          ),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorInfo(_currentPost.userId),
                const SizedBox(height: 16),
                Chip(
                  avatar: Text(category.emoji,
                      style: const TextStyle(fontSize: 16)),
                  label: Text(category.nameKey.tr()),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 8),
                Text(_currentPost.title ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(_currentPost.body,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5)),
                const SizedBox(height: 16),
                
                // ✅ build 메서드에서 함수를 호출합니다.
                if (hasImages)
                  _buildImageSliderWithIndicator(_currentPost.mediaUrl!),

                const Divider(height: 32),
                _buildPostStats(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CommentListView(
            postId: _currentPost.id,
            postOwnerId: _currentPost.userId,
            activeReplyCommentId: _activeReplyCommentId,
            onReplyTap: _handleReplyTap,
            onCommentDeleted: _handleCommentDeleted,
          ),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              8, 8, 8, MediaQuery.of(context).viewInsets.bottom + 8),
          child: CommentInputField(
            postId: _currentPost.id,
            onCommentAdded: _handleCommentAdded,
            hintText: 'localNewsDetail.buttons.comment'.tr(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSliderWithIndicator(List<String> imageUrls) {
    if (imageUrls.length <= 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageGalleryScreen(
                imageUrls: imageUrls,
                initialIndex: 0,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrls.first, fit: BoxFit.cover),
        ),
      );
    }
    
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageGalleryScreen(
                        imageUrls: imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: imageUrls.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Theme.of(context).colorScheme.primary,
            paintStyle: PaintingStyle.stroke,
          ),
        ),
      ],
    );
  }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.nickname,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        TrustLevelBadge(
                            trustLevel: user.trustLevel, showText: true),
                      ],
                    ),
                    Text(
                      user.locationName ?? 'postCard.locationNotSet'.tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
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
          icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey, size: 20),
          label:
              Text('$_likesCount', style: const TextStyle(color: Colors.black)),
        ),
        TextButton.icon(
          onPressed: _isThanksProcessing ? null : _toggleThanks,
          icon:
              const Icon(Icons.redeem_outlined, size: 20, color: Colors.orange),
          label: Text('$_thanksCount',
              style: const TextStyle(color: Colors.black)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${_currentPost.viewsCount + 1}'),
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

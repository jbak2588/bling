// lib/features/local_news/screens/local_news_detail_screen.dart

import 'package:bling_app/features/shared/widgets/mini_map_view.dart'; // ✅ [수정] 공통 미니맵 위젯 import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ❌ 리소스 충돌을 일으키는 google_maps_flutter 패키지는 더 이상 필요 없으므로 삭제합니다. (주석 유지)
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:share_plus/share_plus.dart'; // ✅ SharePlus import 확인
import '../../../core/constants/app_categories.dart';
import '../models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/comment_input_field.dart';
import '../widgets/comment_list_view.dart';
import 'edit_local_news_screen.dart';
import 'tag_search_result_screen.dart';

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
  bool _isReporting = false; // 신고 처리 중 상태

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

  Widget _buildAuthorInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final user = UserModel.fromFirestore(snapshot.data!);
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: userId),
              ));
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child:
                      user.photoUrl == null ? const Icon(Icons.person) : null,
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
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final category = AppCategories.postCategories.firstWhere(
      (cat) => cat.categoryId == _currentPost.category,
      orElse: () =>
          AppCategories.postCategories.firstWhere((c) => c.categoryId == 'etc'),
    );
    final hasImages =
        _currentPost.mediaUrl != null && _currentPost.mediaUrl!.isNotEmpty;
    final hasLocation = _currentPost.geoPoint != null;

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
            itemBuilder: (context) => _buildPopupMenuItems(context),
            onSelected: (value) => _handleMenuSelection(context, value),
          ),
          // 공유 버튼 추가
          IconButton(
            icon: const Icon(Icons.share),
            // ✅ [수정] onPressed에 바로 _sharePost 연결 및 툴팁 추가
            onPressed: _sharePost,
            tooltip: 'common.share'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                  if (_currentPost.tags.isNotEmpty) ...[
                    _buildTags(context, _currentPost.tags),
                    const SizedBox(height: 16),
                  ],
                  if (hasImages)
                    _buildImageSliderWithIndicator(_currentPost.mediaUrl!),
                  if (hasLocation) ...[
                    const SizedBox(height: 16),
                    // 위치 섹션 제목
                    Text('postCard.location'.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    // ✅ [수정] 잘못된 _buildGoogleMap/_buildMiniMap 호출을 MiniMapView (공통 위젯)으로 교체
                    MiniMapView(
                      location: _currentPost.geoPoint!,
                      markerId: _currentPost.id,
                    ),
                  ],
                  const Divider(height: 32),
                  _buildPostStats(),
                ],
              ),
            ),
            CommentListView(
              postId: _currentPost.id,
              postOwnerId: _currentPost.userId,
              activeReplyCommentId: _activeReplyCommentId,
              onReplyTap: _handleReplyTap,
              onCommentDeleted: _handleCommentDeleted,
            ),
          ],
        ),
      ),
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

  // ✅ [네이티브 딥링킹] 공유 기능 함수
  Future<void> _sharePost() async {
    try {
      // 1. 공유할 웹 URL 생성 (Firebase Hosting 기본 도메인 사용)
      final String postUrl =
          'https://blingbling-app.web.app/post/${_currentPost.id}';

      // 2. 생성된 URL과 함께 공유 메시지 전달
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this post on Bling!\n${_currentPost.title ?? ''}\n\n$postUrl',
          subject: 'Bling Post: ${_currentPost.title ?? ''}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('common.shareError'.tr())),
        );
      }
    } finally {
      // 상태 업데이트 없음
    }
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner =
        currentUserId != null && currentUserId == _currentPost.userId;

    if (isOwner) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(value: 'edit', child: Text('common.edit'.tr())),
        PopupMenuItem(value: 'delete', child: Text('common.delete'.tr())),
      ];
    } else {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(value: 'report', child: Text('common.report'.tr())),
      ];
    }
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (_) => EditLocalNewsScreen(post: _currentPost),
          ),
        )
            .then((result) {
          if (result == true) {
            _refreshPostData();
          }
        });
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
      case 'report':
        _showReportDialog(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('common.delete'.tr()),
        content: Text('localNewsDetail.confirmDelete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deletePost();
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(_currentPost.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('localNewsDetail.deleted'.tr())),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('main.errors.unknown'.tr())),
        );
      }
    }
  }

  // 신고 다이얼로그
  void _showReportDialog(BuildContext context) {
    String? selectedReason;
    final reportReasons = [
      'reportReasons.spam',
      'reportReasons.abuse',
      'reportReasons.inappropriate',
      'reportReasons.illegal',
      'reportReasons.etc',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('reportDialog.title'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: reportReasons.map((reasonKey) {
                    return RadioListTile<String>(
                      title: Text(reasonKey.tr()),
                      value: reasonKey,
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() => selectedReason = value);
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('common.cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: (selectedReason != null && !_isReporting)
                      ? () async {
                          Navigator.pop(dialogContext);
                          await _submitReport(context, selectedReason!);
                        }
                      : null,
                  child: _isReporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('common.report'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(BuildContext context, String reasonKey) async {
    if (_isReporting) return;

    final reporterId = FirebaseAuth.instance.currentUser?.uid;
    if (reporterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('main.errors.loginRequired'.tr())));
      return;
    }

    if (_currentPost.userId == reporterId) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reportDialog.cannotReportSelf'.tr())));
      return;
    }

    setState(() => _isReporting = true);
    try {
      final reportData = {
        'reportedContentId': _currentPost.id,
        'reportedContentType': 'post',
        'reportedUserId': _currentPost.userId,
        'reporterUserId': reporterId,
        'reason': reasonKey,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('reportDialog.success'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'reportDialog.fail'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  Widget _buildTags(BuildContext context, List<String> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TagSearchResultScreen(tag: tag),
            ));
          },
          borderRadius: BorderRadius.circular(16),
          child: Chip(
            label: Text('#$tag', style: const TextStyle(fontSize: 12)),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.grey[200],
          ),
        );
      }).toList(),
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

  // ✅ [수정] 버그의 원인이었던 _buildGoogleMap/_buildMiniMap 함수 전체 삭제 (MiniMapView로 대체)
}

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
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart'; // 🗑️ Dynamic Links 제거
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:any_link_preview/any_link_preview.dart'; // ✅ 링크 미리보기 import
// ✅ [수정] url_launcher import 경로 확인 (기존 코드에 없었을 수 있음)
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart'; // ✅ SharePlus import 확인
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';
// ❌ [태그 시스템] 기존 카테고리 import 제거
// import '../../../core/constants/app_categories.dart';
// ✅ [태그 시스템] 태그 사전 import 추가
import '../../../core/constants/app_tags.dart';

// 태그 검색 화면 네비게이션을 위해 import
import 'tag_search_result_screen.dart';
import '../models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/comment_input_field.dart';
import '../widgets/comment_list_view.dart';
import 'edit_local_news_screen.dart';

class LocalNewsDetailScreen extends StatefulWidget {
  final PostModel post;
  // When embedded into the main shell, set `embedded=true` to hide its
  // internal AppBar and use the parent's AppBar/back handling.
  final bool embedded;
  final VoidCallback? onClose;

  const LocalNewsDetailScreen({
    super.key,
    required this.post,
    this.embedded = false,
    this.onClose,
  });

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
                          // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
                          TrustLevelBadge(
                              trustLevelLabel: user.trustLevelLabel),
                        ],
                      ),
                      Text(
                        // 요청: 전체 주소 대신 kel만 표시
                        user.locationParts?['kel'] ??
                            'postCard.locationNotSet'.tr(),
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
    final hasImages =
        _currentPost.mediaUrl != null && _currentPost.mediaUrl!.isNotEmpty;
    final hasLocation = _currentPost.geoPoint != null;

    // If embedded into the app shell, do not render an inner AppBar.
    // The parent `MainNavigationScreen` will show the AppBar and provide
    // the back behavior via its leading icon.
    if (widget.embedded) {
      return Scaffold(
        // no appBar when embedded
        body: SingleChildScrollView(
          // ✅ 키보드 문제 해결 위해 CommentInputField를 bottomNavigationBar로 이동하고, 본문에 충분한 하단 패딩 확보
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthorInfo(_currentPost.userId),
              const SizedBox(height: 16),
              _buildTitleAndTags(context, _currentPost),
              const SizedBox(height: 16),
              Text(
                _currentPost.body,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.5),
              ),
              // ✅ [링크 미리보기] 본문 아래에 미리보기 카드 추가
              _buildLinkPreview(_currentPost.body),
              const SizedBox(height: 16),
              // [NEW] 태그 칩 노출 (ClickableTagList)
              // ✅ 본문 아래 #태그 중복 노출 제거: 상단 칩만 유지
              if (hasImages)
                _buildImageSliderWithIndicator(_currentPost.mediaUrl!),
              if (hasLocation) ...[
                const SizedBox(height: 16),
                // 위치 섹션 제목
                Text('postCard.location'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                MiniMapView(
                  location: _currentPost.geoPoint!,
                  markerId: _currentPost.id,
                ),
              ],
              const Divider(height: 32),
              _buildPostStats(),
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
        bottomNavigationBar: CommentInputField(
          postId: _currentPost.id,
          onCommentAdded: _handleCommentAdded,
          hintText: 'commentInputField.hintText'.tr(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () {
              if (widget.embedded) {
                widget.onClose?.call();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: Text(_currentPost.title ?? 'localNewsDetail.appBarTitle'.tr()),
        actions: [
          if (currentUserId != null && currentUserId == _currentPost.userId)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.edit_outlined,
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
            ),
          PopupMenuButton<String>(
            itemBuilder: (context) => _buildPopupMenuItems(context),
            onSelected: (value) => _handleMenuSelection(context, value),
          ),
          // 공유 버튼 추가
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppBarIcon(
              icon: Icons.share,
              onPressed: _sharePost,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // ✅ 키보드 문제 해결 위해 CommentInputField를 bottomNavigationBar로 이동하고, 본문에 충분한 하단 패딩 확보
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorInfo(_currentPost.userId),
            const SizedBox(height: 16),
            _buildTitleAndTags(context, _currentPost),
            const SizedBox(height: 16),
            Text(
              _currentPost.body,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            // ✅ [링크 미리보기] 본문 아래에 미리보기 카드 추가
            _buildLinkPreview(_currentPost.body),
            const SizedBox(height: 16),
            // [NEW] 태그 칩 노출 (ClickableTagList)
            // ✅ 본문 아래 #태그 중복 노출 제거: 상단 칩만 유지
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
      // ✅ [키보드 문제 해결] CommentInputField를 bottomNavigationBar로 이동 (Scaffold가 자동으로 키보드 위로 올림)
      bottomNavigationBar: CommentInputField(
        postId: _currentPost.id,
        onCommentAdded: _handleCommentAdded,
        hintText: 'commentInputField.hintText'.tr(),
      ),
    );
  }

  // ✅ [네이티브 딥링킹] 공유 기능 함수
  Future<void> _sharePost() async {
    try {
      // 1. 공유할 웹 URL 생성 (Firebase Hosting 기본 도메인 사용)
      //    URL 형식: https://<your-project-id>.web.app/post/<postId>
      final String postUrl =
          'https://blingbling-app.web.app/post/${widget.post.id}'; // 👈 Firebase Hosting 도메인 및 경로

      // 2. 생성된 URL과 함께 공유 메시지 전달 (✅ 수정: 인스턴스 API 및 ShareParams 사용)
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this post on Bling!\n${widget.post.title ?? ''}\n\n$postUrl', // ✅ URL 포함
          subject: 'Bling Post: ${widget.post.title ?? ''}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('common.shareError'.tr()))); // 다국어 필요
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
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: reportReasons.map((reasonKey) {
                        final isSelected = selectedReason == reasonKey;
                        return ChoiceChip(
                          label: Text(reasonKey.tr()),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => selectedReason = reasonKey),
                        );
                      }).toList(),
                    ),
                  ],
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

    // ✅ [Exception Fix] await 전에 ScaffoldMessenger 참조 저장
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
      // ✅ [Exception Fix] 저장된 참조 사용
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('reportDialog.success'.tr())),
      );
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
      // ✅ [Exception Fix] 저장된 참조 사용
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'reportDialog.fail'.tr(namedArgs: {'error': e.toString()}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  // ✅ [태그 시스템 수정] 제목과 태그 목록 표시 위젯
  Widget _buildTitleAndTags(BuildContext context, PostModel post) {
    // PostModel의 tags 리스트에서 TagInfo 객체 리스트 생성
    final List<TagInfo> tagInfos = post.tags
        .map((tagId) => AppTags.localNewsTags.firstWhere(
              (tagInfo) => tagInfo.tagId == tagId,
              // ✅ [i18n 버그 수정] AppTags에 없는 tagId라면
              // nameKey에 tagId를 두고, emoji에 기본 아이콘을 부여해 키 노출 대신 태그 ID 자체가 보이도록 처리
              orElse: () => TagInfo(
                tagId: tagId,
                nameKey: tagId,
                descriptionKey: '',
                emoji: '🏷️',
              ),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tagInfos.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: tagInfos
                .map(
                  (tagInfo) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TagSearchResultScreen(tags: [tagInfo.tagId]),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Chip(
                      // 표준화: 레이블에 "이모지 + 이름" 표시
                      label: Text(
                        '${tagInfo.emoji != null && tagInfo.emoji!.isNotEmpty ? '${tagInfo.emoji!} ' : ''}${tagInfo.nameKey.tr()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                )
                .toList(),
          ),

        // 게시글 제목 (옵션)
        if (post.title != null && post.title!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            post.title!,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }

  // (Deprecated) 개별 태그 칩 렌더링은 ClickableTagList로 대체되었습니다.

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

// ✅ [링크 미리보기] 링크 미리보기 위젯 빌더 함수
Widget _buildLinkPreview(String text) {
  // 본문 텍스트에서 첫 번째 URL 추출 (간단한 정규식 사용)
  // 더 강력한 URL 감지를 원하면 linkify 패키지 등 사용 가능
  final urlRegExp = RegExp(r'(https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/\S*)?');
  final match = urlRegExp.firstMatch(text);
  final String? rawUrl = match?.group(0);

  if (rawUrl == null || rawUrl.isEmpty) {
    return const SizedBox.shrink(); // URL 없으면 아무것도 표시 안 함
  }

  // 스킴 누락 시 https:// 프리픽스 부여
  final String normalizedUrl =
      rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';

  return Padding(
    padding: const EdgeInsets.only(top: 16.0), // 본문과의 간격
    child: AnyLinkPreview(
      link: normalizedUrl,
      displayDirection: UIDirection.uiDirectionHorizontal, // 가로형 카드
      showMultimedia: true, // 이미지 표시
      bodyMaxLines: 3, // 설명 최대 3줄
      bodyTextOverflow: TextOverflow.ellipsis,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      bodyStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
      errorTitle: 'linkPreview.errorTitle'.tr(),
      errorBody: 'linkPreview.errorBody'.tr(),
      errorWidget: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.grey[200],
        child: Text('linkPreview.errorBody'.tr()),
      ),
      cache: const Duration(days: 7), // 미리보기 정보 캐시 기간
      backgroundColor: Colors.grey[100],
      borderRadius: 12,
      removeElevation: true,
      onTap: () async {
        final uri = Uri.parse(normalizedUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    ),
  );
}

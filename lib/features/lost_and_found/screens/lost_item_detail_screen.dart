// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 상세 정보, 이미지, 채팅 연동, 현상금, 위치 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 이미지, 채팅 연동, 현상금, 위치 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 분실자/습득자 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/현상금 UX 개선.
// =====================================================
// lib/features/lost_and_found/screens/lost_item_detail_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 상세 정보, 이미지, 채팅 연동, 현상금, 위치 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 이미지, 채팅 연동, 현상금, 위치 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 분실자/습득자 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/현상금 UX 개선.
// =====================================================

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/screens/edit_lost_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/models/chat_room_model.dart';
// ✅ [작업 44] 현상금 포맷을 위해 추가

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
// ✅ [작업 42] 공용 댓글 위젯 import
import 'package:bling_app/features/local_news/widgets/comment_input_field.dart';
import 'package:bling_app/features/local_news/widgets/comment_list_view.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';
import 'package:bling_app/features/user_profile/screens/user_profile_screen.dart'; // ✅ [작업 9] 프로필 이동을 위해 추가

// [수정] StatelessWidget -> StatefulWidget으로 변경
class LostItemDetailScreen extends StatefulWidget {
  final LostItemModel item;
  final bool embedded;
  final VoidCallback? onClose;
  const LostItemDetailScreen(
      {super.key, required this.item, this.embedded = false, this.onClose});

  @override
  State<LostItemDetailScreen> createState() => _LostItemDetailScreenState();
}

// [추가 코드]
// ✅ [작업 3] 별도 위젯으로 분리한 해결/미담 작성 바텀시트
class _ResolveBottomSheet extends StatefulWidget {
  final List<UserModel> candidates;
  final Function(String?, String?) onConfirm;
  final String itemType; // 'lost' or 'found'

  const _ResolveBottomSheet(
      {required this.candidates,
      required this.onConfirm,
      required this.itemType});

  @override
  State<_ResolveBottomSheet> createState() => _ResolveBottomSheetState();
}

class _ResolveBottomSheetState extends State<_ResolveBottomSheet> {
  String? _selectedUserId;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Choose copy depending on whether this is a lost or found item
          Text(
              widget.itemType == 'lost'
                  ? 'lostAndFound.resolve.whoHelpedLost'.tr()
                  : 'lostAndFound.resolve.whoReturnedFound'.tr(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (widget.candidates.isEmpty)
            Text('lostAndFound.resolve.noCandidates'.tr(),
                style: const TextStyle(color: Colors.grey)),
          if (widget.candidates.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.candidates.length,
                itemBuilder: (context, index) {
                  final user = widget.candidates[index];
                  final isSelected = _selectedUserId == user.uid;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUserId = isSelected ? null : user.uid;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              if (isSelected)
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.green,
                                    child: Icon(Icons.check,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(user.nickname,
                              style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            widget.itemType == 'lost'
                ? 'lostAndFound.resolve.leaveReview'.tr()
                : 'lostAndFound.resolve.leaveReviewFound'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              hintText: widget.itemType == 'lost'
                  ? 'lostAndFound.resolve.reviewHint'.tr()
                  : 'lostAndFound.resolve.reviewHintFound'.tr(),
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(
                    _selectedUserId, _reviewController.text.trim());
                Navigator.of(context).pop();
              },
              child: Text('lostAndFound.detail.markAsResolved'.tr()),
            ),
          ),
          const SizedBox(height: 8),
          // 옵션: 앱 외부/오프라인에서 해결된 경우, resolverId 없이 후기만 남기고 해결 처리
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                widget.onConfirm(null, _reviewController.text.trim());
                Navigator.of(context).pop();
              },
              child: Text('lostAndFound.resolve.offlineResolved'.tr()),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LostItemDetailScreenState extends State<LostItemDetailScreen> {
  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ChatService _chatService = ChatService();

  // ✅ [작업 42] 댓글/조회수 상태 관리
  late LostItemModel _currentItem;
  late int _commentCount;
  late int _viewsCount;
  String? _activeReplyCommentId;
  // 댓글 입력 위치로 스크롤하기 위한 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _commentCount = _currentItem.commentsCount;
    _viewsCount = _currentItem.viewsCount;
    _increaseViewsCount();
  }

  Future<void> _increaseViewsCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('lost_and_found')
          .doc(_currentItem.id)
          .update({'viewsCount': FieldValue.increment(1)});
      if (!mounted) return;
      setState(() => _viewsCount++);
    } catch (_) {
      // No-op
    }
  }

  void _handleCommentAdded(Map<String, dynamic> _) {
    setState(() => _commentCount++);
  }

  Future<void> _handleCommentDeleted() async {
    // ✅ [작업 43] 새로고침 대신 카운트 즉시 차감
    setState(() => _commentCount--);
  }

  void _handleReplyTap(String commentId) {
    setState(() {
      _activeReplyCommentId =
          (_activeReplyCommentId == commentId) ? null : commentId;
    });
  }

  void _scrollToCommentInput() {
    // 현재 리스트의 최하단(댓글 입력란 위치)으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startChat(BuildContext context) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        otherUserId: widget.item.userId,
        lostItemId: widget.item.id,
        lostItemTitle: widget.item.itemDescription,
        lostItemImage: widget.item.imageUrls.isNotEmpty
            ? widget.item.imageUrls.first
            : null,
        contextType: widget.item.type,
      );

      final otherUser = await _chatService.getOtherUserInfo(widget.item.userId);

      if (!context.mounted) return;

      if (widget.embedded && widget.onClose != null) widget.onClose!();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: widget.item.itemDescription,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('lostAndFound.detail.chatError'
              .tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // [추가] 게시글 삭제 로직
  Future<void> _deleteItem() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('lostAndFound.detail.deleteTitle'.tr()),
        content: Text('lostAndFound.detail.deleteContent'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('lostAndFound.detail.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('lostAndFound.detail.delete'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteItem(widget.item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('lostAndFound.detail.deleteSuccess'.tr()),
              backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('lostAndFound.detail.deleteFail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = widget.item.userId == currentUserId;
    // ✅ [작업 41] 1. 이미 해결된 아이템인지 확인
    final bool isResolved = widget.item.isResolved;
    final Color typeColor =
        widget.item.type == 'lost' ? Colors.redAccent : Colors.blueAccent;

    final Widget content = ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      children: [
        // ✅ 기존 이미지를 공용 이미지 캐러셀로 교체 (해결된 경우 오버레이 표시)
        if (_currentItem.imageUrls.isNotEmpty)
          GestureDetector(
            onTap: () {
              if (widget.embedded && widget.onClose != null) widget.onClose!();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ImageGalleryScreen(imageUrls: _currentItem.imageUrls),
              ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: [
                  ImageCarouselCard(
                    storageId: _currentItem.id,
                    imageUrls: _currentItem.imageUrls,
                    height: 250,
                  ),
                  if (_currentItem.isResolved)
                    Positioned.fill(
                      child: Container(
                        color: (_currentItem.type == 'lost'
                                ? Colors.green
                                : Colors.orange)
                            .withValues(alpha: 0.65),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _currentItem.type == 'lost'
                                  ? 'lostAndFound.card.foundIt'.tr()
                                  : 'lostAndFound.card.returned'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Chip(
          label: Text(widget.item.type == 'lost'
              ? 'lostAndFound.lost'.tr()
              : 'lostAndFound.found'.tr()),
          backgroundColor: typeColor.withValues(alpha: 0.1),
          labelStyle: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
          side: BorderSide(color: typeColor),
        ),
        const SizedBox(height: 8),
        Text(widget.item.itemDescription,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const Divider(height: 32),
        _buildInfoRow(
            context,
            Icons.location_on_outlined,
            'lostAndFound.detail.location'.tr(),
            widget.item.locationDescription),

        const SizedBox(height: 16),

        // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
        ClickableTagList(tags: _currentItem.tags),

        // ✅ [작업 50] 감사 리뷰 카드: 해결된 게시글에 작성된 후기 표시
        if (_currentItem.isResolved &&
            _currentItem.reviewText != null &&
            _currentItem.reviewText!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('lostAndFound.detail.reviewTitle'.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('"${_currentItem.reviewText!}"'),
                if (_currentItem.resolverId != null) ...[
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel>(
                    future:
                        _chatService.getOtherUserInfo(_currentItem.resolverId!),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final user = snap.data!;
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfileScreen(userId: user.uid),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? const Icon(Icons.person, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '- ${'lostAndFound.detail.helpedBy'.tr(namedArgs: {
                                      'name': user.nickname
                                    })}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
        ],

        // ✅ [작업 44] 1. 현상금 정보 표시
        if (_currentItem.isHunted && (_currentItem.bountyAmount ?? 0) > 0) ...[
          const SizedBox(height: 24),
          _buildInfoRow(
            context,
            Icons.paid_outlined,
            'lostAndFound.detail.bounty'.tr(), // '현상금'
            NumberFormat.currency(
              locale: context.locale.toString(),
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(_currentItem.bountyAmount!),
            color: Colors.orange,
          ),
        ],
        if (widget.item.geoPoint != null) ...[
          const SizedBox(height: 16),
          MiniMapView(
              location: widget.item.geoPoint!, markerId: widget.item.id),
        ],
        const Divider(height: 32),
        _buildLostItemStats(),
        const Divider(height: 32),
        Text('lostAndFound.detail.registrant'.tr(),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        // ✅ 기존 _buildOwnerInfo를 공용 AuthorProfileTile로 교체
        AuthorProfileTile(userId: widget.item.userId),

        // ✅ 댓글 입력 및 목록
        const Divider(height: 32),
        Text('common.comments'.tr(),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        CommentListView(
          postId: _currentItem.id,
          postOwnerId: _currentItem.userId,
          collectionPath: 'lost_and_found',
          activeReplyCommentId: _activeReplyCommentId,
          onReplyTap: _handleReplyTap,
          onCommentDeleted: _handleCommentDeleted,
        ),
        const SizedBox(height: 12),
        // 항상 표시되는 댓글 입력란 (본문 맨 하단)
        CommentInputField(
          postId: _currentItem.id,
          collectionPath: 'lost_and_found',
          onCommentAdded: _handleCommentAdded,
          hintText: 'commentInputField.hintText'.tr(),
        ),

        const SizedBox(height: 80),
      ],
    );

    if (widget.embedded) {
      return Container(color: Colors.white, child: content);
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () {
              if (widget.embedded && widget.onClose != null) {
                widget.onClose!();
                return;
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text('lostAndFound.detail.title'.tr()),
        // V V V --- [추가] 작성자에게만 보이는 수정/삭제 버튼 --- V V V
        actions: [
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.edit_note_outlined,
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (_) =>
                                EditLostItemScreen(item: widget.item)),
                      )
                      .then((_) => setState(() {})); // 수정 후 돌아왔을 때 화면 갱신
                },
              ),
            ),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.delete_outline,
                onPressed: _deleteItem,
              ),
            ),
        ],
        // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        children: [
          // ✅ 기존 이미지를 공용 이미지 캐러셀로 교체 (해결된 경우 오버레이 표시)
          if (_currentItem.imageUrls.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ImageGalleryScreen(imageUrls: _currentItem.imageUrls),
              )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Stack(
                  children: [
                    ImageCarouselCard(
                      storageId: _currentItem.id,
                      imageUrls: _currentItem.imageUrls,
                      height: 250,
                    ),
                    if (_currentItem.isResolved)
                      Positioned.fill(
                        child: Container(
                          color: (_currentItem.type == 'lost'
                                  ? Colors.green
                                  : Colors.orange)
                              .withValues(alpha: 0.65),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _currentItem.type == 'lost'
                                    ? 'lostAndFound.card.foundIt'.tr()
                                    : 'lostAndFound.card.returned'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Chip(
            label: Text(widget.item.type == 'lost'
                ? 'lostAndFound.lost'.tr()
                : 'lostAndFound.found'.tr()),
            backgroundColor: typeColor.withValues(alpha: 0.1),
            labelStyle:
                TextStyle(color: typeColor, fontWeight: FontWeight.bold),
            side: BorderSide(color: typeColor),
          ),
          const SizedBox(height: 8),
          Text(widget.item.itemDescription,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          _buildInfoRow(
              context,
              Icons.location_on_outlined,
              'lostAndFound.detail.location'.tr(),
              widget.item.locationDescription),

          const SizedBox(height: 16),

          // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
          ClickableTagList(tags: _currentItem.tags),

          // ✅ [작업 50] 감사 리뷰 카드: 해결된 게시글에 작성된 후기 표시
          if (_currentItem.isResolved &&
              _currentItem.reviewText != null &&
              _currentItem.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('lostAndFound.detail.reviewTitle'.tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('"${_currentItem.reviewText!}"'),
                  if (_currentItem.resolverId != null) ...[
                    const SizedBox(height: 8),
                    FutureBuilder<UserModel>(
                      future: _chatService
                          .getOtherUserInfo(_currentItem.resolverId!),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox.shrink();
                        final user = snap.data!;
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserProfileScreen(userId: user.uid),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? const Icon(Icons.person, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '- ${'lostAndFound.detail.helpedBy'.tr(namedArgs: {
                                      'name': user.nickname
                                    })}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
          ],

          // ✅ [작업 44] 1. 현상금 정보 표시
          if (_currentItem.isHunted &&
              (_currentItem.bountyAmount ?? 0) > 0) ...[
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              Icons.paid_outlined,
              'lostAndFound.detail.bounty'.tr(), // '현상금'
              NumberFormat.currency(
                locale: context.locale.toString(),
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(_currentItem.bountyAmount!),
              color: Colors.orange,
            ),
          ],
          if (widget.item.geoPoint != null) ...[
            const SizedBox(height: 16),
            MiniMapView(
                location: widget.item.geoPoint!, markerId: widget.item.id),
          ],
          const Divider(height: 32),
          _buildLostItemStats(),
          const Divider(height: 32),
          Text('lostAndFound.detail.registrant'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // ✅ 기존 _buildOwnerInfo를 공용 AuthorProfileTile로 교체
          AuthorProfileTile(userId: widget.item.userId),

          // ✅ 댓글 입력 및 목록
          const Divider(height: 32),
          Text('common.comments'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          CommentListView(
            postId: _currentItem.id,
            postOwnerId: _currentItem.userId,
            collectionPath: 'lost_and_found',
            activeReplyCommentId: _activeReplyCommentId,
            onReplyTap: _handleReplyTap,
            onCommentDeleted: _handleCommentDeleted,
          ),
          const SizedBox(height: 12),
          // 항상 표시되는 댓글 입력란 (본문 맨 하단)
          CommentInputField(
            postId: _currentItem.id,
            collectionPath: 'lost_and_found',
            onCommentAdded: _handleCommentAdded,
            hintText: 'commentInputField.hintText'.tr(),
          ),

          const SizedBox(height: 80),
        ],
      ),
      // ✅ [작업 41] 2. 하단 버튼 로직 수정
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // 1. 이미 해결됨: 비활성화 + "해결 완료" 텍스트
          onPressed: isResolved
              ? null
              : () {
                  // 2. 작성자(Owner)인 경우: '해결 완료' 다이얼로그 호출
                  if (isOwner) {
                    _showResolveDialog(context); // ✅ 함수 변경됨
                  } else {
                    // 3. 타인인 경우: '연락하기' (채팅) 함수 호출
                    _startChat(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            // 이미 해결되었으면 회색으로 변경
            backgroundColor: isResolved ? Colors.grey : null,
          ),
          child: Text(
            isResolved
                ? 'lostAndFound.detail.resolved'.tr() // "해결 완료"
                : isOwner
                    ? 'lostAndFound.detail.markAsResolved'.tr() // "해결 완료로 표시"
                    : 'lostAndFound.detail.contact'.tr(), // "연락하기"
          ),
        ),
      ),
    );
  }

  // ✅ [작업 41] 3. '해결 완료' 확인 팝업 및 Firestore 업데이트 로직
  // ✅ [작업 3] 해결 처리 및 미담 작성 다이얼로그 로직
  Future<void> _showResolveDialog(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 채팅방 목록 조회 (1회성)
      final allChats = await _chatService.getChatRoomsStream().first;

      // 현재 아이템과 연관된 채팅방 필터링
      final relatedChats =
          allChats.where((room) => room.lostItemId == widget.item.id).toList();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // 로딩 닫기

      // 2. 채팅 상대방 ID 목록 추출
      List<String> candidateIds = [];
      for (var room in relatedChats) {
        final otherId = room.participants
            .firstWhere((uid) => uid != currentUser.uid, orElse: () => '');
        if (otherId.isNotEmpty) candidateIds.add(otherId);
      }
      candidateIds = candidateIds.toSet().toList(); // 중복 제거

      // 사용자 정보 조회
      Map<String, UserModel> candidatesMap = {};
      if (candidateIds.isNotEmpty) {
        candidatesMap = await _chatService.getParticipantsInfo(candidateIds);
      }

      if (!context.mounted) return;

      // 3. 바텀시트 표시
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _ResolveBottomSheet(
          candidates: candidatesMap.values.toList(),
          onConfirm: (selectedUserId, review) async {
            try {
              // Repository 호출
              await _repository.resolveItemWithReview(
                itemId: widget.item.id,
                resolverId: selectedUserId,
                reviewText: review,
              );

              // 선택된 이웃이 있다면 관련 채팅방에 시스템 감사 메시지 전송
              if (selectedUserId != null) {
                try {
                  ChatRoomModel? targetRoom;
                  for (var room in relatedChats) {
                    if (room.participants.contains(selectedUserId)) {
                      targetRoom = room;
                      break;
                    }
                  }
                  if (targetRoom != null) {
                    final systemMsg = 'lostAndFound.resolve.systemMessage'.tr();
                    await _chatService.sendMessage(
                      targetRoom.id,
                      systemMsg,
                      otherUserId: selectedUserId,
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to send resolve system message: $e');
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('lostAndFound.resolve.success'.tr())));
                Navigator.of(context).pop(); // 화면 닫기
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('lostAndFound.error'
                        .tr(namedArgs: {'error': e.toString()})),
                    backgroundColor: Colors.red));
              }
            }
          },
          itemType: widget.item.type,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // 에러 시 로딩 닫기
      debugPrint('Error in resolve dialog: $e');
    }
  }

  // ✅ 통계 위젯
  Widget _buildLostItemStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                size: 20, color: Colors.grey),
            const SizedBox(width: 4),
            Text('$_viewsCount'),
          ],
        ),
        // 댓글 아이콘 클릭 시 하단 댓글 입력란으로 스크롤
        InkWell(
          onTap: _scrollToCommentInput,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$_commentCount'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String text,
      {Color? color}) {
    // ✅ [작업 44] 강조 색상 파라미터 추가
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20), // ✅ 색상 적용
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color ?? Colors.grey[700],
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color)),
            ],
          ),
        )
      ],
    );
  }
}

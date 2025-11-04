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
// import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/screens/edit_lost_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// ✅ [작업 44] 현상금 포맷을 위해 추가

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
// ✅ [작업 42] 공용 댓글 위젯 import
import 'package:bling_app/features/local_news/widgets/comment_input_field.dart';
import 'package:bling_app/features/local_news/widgets/comment_list_view.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class LostItemDetailScreen extends StatefulWidget {
  final LostItemModel item;
  const LostItemDetailScreen({super.key, required this.item});

  @override
  State<LostItemDetailScreen> createState() => _LostItemDetailScreenState();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('lostAndFound.detail.title'.tr()),
        // V V V --- [추가] 작성자에게만 보이는 수정/삭제 버튼 --- V V V
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: 'lostAndFound.detail.editTooltip'.tr(),
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
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'lostAndFound.detail.deleteTooltip'.tr(),
              onPressed: _deleteItem,
            ),
        ],
        // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        children: [
          // ✅ 기존 이미지를 공용 이미지 캐러셀로 교체
          if (widget.item.imageUrls.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ImageGalleryScreen(imageUrls: widget.item.imageUrls),
              )),
              child: ImageCarouselCard(
                storageId: widget.item.id,
                imageUrls: widget.item.imageUrls,
                height: 250,
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
                  // 2. 작성자(Owner)인 경우: '해결 완료' 함수 호출
                  if (isOwner) {
                    _markAsResolved(context);
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
  Future<void> _markAsResolved(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('lostAndFound.resolve.confirmTitle'.tr()),
        content: Text('lostAndFound.resolve.confirmBody'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('lostAndFound.detail.markAsResolved'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('lost_and_found')
            .doc(widget.item.id)
            .update({
          'isResolved': true,
          'resolvedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('lostAndFound.resolve.success'.tr())),
          );
          // 화면을 닫거나 새로고침 (여기서는 닫기)
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'common.error'.tr(namedArgs: {'error': e.toString()}),
              ),
            ),
          );
        }
      }
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

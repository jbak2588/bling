// lib/features/feed/widgets/comment_list_view.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; 

import '../../../core/models/comment_model.dart';
import '../../../core/models/user_model.dart';
import 'reply_input_field.dart';
import 'reply_list_view.dart';

class CommentListView extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String? activeReplyCommentId;
  final void Function(String commentId) onReplyTap;
  final VoidCallback? onCommentDeleted;

  const CommentListView({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.activeReplyCommentId,
    required this.onReplyTap,
    this.onCommentDeleted,
  });

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  final _likeLoading = <String, bool>{};
  final _likedComments = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _fetchLikedComments();
  }

  Future<void> _fetchLikedComments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('likedComments')
        .get();
    if (mounted) {
      setState(() {
        for (var doc in snap.docs) {
          _likedComments[doc.id] = true;
        }
      });
    }
  }

  Future<void> _toggleLike(String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _likeLoading[commentId] == true) return;
    setState(() => _likeLoading[commentId] = true);

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);
    final likedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('likedComments')
        .doc(commentId);
    final isLiked = _likedComments[commentId] == true;

    try {
      if (isLiked) {
        await commentRef.update({'likesCount': FieldValue.increment(-1)});
        await likedRef.delete();
      } else {
        await commentRef.update({'likesCount': FieldValue.increment(1)});
        await likedRef.set({'likedAt': FieldValue.serverTimestamp()});
      }
      if (mounted) setState(() => _likedComments[commentId] = !isLiked);
    } finally {
      if (mounted) setState(() => _likeLoading[commentId] = false);
    }
  }

  // [수정] Copilot 프롬프트를 통해 완성된 삭제 로직입니다.
  Future<void> _deleteComment(String commentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // ✅ [다국어 수정]
        title: Text('deleteConfirm.title'.tr()),
        content: Text('deleteConfirm.content'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr())),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('common.delete'.tr(),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      final commentRef = postRef.collection('comments').doc(commentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(commentRef);
        transaction
            .update(postRef, {'commentsCount': FieldValue.increment(-1)});
      });

      widget.onCommentDeleted?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // ✅ [다국어 수정]
          SnackBar(
              content: Text('deleteConfirm.failure'
                  .tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // ✅ [다국어 수정] 댓글 없음 안내
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('commentListView.empty'.tr(),
                style: const TextStyle(color: Colors.grey)),
          ));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final comment =
                CommentModel.fromDocument(snapshot.data!.docs[index]);
            return _buildCommentItem(comment, currentUserId);
          },
        );
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment, String currentUserId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(comment.userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox.shrink();
        final user = UserModel.fromFirestore(userSnapshot.data!);
        final isLiked = _likedComments[comment.id] == true;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.nickname,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatTime(comment.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (currentUserId == comment.userId)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteComment(comment.id),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (comment.isSecret &&
                        comment.userId != currentUserId &&
                        widget.postOwnerId != currentUserId)
                    // ✅ [다국어 수정]
                    ? 'commentListView.secret'.tr()
                    : comment.content,
              ),
              ReplyListView(postId: widget.postId, commentId: comment.id),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _toggleLike(comment.id),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                    label: Text('${comment.likesCount}',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onReplyTap(comment.id),
                    icon: const Icon(Icons.reply, size: 18, color: Colors.grey),
                    label:
                        // ✅ [다국어 수정]
                        Text('commentListView.reply'.tr(),
                            style: const TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              if (comment.id == widget.activeReplyCommentId)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ReplyInputField(
                    postId: widget.postId,
                    commentId: comment.id,
                    onReplyAdded: () => widget.onReplyTap(''),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return 'time.now'.tr();
    if (difference.inMinutes < 60) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': difference.inMinutes.toString()});
    }
    if (difference.inHours < 24) {
      return 'time.hoursAgo'
          .tr(namedArgs: {'hours': difference.inHours.toString()});
    }

    // ✅ [다국어 수정] 날짜 포맷도 JSON 파일에서 가져오도록 변경
    return DateFormat('time.dateFormatLong'.tr()).format(dateTime);
  }
}

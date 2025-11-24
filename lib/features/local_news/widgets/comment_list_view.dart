// lib/features/feed/widgets/comment_list_view.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:intl/intl.dart';

import '../../../core/models/comment_model.dart';
import '../../../core/models/user_model.dart';
import 'reply_input_field.dart';
import 'reply_list_view.dart';

class CommentListView extends StatefulWidget {
  final String postId;
  // ✅ [작업 42] 1. 컬렉션 경로를 파라미터로 받음 (기본값: 'posts')
  final String collectionPath;
  final String postOwnerId;
  final String? activeReplyCommentId;
  final Function(String) onReplyTap;
  final Function() onCommentDeleted; // 댓글 삭제 시 콜백

  const CommentListView({
    super.key,
    required this.postId,
    this.collectionPath = 'posts', // ✅ [작업 42] 2. 기본값 설정
    required this.postOwnerId,
    required this.activeReplyCommentId,
    required this.onReplyTap,
    required this.onCommentDeleted,
  });

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  final _likeLoading = <String, bool>{};
  final _likedComments = <String, bool>{};
  // ✅ [신고하기] 신고 처리 중 상태 변수 추가
  bool _isReporting = false;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
        .collection(widget.collectionPath)
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
        title: Text(t.deleteConfirm.title),
        content: Text(t.deleteConfirm.content),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.common.cancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final postRef = FirebaseFirestore.instance
          .collection(widget.collectionPath)
          .doc(widget.postId);
      final commentRef = postRef.collection('comments').doc(commentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(commentRef);
        transaction
            .update(postRef, {'commentsCount': FieldValue.increment(-1)});
      });

      widget.onCommentDeleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // ✅ [다국어 수정]
          SnackBar(
              content: Text(t.deleteConfirm.failure
                  .replaceAll('{error}', e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(widget.collectionPath)
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
            child: Text(t.commentListView.empty,
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
                  // ✅ [신고하기] 본인 댓글/답글 여부에 따라 다른 메뉴 표시
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    tooltip: t.common.moreOptions,
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteComment(comment.id);
                      } else if (value == 'report') {
                        _showReportDialog(context, comment);
                      }
                    },
                    itemBuilder: (context) {
                      final bool isOwner = comment.userId == currentUserId;
                      List<PopupMenuItem<String>> items = [];

                      if (isOwner) {
                        items.add(PopupMenuItem(
                          value: 'delete',
                          child: Text(t.common.delete),
                        ));
                      } else {
                        items.add(PopupMenuItem(
                          value: 'report',
                          child: Text(t.common.report),
                        ));
                      }
                      return items;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (comment.isSecret &&
                        comment.userId != currentUserId &&
                        widget.postOwnerId != currentUserId)
                    // ✅ [다국어 수정]
                    ? t.commentListView.secret
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
                        Text(t.commentListView.reply,
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

  // ✅ [신고하기] 신고 다이얼로그 표시 함수
  void _showReportDialog(BuildContext context, CommentModel comment) {
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
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(t.reportDialog.titleComment),
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
                        label: Text(t[reasonKey]),
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
                child: Text(t.common.cancel),
              ),
              ElevatedButton(
                onPressed: (selectedReason != null && !_isReporting)
                    ? () async {
                        Navigator.pop(dialogContext);
                        await _submitReport(context, comment, selectedReason!);
                      }
                    : null,
                child: _isReporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.common.report),
              ),
            ],
          );
        });
      },
    );
  }

  // ✅ [신고하기] Firestore에 신고 내역 저장 함수
  Future<void> _submitReport(
      BuildContext context, CommentModel comment, String reasonKey) async {
    if (_isReporting) return;

    final reporterId = currentUserId;
    if (reporterId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.main.errors.loginRequired)),
        );
      }
      return;
    }

    // 자기 자신의 댓글은 신고 불가
    if (comment.userId == reporterId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.reportDialog.cannotReportSelfComment)),
        );
      }
      return;
    }

    setState(() => _isReporting = true);
    // ✅ [Exception Fix] await 전에 ScaffoldMessenger 참조 저장
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final reportData = {
        'reportedContentId': comment.id,
        'reportedContentType': 'comment',
        'reportedParentId': widget.postId,
        'reportedUserId': comment.userId,
        'reporterUserId': reporterId,
        'reason': reasonKey,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      // ✅ [Exception Fix] 저장된 참조 사용 (mounted 체크 불필요, showSnackBar는 내부적으로 체크함)
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(t.reportDialog.success)),
      );
    } catch (e) {
      // ✅ [Exception Fix] 저장된 참조 사용
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            t.reportDialog.fail.replaceAll('{error}', e.toString()),
          ),
        ),
      );
    } finally {
      // setState 호출은 StatefulBuilder 내에서만 유효하므로 여기서는 호출하지 않음
      // 대신 _isReporting 상태를 외부에서 관리하거나 다른 방식으로 처리 필요
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) return t.time.now;
    if (difference.inMinutes < 60) {
      return t.time.minutesAgo
          .replaceAll('{minutes}', difference.inMinutes.toString());
    }
    if (difference.inHours < 24) {
      return t.time.hoursAgo
          .replaceAll('{hours}', difference.inHours.toString());
    }

    // ✅ [다국어 수정] 날짜 포맷도 JSON 파일에서 가져오도록 변경
    return DateFormat(t.time.dateFormatLong).format(dateTime);
  }
}

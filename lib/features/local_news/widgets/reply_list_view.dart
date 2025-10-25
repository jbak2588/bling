// lib/features/feed/widgets/reply_list_view.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ 인증 정보 가져오기
import 'package:easy_localization/easy_localization.dart'; // ✅ 다국어

// v0.9 모델 import
import '../../../core/models/reply_model.dart';
import '../../../core/models/user_model.dart';

// ✅ [신고하기] StatelessWidget -> StatefulWidget 변경
class ReplyListView extends StatefulWidget {
  final String postId;
  final String commentId;

  const ReplyListView({
    super.key,
    required this.postId,
    required this.commentId,
  });

  @override
  State<ReplyListView> createState() => _ReplyListViewState();
}

class _ReplyListViewState extends State<ReplyListView> {
  bool _isReporting = false; // ✅ [신고하기] 신고 처리 중 상태
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId) // ✅ widget. 사용
          .collection('replies')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final replies = snapshot.data!.docs
            .map((doc) => ReplyModel.fromDocument(doc))
            .toList();

        return Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: replies.map((reply) {
              // Firestore에서 사용자 정보 가져오기 (비동기)
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  // ✅ [신고하기] reply.userId 사용 확인
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(reply.userId)
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      // 로딩 중 표시 (옵션)
                      return const SizedBox.shrink();
                    }

                    final user = UserModel.fromFirestore(userSnapshot.data!);

                    // ✅ [경고 수정] 불필요한 Container 제거, 직접 Row 반환
                    return Row(
                      children: [
                        Expanded(
                          // 기존 답글 내용 표시 부분
                          child: Container(
                            // Padding 적용 위한 Container는 유지
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('└',
                                    style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .copyWith(fontSize: 13),
                                        children: [
                                          TextSpan(
                                            text: '${user.nickname}: ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: reply.content),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ✅ [신고하기] 메뉴 버튼 추가
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              size: 18), // 아이콘 크기 조정
                          tooltip: 'common.moreOptions'.tr(),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _handleDeleteReply(context, reply); // 삭제 함수 호출
                            } else if (value == 'report') {
                              _showReportDialog(context, reply); // 신고 다이얼로그 호출
                            }
                          },
                          itemBuilder: (context) {
                            final bool isOwner = reply.userId == currentUserId;
                            List<PopupMenuItem<String>> items = [];
                            if (isOwner) {
                              items.add(PopupMenuItem(
                                value: 'delete',
                                child: Text('common.delete'.tr()),
                              ));
                            } else {
                              items.add(PopupMenuItem(
                                value: 'report',
                                child: Text('common.report'.tr()),
                              ));
                            }
                            return items;
                          },
                        ),
                      ],
                    );
                  });
            }).toList(),
          ),
        );
      },
    );
  }

  // ✅ [신고하기] 답글 삭제 함수 (기존 comment_list_view 참조 및 수정)
  Future<void> _handleDeleteReply(
      BuildContext context, ReplyModel reply) async {
    // 삭제 확인 다이얼로그
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteConfirm.title'.tr()),
        content: Text('deleteConfirm.content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
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
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('replies')
          .doc(reply.id)
          .delete();
      // Optionally update comment's reply count if needed
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('replyDelete.fail'
              .tr(namedArgs: {'error': e.toString()})))); // 다국어 필요
    }
  }

  // ✅ [신고하기] 신고 다이얼로그 표시 함수 (comment_list_view에서 가져와 수정)
  void _showReportDialog(BuildContext context, ReplyModel reply) {
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
              title: Text('reportDialog.titleReply'.tr()), // 답글 신고 제목 (다국어 필요)
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: reportReasons.map((reasonKey) {
                    return RadioListTile<String>(
                      title: Text(reasonKey.tr()),
                      value: reasonKey,
                      groupValue: selectedReason,
                      onChanged: (value) =>
                          setState(() => selectedReason = value),
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
                          await _submitReport(context, reply, selectedReason!);
                        }
                      : null,
                  child: _isReporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('common.report'.tr()),
                ),
              ],
            );
          });
        });
  }

  // ✅ [신고하기] Firestore에 신고 내역 저장 함수 (comment_list_view에서 가져와 수정)
  Future<void> _submitReport(
      BuildContext context, ReplyModel reply, String reasonKey) async {
    if (_isReporting) return;

    final reporterId = currentUserId;
    if (reporterId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('main.errors.loginRequired'.tr())));
      return;
    }

    // 자기 자신의 답글은 신고 불가
    if (reply.userId == reporterId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reportDialog.cannotReportSelfReply'.tr())));
      return;
    }

    setState(() => _isReporting = true);
    try {
      final reportData = {
        'reportedContentId': reply.id, // 답글 ID
        'reportedContentType': 'reply', // 콘텐츠 타입: 답글
        'reportedParentId': widget.commentId, // 상위 댓글 ID
        'reportedGrandparentId': widget.postId, // 상위 게시글 ID
        'reportedUserId': reply.userId, // 신고 대상자 (답글 작성자)
        'reporterUserId': reporterId,
        'reason': reasonKey,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('reports').add(reportData);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('reportDialog.success'.tr())));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'reportDialog.fail'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }
}

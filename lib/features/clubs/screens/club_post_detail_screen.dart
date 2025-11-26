// lib/features/clubs/screens/club_post_detail_screen.dart

import 'package:bling_app/features/clubs/models/club_comment_model.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class ClubPostDetailScreen extends StatefulWidget {
  final ClubPostModel post;
  final ClubModel club;
  final bool embedded;
  final VoidCallback? onClose;

  const ClubPostDetailScreen(
      {super.key,
      required this.post,
      required this.club,
      this.embedded = false,
      this.onClose});

  @override
  State<ClubPostDetailScreen> createState() => _ClubPostDetailScreenState();
}

class _ClubPostDetailScreenState extends State<ClubPostDetailScreen> {
  final ClubRepository _repository = ClubRepository();
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // [추가] 댓글 전송 함수
  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (body.isEmpty || user == null) return;

    setState(() => _isSendingComment = true);

    try {
      final newComment = ClubCommentModel(
        id: '',
        userId: user.uid,
        body: body,
        createdAt: Timestamp.now(),
      );
      await _repository.addClubPostComment(
          widget.club.id, widget.post.id, newComment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.postDetail.commentFail'
              .tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }

  // [복원] 누락되었던 _formatTimestamp 함수
  String _formatTimestamp(BuildContext context, Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  // [복원] 누락되었던 _buildAuthorInfo 헬퍼 함수
  Widget _buildAuthorInfo(String userId) {
    final bool isKicked = widget.club.kickedMembers?.contains(userId) ?? false;

    // 강퇴된 멤버일 경우, DB를 조회하지 않고 바로 UI를 반환합니다.
    if (isKicked) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
        title: Text('clubs.postCard.withdrawnMember'.tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        subtitle: const Text(''),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person_off)),
            title: Text('clubs.postDetail.unknownUser'.tr()),
          );
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage:
                (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(_formatTimestamp(context, widget.post.createdAt)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inner = Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuthorInfo(widget.post.userId),
                      const Divider(height: 24),
                      Text(widget.post.body,
                          style: const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 16),
                      if (widget.post.imageUrls != null &&
                          widget.post.imageUrls!.isNotEmpty)
                        ...widget.post.imageUrls!.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.embedded &&
                                      widget.onClose != null) {
                                    widget.onClose!();
                                  }
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => Image.network(url)));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(url),
                                ),
                              ),
                            )),
                      const Divider(height: 32),
                      _buildActionRow(),
                      const Divider(height: 32),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('clubs.postDetail.commentsTitle'.tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              StreamBuilder<List<ClubCommentModel>>(
                stream: _repository.getClubPostCommentsStream(
                    widget.club.id, widget.post.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final comments = snapshot.data!;
                  if (comments.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                            child: Text('clubs.postDetail.noComments'.tr(),
                                style: const TextStyle(color: Colors.grey))),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCommentItem(comments[index]),
                      childCount: comments.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // --- 댓글 입력창 ---
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'clubs.postDetail.commentHint'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                IconButton(
                  icon: _isSendingComment
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: _isSendingComment ? null : _submitComment,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(color: Colors.white, child: inner);
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
        title: Text('clubs.postDetail.appBarTitle'
            .tr(namedArgs: {'title': widget.club.title})),
      ),
      body: inner,
    );
  }

  Widget _buildActionRow() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: _repository.getClubPostStream(widget.club.id, widget.post.id),
      builder: (context, postSnapshot) {
        if (!postSnapshot.hasData) return const SizedBox(height: 36);

        final livePost = ClubPostModel.fromFirestore(
            postSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .snapshots(),
          builder: (context, currentUserSnapshot) {
            if (!currentUserSnapshot.hasData) return const SizedBox(height: 36);

            final currentUser = UserModel.fromFirestore(currentUserSnapshot
                .data! as DocumentSnapshot<Map<String, dynamic>>);
            final bool isLiked =
                currentUser.bookmarkedClubPostIds?.contains(widget.post.id) ??
                    false;

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => _repository.toggleClubPostLike(
                      widget.club.id, widget.post.id, isLiked),
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  label: Text(livePost.likesCount.toString()),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: null,
                  icon:
                      const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  label: Text(livePost.commentsCount.toString()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCommentItem(ClubCommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(comment.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final user = (snapshot.data!.exists)
              ? UserModel.fromFirestore(snapshot.data!)
              : null;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: (user == null ||
                        user.photoUrl == null ||
                        user.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        user?.nickname ?? 'clubs.postCard.withdrawnMember'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(comment.body),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

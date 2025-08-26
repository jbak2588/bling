// lib/features/clubs/widgets/club_post_card.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 동호회 게시글 카드는 작성자, 본문, 이미지, 좋아요, 댓글, 작성 시간 등 요약 정보를 표시합니다.
//
// [구현 요약]
// - 게시글 본문, 이미지, 작성자, 좋아요, 댓글, 시간 정보를 표시합니다.
// - 게시글 삭제 및 상세 화면 이동 기능을 지원합니다.
//
// [차이점 및 부족한 부분]
// - 운영자 상태, 통계, 게시글 공개/비공개 등 추가 정보 표시가 부족합니다.
//
// [개선 제안]
// - 카드에 운영자 상태, 통계 정보 표시.
// - 작성자 및 운영자를 위한 빠른 관리 액션 지원.
// =====================================================

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/screens/club_post_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubPostCard extends StatelessWidget {
  final ClubPostModel post;
  final ClubModel club;
  const ClubPostCard({super.key, required this.post, required this.club});

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

  Future<void> _deletePost(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 정말로 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ClubRepository().deleteClubPost(post.clubId, post.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('게시글이 삭제되었습니다.'), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('삭제에 실패했습니다: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final clubOwnerId = club.ownerId;

    // StreamBuilder를 사용하기 전에 강퇴 여부를 먼저 확인합니다.
    final isKicked = club.kickedMembers?.contains(post.userId) ?? false;

    if (isKicked) {
      // V V V --- [수정] '탈퇴한 멤버' 카드에 InkWell을 추가하여 탭 가능하게 만듭니다 --- V V V
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade50,
        child: InkWell(
          onTap: () {
            // 탭하면 상세 화면으로 이동합니다.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClubPostDetailScreen(post: post, club: club),
              ),
            );
          },
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_off_outlined, color: Colors.grey),
            ),
            title: const Text('탈퇴한 멤버',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            subtitle:
                Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: (currentUserId == clubOwnerId)
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    tooltip: '게시글 삭제',
                    onPressed: () => _deletePost(context),
                  )
                : null,
          ),
        ),
      );
    }

    // 강퇴되지 않은 멤버일 경우에만, 기존처럼 작성자 정보를 불러옵니다.
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(post.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Card(child: ListTile(title: Text('사용자 정보 로딩중...')));
        }

        final user = UserModel.fromFirestore(snapshot.data!);
        final amIOwner = currentUserId == clubOwnerId;
        final isMyPost = currentUserId == post.userId;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClubPostDetailScreen(post: post, club: club),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                                ? NetworkImage(user.photoUrl!)
                                : null,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.nickname,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(_formatTimestamp(context, post.createdAt),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      if (amIOwner || isMyPost)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deletePost(context);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                                value: 'delete', child: Text('삭제하기')),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(post.body,
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                  if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(post.imageUrls!.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200),
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, size: 18),
                        label: Text(post.likesCount.toString()),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(post.commentsCount.toString()),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

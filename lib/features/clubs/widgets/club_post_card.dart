// lib/features/clubs/widgets/club_post_card.dart

import 'package:bling_app/core/models/club_post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubPostCard extends StatelessWidget {
  final ClubPostModel post;
  final String clubOwnerId;
  const ClubPostCard({super.key, required this.post, required this.clubOwnerId});

  String _formatTimestamp(BuildContext context, Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) return 'time.minutesAgo'.tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    if (diff.inDays < 1) return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  Future<void> _deletePost(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('이 게시글을 정말로 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ClubRepository().deleteClubPost(post.clubId, post.id);
        if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제에 실패했습니다: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(post.userId).snapshots(),
      builder: (context, snapshot) {
        // --- [수정] '탈퇴한 멤버' 처리 로직 ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: ListTile(title: Text('...')));
        }

        // V V V --- [핵심 수정] 사용자를 찾을 수 없는 경우 (탈퇴 또는 강퇴) --- V V V
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: 1,
            color: Colors.grey.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_off_outlined, color: Colors.grey),
              ),
              title: const Text('탈퇴한 멤버', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              // 방장에게만 삭제 버튼 표시
              trailing: (currentUserId == clubOwnerId)
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      tooltip: '게시글 삭제',
                      onPressed: () => _deletePost(context),
                    )
                  : null,
            ),
          );
        }
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        
        final user = UserModel.fromFirestore(snapshot.data!);
        final amIOwner = currentUserId == clubOwnerId;
        final isMyPost = currentUserId == post.userId;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_formatTimestamp(context, post.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('삭제하기'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post.body, style: const TextStyle(fontSize: 15, height: 1.4)),
                if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(post.imageUrls!.first, fit: BoxFit.cover, width: double.infinity, height: 200),
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
        );
      },
    );
  }
}
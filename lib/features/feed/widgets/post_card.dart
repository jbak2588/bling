// lib/features/feed/widgets/post_card.dart
// Bling App v0.4
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../post/screens/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(post.userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(child: CircularProgressIndicator())),
          );
        }

        final user = UserModel.fromFirestore(userSnapshot.data!);
        final category = AppCategories.postCategories.firstWhere(
          (cat) => cat.categoryId == post.category,
          orElse: () => AppCategories.postCategories
              .firstWhere((c) => c.categoryId == 'etc'),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post)));
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(context, user), // user를 전달하도록 수정
                  const SizedBox(height: 16),

                  if (post.title != null && post.title!.isNotEmpty)
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                              text: '${category.emoji} ',
                              style: const TextStyle(fontSize: 18)),
                          TextSpan(
                            text: post.title!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  Text(post.body, maxLines: 5, overflow: TextOverflow.ellipsis),

                  if (post.mediaUrl != null && post.mediaType == 'image') ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.mediaUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey, size: 48),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                  const SizedBox(height: 12),

                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: post.tags
                          .map((tag) => Chip(
                                label: Text('#$tag',
                                    style: const TextStyle(fontSize: 12)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  const Divider(height: 24),

                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 작성자 정보 위젯
  Widget _buildAuthorInfo(BuildContext context, UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage:
              (user.photoUrl != null && user.photoUrl!.startsWith('http'))
                  ? NetworkImage(user.photoUrl!)
                  : null,
          child: (user.photoUrl == null || !user.photoUrl!.startsWith('http'))
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(user.nickname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 4),
                  TrustLevelBadge(
                    trustLevel: user.trustLevel,
                    showText: false,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${user.locationParts?['kel']?.replaceFirst('Kel. ', '') ?? '지역 미설정'}(Kel.) • ${_formatTime(post.createdAt.toDate())}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
            icon: Icons.thumb_up_alt_outlined, label: '${post.likesCount}'),
        _buildActionButton(
            icon: Icons.chat_bubble_outline, label: '${post.commentsCount}'),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.redeem_outlined, size: 20, color: Colors.grey[600]),
          label: Text('${post.thanksCount}',
              style: TextStyle(color: Colors.grey[800])),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        _buildActionButton(icon: Icons.share_outlined, label: 'Share'),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: Colors.grey[800]),
      label: Text(label, style: TextStyle(color: Colors.grey[800])),
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inSeconds < 60) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    return DateFormat('M월 d일').format(time);
  }
}

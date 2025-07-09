// lib/features/feed/widgets/post_card.dart

import 'package:bling_app/core/models/post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/post/screens/post_detail_screen.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_category_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  // ✅ [다국어 수정] 시간 포맷 함수가 다국어 키를 사용하도록 변경
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
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final category = AppCategories.postCategories.firstWhere(
        (c) => c.categoryId == post.category,
        orElse: () => AppCategories.postCategories.first);

    // ✅ [다국어 수정] mediaUrl을 안전하게 처리
    String? firstImageUrl;
    if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) {
      firstImageUrl = post.mediaUrl!.first;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthorInfo(context, post.userId, post.createdAt),
              const SizedBox(height: 12),
              _buildTitleAndCategory(context, post, category, firstImageUrl),
              if (firstImageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    firstImageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade100),
                  ),
                ),
              ],
              if (post.tags.isNotEmpty) _buildTags(post.tags),
              const Divider(height: 24),
              _buildActionButtons(post),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorInfo(
      BuildContext context, String userId, Timestamp createdAt) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 40); // 로딩 중 높이 유지
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        final timeAgo = _formatTimestamp(context, createdAt);

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 20)
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
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      TrustLevelBadge(trustLevel: user.trustLevel),
                    ],
                  ),
                  Text(
                    // ✅ [다국어 수정] '지역 미설정' 텍스트에 다국어 키 적용
                    '${user.locationParts ?['kel'] ?? 'postCard.locationNotSet'.tr()} • $timeAgo',
                   
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.more_horiz_outlined)),
          ],
        );
      },
    );
  }

  Widget _buildTitleAndCategory(BuildContext context, PostModel post,
      PostCategoryModel category, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                post.title ?? post.body,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // ✅ [핵심 수정] imageUrl == null 조건을 제거하여,
        // 제목이 있는 게시물은 항상 본문 요약을 표시하도록 수정합니다.
        if (post.title != null && post.body.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            post.body,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade800, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: tags
            .map((tag) => Chip(
                  label: Text('#$tag'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  labelStyle:
                      TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  backgroundColor: Colors.grey.shade100,
                  visualDensity: VisualDensity.compact,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActionButtons(PostModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(icon: Icons.favorite_border, count: post.likesCount),
        _actionButton(
            icon: Icons.chat_bubble_outline, count: post.commentsCount),
        _actionButton(
            icon: Icons.card_giftcard_outlined, count: post.thanksCount),
        _actionButton(icon: Icons.share_outlined, count: null),
      ],
    );
  }

  Widget _actionButton({required IconData icon, int? count}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text('$count',
              style: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}

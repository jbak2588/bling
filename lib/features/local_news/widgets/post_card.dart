// lib/features/local_news/widgets/post_card.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 위치 기반 동네 소통 피드, 카테고리별 분류, 신뢰등급 뱃지, 미디어, 시간 포맷 등 시각화
///
/// 2. 실제 코드 분석
///   - PostModel 기반 카드 UI, 신뢰등급 뱃지, 다국어 시간 포맷, 상세 화면 연동, 카테고리별 스타일, 위치 정보, 미디어 등 시각화
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 현지화(i18n), 신뢰등급 뱃지, 시간 포맷 등 사용자 경험 강화
///   - 기획에 못 미친 점: AI 태그 추천, 광고/추천글 노출 등 일부 기능 미구현
///
/// 4. 개선 제안
///   - 카테고리별 색상/아이콘, 위치 기반 추천, 미디어 업로드/미리보기, KPI/Analytics 이벤트 로깅, 광고/추천글 연계
library;

import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_news/screens/local_news_detail_screen.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 새로 만든 프로필 스크린 import
import 'package:bling_app/features/user_profile/screens/user_profile_screen.dart';
import 'package:bling_app/features/local_news/screens/tag_search_result_screen.dart';


import '../../../core/constants/app_categories.dart';
import '../models/post_category_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page?.round() ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatTimestamp(BuildContext context, Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'.tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  Widget _buildAuthorInfo(BuildContext context, String userId, Timestamp createdAt) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 40);
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        final timeAgo = _formatTimestamp(context, createdAt);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: userId),
            ));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, size: 20) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.nickname, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        TrustLevelBadge(trustLevel: user.trustLevel),
                      ],
                    ),
                    Text(
                      '${user.locationParts?['kel'] ?? user.locationParts?['kec'] ?? 'postCard.locationNotSet'.tr()} • $timeAgo',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_outlined)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleAndCategory(BuildContext context, PostModel post, PostCategoryModel category) {
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
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (post.title != null && post.body.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            post.body,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildImageCarousel(BuildContext context, List<String> imageUrls) {
    if (imageUrls.length <= 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrls.first,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            '${_currentPage + 1} / ${imageUrls.length}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ✅ _buildTags 함수를 수정하여 탭 이벤트를 추가합니다.
  Widget _buildTags(BuildContext context, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: tags.map((tag) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TagSearchResultScreen(tag: tag),
              ));
            },
            borderRadius: BorderRadius.circular(16),
            child: Chip(
              label: Text('#$tag'),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              backgroundColor: Colors.grey.shade100,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _actionButton({required IconData icon, int? count}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text('$count', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }

  Widget _buildActionButtons(PostModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(icon: Icons.favorite_border, count: post.likesCount),
        _actionButton(icon: Icons.chat_bubble_outline, count: post.commentsCount),
        _actionButton(icon: Icons.card_giftcard_outlined, count: post.thanksCount),
        _actionButton(icon: Icons.share_outlined, count: null),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post; 
    final hasImages = post.mediaUrl != null && post.mediaUrl!.isNotEmpty;

    final category = AppCategories.postCategories.firstWhere(
      (c) => c.categoryId == post.category,
      orElse: () => AppCategories.postCategories.first,
    );

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
            builder: (_) => LocalNewsDetailScreen(post: post),
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
              _buildTitleAndCategory(context, post, category),
              if (hasImages) ...[
                const SizedBox(height: 12),
                _buildImageCarousel(context, post.mediaUrl!),
              ],
              // ✅ build 메서드에서 _buildTags를 호출할 때 context를 전달합니다.
              if (post.tags.isNotEmpty) _buildTags(context, post.tags),
              const Divider(height: 24),
              _buildActionButtons(post),
            ],
          ),
        ),
      ),
    );
  }
}
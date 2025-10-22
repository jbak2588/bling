// lib/features/main_feed/widgets/post_thumb.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/screens/local_news_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. Firestore import 추가
import 'package:easy_localization/easy_localization.dart'; // ✅ 이슈 2: 다국어 import
import 'package:bling_app/core/models/user_model.dart'; // ✅ 이슈 1: UserModel import
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart'; // ✅ 이슈 1: 신뢰배지 import

/// [개편] 2단계: 메인 피드용 표준 썸네일 (Post 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Post 전용 규칙 (이미지 유/무)
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class PostThumb extends StatelessWidget {
  final PostModel post;
  const PostThumb({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          // MD: "썸네일 탭 → 해당 feature의 _detail_screen.dart 'ontop push'"
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LocalNewsDetailScreen(post: post),
            ),
          );
        },
        child: Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MD: "로컬뉴스(Post) 전용 규칙" - 이미지 유/무 분기
              (post.mediaUrl?.isNotEmpty == true)
                  ? _buildImageContent(context)
                  : _buildTextContent(context),

              // --- 하단 컨텐츠 (제목/본문/메타) ---
              (post.mediaUrl?.isNotEmpty == true)
                  ? _buildImageMeta(context)
                  : _buildTextMeta(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. 이미지 있는 글 상단 (16:9 이미지) ---
  Widget _buildImageContent(BuildContext context) {
    // MD: "이미지 있는 글: 상단 16:9 이미지"
    // 220 (width) / 1.777 (16:9) = 123.7
    const double imageHeight = 124.0;

    return CachedNetworkImage(
      imageUrl: post.mediaUrl!.first,
      height: imageHeight,
      width: 220,
      fit: BoxFit.cover,
      // MD: "로딩/이미지 실패 시 스켈레톤/플레이스홀더"
      placeholder: (context, url) => Container(
        height: imageHeight,
        width: 220,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        height: imageHeight,
        width: 220,
        color: Colors.grey[200],
        child: Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
      ),
    );
  }

  // --- 2. 이미지 없는 글 상단 (텍스트 블록) ---
  Widget _buildTextContent(BuildContext context) {
    // MD: "이미지 없는 글: 상단 텍스트 블록(제목 2줄 + 본문 2줄)"
    const double textBlockHeight = 124.0;

    return Container(
      height: textBlockHeight,
      width: 220,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title ?? '',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2, // MD: 오버플로우 방지
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 2, // MD: 오버플로우 방지
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 1-A. 이미지 있는 글 하단 (제목 + 메타) ---
  Widget _buildImageMeta(BuildContext context) {
    // 240 (total) - 124 (image) = 116
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "제목 2줄"
            Text(
              post.title ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // MD: "하단 메타(카테고리 • kab/kota • 작성일)"
            _buildMetaRow(context),
          ],
        ),
      ),
    );
  }

  // --- 2-A. 이미지 없는 글 하단 (작성자 + 메타) ---
  Widget _buildTextMeta(BuildContext context) {
    // 240 (total) - 124 (text block) = 116
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MD: "작성자 1줄"
            // ✅ 2. 'authorNickname' (존재하지 않음) 대신 FutureBuilder로 사용자 정보 조회
            // ✅ 이슈 1 수정: 닉네임만 표시하던 것을 프로필+닉네임+배지로 변경
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(post.userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.exists) {
                  final user = UserModel.fromFirestore(
                      snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage:
                            (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(user.photoUrl!)
                                : null,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.nickname,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TrustLevelBadge(trustLevel: user.trustLevel),
                    ],
                  );
                }

                return const SizedBox(
                  height: 28, // CircleAvatar(14*2) 높이와 맞춤
                );
              },
            ),
            const Spacer(),
            // MD: "하단 메타(카테고리 • kab/kota • 작성일)"
            _buildMetaRow(context),
          ],
        ),
      ),
    );
  }

  // --- 공통 하단 메타 Row ---
  Widget _buildMetaRow(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        );

    // MD: "위치는 kab/kota만 단축 표기"
    final location =
        post.locationParts?['kab'] ?? post.locationParts?['kota'] ?? '';
    final date = DateFormat('MM.dd').format(post.createdAt.toDate());

    return DefaultTextStyle(
      style: textStyle!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: Row(
        children: [
          // 카테고리
          Flexible(
            flex: 3,
            child: Text(
              // ✅ [수정] "store_promo" -> "categories.post.store_promo.name"
              // post.category 값(ID)을 기반으로 올바른 i18n 키를 조립합니다.
              //
              "categories.post.${post.category}.name".tr(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(' • '),
          // 위치 (Kab/Kota)
          Flexible(
            flex: 2,
            child: Text(
              location,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          // 작성일
          Text(date),
        ],
      ),
    );
  }
}

// (로딩 플레이스홀더는 SizedBox로 대체되어 쉬머 위젯 제거)

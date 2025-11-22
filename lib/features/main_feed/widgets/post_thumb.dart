// lib/features/main_feed/widgets/post_thumb.dart
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/screens/local_news_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. Firestore import 추가
import 'package:easy_localization/easy_localization.dart'; // ✅ 이슈 2: 다국어 import
import 'package:bling_app/core/models/user_model.dart'; // ✅ 이슈 1: UserModel import
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart'; // ✅ 이슈 1: 신뢰배지 import
import 'package:bling_app/core/constants/app_tags.dart'; // ✅ 태그 사전 매핑

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
  // Optional callback to delegate navigation to parent (keeps top/bottom bars)
  final void Function(Widget, String)? onIconTap;

  const PostThumb({super.key, required this.post, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          final detailScreen = LocalNewsDetailScreen(post: post);
          if (onIconTap != null) {
            // Delegate to parent to keep top/bottom bars
            onIconTap!(detailScreen, 'main.tabs.localNews');
          } else {
            // Fallback: push a full-screen route
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => detailScreen),
            );
          }
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
                      // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
                      TrustLevelBadge(trustLevelLabel: user.trustLevelLabel),
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

    // 요청: locationParts의 전체 주소 대신 kel만 표시
    final location = post.locationParts?['kel'] ?? '';
    final date = DateFormat('MM.dd').format(post.createdAt.toDate());

    // 카테고리 텍스트를 태그와 완전히 일치시키기 위한 라벨 구성 함수 (최대 2개 + "+N")
    String resolveTagLabels(BuildContext ctx) {
      List<String> tagIds = post.tags.isNotEmpty ? post.tags : ['etc'];

      String labelFor(String tagId) {
        TagInfo? matched;
        for (final t in AppTags.localNewsTags) {
          if (t.tagId == tagId) {
            matched = t;
            break;
          }
        }

        if (matched != null) {
          final name = matched.nameKey.tr();
          final emoji = matched.emoji;
          return (emoji != null && emoji.isNotEmpty) ? '$emoji $name' : name;
        }

        // [수정] 사용자 정의 태그는 번역 시도 없이 그대로 표시 (다국어 키 누락 경고 방지)
        return tagId;
      }

      final labels = <String>[];
      final takeCount = tagIds.length >= 2 ? 2 : 1;
      for (final id in tagIds.take(takeCount)) {
        labels.add(labelFor(id));
      }

      String result = labels.join(' · ');
      final remaining = tagIds.length - takeCount;
      if (remaining > 0) {
        result = '$result +$remaining';
      }
      return result;
    }

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
              resolveTagLabels(context),
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

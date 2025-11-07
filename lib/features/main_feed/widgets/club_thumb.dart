// lib/features/main_feed/widgets/club_thumb.dart
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_post_model.dart';
import 'package:bling_app/features/clubs/screens/club_post_detail_screen.dart';
import 'package:bling_app/core/models/user_model.dart'; // UserModel 참조
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart'; // ✅ 신뢰배지 import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [개편] 4단계: 메인 피드용 표준 썸네일 (Club Post 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Club 전용 규칙: 이미지 / 내용 요약 / 클럽명 / 작성자
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class ClubThumb extends StatelessWidget {
  final ClubPostModel post;
  final void Function(Widget, String)? onIconTap;
  const ClubThumb({super.key, required this.post, this.onIconTap});

  // 클럽 정보를 가져오는 Future 함수
  Future<ClubModel?> _fetchClubInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clubs')
          .doc(post.clubId) //
          .get();
      if (doc.exists) {
        return ClubModel.fromFirestore(doc); //
      }
    } catch (e) {
      debugPrint('Error fetching club info: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      // 클럽 정보를 먼저 로드하고 탭 동작 처리
      child: FutureBuilder<ClubModel?>(
        future: _fetchClubInfo(),
        builder: (context, clubSnapshot) {
          final club = clubSnapshot.data; // ClubModel 또는 null

          return InkWell(
            onTap: (club != null)
                ? () {
                    final detailScreen =
                        ClubPostDetailScreen(post: post, club: club);
                    if (onIconTap != null) {
                      onIconTap!(detailScreen, 'main.tabs.clubs');
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => detailScreen),
                      );
                    }
                  }
                : null, // 클럽 정보 로드 실패 시 탭 비활성화
            child: Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 상단 이미지 (16:9 비율)
                  _buildImageContent(context),
                  // 2. 하단 메타 (내용, 클럽명, 작성자)
                  _buildMeta(context, club), // ClubModel 전달
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 상단 이미지 (16:9 이미지) ---
  Widget _buildImageContent(BuildContext context) {
    const double imageHeight = 124.0;
    //
    final imageUrl =
        (post.imageUrls?.isNotEmpty == true) ? post.imageUrls!.first : null;

    return (imageUrl != null)
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            height: imageHeight,
            width: 220,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: 220,
              color: Colors.grey[200],
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: 220,
              color: Colors.grey[200],
              child: Center(
                  child: Icon(Icons.groups_outlined,
                      color: Colors.grey[400], size: 40)),
            ),
          )
        : Container(
            // 이미지가 없는 경우 플레이스홀더
            height: imageHeight, width: 220, color: Colors.grey[200],
            child: Center(
                child: Icon(Icons.groups_outlined,
                    color: Colors.grey[400], size: 40)),
          );
  }

  // --- 하단 메타 (내용 + 클럽명 + 작성자) ---
  Widget _buildMeta(BuildContext context, ClubModel? club) {
    // 하단 영역 높이: 240 - 124 = 116
    final date = DateFormat('MM.dd').format(post.createdAt.toDate()); //

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 내용 요약 (body)
            Text(
              post.body, //
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 클럽명
            Text(
              club?.title ?? '...', // ClubModel에서 클럽 이름 가져오기
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 1, // MD: 오버플로우 방지
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // 작성자 정보 (FutureBuilder 사용) + 날짜
            Row(
              children: [
                Expanded(child: _buildAuthorInfo(context)),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 작성자 정보 (닉네임만) ---
  // ✅ [수정] 프로필 아이콘과 신뢰 배지를 추가합니다.
  Widget _buildAuthorInfo(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      //
      future:
          FirebaseFirestore.instance.collection('users').doc(post.userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.done &&
            userSnapshot.hasData &&
            userSnapshot.data!.exists) {
          final user = UserModel.fromFirestore(
              userSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
          // ✅ 프로필 아이콘 + 닉네임 + 신뢰 배지를 Row로 표시
          return Row(
            mainAxisSize: MainAxisSize.min, // Row 크기를 내용에 맞춤
            children: [
              CircleAvatar(
                radius: 10, // 작은 크기로 조절
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(user.photoUrl!)
                        : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 10)
                    : null,
              ),
              const SizedBox(width: 4),
              Flexible(
                // 닉네임 (넘칠 경우 ...)
                child: Text(
                  user.nickname,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              // [v2.1] 뱃지 파라미터 수정 (int -> String Label)
              TrustLevelBadge(
                trustLevelLabel: user.trustLevelLabel,
                showText: false,
              ), // 신뢰 배지 (아이콘만)
            ],
          );
        } else if (userSnapshot.connectionState == ConnectionState.done) {
          // 사용자 정보 로드 실패 시
          return Text(
            'Unknown',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          );
        }

        // 로딩 중 Placeholder (높이 유지)
        return SizedBox(
          height: 20, // CircleAvatar 높이와 맞춤
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}

// lib/features/main_feed/widgets/find_friend_thumb.dart
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// [개편] 5단계: 메인 피드용 표준 썸네일 (Find Friend 전용)
///
/// MD문서 요구사항:
/// 1. 표준 썸네일 (고정 크기): 220x240
/// 2. 탭 동작: _detail_screen.dart 로 "ontop push"
/// 3. Find Friend 규칙: 프로필 사진 / 닉네임 / 나이 / 지역
/// 4. 오버플로우 방지 (maxLines, ellipsis)
/// 5. 스켈레톤/플레이스홀더
class FindFriendThumb extends StatelessWidget {
  final UserModel user;
  final UserModel? currentUserModel; // 상세 화면 이동 시 필요
  final void Function(Widget, String)? onIconTap;

  const FindFriendThumb({
    super.key,
    required this.user,
    required this.currentUserModel,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          if (currentUserModel == null) return; // 현재 사용자 정보 없으면 이동 불가
          final detailScreen = FindFriendDetailScreen(
              user: user, currentUserModel: currentUserModel!);
          if (onIconTap != null) {
            onIconTap!(detailScreen, 'main.tabs.findFriends');
          } else {
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
              // 1. 상단 이미지 (1:1 비율)
              // Wrap image in Flexible(fit: FlexFit.loose) so it can shrink
              // if the meta content needs more vertical space (accessibility
              // text scaling, chips, etc.). This prevents Column overflow.
              Flexible(fit: FlexFit.loose, child: _buildImageContent(context)),
              // 2. 하단 메타 (닉네임, 나이, 지역)
              // Use Expanded so the meta area flexes to the remaining space and
              // avoids RenderFlex overflow when textScaleFactor is large.
              Expanded(child: _buildMeta(context)),
            ],
          ),
        ),
      ),
    );
  }

  // --- 상단 이미지 (1:1 비율, 원형) ---
  Widget _buildImageContent(BuildContext context) {
    // 1:1 비율 이미지 (가로 220 전체 사용)
    const double imageSize = 140.0; // 높이를 좀 더 확보

    return Container(
      height: imageSize,
      width: 220,
      color: Colors.grey[100], // 배경색
      alignment: Alignment.center,
      child: Hero(
        tag: 'profile-image-${user.uid}',
        child: CircleAvatar(
          radius: 50, // 원 크기 조절
          backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
              ? CachedNetworkImageProvider(user.photoUrl!) //
              : null,
          // MD: "로딩/이미지 실패 시 스켈레톤/플레이스홀더"
          // CircleAvatar는 placeholder/errorBuilder가 없으므로 배경 아이콘 사용
          child: (user.photoUrl == null || user.photoUrl!.isEmpty)
              ? Icon(Icons.person, size: 50, color: Colors.grey[400])
              : null,
        ),
      ),
    );
  }

  // --- 하단 메타 (닉네임 + 나이 + 지역) ---
  Widget _buildMeta(BuildContext context) {
    // [v2.1] 'age' 및 'ageRange' 필드 삭제됨.
    final interests = user.interests?.take(2).toList() ?? []; // 최대 2개만 표시

    // 지역명 추출 (Kelurahan 우선, 없으면 Kecamatan)
    final location =
        user.locationParts?['kab'] ?? user.locationParts?['kota'] ?? '';

    // Return a flexible meta area (no fixed height). The parent Column
    // wraps this widget in Expanded so it will take remaining space and
    // avoid RenderFlex overflow even when textScaleFactor increases.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닉네임
          Text(
            user.nickname, //
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1, // MD: 오버플로우 방지
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // [v2.1] 'age' 대신 'interests' 표시 (최대 2개)
          if (interests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: interests
                    .map((interest) => Chip(
                          label: Text(interest,
                              style: Theme.of(context).textTheme.labelSmall),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),

          // Small gap instead of Spacer to avoid forcing expansion inside the
          // meta area - but the parent uses Expanded so this Column can grow.
          const SizedBox(height: 4),
          // 지역
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                // 지역명이 길 경우 대비
                child: Text(
                  location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1, // MD: 오버플로우 방지
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

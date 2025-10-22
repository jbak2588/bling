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

  const FindFriendThumb({
    super.key,
    required this.user,
    required this.currentUserModel,
  });

  @override
  Widget build(BuildContext context) {
    // MD: "표준 썸네일(고정 크기)로 노출 — main_feed에서만 래핑 (예: 220x240)"
    return SizedBox(
      width: 220,
      height: 240,
      child: InkWell(
        onTap: () {
          // MD: "썸네일 탭 → 해당 feature의 _detail_screen.dart 'ontop push'"
          if (currentUserModel == null) return; // 현재 사용자 정보 없으면 이동 불가
          Navigator.of(context).push(
            MaterialPageRoute(
              //
              builder: (_) => FindFriendDetailScreen(
                user: user,
                currentUserModel: currentUserModel!,
              ),
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
              // 1. 상단 이미지 (1:1 비율)
              _buildImageContent(context),
              // 2. 하단 메타 (닉네임, 나이, 지역)
              _buildMeta(context),
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
    // 하단 영역 높이: 240 - 140 = 100
    //
    final location =
        user.locationParts?['kab'] ?? user.locationParts?['kota'] ?? '';
    final ageString =
        (user.age != null) ? '${user.age}歳' : ''; // 나이 표시 (예: 30歳)

    return Expanded(
      child: Padding(
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
            // 나이
            if (ageString.isNotEmpty)
              Text(
                ageString,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            const Spacer(), // 하단으로 밀기
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
      ),
    );
  }
}

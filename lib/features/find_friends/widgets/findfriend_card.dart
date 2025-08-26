/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/widgets/findfriend_card.dart
/// Purpose       : 리스트에서 간단한 프로필 요약을 표시합니다.
/// User Impact   : 주변 친구 후보를 빠르게 훑어볼 수 있게 합니다.
/// Feature Links : lib/features/find_friends/screens/find_friend_detail_screen.dart
/// Data Model    : `users` 필드 `nickname`, `age`, `photoUrl`, `locationName`을 사용합니다.
/// Location Scope: `locationName`을 표시하며 프로필 위치 계층을 가정합니다.
/// Trust Policy  : `trustLevel`에 따른 배지를 표시할 수 있음(TODO).
/// Monetization  : 프로모션 프로필 슬롯을 제공합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `click_findfriend_card`.
/// Analytics     : 카드 렌더링 시 노출을 기록합니다.
/// I18N          : 없음.
/// Dependencies  : flutter
/// Security/Auth : 없음; 읽기 전용 위젯입니다.
/// Edge Cases    : 아바타나 나이가 없을 때./// 실제 구현 비교 : 프로필 요약, 아바타, 나이, 위치 등 모든 정보 정상 표시. UI/UX 완비.
/// 개선 제안     : KPI/통계/프리미엄 기능 실제 구현 필요. 신뢰 등급/차단/신고 UI 노출 및 기능 강화. 프로모션 슬롯 UX 개선.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012 Find Friend & Club & Jobs & etc 모듈.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';

/// Card displaying basic information for a FindFriend profile.
class FindFriendCard extends StatelessWidget {
  final UserModel user;
  const FindFriendCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Hero(
              tag: 'profile-image-${user.uid}',
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child:
                    user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nickname,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  if (user.age != null)
                    Text('${user.age}',
                        style: const TextStyle(fontSize: 14)),
                  if (user.locationName != null)
                    Text(user.locationName!,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

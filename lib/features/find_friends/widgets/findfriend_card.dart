/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/widgets/findfriend_card.dart
/// Purpose       : 리스트에서 간단한 프로필 요약을 표시합니다.
/// User Impact   : 주변 친구 후보를 빠르게 훑어볼 수 있게 합니다.
/// Feature Links : lib/features/find_friends/screens/find_friend_detail_screen.dart
/// Data Model    : `users` 필드 `nickname`, `age`, `photoUrl`, `locationName`, `locationParts`, `geoPoint`를 사용합니다.
/// Location Note : `locationParts`는 {prov,kab,kec,kel,street,rt,rw} 구조이며, UI/검색 일관성을 위해 `LocationHelper.cleanName`으로 정규화된 값을 사용하세요.
/// Privacy Note : 피드(목록/카드)에서 `locationParts['street']`나 전체 `locationName`을 사용자 동의 없이 표시하지 마세요. 피드에는 행정구역만 약어(`kel.`, `kec.`, `kab.`, `prov.`)로 간략 표기하세요.
/// Location Scope: `locationName`을 표시하며 프로필 위치 계층을 가정합니다.
/// Trust Policy  : `trustLevel`에 따른 배지를 표시할 수 있음(TODO).
/// Monetization  : 프로모션 프로필 슬롯을 제공합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `click_findfriend_card`.
/// Analytics     : 카드 렌더링 시 노출을 기록합니다.
/// I18N          : 없음.
/// Dependencies  : flutter
/// Security/Auth : 없음; 읽기 전용 위젯입니다.
/// Edge Cases    : 아바타나 나이가 없을 때./// 실제 구현 비교 : 프로필 요약, 아바타, 나이, 위치 등 모든 정보 정상 표시. UI/UX 완비.
/// Edge Cases    : 아바타나 나이가 없을 때.
/// 실제 구현 비교 : 프로필 요약, 아바타, 나이, 위치 등 모든 정보 정상 표시. UI/UX 완비.
/// 개선 제안     : KPI/통계/프리미엄 기능 실제 구현 필요. 신뢰 등급/차단/신고 UI 노출 및 기능 강화. 프로모션 슬롯 UX 개선.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012 Find Friend & Club & Jobs & etc 모듈.md
/// ============================================================================
// [작업 27] TrustLevelBadge 텍스트 표시 옵션 추가
// [Task 16] 프라이버시 정책 적용: 위치 정보 약어 표기(Safe Location) 로직 추가
library;
// 아래부터 실제 코드

import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import 'package:bling_app/core/utils/address_formatter.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';

/// Card displaying basic information for a FindFriend profile.
class FindFriendCard extends StatelessWidget {
  final UserModel user;
  const FindFriendCard({super.key, required this.user});

  // [Task 16] 위치 정보 프라이버시 보호 헬퍼
  // locationParts를 사용하여 "Kel. OO, Kec. OO" 형태로 변환
  String _getSafeLocationText(UserModel user) {
    final formatted = AddressFormatter.formatKelKabFromParts(
        user.locationParts); // kel/kab only
    if (formatted.isNotEmpty) return formatted;
    return '';
  }

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
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [v2.1] 닉네임과 신뢰 뱃지를 Row로 묶음
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nickname,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TrustLevelBadge(
                        trustLevelLabel: user.trustLevelLabel,
                        showText: true, // [작업 27] 뱃지 텍스트 표시
                      ),
                    ],
                  ),
                  // [v2.1] 'age' 대신 'interests' 표시
                  if (user.interests != null && user.interests!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: user.interests!
                            .take(3) // 최대 3개만 표시
                            .map((interest) => Chip(
                                  label: Text(interest,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),
                  // [Task 16] 안전한 위치 표기 적용
                  if (user.locationName != null || user.locationParts != null)
                    Text(_getSafeLocationText(user),
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

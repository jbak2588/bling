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
// address_formatter not used in this card after refactor
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';

/// Card displaying basic information for a FindFriend profile.
class FindFriendCard extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;

  const FindFriendCard({
    super.key,
    required this.user,
    required this.currentUser,
  });

  // [Added] 관심사 키 -> 이모지 매핑 테이블
  static const Map<String, String> _interestEmojiMap = {
    'drawing': '🎨',
    'sports': '🏃',
    'movie': '🎬',
    'study': '📖',
    'pet': '🐾',
    'cafe': '☕',
    'coffee': '☕',
    'instrument': '🎸',
    'photography': '📷',
    'writing': '✍️',
    'crafting': '🧶',
    'gardening': '🌿',
    'soccer': '⚽',
    'hiking': '🥾',
    'camping': '⛺',
    'running': '🏃',
    'biking': '🚴',
    'golf': '⛳',
    'workout': '🏋️',
    'foodie': '🍽️',
    'cooking': '🍳',
    'baking': '🥐',
    'wine': '🍷',
    'tea': '🍵',
    'music': '🎵',
    'concerts': '🎤',
    'gaming': '🎮',
    'reading': '📚',
    'investing': '📈',
    'language': '🗣️',
    'coding': '💻',
    'travel': '✈️',
    'volunteering': '🤝',
    'minimalism': '🧘',
  };

  // [Added] 관심사 리스트를 이모지 문자열로 변환하는 헬퍼
  String _getInterestEmojis(List<String> interests) {
    return interests
        .map((key) => _interestEmojiMap[key])
        .where((emoji) => emoji != null)
        .join(' ');
  }

  // ProductCard 패턴처럼, 메인 + 추가 프로필 이미지를 합쳐 미리보기 리스트를 만듭니다.
  List<String> _getProfileImages(UserModel user) {
    final List<String> images = [];

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      images.add(user.photoUrl!);
    }

    if (user.findfriendProfileImages != null &&
        user.findfriendProfileImages!.isNotEmpty) {
      for (final url in user.findfriendProfileImages!) {
        if (!images.contains(url)) {
          images.add(url);
        }
      }
    }

    // 리스트/피드 부하를 줄이기 위해 최대 4장까지만 사용
    return images.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final profileImages = _getProfileImages(user);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FindFriendDetailScreen(
              user: user,
              currentUserModel: currentUser,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (profileImages.isNotEmpty)
                SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImageCarouselCard(
                      imageUrls: profileImages,
                      storageId: 'findfriend_${user.uid}',
                      width: 90,
                      height: 90,
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child:
                      user.photoUrl == null ? const Icon(Icons.person) : null,
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

                    // [B. Bio 추가] 자기소개 (1줄 제한)
                    if (user.bio != null && user.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          user.bio!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // [C. 주소 + 관심사 이모지]
                    Row(
                      children: [
                        // 주소: Kel. 단위만 표시
                        if (user.locationParts != null &&
                            user.locationParts!['kel'] != null)
                          Text(
                            "Kel. ${user.locationParts!['kel']}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),

                        if ((user.locationParts?['kel'] != null) &&
                            (user.interests?.isNotEmpty ?? false))
                          const SizedBox(width: 8),

                        // 관심사 이모지
                        if (user.interests != null &&
                            user.interests!.isNotEmpty)
                          Expanded(
                            child: Text(
                              _getInterestEmojis(user.interests!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

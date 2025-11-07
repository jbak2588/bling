// [v2.1 리팩토링 이력: Job 25, 26]
// - (Job 25) 'trustLevel' (int) 파라미터를 'trustLevelLabel' (String)으로 변경.
// - (Job 25) 'switch(trustLevel)' (int) 로직을 'switch(trustLevelLabel)' (String) 로직으로 변경.
// [v2.1 리팩토링 이력: Job 9, 27]
// - (Job 9) 'age' 필드를 'interests' (관심사) 칩으로 교체.
// - (Job 27) 닉네임 옆에 'TrustLevelBadge'가 표시되도록 UI 수정.
// [v2.1 리팩토링 이력: Job 29-31]
// - (Job 29) 'startFriendChat' (onCall) 함수 신규 추가.
// - (Job 29) 'DAILY_CHAT_LIMIT' (일일 신규 채팅 5회) 상수 정의.
// - (Job 29) 'startFriendChat' 로직:
//   1. 기존 채팅방(chats/{chatId}) 존재 시 'allow: true, isExisting: true' 반환.
//   2. 신규 채팅 시 'users/{uid}.chatLimits'의 날짜(todayUTC) 및 카운트(findFriendCount) 확인.
//   3. 한도 미만 시 'allow: true', 카운트 증가 및 타임스탬프 갱신.
//   4. 한도 초과 시 'allow: false' 반환.
// [v2.1 리팩토링 이력: Job 11, 13]
// - (Job 11) 'FindFriendFormScreen' 참조를 'ProfileEditScreen'으로 변경.
// - (Job 11, 13) 런타임 예외(Null check) 수정: _userModel이 null일 때를 대비하여
//   AppBar, Drawer, MyBlingScreen 탭 등에서 _userModel! 대신 _userModel? 사용.

import 'package:flutter/material.dart';

class TrustLevelBadge extends StatelessWidget {
  final String trustLevelLabel; // [v2.1] 파라미터명 변경 (int -> String Label)
  final bool showText;

  const TrustLevelBadge({
    super.key,
    required this.trustLevelLabel, // [v2.1] 파라미터명 변경
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    late IconData icon;
    late Color color;
    late String text;

    // [v2.1] int가 아닌 String 라벨로 switch
    switch (trustLevelLabel) {
      case 'trusted':
        icon = Icons.verified_user;
        color = Colors.blue[400]!;
        text = 'Trusted';
        break;
      case 'verified':
        icon = Icons.check_circle;
        color = Colors.green[400]!;
        text = 'Verified';
        break;
      default:
        icon = Icons.person;
        color = Colors.grey[600]!;
        text = 'Normal';
    }

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      );
    } else {
      return Icon(icon, color: color, size: 18);
    }
  }
}

/// TrustLevel 뱃지 위젯
  // Widget _buildTrustLevelBadge(String trustLevel) {
  //   IconData icon;
  //   Color color;
  //   switch (trustLevel) {
  //     case 'verified':
  //       icon = Icons.verified;
  //       color = Colors.blue;
  //       break;
  //     case 'trusted':
  //       icon = Icons.shield;
  //       color = const Color(0xFF00A66C); // Primary Color
  //       break;
  //     default: // normal
  //       return const SizedBox.shrink(); // 일반 등급은 표시 안 함
  //   }
  //   return Icon(icon, color: color, size: 18);
  // }

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

// lib/features/marketplace/widgets/ai_verification_badge.dart

import 'package:flutter/material.dart';

class AiVerificationBadge extends StatelessWidget {
  final String status;
  const AiVerificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // 'approved' 상태일 때만 배지를 표시합니다.
    if (status == 'approved') {
      return const Tooltip(
        message: 'AI 검증 완료',
        child: Icon(Icons.verified, color: Colors.blue, size: 20),
      );
    }
    
    // 그 외의 경우(pending, rejected, none)에는 아무것도 표시하지 않습니다.
    return const SizedBox.shrink();
  }
}
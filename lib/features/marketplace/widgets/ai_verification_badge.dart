// lib/features/marketplace/widgets/ai_verification_badge.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AiVerificationBadge extends StatelessWidget {
  const AiVerificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              color: Theme.of(context).primaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            'marketplace.aiBadge'.tr(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

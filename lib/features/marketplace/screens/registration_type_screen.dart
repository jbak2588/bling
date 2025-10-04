// lib/features/marketplace/screens/registration_type_screen.dart

import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/marketplace/screens/ai_category_selection_screen.dart';

class RegistrationTypeScreen extends StatelessWidget {
  const RegistrationTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('registration_flow.title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 신품 판매 카드
            _buildSelectionCard(
              context: context,
              icon: Icons.add_box_outlined,
              title: 'registration_flow.new_item_title'.tr(),
              description: 'registration_flow.new_item_desc'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProductRegistrationScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            // 2. 중고품 판매(AI 검수) 카드 (isFeatured: true로 강조)
            _buildSelectionCard(
              context: context,
              icon: Icons.shield_outlined,
              title: 'registration_flow.used_item_title'.tr(),
              description: 'registration_flow.used_item_desc'.tr(),
              isFeatured: true, // AI 검수 옵션을 강조 표시합니다.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AiCategorySelectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 등록 방식 선택 카드를 만드는 위젯 (기존 코드 활용 및 개선)
  Widget _buildSelectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return Card(
      elevation: isFeatured ? 6.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isFeatured
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon,
                  size: 48,
                  color: isFeatured
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

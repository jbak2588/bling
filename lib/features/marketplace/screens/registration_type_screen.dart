// lib/features/marketplace/screens/registration_type_screen.dart

import 'package:bling_app/features/marketplace/screens/product_registration_screen.dart';
import 'package:flutter/material.dart';
import 'ai_inspection_guide_screen.dart'; // AI 검수 안내 화면

class RegistrationTypeScreen extends StatelessWidget {
  const RegistrationTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('등록 방식 선택'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectionCard(
              context: context,
              icon: Icons.edit_note,
              title: '일반 등록',
              description: '기본적인 정보를 입력하여 빠르게 상품을 등록합니다.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductRegistrationScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSelectionCard(
              context: context,
              icon: Icons.shield_outlined,
              title: 'AI 검수 안전 거래 등록',
              description: 'AI가 상품을 분석하여 신뢰도를 높이고 더 빠르게 판매할 수 있도록 도와줍니다.',
              isFeatured: true, // AI 검수 옵션을 강조
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiInspectionGuideScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 등록 방식 선택 카드를 만드는 위젯
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
              Icon(icon, size: 48, color: isFeatured ? Theme.of(context).primaryColor : Colors.grey[700]),
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
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
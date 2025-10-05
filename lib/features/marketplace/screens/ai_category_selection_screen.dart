// lib/features/marketplace/screens/ai_category_selection_screen.dart

import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/marketplace/screens/ai_gallery_upload_screen.dart';

class AiCategorySelectionScreen extends StatelessWidget {
  const AiCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.category_selection.title'.tr()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore 'ai_verification_rules' 컬렉션에서 데이터를 실시간으로 가져옵니다.
        stream: FirebaseFirestore.instance
            .collection('ai_verification_rules')
            .where('is_ai_verification_supported',
                isEqualTo: true) // AI 검수를 지원하는 카테고리만 필터링
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ai_flow.category_selection.error'.tr()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('ai_flow.category_selection.no_categories'.tr()));
          }

          final rules = snapshot.data!.docs
              .map((doc) => AiVerificationRule.fromSnapshot(doc))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 한 줄에 2개의 아이템
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2, // 아이템의 가로세로 비율
            ),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return _buildCategoryCard(context, rule);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AiVerificationRule rule) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 기존: ScaffoldMessenger...
          // 수정: 새로 만든 1차 갤러리 업로드 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AiGalleryUploadScreen(rule: rule), // 선택한 rule 객체를 전달
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: 아이콘을 DB에 추가하거나, 카테고리 ID별로 아이콘을 매핑하는 로직이 필요합니다.
            // 현재는 임시 아이콘을 사용합니다.
            _getIconForCategory(rule.id,
                size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              // 현재 앱의 언어 설정에 따라 ko 또는 id 이름을 보여줍니다.
              context.locale.languageCode == 'ko' ? rule.nameKo : rule.nameId,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 ID에 따라 적절한 아이콘을 반환하는 임시 함수
  Icon _getIconForCategory(String categoryId, {double? size, Color? color}) {
    IconData iconData;
    switch (categoryId) {
      case 'smartphone':
        iconData = Icons.smartphone;
        break;
      case 'womens_bag':
        iconData = Icons.shopping_bag_outlined;
        break;
      case 'shoes':
        iconData = Icons.directions_run; // 임시 아이콘
        break;
      default:
        iconData = Icons.category;
    }
    return Icon(iconData, size: size, color: color);
  }
}

/// ============================================================================
/// Bling DocHeader
/// Module        : Categories
/// File          : lib/features/categories/screens/parent_category_screen.dart
/// Purpose       : 부모 카테고리 선택 화면 (아이콘 포함, 저장소 기반)
/// User Impact   : 등록/수정 시 대분류를 직관적으로 선택하고, 서브 화면으로 진입합니다.
/// Notes         : 관리자에서 저장한 icon 필드를 그대로 반영하며, 없으면 slug/nameEn 기반 fallback.
/// ============================================================================
/// 상품 등록용 부모 카테고리 선택 화면
/// - Firestore의 `icon: 'ms:*'` 문자열을 받아 Material 아이콘으로 표시

library;

import 'package:bling_app/features/categories/domain/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/category_icons.dart';

class ParentCategoryScreen extends StatelessWidget {
  const ParentCategoryScreen({super.key});

  String _getCategoryName(BuildContext context, Category category) {
    final langCode = context.locale.languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      case 'en':
      default:
        return category.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('selectCategory'.tr())),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories_v2')
            .where('isParent', isEqualTo: true)
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('marketplace.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('category_empty'.tr()));
          }

          final categories = snapshot.data!.docs
              .map((doc) => Category.fromFirestore(doc))
              .where((c) => c.parentId == null || c.isParent == true)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = _getCategoryName(context, category);

              return ListTile(
                leading: CategoryIcons.widget(
                  category.icon ??
                      CategoryIcons.suggestForParent(
                        nameEn: category.nameEn,
                        slug: category.slug,
                      ),
                  size: 22,
                ),
                title: Text(categoryName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.of(context).push<Category>(
                    MaterialPageRoute(
                      builder: (_) => SubCategoryScreen(
                        parentId: category.id,
                        parentName: categoryName,
                      ),
                    ),
                  );

                  if (result != null && context.mounted) {
                    Navigator.of(context).pop(result);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SubCategoryScreen extends StatelessWidget {
  final String parentId;
  final String parentName;
  const SubCategoryScreen({
    super.key,
    required this.parentId,
    required this.parentName,
  });

  String _getCategoryName(BuildContext context, Category category) {
    final langCode = context.locale.languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      case 'en':
      default:
        return category.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(parentName)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories_v2')
            .doc(parentId)
            .collection('subCategories')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('marketplace.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('category_empty'.tr()));
          }

          final categories = snapshot.data!.docs
              .map((doc) => Category.fromFirestore(doc))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: CategoryIcons.widget(
                  category.icon ??
                      CategoryIcons.suggestForSub(
                        nameEn: category.nameEn,
                        slug: category.slug,
                      ),
                  size: 20,
                ),
                title: Text(_getCategoryName(context, category)),
                onTap: () => Navigator.of(context).pop(category),
              );
            },
          );
        },
      ),
    );
  }
}

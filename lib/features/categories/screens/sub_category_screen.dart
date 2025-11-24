/// ============================================================================
/// Bling DocHeader
/// Module        : Categories
/// File          : lib/features/categories/screens/sub_category_screen.dart
/// Purpose       : 서브 카테고리 선택 화면 (아이콘 포함, 저장소 기반)
/// User Impact   : 선택한 대분류 하위 소분류를 직관적으로 선택합니다.
/// Notes         : 관리자에서 저장한 icon 필드를 그대로 반영하며, 없으면 slug/nameEn 기반 fallback.
/// ============================================================================
///

library;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/i18n/strings.g.dart';

import '../constants/category_icons.dart';
// repository imports removed: using direct Firestore queries against categories_v2
import '../domain/category.dart';

class SubCategoryScreen extends StatelessWidget {
  final Category parent;
  const SubCategoryScreen({super.key, required this.parent});

  String _displayName(BuildContext context, Category c) {
    final code = LocaleSettings.currentLocale.languageCode;
    switch (code) {
      case 'ko':
        return c.nameKo;
      case 'id':
        return c.nameId;
      default:
        return c.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentTitle = _displayName(context, parent);

    return Scaffold(
      appBar: AppBar(title: Text(parentTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories_v2')
            .doc(parent.id)
            .collection('subCategories')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                t.marketplace.error
                    .replaceAll('{error}', snapshot.error.toString()),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(t.categoryEmpty));
          }

          final items = snapshot.data!.docs
              .map((doc) => Category.fromFirestore(doc))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, i) {
              final c = items[i];
              final title = _displayName(context, c);
              return ListTile(
                leading: CategoryIcons.widget(
                  c.effectiveIcon(forParent: false),
                  size: 20,
                ),
                title:
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.of(context).pop(c),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}

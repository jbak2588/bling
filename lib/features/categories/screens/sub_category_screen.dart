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
import 'package:easy_localization/easy_localization.dart';

import '../constants/category_icons.dart';
import '../data/category_repository.dart';
import '../data/firestore_category_repository.dart';
import '../domain/category.dart';

class SubCategoryScreen extends StatelessWidget {
  final Category parent;
  const SubCategoryScreen({super.key, required this.parent});

  String _displayName(BuildContext context, Category c) {
    final code = context.locale.languageCode;
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
    final CategoryRepository repo = FirestoreCategoryRepository();
    final parentTitle = _displayName(context, parent);

    return Scaffold(
      appBar: AppBar(title: Text(parentTitle)),
      body: StreamBuilder<List<Category>>(
        // parentId 기준으로 active == true, order 정렬
        stream: repo.watchSubs(parent.id, activeOnly: true),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'marketplace.error'
                    .tr(namedArgs: {'error': snap.error.toString()}),
              ),
            );
          }
          final items = snap.data ?? const <Category>[];
          if (items.isEmpty) {
            return Center(child: Text('category_empty'.tr()));
          }

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

// lib/features/categories/presentation/screens/parent_category_screen.dart
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/categories/screens/sub_category_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
            .collection('categories')
            .where('parentId', isEqualTo: "")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                  'marketplace.error'.tr(namedArgs: {'error': snapshot.error.toString()})),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('category_empty'.tr()));
          }

          final categories = snapshot.data!.docs
              .map((doc) => Category.fromFirestore(doc))
              .toList();

          categories.sort((a, b) => a.order.compareTo(b.order));

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = _getCategoryName(context, category);

              return ListTile(
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

// lib/features/categories/presentation/screens/sub_category_screen.dart
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
            .collection('categories')
            .where('parentId', isEqualTo: parentId)
            .orderBy('order')
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

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(_getCategoryName(context, category)),
                onTap: () {
                  Navigator.of(context).pop(category);
                },
              );
            },
          );
        },
      ),
    );
  }
}

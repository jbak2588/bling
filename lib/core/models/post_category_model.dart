// lib/core/models/post_category_model.dart
// Bling App v0.4
import 'package:flutter/widgets.dart';

class PostCategoryModel {
  final String categoryId;
  final String name;
  final String description;
  final IconData icon;
  final String emoji; // [추가] 이모지를 담을 필드

  const PostCategoryModel({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.icon,
    required this.emoji, // [추가]
  });
}

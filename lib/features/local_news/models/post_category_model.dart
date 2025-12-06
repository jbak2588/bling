// lib/core/models/post_category_model.dart

class PostCategoryModel {
  final String categoryId;
  final String emoji;
  // ✅ [수정] 필드명을 name -> nameKey, description -> descriptionKey로 변경합니다.
  final String nameKey;
  final String descriptionKey;

  PostCategoryModel({
    required this.categoryId,
    required this.emoji,
    required this.nameKey,
    required this.descriptionKey,
  });

  // Compatibility: provide a common `title` getter used by UI helpers.
  String get title => nameKey;
}

// lib/features/auction/models/auction_category_model.dart

class AuctionCategoryModel {
  final String categoryId;
  final String emoji;
  final String nameKey;

  const AuctionCategoryModel({
    required this.categoryId,
    required this.emoji,
    required this.nameKey,
  });
}

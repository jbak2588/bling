// lib/core/constants/app_categories.dart

import '../../features/local_news/models/post_category_model.dart';
import '../../features/auction/models/auction_category_model.dart';

class AppCategories {
  // ✅ [핵심 수정] name과 description을 다국어 키(key)로 변경합니다.

  // ✅ local news 카테고리 (동네소식 전용)
  static final List<PostCategoryModel> postCategories = [
    PostCategoryModel(
      categoryId: 'daily_life',
      emoji: '😊',
      nameKey: 'categories.post.daily_life.name',
      descriptionKey: 'categories.post.daily_life.description',
    ),
    PostCategoryModel(
      categoryId: 'help_share',
      emoji: '🤝',
      nameKey: 'categories.post.help_share.name',
      descriptionKey: 'categories.post.help_share.description',
    ),
    PostCategoryModel(
      categoryId: 'incident_report',
      emoji: '🚨',
      nameKey: 'categories.post.incident_report.name',
      descriptionKey: 'categories.post.incident_report.description',
    ),
    PostCategoryModel(
      categoryId: 'local_news',
      emoji: '📰',
      nameKey: 'categories.post.local_news.name',
      descriptionKey: 'categories.post.local_news.description',
    ),
    PostCategoryModel(
      categoryId: 'daily_question',
      emoji: '❓',
      nameKey: 'categories.post.daily_question.name',
      descriptionKey: 'categories.post.daily_question.description',
    ),
    PostCategoryModel(
      categoryId: 'store_promo',
      emoji: '🎉',
      nameKey: 'categories.post.store_promo.name',
      descriptionKey: 'categories.post.store_promo.description',
    ),
    PostCategoryModel(
      categoryId: 'etc',
      emoji: '💬',
      nameKey: 'categories.post.etc.name',
      descriptionKey: 'categories.post.etc.description',
    ),
  ];

  // ✅ Auction 카테고리 (경매용)
  static const List<AuctionCategoryModel> auctionCategories = [
    AuctionCategoryModel(
      categoryId: 'collectibles',
      emoji: '🧸',
      nameKey: 'categories.auction.collectibles.name',
    ),
    AuctionCategoryModel(
      categoryId: 'digital',
      emoji: '💾',
      nameKey: 'categories.auction.digital.name',
    ),
    AuctionCategoryModel(
      categoryId: 'fashion',
      emoji: '👗',
      nameKey: 'categories.auction.fashion.name',
    ),
    AuctionCategoryModel(
      categoryId: 'vintage',
      emoji: '🕰️',
      nameKey: 'categories.auction.vintage.name',
    ),
    AuctionCategoryModel(
      categoryId: 'art_craft',
      emoji: '🎨',
      nameKey: 'categories.auction.art_craft.name',
    ),
    AuctionCategoryModel(
      categoryId: 'etc',
      emoji: '📦',
      nameKey: 'categories.auction.etc.name',
    ),
  ];
}

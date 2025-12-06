// lib/core/constants/app_categories.dart

import '../../features/local_news/models/post_category_model.dart';
import '../../features/auction/models/auction_category_model.dart';
// 추가된 feature 카테고리 참조
import '../../features/jobs/constants/job_categories.dart';

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

  // Jobs 카테고리(앱 전체에서 사용될 수 있도록 노출)
  // AppJobCategories에서 정의된 JobCategory들을 재사용합니다.
  static final List<JobCategory> jobCategories = AppJobCategories.allCategories;

  // Local Stores(상점) 업종 카테고리
  static final List<PostCategoryModel> shopCategories = [
    PostCategoryModel(
      categoryId: 'food',
      emoji: '🍽️',
      nameKey: 'localStores.categories.food',
      descriptionKey: 'localStores.categories.food.description',
    ),
    PostCategoryModel(
      categoryId: 'cafe',
      emoji: '☕',
      nameKey: 'localStores.categories.cafe',
      descriptionKey: 'localStores.categories.cafe.description',
    ),
    PostCategoryModel(
      categoryId: 'massage',
      emoji: '💆',
      nameKey: 'localStores.categories.massage',
      descriptionKey: 'localStores.categories.massage.description',
    ),
    PostCategoryModel(
      categoryId: 'beauty',
      emoji: '💄',
      nameKey: 'localStores.categories.beauty',
      descriptionKey: 'localStores.categories.beauty.description',
    ),
    PostCategoryModel(
      categoryId: 'nail',
      emoji: '💅',
      nameKey: 'localStores.categories.nail',
      descriptionKey: 'localStores.categories.nail.description',
    ),
    PostCategoryModel(
      categoryId: 'auto',
      emoji: '🚗',
      nameKey: 'localStores.categories.auto',
      descriptionKey: 'localStores.categories.auto.description',
    ),
    PostCategoryModel(
      categoryId: 'kids',
      emoji: '🧒',
      nameKey: 'localStores.categories.kids',
      descriptionKey: 'localStores.categories.kids.description',
    ),
    PostCategoryModel(
      categoryId: 'hospital',
      emoji: '🏥',
      nameKey: 'localStores.categories.hospital',
      descriptionKey: 'localStores.categories.hospital.description',
    ),
    PostCategoryModel(
      categoryId: 'etc',
      emoji: '📦',
      nameKey: 'localStores.categories.etc',
      descriptionKey: 'localStores.categories.etc.description',
    ),
  ];

  // Clubs(동호회/모임) 카테고리
  static final List<PostCategoryModel> clubCategories = [
    PostCategoryModel(
      categoryId: 'sports',
      emoji: '🏀',
      nameKey: 'clubs.categories.sports',
      descriptionKey: 'clubs.categories.sports.description',
    ),
    PostCategoryModel(
      categoryId: 'hobbies',
      emoji: '🎯',
      nameKey: 'clubs.categories.hobbies',
      descriptionKey: 'clubs.categories.hobbies.description',
    ),
    PostCategoryModel(
      categoryId: 'social',
      emoji: '🤝',
      nameKey: 'clubs.categories.social',
      descriptionKey: 'clubs.categories.social.description',
    ),
    PostCategoryModel(
      categoryId: 'study',
      emoji: '📚',
      nameKey: 'clubs.categories.study',
      descriptionKey: 'clubs.categories.study.description',
    ),
    PostCategoryModel(
      categoryId: 'reading',
      emoji: '📖',
      nameKey: 'clubs.categories.reading',
      descriptionKey: 'clubs.categories.reading.description',
    ),
    PostCategoryModel(
      categoryId: 'culture',
      emoji: '🎭',
      nameKey: 'clubs.categories.culture',
      descriptionKey: 'clubs.categories.culture.description',
    ),
    PostCategoryModel(
      categoryId: 'travel',
      emoji: '✈️',
      nameKey: 'clubs.categories.travel',
      descriptionKey: 'clubs.categories.travel.description',
    ),
    PostCategoryModel(
      categoryId: 'volunteer',
      emoji: '🤲',
      nameKey: 'clubs.categories.volunteer',
      descriptionKey: 'clubs.categories.volunteer.description',
    ),
    PostCategoryModel(
      categoryId: 'pets',
      emoji: '🐶',
      nameKey: 'clubs.categories.pets',
      descriptionKey: 'clubs.categories.pets.description',
    ),
    PostCategoryModel(
      categoryId: 'food',
      emoji: '🍽️',
      nameKey: 'clubs.categories.food',
      descriptionKey: 'clubs.categories.food.description',
    ),
    PostCategoryModel(
      categoryId: 'etc',
      emoji: '💬',
      nameKey: 'clubs.categories.etc',
      descriptionKey: 'clubs.categories.etc.description',
    ),
  ];

  // Real Estate 카테고리 (매물 타입)
  static final List<PostCategoryModel> realEstateCategories = [
    PostCategoryModel(
      categoryId: 'kos',
      emoji: '🏠',
      nameKey: 'realEstate.form.roomTypes.kos',
      descriptionKey: 'realEstate.form.roomTypes.kos.description',
    ),
    PostCategoryModel(
      categoryId: 'apartment',
      emoji: '🏢',
      nameKey: 'realEstate.form.roomTypes.apartment',
      descriptionKey: 'realEstate.form.roomTypes.apartment.description',
    ),
    PostCategoryModel(
      categoryId: 'kontrakan',
      emoji: '🏘️',
      nameKey: 'realEstate.form.roomTypes.kontrakan',
      descriptionKey: 'realEstate.form.roomTypes.kontrakan.description',
    ),
    PostCategoryModel(
      categoryId: 'house',
      emoji: '🏡',
      nameKey: 'realEstate.form.roomTypes.house',
      descriptionKey: 'realEstate.form.roomTypes.house.description',
    ),
    PostCategoryModel(
      categoryId: 'ruko',
      emoji: '🏬',
      nameKey: 'realEstate.form.roomTypes.ruko',
      descriptionKey: 'realEstate.form.roomTypes.ruko.description',
    ),
    PostCategoryModel(
      categoryId: 'gudang',
      emoji: '🏭',
      nameKey: 'realEstate.form.roomTypes.gudang',
      descriptionKey: 'realEstate.form.roomTypes.gudang.description',
    ),
    PostCategoryModel(
      categoryId: 'kantor',
      emoji: '🏢',
      nameKey: 'realEstate.form.roomTypes.kantor',
      descriptionKey: 'realEstate.form.roomTypes.kantor.description',
    ),
    PostCategoryModel(
      categoryId: 'etc',
      emoji: '📦',
      nameKey: 'realEstate.form.roomTypes.etc',
      descriptionKey: 'realEstate.form.roomTypes.etc.description',
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

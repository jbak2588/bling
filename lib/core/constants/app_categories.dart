// lib/core/constants/app_categories.dart
// Bling App v0.4
import 'package:flutter/material.dart';
import '../models/post_category_model.dart';

class AppCategories {
  static const List<PostCategoryModel> postCategories = [
    PostCategoryModel(
      categoryId: 'daily_question',
      name: '일상/궁금',
      description: '소소한 일상, 동네 사진, 생활 꿀팁, 동네 질문 등',
      icon: Icons.chat_bubble_outline,
      emoji: '💬', // [추가]
    ),
    PostCategoryModel(
      categoryId: 'help_share',
      name: '도움/나눔',
      description: '무료 나눔, 공동구매, 카풀, 작은 도움이 필요한 일 등',
      icon: Icons.people_outline,
      emoji: '🤝', // [추가]
    ),
    PostCategoryModel(
      categoryId: 'incident_report',
      name: '사건/사고',
      description: '분실/습득, 사건사고, 동네 위험지역 공유',
      icon: Icons.report_problem_outlined,
      emoji: '🚨', // [추가]
    ),
    PostCategoryModel(
      categoryId: 'local_news',
      name: '동네소식',
      description: '마을 행사, 플리마켓, 관리사무소/RT/RW 공지 등',
      icon: Icons.campaign_outlined,
      emoji: '📢', // [추가]
    ),
    PostCategoryModel(
      categoryId: 'store_promo',
      name: '우리동네 홍보',
      description: '내 가게, 새로 오픈한 가게, 과외/클래스 홍보',
      icon: Icons.store_outlined,
      emoji: '🏪', // [추가]
    ),
    PostCategoryModel(
      categoryId: 'etc',
      name: '기타',
      description: '다른 카테고리에 속하지 않는 자유로운 주제의 글',
      icon: Icons.more_horiz_outlined,
      emoji: '🏷️', // [추가]
    ),
  ];
}

// lib/features/categories/constants/category_icons.dart
// node scripts/backfill_category_icons.js --dry-run
// node scripts/backfill_category_icons.js
// node scripts/export_categories_v2_design.js

/// 카테고리 아이콘 규격 통일 모듈
/// - Firestore에는 항상 `icon: "ms:*"` 문자열만 저장
/// - 화면에서는 `IconData`로 매핑하여 아이콘 렌더링 (assets/svg 미사용)
///
library;

import 'package:flutter/material.dart';

class CategoryIcons {
  /// 사용 가능한 옵션(관리자 팝업에 노출)
  static const List<String> options = [
    // 공통/기본
    'ms:category',
    // 상위 카테고리 추천 세트
    'ms:devices', // Digital Devices
    'ms:home', // Home Essentials
    'ms:checkroom', // Fashion
    'ms:spa', // Beauty & Care
    'ms:diamond', // Limited & Luxury
    'ms:sports_esports', // Hobby & Leisure
    'ms:child_friendly', // Baby & Kids
    'ms:two_wheeler', // Motorcycle

    // 서브카테고리 대표 세트
    'ms:electronics',
    'ms:smartphone',
    'ms:laptop',
    'ms:photo_camera',
    'ms:extension', // other digital

    'ms:restaurant', // kitchenware
    'ms:weekend', // furniture
    'ms:lightbulb', // lighting
    'ms:inventory_2', // other home

    'ms:woman', // women’s clothing
    'ms:man', // men’s clothing
    'ms:shoe', // shoes
    'ms:work', // bags/accessories
    'ms:category', // other fashion

    'ms:skincare', // skincare(대체)
    'ms:brush', // makeup
    'ms:face_retouching_natural', // hair-body(대체)
    'ms:spa', // other beauty

    'ms:military_tech', // limited edition
    'ms:diamond', // luxury
    'ms:target', // hunter's pick(대체)
    'ms:category', // other limited

    'ms:sports_soccer',
    'ms:sports_esports',
    'ms:piano', // instruments(대체)
    'ms:menu_book',
    'ms:category', // other hobby

    'ms:child_friendly', // baby clothing
    'ms:toys',
    'ms:crib', // baby essentials(대체)
    'ms:category', // other baby

    'ms:two_wheeler', // motorcycle
    'ms:build', // parts
    'ms:build_circle', // accessories
    'ms:category', // other motor

    'ms:handyman', // handcrafts
    'ms:category', // other items
  ];

  /// 문자열 코드 → IconData 매핑
  static IconData _toIconData(String code) {
    switch (code) {
      // 공통
      case 'ms:category':
        return Icons.category_outlined;

      // 상위 카테고리
      case 'ms:devices':
        return Icons.devices_outlined;
      case 'ms:home':
        return Icons.home_outlined;
      case 'ms:checkroom':
        return Icons.checkroom_outlined;
      case 'ms:spa':
        return Icons.spa_outlined;
      case 'ms:diamond':
        return Icons.diamond_outlined;
      case 'ms:sports_esports':
        return Icons.sports_esports_outlined;
      case 'ms:child_friendly':
        return Icons.child_friendly_outlined;
      case 'ms:two_wheeler':
        return Icons.two_wheeler_outlined;

      // 디지털
      case 'ms:electronics':
        return Icons.memory_outlined;
      case 'ms:smartphone':
        return Icons.smartphone_outlined;
      case 'ms:laptop':
        return Icons.laptop_outlined;
      case 'ms:photo_camera':
        return Icons.photo_camera_outlined;
      case 'ms:extension':
        return Icons.extension_outlined;

      // 생활
      case 'ms:restaurant':
        return Icons.restaurant_outlined;
      case 'ms:weekend':
        return Icons.weekend_outlined;
      case 'ms:lightbulb':
        return Icons.lightbulb_outline;
      case 'ms:inventory_2':
        return Icons.inventory_2_outlined;

      // 패션
      case 'ms:woman':
        return Icons.woman_outlined;
      case 'ms:man':
        return Icons.man_outlined;
      case 'ms:shoe':
        return Icons.hiking_outlined; // 대체(신발 전용 아이콘 부재)
      case 'ms:work':
        return Icons.work_outline;

      // 뷰티
      case 'ms:skincare':
        return Icons.clean_hands_outlined; // 대체
      case 'ms:brush':
        return Icons.brush_outlined;
      case 'ms:face_retouching_natural':
        return Icons.face_retouching_natural_outlined;

      // 리미티드
      case 'ms:military_tech':
        return Icons.military_tech_outlined;
      case 'ms:target':
        return Icons.my_location_outlined;

      // 취미
      case 'ms:sports_soccer':
        return Icons.sports_soccer_outlined;
      case 'ms:piano':
        return Icons.piano_outlined;
      case 'ms:menu_book':
        return Icons.menu_book_outlined;

      // 유아
      case 'ms:toys':
        return Icons.toys_outlined;
      case 'ms:crib':
        return Icons.crib_outlined;

      // 모터
      case 'ms:build':
        return Icons.build_outlined;
      case 'ms:build_circle':
        return Icons.build_circle_outlined;

      // 기타
      case 'ms:handyman':
        return Icons.handyman_outlined;
    }
    return Icons.category_outlined;
  }

  /// 주어진 코드로 Icon 위젯 생성
  static Widget widget(String? code, {double size = 20, Color? color}) {
    final c = code ?? 'ms:category';
    return Icon(_toIconData(c), size: size, color: color);
  }

  // 입력값에서 basename을 추출하여 'ms:<basename>' 형태로 반환합니다.
  // - 입력 예: 'assets/icons/electronics.png' -> 'ms:electronics'
  static String basename(String pathOrFile) {
    final parts = pathOrFile.split(RegExp(r'[\\/]+'));
    final file = parts.isNotEmpty ? parts.last : pathOrFile;
    final base = file.split('.').first;
    return 'ms:$base';
  }

  /// 아이콘 코드/slug 기반으로 최종 코드(ms:*)를 반환합니다.
  /// - icon이 주어지면 ms: 형식으로 변환/유지
  /// - 없으면 slug/name 기반 추천값을 반환
  static String resolve(
      {String? icon, required String slug, required bool isParent}) {
    if (icon != null && icon.isNotEmpty) {
      return icon.startsWith('ms:') ? icon : basename(icon);
    }
    return isParent
        ? suggestForParent(nameEn: slug, slug: slug)
        : suggestForSub(nameEn: slug, slug: slug);
  }

  /// 추천 아이콘(부모용): nameEn/slug 키워드 기반
  static String suggestForParent(
      {required String nameEn, required String slug}) {
    final s = '${nameEn.toLowerCase()}|${slug.toLowerCase()}';
    if (s.contains('digital')) return 'ms:devices';
    if (s.contains('home') || s.contains('house') || s.contains('living')) {
      return 'ms:home';
    }
    if (s.contains('fashion')) return 'ms:checkroom';
    if (s.contains('beauty') || s.contains('care')) return 'ms:spa';
    if (s.contains('limited') || s.contains('luxury')) return 'ms:diamond';
    if (s.contains('hobby') || s.contains('leisure')) {
      return 'ms:sports_esports';
    }
    if (s.contains('baby') || s.contains('kids')) return 'ms:child_friendly';
    if (s.contains('motor')) return 'ms:two_wheeler';
    if (s.contains('other')) return 'ms:category';
    return 'ms:category';
  }

  /// 추천 아이콘(서브용): slug 기준 우선
  static String suggestForSub({required String nameEn, required String slug}) {
    final s = slug.toLowerCase();
    if (s.contains('electronics')) return 'ms:electronics';
    if (s.contains('smartphone') || s.contains('tablet')) {
      return 'ms:smartphone';
    }
    if (s.contains('computer') || s.contains('laptop')) return 'ms:laptop';
    if (s.contains('camera') || s.contains('drone')) return 'ms:photo_camera';

    if (s.contains('kitchen')) return 'ms:restaurant';
    if (s.contains('furniture')) return 'ms:weekend';
    if (s.contains('lighting') || s.contains('electrical')) {
      return 'ms:lightbulb';
    }

    if (s.contains('women')) return 'ms:woman';
    if (s.contains('men')) return 'ms:man';
    if (s.contains('shoes')) return 'ms:shoe';
    if (s.contains('bags') || s.contains('accessories')) return 'ms:work';

    if (s.contains('skincare')) return 'ms:skincare';
    if (s.contains('makeup')) return 'ms:brush';
    if (s.contains('hair') || s.contains('body')) {
      return 'ms:face_retouching_natural';
    }

    if (s.contains('limited')) return 'ms:military_tech';
    if (s.contains('luxury')) return 'ms:diamond';
    if (s.contains('hunter')) return 'ms:target';

    if (s.contains('sports')) return 'ms:sports_soccer';
    if (s.contains('games') || s.contains('consoles')) {
      return 'ms:sports_esports';
    }
    if (s.contains('instrument')) return 'ms:piano';
    if (s.contains('books') || s.contains('stationery')) return 'ms:menu_book';

    if (s.contains('baby') && s.contains('clothing')) {
      return 'ms:child_friendly';
    }
    if (s.contains('toys')) return 'ms:toys';
    if (s.contains('essentials')) return 'ms:crib';

    if (s.contains('motor') && s.contains('parts')) return 'ms:build';
    if (s.contains('motor') && s.contains('accessor')) return 'ms:build_circle';

    if (s.contains('handcraft')) return 'ms:handyman';
    if (s.contains('other')) return 'ms:category';
    return 'ms:category';
  }
}

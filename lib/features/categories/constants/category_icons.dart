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
    'ms:kitchen', // Home Appliances (New)
    'ms:chair', // Furniture (New)
    'ms:inventory_2', // Living (New)
    'ms:book', // Books (New)
    'ms:pets', // Pets (New)
    'ms:potted_plant', // Plants (New)
    'ms:grid_view', // All (New)
    'ms:apps', // Sub All (New)

    // 서브카테고리 대표 세트
    'ms:electronics',
    'ms:smartphone',
    'ms:laptop',
    'ms:photo_camera',
    'ms:speaker', // Audio (New)
    'ms:tv', // TV (New)
    'ms:watch', // Wearable (New)
    'ms:extension', // other digital

    'ms:restaurant', // kitchenware
    'ms:weekend', // furniture
    'ms:lightbulb', // lighting
    'ms:inventory_2', // other home

    'ms:woman', // women’s clothing
    'ms:man', // men’s clothing
    'ms:shoe', // shoes
    'ms:work', // bags/accessories
    'ms:apparel', // clothes (New)
    'ms:shopping_bag', // bag (New)
    'ms:category', // other fashion

    'ms:skincare', // skincare(대체)
    'ms:brush', // makeup
    'ms:clean_hands', // cleanser (New)
    'ms:face_retouching_natural', // hair-body(대체)
    'ms:spa', // other beauty

    'ms:military_tech', // limited edition
    'ms:diamond', // luxury
    'ms:target', // hunter's pick(대체)
    'ms:category', // other limited

    'ms:sports_soccer',
    'ms:sports_esports',
    'ms:piano', // instruments(대체)
    'ms:fitness_center', // Gym (New)
    'ms:hiking', // Outdoor (New)
    'ms:sports_golf', // Golf (New)
    'ms:gamepad', // Game console (New)
    'ms:menu_book',
    'ms:category', // other hobby

    'ms:child_care', // baby general (New)
    'ms:stroller', // stroller (New)
    'ms:toys',
    'ms:crib', // baby essentials(대체)
    'ms:category', // other baby

    'ms:two_wheeler', // motorcycle
    'ms:build', // parts
    'ms:build_circle', // accessories
    'ms:category', // other motor

    'ms:local_laundry_service', // Washer (New)
    'ms:cleaning_services', // Vacuum (New)
    'ms:bed', // Bed (New)
    'ms:light', // Light (New)
    'ms:umbrella', // Living misc (New)
    'ms:confirmation_number', // Ticket (New)
    'ms:local_florist', // Flower (New)

    'ms:handyman', // handcrafts
    'ms:category', // other items
  ];

  /// 문자열 코드 → IconData 매핑
  static IconData _toIconData(String code) {
    switch (code) {
      // 공통
      case 'ms:category':
        return Icons.category_rounded; // Rounded 스타일 권장
      case 'ms:grid_view':
        return Icons.grid_view_rounded;
      case 'ms:apps':
        return Icons.apps_rounded;

      // 상위 카테고리
      case 'ms:devices':
        return Icons.devices_rounded;
      case 'ms:home':
        return Icons.home_rounded;
      case 'ms:checkroom':
        return Icons.checkroom_rounded;
      case 'ms:spa':
        return Icons.spa_rounded;
      case 'ms:diamond':
        return Icons.diamond_rounded;
      case 'ms:sports_esports':
        return Icons.sports_esports_rounded;
      case 'ms:child_friendly':
        return Icons.child_friendly_rounded;
      case 'ms:two_wheeler':
        return Icons.two_wheeler_rounded;
      case 'ms:kitchen':
        return Icons.kitchen_rounded;
      case 'ms:chair':
        return Icons.chair_rounded;
      // (inventory_2 mapping kept in '생활' section below)
      case 'ms:book':
        return Icons.book_rounded;
      case 'ms:pets':
        return Icons.pets_rounded;
      case 'ms:potted_plant':
        return Icons.local_florist_rounded; // potted_plant -> local_florist 대체
      case 'ms:more_horiz':
        return Icons.more_horiz_rounded;

      // 디지털
      case 'ms:electronics':
        return Icons.memory_rounded;
      case 'ms:smartphone':
        return Icons.smartphone_rounded;
      case 'ms:laptop':
        return Icons.laptop_rounded;
      case 'ms:photo_camera':
        return Icons.photo_camera_rounded;
      case 'ms:extension':
        return Icons.extension_rounded;
      case 'ms:speaker':
        return Icons.speaker_rounded;
      case 'ms:tv':
        return Icons.tv_rounded;
      case 'ms:watch':
        return Icons.watch_rounded;

      // 생활
      case 'ms:restaurant':
        return Icons.restaurant_rounded;
      case 'ms:weekend':
        return Icons.weekend_rounded;
      case 'ms:lightbulb':
        return Icons.lightbulb_rounded;
      case 'ms:inventory_2':
        return Icons.inventory_2_rounded;
      case 'ms:local_laundry_service':
        return Icons.local_laundry_service_rounded;
      case 'ms:cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'ms:bed':
        return Icons.bed_rounded;
      case 'ms:light':
        return Icons.light_mode_rounded;
      case 'ms:umbrella':
        return Icons.umbrella_rounded;

      // 패션
      case 'ms:woman':
        return Icons.woman_2_rounded; // woman -> woman_2
      case 'ms:man':
        return Icons.man_2_rounded; // man -> man_2
      case 'ms:shoe':
        return Icons.roller_skating_rounded; // hiking -> roller_skating (신발 느낌)
      case 'ms:work':
        return Icons.work_rounded;
      case 'ms:apparel':
        return Icons.checkroom_rounded;
      case 'ms:shopping_bag':
        return Icons.shopping_bag_rounded;

      // 뷰티
      case 'ms:skincare':
        return Icons.clean_hands_rounded;
      case 'ms:brush':
        return Icons.brush_rounded;
      case 'ms:face_retouching_natural':
        return Icons.face_retouching_natural_rounded;
      case 'ms:face':
        return Icons.face_rounded;
      case 'ms:clean_hands':
        return Icons.clean_hands_rounded;

      // 리미티드
      case 'ms:military_tech':
        return Icons.military_tech_rounded;
      case 'ms:target':
        return Icons.my_location_rounded;

      // 취미
      case 'ms:sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'ms:piano':
        return Icons.piano_rounded;
      case 'ms:menu_book':
        return Icons.menu_book_rounded;
      case 'ms:fitness_center':
        return Icons.fitness_center_rounded;
      case 'ms:hiking':
        return Icons.hiking_rounded;
      case 'ms:sports_golf':
        return Icons.sports_golf_rounded;
      case 'ms:gamepad':
        return Icons.gamepad_rounded;
      case 'ms:confirmation_number':
        return Icons.confirmation_number_rounded;

      // 유아
      case 'ms:child_care':
        return Icons.child_care_rounded;
      case 'ms:stroller':
        return Icons.stroller_rounded;
      case 'ms:toys':
        return Icons.toys_rounded;
      case 'ms:crib':
        return Icons.crib_rounded;

      // 모터
      case 'ms:build':
        return Icons.build_rounded;
      case 'ms:build_circle':
        return Icons.build_circle_rounded;

      // 기타
      case 'ms:handyman':
        return Icons.handyman_rounded;
      case 'ms:local_florist':
        return Icons.local_florist_rounded;
      case 'ms:cruelty_free':
        return Icons.cruelty_free_rounded;
      // utility icons used across app
      case 'ms:copy_all':
        return Icons.copy_all_outlined;
      case 'ms:close':
        return Icons.close_rounded;
      case 'ms:check':
        return Icons.check_rounded;
    }
    return Icons.category_rounded;
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
    if (s.contains('appliance') || s.contains('kitchen')) return 'ms:kitchen';
    if (s.contains('furniture')) return 'ms:chair';
    if (s.contains('life') || s.contains('living')) return 'ms:inventory_2';
    if (s.contains('wearable') || s.contains('smartwatch')) {
      return 'ms:watch';
    }
    if (s.contains('watch') || s.contains('wearable')) {
      return 'ms:watch';
    }
    if (s.contains('electronics')) {
      return 'ms:electronics';
    }
    if (s.contains('smartphone') || s.contains('tablet')) {
      return 'ms:smartphone';
    }
    if (s.contains('computer') || s.contains('laptop')) {
      return 'ms:laptop';
    }
    if (s.contains('camera') || s.contains('drone')) {
      return 'ms:photo_camera';
    }

    if (s.contains('kitchen') ||
        s.contains('kitchenware') ||
        s.contains('dish')) {
      return 'ms:restaurant';
    }
    if (s.contains('furniture')) {
      return 'ms:weekend';
    }
    if (s.contains('lighting') || s.contains('electrical')) {
      return 'ms:lightbulb';
    }
    if (s.contains('bed') || s.contains('mattress')) {
      return 'ms:bed';
    }
    if (s.contains('clean') || s.contains('vacuum') || s.contains('washer')) {
      return 'ms:cleaning_services';
    }
    if (s.contains('clean') || s.contains('wash')) {
      return 'ms:cleaning_services';
    }

    if (s.contains('women')) {
      return 'ms:woman';
    }
    if (s.contains('men')) {
      return 'ms:man';
    }
    if (s.contains('shoes')) {
      return 'ms:shoe';
    }
    if (s.contains('bags') || s.contains('accessories')) {
      return 'ms:work';
    }

    if (s.contains('skincare')) {
      return 'ms:skincare';
    }
    if (s.contains('makeup')) {
      return 'ms:brush';
    }
    if (s.contains('hair') || s.contains('body')) {
      return 'ms:face_retouching_natural';
    }
    if (s.contains('perfume') || s.contains('fragrance')) {
      return 'ms:spa'; // Fragrance 추가
    }

    if (s.contains('limited')) {
      return 'ms:military_tech';
    }
    if (s.contains('luxury')) {
      return 'ms:diamond';
    }
    if (s.contains('hunter')) {
      return 'ms:target';
    }

    if (s.contains('sports')) {
      return 'ms:sports_soccer';
    }
    if (s.contains('games') || s.contains('consoles')) {
      return 'ms:sports_esports';
    }
    if (s.contains('bicycle') || s.contains('bike')) {
      return 'ms:two_wheeler'; // Bicycle (Sports)
    }
    if (s.contains('instrument')) {
      return 'ms:piano';
    }
    if (s.contains('books') || s.contains('stationery')) {
      return 'ms:menu_book';
    }
    if (s.contains('ticket') || s.contains('coupon')) {
      return 'ms:confirmation_number';
    }

    if (s.contains('baby') && s.contains('clothing')) {
      return 'ms:child_friendly';
    }
    if (s.contains('stroller') || s.contains('carseat')) {
      return 'ms:stroller'; // Carseat 추가
    }
    if (s.contains('toys')) {
      return 'ms:toys';
    }
    if (s.contains('essentials')) {
      return 'ms:crib';
    }

    if (s.contains('motor') && s.contains('parts')) {
      return 'ms:build';
    }
    if (s.contains('motor') && s.contains('accessor')) {
      return 'ms:build_circle';
    }

    if (s.contains('handcraft')) {
      return 'ms:handyman';
    }
    if (s.contains('cat') || s.contains('dog')) {
      return 'ms:pets';
    }
    if (s.contains('plant') || s.contains('flower')) {
      return 'ms:local_florist';
    }
    if (s.contains('ticket') || s.contains('coupon') || s.contains('voucher')) {
      return 'ms:confirmation_number'; // Voucher 추가
    }
    if (s.contains('other')) {
      return 'ms:category';
    }
    return 'ms:category';
  }

  /// 추천 아이콘(서브용): slug 기준 우선
  static String suggestForSub({required String nameEn, required String slug}) {
    final s = slug.toLowerCase();
    if (s.contains('audio') || s.contains('speaker')) {
      return 'ms:speaker';
    }
    if (s.contains('tv') || s.contains('monitor')) {
      return 'ms:tv';
    }
    if (s.contains('wearable') || s.contains('smartwatch')) return 'ms:watch';
    if (s.contains('watch') || s.contains('wearable')) {
      return 'ms:watch';
    }
    if (s.contains('electronics')) {
      return 'ms:electronics';
    }
    if (s.contains('smartphone') || s.contains('tablet')) {
      return 'ms:smartphone';
    }
    if (s.contains('computer') || s.contains('laptop')) {
      return 'ms:laptop';
    }
    if (s.contains('camera') || s.contains('drone')) {
      return 'ms:photo_camera';
    }

    if (s.contains('kitchen') ||
        s.contains('kitchenware') ||
        s.contains('dish')) {
      return 'ms:restaurant';
    }
    if (s.contains('furniture')) {
      return 'ms:weekend';
    }
    if (s.contains('lighting') || s.contains('electrical')) {
      return 'ms:lightbulb';
    }
    if (s.contains('bed') || s.contains('mattress')) {
      return 'ms:bed';
    }
    if (s.contains('clean') || s.contains('vacuum') || s.contains('washer')) {
      return 'ms:cleaning_services';
    }
    if (s.contains('clean') || s.contains('wash')) {
      return 'ms:cleaning_services';
    }

    if (s.contains('women')) {
      return 'ms:woman';
    }
    if (s.contains('men')) {
      return 'ms:man';
    }
    if (s.contains('shoes')) {
      return 'ms:shoe';
    }
    if (s.contains('bags') || s.contains('accessories')) {
      return 'ms:work';
    }

    if (s.contains('skincare')) {
      return 'ms:skincare';
    }
    if (s.contains('makeup')) {
      return 'ms:brush';
    }
    if (s.contains('hair') || s.contains('body')) {
      return 'ms:face_retouching_natural';
    }
    if (s.contains('perfume') || s.contains('fragrance')) {
      return 'ms:spa'; // Fragrance 추가
    }

    if (s.contains('limited')) {
      return 'ms:military_tech';
    }
    if (s.contains('luxury')) {
      return 'ms:diamond';
    }
    if (s.contains('hunter')) {
      return 'ms:target';
    }

    if (s.contains('sports')) {
      return 'ms:sports_soccer';
    }
    if (s.contains('games') || s.contains('consoles')) {
      return 'ms:sports_esports';
    }
    if (s.contains('bicycle') || s.contains('bike')) {
      return 'ms:two_wheeler'; // Bicycle (Sports)
    }
    if (s.contains('instrument')) {
      return 'ms:piano';
    }
    if (s.contains('books') || s.contains('stationery')) {
      return 'ms:menu_book';
    }
    if (s.contains('ticket') || s.contains('coupon')) {
      return 'ms:confirmation_number';
    }

    if (s.contains('baby') && s.contains('clothing')) {
      return 'ms:child_friendly';
    }
    if (s.contains('stroller') || s.contains('carseat')) {
      return 'ms:stroller'; // Carseat 추가
    }
    if (s.contains('toys')) {
      return 'ms:toys';
    }
    if (s.contains('essentials')) {
      return 'ms:crib';
    }

    if (s.contains('motor') && s.contains('parts')) {
      return 'ms:build';
    }
    if (s.contains('motor') && s.contains('accessor')) {
      return 'ms:build_circle';
    }

    if (s.contains('handcraft')) {
      return 'ms:handyman';
    }
    if (s.contains('cat') || s.contains('dog')) {
      return 'ms:pets';
    }
    if (s.contains('plant') || s.contains('flower')) {
      return 'ms:local_florist';
    }
    if (s.contains('ticket') || s.contains('coupon') || s.contains('voucher')) {
      return 'ms:confirmation_number'; // Voucher 추가
    }
    if (s.contains('other')) {
      return 'ms:category';
    }
    return 'ms:category';
  }
}

// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 31, 33) '직방' 모델 도입.
// 2. 이 화면을 '매물 리스트'에서 '카테고리 런처(Launcher)' 화면으로 전면 개편.
// 3. 기존 리스트/필터 로직은 'room_list_screen.dart' 파일로 이전됨.
//
// [LEGAL DISCLAIMER - 절대 삭제 금지]
// 아래 고지 문구는 각 섹션 및 화면 하단에 공통적으로 노출되어야 하며,
// 현지 법률의 미묘한 차이를 고려하되 동일한 취지를 유지해야 합니다.
// 번역 키: 'realEstate.disclaimer' (ko/en/id 모두 존재)
// =====================================================
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 5) 인도네시아 현지 수요('rumah123' 분석)를 반영하여 'Gudang'(창고) 카테고리 추가.
// 2. (기존) '직방' 모델(Task 31)에 따라 카테고리 런처 화면으로 개편됨.
// =====================================================
// lib/features/real_estate/screens/real_estate_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart'; // AppSection 타입
import 'package:bling_app/features/real_estate/screens/room_list_screen.dart';

class RealEstateScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const RealEstateScreen({
    super.key,
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // '직방' 스타일 카테고리 정의
    final List<Map<String, dynamic>> categories = [
      {
        'type': 'kos',
        'icon': Icons.night_shelter_outlined,
        'labelKey': 'realEstate.form.roomTypes.kos'
      },
      {
        'type': 'apartment',
        'icon': Icons.apartment_outlined,
        'labelKey': 'realEstate.form.roomTypes.apartment'
      },
      {
        'type': 'kontrakan', // Kontrakan (월/연세 - 원룸/빌라)
        'icon': Icons.house_siding_outlined,
        'labelKey': 'realEstate.form.roomTypes.kontrakan'
      },
      {
        'type': 'house', // House (주택)
        'icon': Icons.house_outlined,
        'labelKey': 'realEstate.form.roomTypes.house'
      },
      {
        'type': 'ruko',
        'icon': Icons.storefront_outlined,
        'labelKey': 'realEstate.form.roomTypes.ruko'
      },
      {
        // [추가] Gudang (창고)
        'type': 'gudang',
        'icon': Icons.warehouse_outlined, // 창고 아이콘
        'labelKey': 'realEstate.form.roomTypes.gudang'
      },
      {
        'type': 'kantor',
        'icon': Icons.business_center_outlined,
        'labelKey': 'realEstate.form.roomTypes.kantor'
      },
      {
        'type': 'etc',
        'icon': Icons.more_horiz_outlined,
        'labelKey': 'realEstate.form.roomTypes.etc'
      },
    ];

    return Scaffold(
      // (참고) 이 화면은 MainNavigationScreen의 탭이므로 자체 AppBar가 없습니다.
      body: Column(
        children: [
          // TODO: 검색바가 필요하다면 여기에 InlineSearchChip 추가
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 2개
                childAspectRatio: 1.5, // 가로:세로 비율
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  context,
                  icon: category['icon'] as IconData,
                  label: (category['labelKey'] as String).tr(),
                  onTap: () {
                    // 다음 화면 (RoomListScreen)으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RoomListScreen(
                          userModel: userModel,
                          locationFilter: locationFilter,
                          roomType: category['type'] as String, // 선택된 카테고리 전달
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // [LEGAL DISCLAIMER - 절대 삭제 금지]
          // 각 현지 법률의 미묘한 차이는 번역 문구에서 반영되며, 본 앱은 광고/게시판 플랫폼임을 고지합니다.
          // 아래 문구는 카테고리 그리드 하단에 항상 노출되어야 합니다.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'realEstate.disclaimer'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600], height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 런처 카드 UI
  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

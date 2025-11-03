// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 31, 33) '직방' 모델 도입.
// 2. 이 화면을 '매물 리스트'에서 '카테고리 런처(Launcher)' 화면으로 전면 개편.
// 3. 기존 리스트/필터 로직은 'room_list_screen.dart' 파일로 이전됨.
// =====================================================

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
        'type': 'kontrakan',
        'icon': Icons.house_outlined,
        'labelKey': 'realEstate.form.roomTypes.kontrakan'
      },
      {
        'type': 'ruko',
        'icon': Icons.storefront_outlined,
        'labelKey': 'realEstate.form.roomTypes.ruko'
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
                  icon: category['icon'],
                  label: (category['labelKey'] as String).tr(),
                  onTap: () {
                    // 다음 화면 (RoomListScreen)으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RoomListScreen(
                          userModel: userModel,
                          locationFilter: locationFilter,
                          roomType: category['type'], // 선택된 카테고리 전달
                        ),
                      ),
                    );
                  },
                );
              },
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

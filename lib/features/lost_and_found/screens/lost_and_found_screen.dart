// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore lost_and_found 컬렉션 구조와 1:1 매칭, 이미지, 위치, 현상금 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/현상금 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 현상금, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// - 분실자/습득자 모두를 위한 UX 개선(채팅/알림/현상금 등).
// =====================================================
// lib/features/lost_and_found/screens/lost_and_found_screen.dart

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class LostAndFoundScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;

  const LostAndFoundScreen(
      {this.userModel,
      this.locationFilter, // [추가]
      super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

// ✅ [작업 39] 1. TabController를 사용하기 위해 TickerProviderStateMixin 추가
class _LostAndFoundScreenState extends State<LostAndFoundScreen>
    with TickerProviderStateMixin {
  // [추가] 화면 내부의 필터 상태를 관리합니다.
  late Map<String, String?>? _locationFilter;

  // ✅ [작업 39] 2. TabController 및 필터 값 정의
  late final TabController _tabController;
  final List<String?> _tabFilters = [
    null, // 'all' (전체)
    'lost', // '분실'
    'found', // '습득'
  ];

  @override
  void initState() {
    super.initState();
    // [추가] HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;

    // ✅ [작업 39] 3. TabController 초기화
    _tabController = TabController(length: _tabFilters.length, vsync: this);
  }

  // ✅ [작업 39] 4. TabController 해제
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // [추가] 필터 화면을 여는 함수

  // [추가] 필터를 제거하는 함수

  @override
  Widget build(BuildContext context) {
    final LostAndFoundRepository repository = LostAndFoundRepository();

    return Scaffold(
      body: Column(
        children: [
          // [추가] 필터 관리 UI
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     if (_locationFilter != null)
          //       IconButton(
          //         icon: const Icon(Icons.clear),
          //         tooltip: 'Clear Filter',
          //         onPressed: _clearFilter,
          //       ),
          //     IconButton(
          //       icon: const Icon(Icons.filter_alt_outlined),
          //       tooltip: 'Filter',
          //       onPressed: _openFilter,
          //     ),
          //   ],
          // ),
          // ✅ [작업 39] 5. '분실'/'습득' 필터링을 위한 TabBar 추가
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: 'lostAndFound.tabs.all'.tr()), // '전체'
              Tab(text: 'lostAndFound.tabs.lost'.tr()), // '분실했어요'
              Tab(text: 'lostAndFound.tabs.found'.tr()), // '주웠어요'
            ],
            // 탭 변경 시 StreamBuilder를 재실행하기 위해 setState 호출
            onTap: (index) => setState(() {}),
          ),
          Expanded(
            child: StreamBuilder<List<LostItemModel>>(
              // ✅ [작업 39] 6. fetchItems에 locationFilter와 itemType 필터를 함께 전달
              stream: repository.fetchItems(
                locationFilter: _locationFilter,
                itemType: _tabFilters[_tabController.index], // 현재 탭의 필터 값
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('lostAndFound.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('lostAndFound.empty'.tr()));
                }

                final items = snapshot.data!;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return LostItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore room_listings 컬렉션 구조와 1:1 매칭, 이미지, 가격, 편의시설 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/가격/편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// - 임대인/임차인 모두를 위한 UX 개선(채팅/알림/편의시설 등).
// =====================================================
// lib/features/real_estate/screens/real_estate_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore room_listings 컬렉션 구조와 1:1 매칭, 이미지, 가격, 편의시설 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/가격/편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// - 임대인/임차인 모두를 위한 UX 개선(채팅/알림/편의시설 등).
// =====================================================

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_room_listing_screen.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class RealEstateScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;

  const RealEstateScreen({
    this.userModel,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  // [추가] 화면 내부의 필터 상태를 관리합니다.
  late Map<String, String?>? _locationFilter;

  @override
  void initState() {
    super.initState();
    // [추가] HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;
  }

  // [추가] 필터 화면을 여는 함수
  void _openFilter() async {
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (result != null) {
      setState(() => _locationFilter = result);
    }
  }

  // [추가] 필터를 제거하는 함수
  void _clearFilter() {
    setState(() => _locationFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    final RoomRepository roomRepository = RoomRepository();

    return Scaffold(
      body: Column(
        children: [
          // [추가] 필터 관리 UI
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_locationFilter != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filter',
                  onPressed: _clearFilter,
                ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filter',
                onPressed: _openFilter,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<RoomListingModel>>(
              // [수정] fetchRooms 함수에 현재 필터 상태를 전달합니다.
              stream: roomRepository.fetchRooms(locationFilter: _locationFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'realEstate.error'.tr(namedArgs: {'error': snapshot.error.toString()}),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('realEstate.empty'.tr()));
                }

                final rooms = snapshot.data!;

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return RoomCard(room: room);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userModel != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CreateRoomListingScreen(userModel: widget.userModel!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'realEstate.create'.tr(),
        child: const Icon(Icons.add_home_outlined),
      ),
    );
  }
}
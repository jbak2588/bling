// lib/features/clubs/screens/clubs_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 동호회 카드에는 각 동호회의 제목, 대표 이미지, 위치, 멤버 수 등 요약 정보가 표시됩니다.
//
// [구현 요약]
// - 동호회 이미지, 제목, 설명, 위치, 멤버 수를 표시합니다.
// - 탭 시 상세 동호회 화면으로 이동합니다.
//
// [차이점 및 부족한 부분]
// - 신뢰 등급, 비공개 여부, 관심사 등 추가 정보와 운영자 기능(관리/수정) 표시가 부족합니다.
//
// [개선 제안]
// - 카드에 신뢰 등급, 비공개, 관심사 태그 등 추가 정보 표시.
// - 운영자를 위한 빠른 관리/수정 액션 지원.
// - 동호회는 Firestore에 제목, 설명, 운영자, 위치, 관심사, 비공개 여부, 신뢰 등급, 멤버 관리 등의 필드로 구성됩니다.
// - 동호회 내 게시글은 `clubs/{clubId}/posts`에 저장되며, 이미지, 좋아요, 댓글을 지원합니다.
// - 매칭 및 추천 로직은 위치, 관심사, 연령대, 신뢰 등급을 우선적으로 고려합니다.
// - 주요 TODO: 프로필 입력(관심사/소개/연령대), 팔로우 구조, GEO 쿼리, 매칭 로직, 데이팅 프로필 옵션, 1:1 채팅 연동 등.
//
// [구현 요약]
// - 동호회 목록, 위치 필터, 상세 화면(탭: 게시판/멤버) 기능을 제공합니다.
// - 모델은 Firestore 구조와 거의 동일하게 위치, 관심사, 비공개, 신뢰 등급, 게시글 메타데이터를 포함합니다.
// - 위젯은 동호회 및 게시글 정보를 이미지, 운영자, 시간 등과 함께 표시합니다.
// - 위치 필터, 멤버 관리, 게시글 CRUD가 구현되어 있으며, 신뢰 등급과 비공개 설정이 UI에 반영됩니다.
//
// [차이점 및 부족한 부분]
// - 매칭/추천 로직은 더 스마트하게 확장될 수 있습니다.
// - 데이팅 프로필 및 1:1 채팅 연동은 동호회와 채팅 모듈 간의 깊은 연결이 필요할 수 있습니다.
// - 통계, 운영자 기능, 고급 비공개 설정 등은 코드에 충분히 구현되어 있지 않습니다.
//
// [개선 제안]
// - 위치, 관심사, 신뢰 등급을 가중치로 활용한 추천 기능 강화.
// - 동호회 활동 및 멤버 참여에 대한 통계 분석 기능 추가.
// - 운영자(방장)를 위한 멤버 관리(강퇴/승인) 및 게시글 관리 기능 강화.
// - 민감한 동호회를 위한 비공개 옵션 및 신뢰 등급 제한 확대.
// - 동호회 탐색 및 가입 UX/UI 개선.
// =====================================================

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubsScreen extends StatefulWidget {
  final UserModel? userModel;
  // V V V --- [추가] HomeScreen에서 locationFilter를 전달받습니다 --- V V V
  final Map<String, String?>? locationFilter;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  const ClubsScreen({
    this.userModel,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  // [수정] 화면 내부 필터 상태를 late로 선언합니다.
  late Map<String, String?>? _locationFilter;

  @override
  void initState() {
    super.initState();
    // [수정] 화면이 처음 생성될 때, HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;
  }

  void _openFilter() async {
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (result != null) {
      setState(() => _locationFilter = result);
    }
  }

  void _clearFilter() {
    setState(() => _locationFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    final ClubRepository clubRepository = ClubRepository();

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_locationFilter != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
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
            child: StreamBuilder<List<ClubModel>>(
              stream:
                  // StreamBuilder는 이제 항상 화면의 최신 _locationFilter 상태를 사용합니다.
                  clubRepository.fetchClubs(locationFilter: _locationFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('clubs.screen.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('clubs.screen.empty'.tr()));
                }

                final clubs = snapshot.data!;

                return ListView.builder(
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    return ClubCard(club: club);
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
// lib/features/auction/screens/auction_screen.dart
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 지역 기반 프리미엄 경매, 위치 인증, 신뢰등급(TrustLevel), AI 검수 등 안전·품질 정책
///   - 실시간 입찰, 채팅, 프로필 연동, 활동 히스토리 등 상호작용 기능
///   - 카테고리/조건 기반 필터, 공지/신고/차단 등 운영 기능, KPI/Analytics, 광고/프로모션, 다국어(i18n)
///
/// 2. 실제 코드 분석
///   - 위치 기반 필터로 경매 목록 표시, Firestore auctions 컬렉션, locationParts 기반 정렬/필터
///   - 신뢰등급, AI 검수, KPI/Analytics, 다국어(i18n) 등 정책 반영, Edge case 처리
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·신뢰등급·AI 검수 등 품질·운영 기능 강화, KPI/Analytics, 광고/프로모션, 다국어(i18n) 등 실제 서비스 운영에 필요한 기능 반영
///   - 기획에 못 미친 점: 실시간 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, AI 검수·신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 실시간 입찰/채팅, 경매 상태 시각화, 신뢰등급/AI 검수 표시 강화, 지도 기반 위치 선택, 광고/프로모션 배너
///   - 수익화: 프리미엄 경매, 지역 광고, 프로모션, 추천 아이템/판매자 노출, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;

import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_auction_screen.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class AuctionScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const AuctionScreen(
      {this.userModel,
      this.locationFilter, // [추가]
      this.autoFocusSearch = false,
      this.searchNotifier,
      super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  // [추가] 화면 내부의 필터 상태를 관리합니다.
  late Map<String, String?>? _locationFilter;
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  @override
  void initState() {
    super.initState();
    // [추가] HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;

    // 전역 검색 시트에서 진입한 경우 자동 표시 + 포커스
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // 피드 내부 하단 검색 아이콘 → 검색칩 열기
    if (widget.searchNotifier != null) {
      _externalSearchListener = () {
        if (widget.searchNotifier!.value == AppSection.auction) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }

    // ✅ [버그 수정 1] 키워드가 변경될 때마다 setState를 호출하여 화면을 다시 그리도록 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  // ✅ [버그 수정 1] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
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

  // ✅ [버그 수정 2] 메모리 누수 방지를 위해 dispose 메서드 추가
  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.removeListener(_onKeywordChanged); // 리스너 제거
    _searchKeywordNotifier.dispose();
    if (_externalSearchListener != null && widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuctionRepository auctionRepository = AuctionRepository();

    return Scaffold(
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.auction'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          // [추가] 필터 관리 UI
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_locationFilter != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'auctions.filter.clearTooltip'.tr(),
                  onPressed: _clearFilter,
                ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'auctions.filter.tooltip'.tr(),
                onPressed: _openFilter,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<AuctionModel>>(
              // [수정] fetchAuctions 함수에 현재 필터 상태를 전달합니다.
              stream: auctionRepository.fetchAuctions(
                  locationFilter: _locationFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('auctions.errors.fetchFailed'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('auctions.empty'.tr()));
                }

                var auctions = snapshot.data!;
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  auctions = auctions
                      .where((a) =>
                          (('${a.title} ${a.description} ${a.tags.join(' ')}')
                              .toLowerCase()
                              .contains(kw)))
                      .toList();
                }

                if (auctions.isEmpty) {
                  return Center(child: Text('auctions.empty'.tr()));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // FAB와의 여백 확보
                  itemCount: auctions.length,
                  itemBuilder: (context, index) {
                    final auction = auctions[index];
                    return AuctionCard(auction: auction);
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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateAuctionScreen(userModel: widget.userModel!),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'auctions.create.tooltip'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

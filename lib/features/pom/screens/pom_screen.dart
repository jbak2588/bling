// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shorts 컬렉션 구조와 1:1 매칭, AI 인증, 신뢰 등급, 태그, 좋아요/댓글/조회수 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, AI 인증, 신뢰 등급, 좋아요/댓글/조회수 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트, AI 인증 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 크리에이터/시청자 모두를 위한 UX 개선(댓글/알림/추천 등).
// =====================================================
// - '뽐' (Pom) 메인 화면. 4개의 탭과 검색 기능 제공.
// [V2 - 2025-11-03]
// - 'shorts' 스크린에서 리팩토링.
// - 'DefaultTabController' (우리동네, 전체, 인기, 내 뽐) 기반 UI.
// [V3 - 2025-11-04]
// - 'InlineSearchChip' (검색칩) UI 통합.
// - FAB (CreatePomScreen)에서 'pop(true)' 반환 값을 감지.
// - '_refreshToken'을 'PomFeedList'로 전달하여 업로드 후 피드 자동 갱신 구현.
// =====================================================

// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/features/pom/screens/create_pom_screen.dart'; // [V2]
import 'package:bling_app/features/pom/screens/pom_pager_screen.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import '../widgets/pom_feed_list.dart';

class PomScreen extends StatefulWidget {
  final UserModel? userModel;
  final List<PomModel>? initialPoms;
  final int initialIndex;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const PomScreen({
    this.userModel,
    this.initialPoms,
    this.initialIndex = 0,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  State<PomScreen> createState() => _PomScreenState();
}

class _PomScreenState extends State<PomScreen> {
  // [V2] TabBarView로 변경 - 내부 데이터 로드는 PomFeedList가 담당
  // 검색 칩/키워드 상태 (하단 검색 아이콘으로 토글됨)
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  int _refreshToken = 0; // bump to trigger feed reloads

  @override
  void initState() {
    super.initState();
    // [V2] PageController 및 즉시 데이터 로드는 사용하지 않음 (PomFeedList가 처리)

    // 전역 검색 시트에서 진입한 경우 자동 표시 + 포커스
    if (widget.autoFocusSearch) {
      // (V2) 검색바 자동 노출은 현재 미사용
    }

    // widget.searchNotifier will be passed directly to the InlineSearchChip below.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }

    // 초기 진입이 썸네일에서의 상세 요청인 경우: 선택한 인덱스로 상세 뷰어를 즉시 오픈
    if (widget.initialPoms != null && widget.initialPoms!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final int startIndex =
            widget.initialIndex.clamp(0, widget.initialPoms!.length - 1);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PomPagerScreen(
              poms: widget.initialPoms!,
              startIndex: startIndex,
              userModel: widget.userModel,
            ),
          ),
        );
      });
    }
  }

  // ✅ [버그 수정] 키워드 변경 시 setState 호출
  // 검색 키워드 변경 리스너는 Tab 구조에서는 사용하지 않음

  @override
  void dispose() {
    // (V2) 페이지 컨트롤러 및 검색 노티파이어 미사용
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    super.dispose();
  }

  void _onSearchSubmitted(String keyword) {
    final kw = keyword.trim().toLowerCase();
    _searchKeywordNotifier.value = kw;
  }

  void _onSearchClosed() {
    if (!mounted) return;
    setState(() => _showSearchBar = false);
    _searchKeywordNotifier.value = '';
  }

  void _externalSearchListener() {
    if (widget.searchNotifier?.value == true) {
      if (!mounted) return;
      setState(() => _showSearchBar = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
      widget.searchNotifier?.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // [V2] 기획서(백서) 기반 탭 구조로 변경
    final List<String> tabs = [
      'pom.tabs.local'.tr(),
      'pom.tabs.all'.tr(),
      'pom.tabs.popular'.tr(), // [V2]
      'pom.tabs.myPoms'.tr(), // [V2]
    ];

    // 상세 진입 시에는 탭 인덱스는 강제로 0(첫 탭)으로 시작, 그 외에는 전달값을 안전하게 사용
    final int safeTabIndex =
        (widget.initialPoms == null || widget.initialPoms!.isEmpty)
            ? widget.initialIndex.clamp(0, tabs.length - 1)
            : 0;

    return DefaultTabController(
      length: tabs.length,
      initialIndex: safeTabIndex,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            if (_showSearchBar)
              InlineSearchChip(
                hintText: 'pom.search.hint'.tr(),
                openNotifier: widget.searchNotifier,
                onSubmitted: _onSearchSubmitted,
                onClose: _onSearchClosed,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TabBar(
                tabs: tabs.map((name) => Tab(text: name)).toList(),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFF00A66C),
                unselectedLabelColor: const Color(0xFF616161),
                indicatorColor: const Color(0xFF00A66C),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PomFeedList(
                    feedType: PomFeedType.local,
                    userModel: widget.userModel,
                    locationFilter: widget.locationFilter,
                    searchKeywordListenable: _searchKeywordNotifier,
                    refreshToken: _refreshToken,
                  ),
                  PomFeedList(
                    feedType: PomFeedType.all,
                    userModel: widget.userModel,
                    searchKeywordListenable: _searchKeywordNotifier,
                    refreshToken: _refreshToken,
                  ),
                  PomFeedList(
                    feedType: PomFeedType.popular,
                    userModel: widget.userModel,
                    locationFilter: widget.locationFilter,
                    searchKeywordListenable: _searchKeywordNotifier,
                    refreshToken: _refreshToken,
                  ),
                  PomFeedList(
                    feedType: PomFeedType.myPoms,
                    userModel: widget.userModel,
                    searchKeywordListenable: _searchKeywordNotifier,
                    refreshToken: _refreshToken,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => CreatePomScreen(userModel: widget.userModel!),
              ),
            );
            if (created == true && mounted) {
              setState(() => _refreshToken++);
            }
          },
          child: const Icon(Icons.add_a_photo_outlined),
        ),
      ),
    );
  }
}

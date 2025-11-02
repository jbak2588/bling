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
// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart';
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

class PomScreen extends StatefulWidget {
  final UserModel? userModel;
  final List<ShortModel>? initialShorts;
  final int initialIndex;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const PomScreen({
    this.userModel,
    this.initialShorts,
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
  final ShortRepository _shortRepository = ShortRepository();
  late Future<List<ShortModel>>? _shortsFuture;
  late final PageController _pageController;
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    if (widget.initialShorts == null) {
      // [수정] fetchShortsOnce 함수에 locationFilter를 전달합니다.
      _shortsFuture = _shortRepository.fetchShortsOnce(
          locationFilter: widget.locationFilter);
    } else {
      _shortsFuture = null;
    }

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
        if (widget.searchNotifier!.value == AppSection.pom) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }

    // ✅ [버그 수정] 키워드가 변경될 때마다 setState를 호출하여 화면을 다시 그리도록 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  // ✅ [버그 수정] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipOpenNotifier.dispose();
    _searchKeywordNotifier
        .removeListener(_onKeywordChanged); // ✅ [버그 수정] 리스너 제거
    _searchKeywordNotifier.dispose();
    if (_externalSearchListener != null && widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.pom'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          Expanded(
            child: widget.initialShorts != null
                ? _buildPageView(_applyKeywordFilter(widget.initialShorts!))
                : FutureBuilder<List<ShortModel>>(
                    future: _shortsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'pom.errors.fetchFailed'.tr(namedArgs: {
                                  'error': snapshot.error.toString()
                                }),
                                style: const TextStyle(color: Colors.white)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('pom.empty'.tr(),
                                style: const TextStyle(color: Colors.white)));
                      }

                      final shorts = _applyKeywordFilter(snapshot.data!);
                      if (shorts.isEmpty) {
                        return Center(
                            child: Text('pom.empty'.tr(),
                                style: const TextStyle(color: Colors.white)));
                      }

                      return _buildPageView(shorts);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(List<ShortModel> shorts) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: shorts.length,
      itemBuilder: (context, index) {
        return ShortPlayer(short: shorts[index], userModel: widget.userModel);
      },
    );
  }

  List<ShortModel> _applyKeywordFilter(List<ShortModel> items) {
    final kw = _searchKeywordNotifier.value;
    if (kw.isEmpty) return items;
    return items
        .where((s) =>
            (('${s.title} ${s.description} ${(s.tags ?? const []).join(' ')}')
                .toLowerCase()
                .contains(kw)))
        .toList();
  }
}

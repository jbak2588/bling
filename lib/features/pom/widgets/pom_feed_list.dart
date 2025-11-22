// lib/features/pom/widgets/pom_feed_list.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 'pom_screen.dart'의 각 탭(우리동네, 전체 등)에 표시될 'ListView'.
// [V2 - 2025-11-03]
// - 'PomFeedType'에 따라 'PomRepository'의 각기 다른 함수(fetchPomsOnce, fetchPopularPoms 등)를 호출.
// [V3 - 2025-11-04]
// - 'searchKeywordListenable'을 받아 서버사이드 검색(searchPomsByKeyword) 수행.
// - 검색 중 'LinearProgressIndicator' 헤더 표시.
// - 'refreshToken' 변경을 감지('didUpdateWidget')하여 피드 자동 갱신.
// =====================================================
// lib/features/pom/widgets/pom_feed_list.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/pom_repository.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/features/pom/widgets/pom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';

/// Pom 피드 탭의 유형
enum PomFeedType {
  local, // 우리 동네
  all, // 전체 (최신순)
  popular, // 인기
  myPoms // 내 뽐
}

/// PomFeedType에 따라 데이터를 로드하고 PomCard 리스트를 표시하는 위젯.
class PomFeedList extends StatefulWidget {
  final PomFeedType feedType;
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final ValueListenable<String>? searchKeywordListenable;
  final int refreshToken;

  const PomFeedList({
    super.key,
    required this.feedType,
    this.userModel,
    this.locationFilter,
    this.searchKeywordListenable,
    required this.refreshToken,
  });

  @override
  State<PomFeedList> createState() => _PomFeedListState();
}

class _PomFeedListState extends State<PomFeedList>
    with AutomaticKeepAliveClientMixin {
  final PomRepository _pomRepository = PomRepository();
  late Future<List<PomModel>> _pomsFuture;
  VoidCallback? _kwListener;
  ValueListenable<String>? _currentKeywordListenable;
  List<PomModel>? _searchResults; // 서버측 검색 결과 (있을 때만 사용)
  String _lastKw = '';
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true; // 탭 상태 유지를 위해 true로 설정

  @override
  void initState() {
    super.initState();
    _pomsFuture = _fetchPoms();
    _kwListener = _onKeywordChanged;
    _currentKeywordListenable = widget.searchKeywordListenable;
    _currentKeywordListenable?.addListener(_kwListener!);
  }

  @override
  void didUpdateWidget(covariant PomFeedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchKeywordListenable != widget.searchKeywordListenable) {
      _currentKeywordListenable?.removeListener(_kwListener!);
      _currentKeywordListenable = widget.searchKeywordListenable;
      _currentKeywordListenable?.addListener(_kwListener!);
    }
    // External refresh signal: refetch base list and clear search state
    if (oldWidget.refreshToken != widget.refreshToken) {
      setState(() {
        _pomsFuture = _fetchPoms();
        _searchResults = null;
        _lastKw = '';
      });
    }
  }

  Future<void> _onKeywordChanged() async {
    final kw = _currentKeywordListenable?.value.trim().toLowerCase() ?? '';
    if (kw.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = null; // 검색 초기화 시 기본 리스트 유지
          _lastKw = '';
        });
      }
      return;
    }
    if (kw == _lastKw || _isSearching) return;
    setState(() {
      _isSearching = true; // 진행 표시 즉시 반영
    });
    try {
      final results = await _pomRepository.searchPomsByKeyword(
          keyword: kw, locationFilter: widget.locationFilter);
      if (!mounted) return;
      if (results.isEmpty) {
        // 빈 결과: 팝업 표시, 리스트는 유지
        _searchResults = null;
        _showNoResultsPopup(context, kw);
      } else {
        _searchResults = results;
      }
      setState(() {
        _lastKw = kw;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('pom.errors.fetchFailed'
                .tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showNoResultsPopup(BuildContext context, String kw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('search.resultsTitle'.tr(namedArgs: {'keyword': kw})),
        content: Text('search.empty.message'.tr(namedArgs: {'keyword': kw})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.confirm'.tr()),
          )
        ],
      ),
    );
  }

  Future<List<PomModel>> _fetchPoms() {
    switch (widget.feedType) {
      case PomFeedType.local:
        // '우리 동네' 탭: locationFilter 적용
        return _pomRepository.fetchPomsOnce(
            locationFilter: widget.locationFilter);
      case PomFeedType.all:
        // '전체' 탭: 필터 없이 조회
        return _pomRepository.fetchPomsOnce(locationFilter: null);
      case PomFeedType.popular:
        return _pomRepository.fetchPopularPoms(
            locationFilter: widget.locationFilter);
      case PomFeedType.myPoms:
        return _pomRepository.fetchMyPoms();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    return FutureBuilder<List<PomModel>>(
      future: _pomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('pom.errors.fetchFailed'
                  .tr(namedArgs: {'error': snapshot.error.toString()})));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          final String emptyKey;
          final String? subKey;
          switch (widget.feedType) {
            case PomFeedType.popular:
              emptyKey = 'pom.emptyPopular';
              subKey = 'pom.emptyHintPopular';
              break;
            case PomFeedType.myPoms:
              emptyKey = 'pom.emptyMine';
              subKey = 'pom.emptyCtaMine';
              break;
            case PomFeedType.local:
            case PomFeedType.all:
              emptyKey = 'pom.empty';
              subKey = null;
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.slow_motion_video_outlined,
                      size: 36, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(emptyKey.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  if (subKey != null) ...[
                    const SizedBox(height: 6),
                    Text(subKey.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ]
                ],
              ),
            ),
          );
        }

        final allPoms = snapshot.data!;
        // 서버측 검색 결과가 있으면 우선 사용, 없으면 기본 리스트 표시
        final poms = _searchResults ?? allPoms;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _pomsFuture = _fetchPoms();
              // 새로고침 시 서버측 검색 결과는 유지하지 않고 초기화
              _searchResults = null;
              _lastKw = '';
            });
          },
          child: ListView.builder(
            itemCount: poms.length + (_isSearching ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isSearching && index == 0) {
                return _buildSearchingHeader(context);
              }
              final hasHeader = _isSearching ? 1 : 0;
              final realIndex = index - hasHeader;
              // 헤더만 있는 경우를 대비한 안전장치
              if (realIndex < 0 || realIndex >= poms.length) {
                return const SizedBox.shrink();
              }
              return PomCard(
                pom: poms[realIndex],
                currentUserModel: widget.userModel,
                allPoms: poms,
                currentIndex: realIndex,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchingHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(minHeight: 3),
      ),
    );
  }

  @override
  void dispose() {
    if (_kwListener != null) {
      _currentKeywordListenable?.removeListener(_kwListener!);
    }
    super.dispose();
  }
}

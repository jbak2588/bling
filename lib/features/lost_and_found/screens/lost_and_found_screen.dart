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
// repository import intentionally removed — using direct Firestore query for search
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

class LostAndFoundScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<bool>? searchNotifier;

  const LostAndFoundScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen>
    with TickerProviderStateMixin {
  late Map<String, String?>? _locationFilter;
  late final TabController _tabController;
  final List<String?> _tabFilters = [null, 'lost', 'found'];

  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _locationFilter = widget.locationFilter;
    _tabController = TabController(length: _tabFilters.length, vsync: this);

    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // If an external search notifier is provided, listen and ensure the search
    // bar is rendered and opened when the notifier toggles.
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.addListener(_externalSearchListener);
    }
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chipOpenNotifier.dispose();
    if (widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener);
    }
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    super.dispose();
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

  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Prepare first-token search token for DB-side filtering
    final kw = _searchKeywordNotifier.value.trim().toLowerCase();
    String? searchToken;
    if (kw.isNotEmpty) {
      final token = kw.split(' ').first;
      if (token.isNotEmpty) searchToken = token;
    }

    return Scaffold(
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.lostAndFound'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) {
                _searchKeywordNotifier.value = kw.trim().toLowerCase();
              },
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: 'lostAndFound.tabs.all'.tr()),
              Tab(text: 'lostAndFound.tabs.lost'.tr()),
              Tab(text: 'lostAndFound.tabs.found'.tr()),
            ],
            onTap: (index) => setState(() {}),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: (() {
                Query<Map<String, dynamic>> query =
                    FirebaseFirestore.instance.collection('lost_and_found');

                // Apply location filter if provided (use most specific key)
                final filter = _locationFilter;
                if (filter != null) {
                  String? key;
                  if (filter['kel'] != null) {
                    key = 'kel';
                  } else if (filter['kec'] != null) {
                    key = 'kec';
                  } else if (filter['kab'] != null) {
                    key = 'kab';
                  } else if (filter['kota'] != null) {
                    key = 'kota';
                  } else if (filter['prov'] != null) {
                    key = 'prov';
                  }
                  if (key != null) {
                    final v = filter[key]!.toLowerCase();
                    query = query.where('locationParts.$key', isEqualTo: v);
                  }
                }

                // Apply item type filter (lost/found)
                final itemType = _tabFilters[_tabController.index];
                if (itemType != null) {
                  query = query.where('type', isEqualTo: itemType);
                }

                // DB-side search token filtering
                if (searchToken != null && searchToken.isNotEmpty) {
                  query =
                      query.where('searchIndex', arrayContains: searchToken);
                }

                query = query.orderBy('createdAt', descending: true);
                return query.snapshots();
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('lostAndFound.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }

                final docs = snapshot.data?.docs ?? [];
                final data = docs.map(LostItemModel.fromFirestore).toList();
                if (data.isEmpty) {
                  final isNational = context.watch<LocationProvider>().mode ==
                      LocationSearchMode.national;
                  if (!isNational) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('lostAndFound.empty'.tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('search.empty.checkSpelling'.tr(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey)),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.map_outlined),
                              label: Text('search.empty.expandToNational'.tr()),
                              onPressed: () => context
                                  .read<LocationProvider>()
                                  .setMode(LocationSearchMode.national),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('lostAndFound.empty'.tr(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }

                // Client-side filtering removed; DB query uses `searchIndex`.

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
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

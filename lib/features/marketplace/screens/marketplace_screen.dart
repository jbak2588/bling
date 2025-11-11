/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/marketplace_screen.dart
/// Purpose       : 위치 기반 필터로 상품 목록을 표시합니다.
/// User Impact   : 구매자가 주변 상품을 둘러보고 상세 페이지를 열 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/location/screens/location_filter_screen.dart
/// Data Model    : Firestore `products`를 `locationParts.prov`로 쿼리하고 `createdAt`으로 정렬합니다.
/// Location Scope: `locationFilter`를 통해 Prov→Kab/Kota→Kec→Kel 값을 지원합니다.
/// Trust Policy  : `isAiVerified` 상품만 강조하며 미검증 상품은 검토 대상입니다.
/// Monetization  : 프로모션 상품과 배너 광고를 지원하며 추후 판매 수수료가 예정되어 있습니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_marketplace`, `apply_location_filter`, `click_product`.
/// Analytics     : 쿼리 결과와 스크롤 깊이를 모니터링합니다.
/// I18N          : 키 `marketplace.error`, `marketplace.empty`, `time.*` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, easy_localization, firebase_auth
/// Security/Auth : 조회는 공개이며 등록은 인증과 신뢰 점수가 필요합니다.
/// Edge Cases    : 사용자 위치가 없으면 설정 프롬프트를 표시합니다.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// ============================================================================
library;

/// 아래부터 실제 코드
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/widgets/inline_search_chip.dart';

import '../models/product_model.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  final bool autoFocusSearch;
  final ValueNotifier<AppSection?>? searchNotifier;

  const MarketplaceScreen({
    this.userModel,
    this.locationFilter,
    this.autoFocusSearch = false,
    this.searchNotifier,
    super.key,
  });

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  // 검색칩 상태
  final ValueNotifier<bool> _chipOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchKeywordNotifier =
      ValueNotifier<String>('');
  bool _showSearchBar = false;
  VoidCallback? _externalSearchListener;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = widget.locationFilter;
    if (filter == null) return allDocs;

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
    if (key == null) return allDocs;

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .toList();
  }

  /// [Fix #2] 'sold' 상태 10일 경과 아이템 숨김 처리를 위한 클라이언트 필터
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyStatusRules(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    // 10일 전 cutoff 타임스탬프
    final cutoffDate = now.subtract(const Duration(days: 10));

    return docs.where((doc) {
      final data = doc.data();
      final status = data['status'] as String?;
      final updatedAt = data['updatedAt'] as Timestamp?;

      if (status == 'sold') {
        if (updatedAt == null) return false; // updatedAt 없으면 숨김
        return updatedAt.toDate().isAfter(cutoffDate); // 10일 이내면 true
      }
      // 'selling' 또는 'reserved'는 항상 true
      return true;
    }).toList();
  }

  // ✅ [수정] initState 추가
  @override
  void initState() {
    super.initState();

    // ✅ [이동] autoFocusSearch 로직을 build -> initState로 이동
    if (widget.autoFocusSearch) {
      _showSearchBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chipOpenNotifier.value = true;
      });
    }

    // ✅ [이동] externalSearchListener 등록 로직을 build -> initState로 이동
    if (widget.searchNotifier != null) {
      _externalSearchListener = () {
        if (widget.searchNotifier!.value == AppSection.marketplace) {
          if (mounted) {
            setState(() => _showSearchBar = true);
            _chipOpenNotifier.value = true;
          }
        }
      };
      widget.searchNotifier!.addListener(_externalSearchListener!);
    }

    // ✅ [버그 수정] 키워드 변경 시 setState 호출 리스너 추가
    _searchKeywordNotifier.addListener(_onKeywordChanged);
  }

  // ✅ [버그 수정] 키워드 변경 시 setState 호출
  void _onKeywordChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ✅ [삭제] build 메서드 내부에 있던 리스너 등록 로직 삭제

    Query<Map<String, dynamic>> buildQuery() {
      final userProv = widget.userModel?.locationParts?['prov'];

      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      if (userProv != null && userProv.isNotEmpty) {
        query = query.where('locationParts.prov', isEqualTo: userProv);
      }

      query = query
          // [Fix #2] 'selling', 'reserved', 'sold' 상태 모두 조회
          .where('status', whereIn: ['selling', 'reserved', 'sold']);

      // 정렬 기준: AI 검증 우선, 그 다음 등록 시간(createdAt) 최신순
      query = query
          .orderBy('isAiVerified', descending: true)
          .orderBy('createdAt', descending: true);

      // (참고: Firestore에서 'locationParts.prov' 필터와 'isAiVerified' 정렬을
      // 함께 사용하려면 복합 인덱스가 필요할 수 있습니다.)

      return query;
    }

    return Scaffold(
      body: Column(
        children: [
          if (_showSearchBar)
            InlineSearchChip(
              hintText: 'main.search.hint.marketplace'.tr(),
              openNotifier: _chipOpenNotifier,
              onSubmitted: (kw) =>
                  _searchKeywordNotifier.value = kw.trim().toLowerCase(),
              onClose: () {
                setState(() => _showSearchBar = false);
                _searchKeywordNotifier.value = '';
              },
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('marketplace.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('marketplace.empty'.tr(),
                          textAlign: TextAlign.center));
                }

                final allDocs = snapshot.data!.docs;
                // [Fix #2] 1. 위치 필터
                var filteredDocs = _applyLocationFilter(allDocs);

                // [Fix #2] 2. 'sold' + 10일 경과 상품 숨김 필터
                filteredDocs = _applyStatusRules(filteredDocs);

                // 키워드 필터 (제목/설명/태그)
                final kw = _searchKeywordNotifier.value;
                if (kw.isNotEmpty) {
                  filteredDocs = filteredDocs.where((d) {
                    final p = ProductModel.fromFirestore(d);
                    final hay =
                        ('${p.title} ${p.description} ${p.tags.join(' ')}')
                            .toLowerCase();
                    return hay.contains(kw);
                  }).toList();
                }

                return ListView.separated(
                  itemCount: filteredDocs.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final product =
                        ProductModel.fromFirestore(filteredDocs[index]);

                    // 이제 ProductCard가 AI 뱃지 표시를 스스로 책임지므로,
                    // 여기서는 ProductCard만 호출하면 됩니다.
                    return ProductCard(
                      key: ValueKey(product.id),
                      product: product,
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

  @override
  void dispose() {
    _chipOpenNotifier.dispose();
    if (_externalSearchListener != null && widget.searchNotifier != null) {
      widget.searchNotifier!.removeListener(_externalSearchListener!);
    }
    // ✅ [버그 수정] 리스너 제거를 먼저 수행한 다음 notifier를 폐기합니다.
    _searchKeywordNotifier.removeListener(_onKeywordChanged);
    _searchKeywordNotifier.dispose();
    super.dispose();
  }
}

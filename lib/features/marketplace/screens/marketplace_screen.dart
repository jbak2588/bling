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
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - CRUD(등록/수정/조회/삭제) 기본 뼈대, 채팅/댓글/찜/좋아요/신고/알림 등 상호작용 기능
///   - TrustLevel/인증, 프로필/Privacy, Opt-in/Opt-out, 다국어(i18n), AI 검수, 통계/카운트, 활동 히스토리 등 품질·운영 기능
///
/// 2. 실제 코드 분석
///   - 위치 기반 필터로 상품 목록 표시, Firestore products 컬렉션, locationParts 기반 정렬/필터
///   - AI 검수(isAiVerified), 신뢰등급, 광고/프로모션, KPI/Analytics, 다국어(i18n) 등 정책 반영
///   - Edge case(위치 미설정, 인증/신뢰 등) 처리
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 위치·신뢰등급·AI 검수 등 품질·운영 기능 강화, KPI/Analytics, 광고/프로모션, 다국어(i18n) 등 실제 서비스 운영에 필요한 기능 반영
///   - 기획에 못 미친 점: 채팅, 댓글, 찜, Opt-in/Opt-out 등 일부 상호작용 기능 미구현, AI 검수·활동 히스토리·광고 슬롯 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 위치 기반 추천, 카테고리별 필터/정렬, 광고/프로모션 배너, 신뢰등급 시각화 강화
///   - 수익화: 지역 광고, 프로모션, 추천 상품/판매자 노출, 프리미엄 기능 연계, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;

/// 아래부터 실제 코드
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const MarketplaceScreen({super.key, this.userModel, this.locationFilter});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
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

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> buildQuery() {
      final userProv = widget.userModel?.locationParts?['prov'];

      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('products');

      if (userProv != null && userProv.isNotEmpty) {
        query = query.where('locationParts.prov', isEqualTo: userProv);
      }

      query = query
          // [수정] 'selling' 상태인 상품만 노출하도록 쿼리를 단순화합니다.
          .where('status', isEqualTo: 'selling');

      // AI 검증 상품을 최상단에, 그 후 최신순으로 정렬
      query = query.orderBy('isAiVerified', descending: true);
      query = query.orderBy('createdAt', descending: true);

      return query;
    }

    if (widget.userModel?.locationParts?['prov'] == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'marketplace.setLocationPrompt'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: buildQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('marketplace.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('marketplace.empty'.tr(),
                    textAlign: TextAlign.center));
          }

          final allDocs = snapshot.data!.docs;
          final productsDocs = _applyLocationFilter(allDocs);

          return ListView.separated(
            itemCount: productsDocs.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final product = ProductModel.fromFirestore(productsDocs[index]);

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
    );
  }
}

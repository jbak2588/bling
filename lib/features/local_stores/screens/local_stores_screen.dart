// ===================== DocHeader =====================
// [기획 요약]
// - 지역 상점 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shops 컬렉션 구조와 1:1 매칭, 신뢰 등급, 대표 이미지, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/연락처/영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 상점주/이용자 모두를 위한 UX 개선(리뷰/채팅/알림 등).
// =====================================================
// lib/features/local_stores/screens/local_stores_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 지역 상점 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shops 컬렉션 구조와 1:1 매칭, 신뢰 등급, 대표 이미지, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, 이미지/연락처/영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 상점주/이용자 모두를 위한 UX 개선(리뷰/채팅/알림 등).
// =====================================================

import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/widgets/shop_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_shop_screen.dart'; // [추가]

class LocalStoresScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const LocalStoresScreen({this.userModel, this.locationFilter, super.key});

  List<ShopModel> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = locationFilter;
    if (filter == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

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
    if (key == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .map((doc) => ShopModel.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ShopRepository shopRepository = ShopRepository();
    final userProvince = userModel?.locationParts?['prov'];

  if (userProvince == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('localStores.setLocationPrompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            shopRepository.fetchShops(locationFilter: locationFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('localStores.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }

          final allDocs = snapshot.data?.docs ?? [];
          final shops = _applyLocationFilter(allDocs);

          if (shops.isEmpty) {
            return Center(child: Text('localStores.empty'.tr()));
          }

          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              return ShopCard(shop: shops[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // V V V --- [수정] 상점 등록 화면으로 이동하는 로직 --- V V V
          if (userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateShopScreen(userModel: userModel!),
            ));
          } else {
            // 로그인하지 않은 사용자에 대한 처리
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
         
        },
        tooltip: 'localStores.create.tooltip'.tr(),
        child: const Icon(Icons.add_business_outlined),
      ),
    );
  }
}

// lib/features/my_bling/widgets/user_product_list.dart
/// DocHeader
/// [기획 요약]
/// - 내 판매상품 탭은 사용자가 등록한 상품 목록, 통계, 활동 내역을 제공합니다.
/// - KPI, 활동 통계, 추천/분석 기능 등 사용자 경험 강화가 목표입니다.
///
/// [실제 구현 비교]
/// - 상품 목록, 최신순 정렬, Firestore 연동, 실시간 통계, UI/UX 개선 적용됨.
///
/// [차이점 및 개선 제안]
/// 1. KPI/Analytics 기반 활동 통계, 추천/분석 기능, 프리미엄 기능(뱃지, 광고 등) 도입 검토.
/// 2. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화 등 코드 안정성/성능 개선.
/// 3. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 상품 기능 연계 강화 필요.
/// 4. 활동 내역, KPI 기반 추천/분석 기능 추가 권장.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// easy_localization compatibility removed; using Slang `t[...]`

import '../../marketplace/models/product_model.dart';
import '../../../core/models/user_model.dart';
import '../../marketplace/widgets/product_card.dart'; // 기존 ProductCard 재사용

/// MyBling 화면의 '내 판매상품' 탭에 표시될 위젯입니다.
class UserProductList extends StatelessWidget {
  const UserProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) {
      return Center(child: Text(t.main.errors.loginRequired));
    }

    // 1. 현재 사용자의 문서를 실시간으로 관찰합니다.
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Center(child: Text(t.main.errors.userNotFound));
        }

        final user = UserModel.fromFirestore(userSnapshot.data!);
        final userId = user.uid;

        // 2. Stream으로 사용자의 상품들을 직접 쿼리합니다.
        // [V3 PENDING FIX] 'pending' 상태의 상품은 '내 상품' 목록에 표시하지 않습니다.
        final productsStream = FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['selling', 'reserved', 'sold'])
            .orderBy('createdAt', descending: true)
            .snapshots();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: productsStream,
          builder: (context, productsSnapshot) {
            if (productsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (productsSnapshot.hasError) {
              return Center(
                  child: Text(t.marketplace.error.replaceAll(
                      '{error}', productsSnapshot.error.toString())));
            }
            if (!productsSnapshot.hasData ||
                productsSnapshot.data!.docs.isEmpty) {
              return Center(child: Text(t.marketplace.empty));
            }

            final products = productsSnapshot.data!.docs
                .map((doc) => ProductModel.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            );
          },
        );
      },
    );
  }
}

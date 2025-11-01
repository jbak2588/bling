// lib/features/main_feed/screens/main_feed_screen.dart
//**
// * DocHeader
// * [기획 요약]
// * - 메인 피드는 각 피드(게시글, 상품, 구인, 경매 등)를 통합하여 한 화면에 보여줍니다.
// * - 한 번에 5개씩 각 피드 유형을 가져오며, 생성시간(createdAt) 기준으로 혼합 정렬합니다.
// * - 향후 인기순, 추천순, 광고 삽입 등 다양한 정렬/추천 로직이 추가될 예정입니다.
// *
// * [실제 구현 비교]
// * - 현재는 fetchUnifiedFeed()에서 각 피드별 5개씩 가져와 createdAt 기준으로 통합 정렬합니다.
// * - 인기순, 추천순, 광고 삽입 등은 아직 구현되지 않았습니다.
// *
// * [차이점 및 개선 제안]
// * 1. 한 피드당 5개씩 가져오는 방식은 신속한 로딩에는 유리하나, 다양한 피드가 혼합될 때 최신성/다양성/사용자 선호 반영에 한계가 있습니다.
// * 2. 생성시간(createdAt) 기준 혼합 정렬은 기본적이나, 인기순(조회수, 좋아요 등), 추천순(사용자 행동 기반), 광고 삽입(노출 빈도/타겟팅) 등 추가 로직이 필요합니다.
// * 3. 추후 페이징/무한스크롤, 피드 유형별 동적 배치, 광고/추천 피드 삽입, 사용자 맞춤형 피드 추천 알고리즘 도입을 적극 검토해야 합니다.
// * 4. 광고 삽입 시 FeedItemModel에 광고 타입 추가 및 노출 위치/빈도 제어 로직 설계 필요.
// * 5. 인기/추천/광고 로직은 KPI(조회수, 클릭률, 사용자 반응 등) 기반으로 설계/튜닝 권장.
// */

import 'package:bling_app/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import

import '../../../core/models/feed_item_model.dart';
import '../../local_news/models/post_model.dart';
import '../../marketplace/models/product_model.dart';
import '../data/feed_repository.dart';
import '../../local_news/widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart';

/// 'New Feed' 탭에 표시될 통합 피드 화면입니다.
class MainFeedScreen extends StatefulWidget {
  final UserModel? userModel;
  const MainFeedScreen({this.userModel, super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final FeedRepository _feedRepository = FeedRepository();
  late Future<List<FeedItemModel>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _feedRepository.fetchUnifiedFeed();
  }

  // 새로고침 기능
  Future<void> _handleRefresh() async {
    setState(() {
      _feedFuture = _feedRepository.fetchUnifiedFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedItemModel>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // ✅ [다국어 수정] 'mainFeed.error' 키를 사용하여 에러 메시지를 표시합니다.
          return Center(
              child: Text('mainFeed.error'
                  .tr(namedArgs: {'error': snapshot.error.toString()})));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // ✅ [다국어 수정] 'mainFeed.empty' 키를 사용하여 안내 메시지를 표시합니다.
          return Center(child: Text('mainFeed.empty'.tr()));
        }

        final feedItems = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              final item = feedItems[index];

              switch (item.type) {
                case FeedItemType.post:
                  final post = PostModel.fromFirestore(item.originalDoc
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return PostCard(post: post);
                case FeedItemType.product:
                  final product = ProductModel.fromFirestore(item.originalDoc
                      as DocumentSnapshot<Map<String, dynamic>>);
                  return ProductCard(product: product);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }
}

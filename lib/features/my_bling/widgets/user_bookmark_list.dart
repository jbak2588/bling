// lib/features/my_bling/widgets/user_bookmark_list.dart
/// DocHeader
/// [기획 요약]
/// - 관심목록(찜) 탭은 사용자가 찜한 '콘텐츠(상품, 게시글, 부동산)'를 필터링하여 제공합니다.
/// - '사람(User)'은 UserFriendList의 '관심 이웃' 탭으로 이동되었습니다.
///
/// [개선 사항 (v2.0)]
/// 1. 필터 칩(Chip) 도입: 전체, 중고, 동네생활, 부동산 카테고리별 필터링 제공.
/// 2. Firestore 쿼리 최적화: 선택된 필터에 해당하는 데이터만 로드.
/// 3. Chunk 로직 적용: 'whereIn' 쿼리의 10개 제한 문제를 해결하여 10개 이상의 북마크도 정상 로드.
/// 4. 확장성: 부동산(Room) 모델 연동 추가.

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// Models
import '../../local_news/models/post_model.dart';
import '../../marketplace/models/product_model.dart';
import '../../../core/models/user_model.dart';
// [추가] 부동산 모델이 있다고 가정 (없을 경우 주석 처리 필요)
import '../../real_estate/models/room_listing_model.dart';

// Widgets
import '../../local_news/widgets/post_card.dart';
import '../../marketplace/widgets/product_card.dart';
// [추가] 부동산 카드 위젯이 있다고 가정
import '../../real_estate/widgets/room_card.dart';

class UserBookmarkList extends StatefulWidget {
  const UserBookmarkList({super.key});

  @override
  State<UserBookmarkList> createState() => _UserBookmarkListState();
}

class _UserBookmarkListState extends State<UserBookmarkList> {
  // 필터 상태 관리
  String _selectedFilter = 'all';

  // 필터 정의
  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'common.all'},
    {'id': 'product', 'label': 'myBling.bookmarks.products'}, // 중고거래
    {'id': 'post', 'label': 'myBling.bookmarks.posts'}, // 동네생활
    {'id': 'room', 'label': 'myBling.bookmarks.rooms'}, // 부동산
  ];

  /// Firestore 'whereIn' 쿼리는 한 번에 최대 10개의 ID만 조회 가능합니다.
  /// 10개가 넘을 경우 리스트를 쪼개서(chunk) 여러 번 쿼리 후 합쳐야 합니다.
  Future<List<DocumentSnapshot>> _fetchDocsByIds(
      String collection, List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<Future<QuerySnapshot>> futures = [];
    // 10개씩 잘라서 쿼리 생성
    for (var i = 0; i < ids.length; i += 10) {
      final end = (i + 10 < ids.length) ? i + 10 : ids.length;
      final chunk = ids.sublist(i, end);
      futures.add(FirebaseFirestore.instance
          .collection(collection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get());
    }

    final results = await Future.wait(futures);
    // 모든 결과를 하나의 리스트로 병합
    return results.expand((element) => element.docs).toList();
  }

  /// 선택된 필터와 ID 목록을 기반으로 실제 데이터를 비동기 로드
  Future<List<dynamic>> _fetchBookmarkedItems(
    List<String> postIds,
    List<String> productIds,
    List<String> roomIds,
  ) async {
    final List<dynamic> items = [];

    // 1. 중고 상품 (Products)
    if ((_selectedFilter == 'all' || _selectedFilter == 'product') &&
        productIds.isNotEmpty) {
      final docs = await _fetchDocsByIds('products', productIds);
      items.addAll(docs.map((doc) => ProductModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>)));
    }

    // 2. 동네 생활 (Posts)
    if ((_selectedFilter == 'all' || _selectedFilter == 'post') &&
        postIds.isNotEmpty) {
      final docs = await _fetchDocsByIds('posts', postIds);
      items.addAll(docs.map((doc) => PostModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>)));
    }

    // 3. 부동산 (Rooms)
    if ((_selectedFilter == 'all' || _selectedFilter == 'room') &&
        roomIds.isNotEmpty) {
      final docs = await _fetchDocsByIds('room_listings', roomIds);
      items.addAll(docs.map((doc) => RoomListingModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>)));
    }

    // 4. 최신순 정렬 (모든 모델이 createdAt 필드를 가지고 있다고 가정)
    // 모델별로 createdAt 타입이 다를 수 있으므로 dynamic 처리 또는 공통 인터페이스 필요
    // 여기서는 런타임 타입 체크로 안전하게 정렬
    items.sort((a, b) {
      Timestamp? timeA;
      Timestamp? timeB;

      if (a is ProductModel) {
        timeA = a.createdAt;
      } else if (a is PostModel) {
        timeA = a.createdAt;
      } else if (a is RoomListingModel) {
        timeA = a.createdAt;
      }

      if (b is ProductModel) {
        timeB = b.createdAt;
      } else if (b is PostModel) {
        timeB = b.createdAt;
      } else if (b is RoomListingModel) {
        timeB = b.createdAt;
      }

      if (timeA == null || timeB == null) return 0;
      return timeB.compareTo(timeA); // 내림차순 (최신순)
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    if (myUid == null) {
      return Center(child: Text('main.errors.loginRequired'.tr()));
    }

    return Column(
      children: [
        // --- 1. 필터 칩 영역 ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter['label']!.tr()),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => _selectedFilter = filter['id']!);
                    }
                  },
                  // 블링 테마 컬러 적용
                  selectedColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: isSelected
                      ? BorderSide(color: Theme.of(context).primaryColor)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),

        // --- 2. 콘텐츠 리스트 영역 ---
        Expanded(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(myUid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return Center(child: Text('common.error'.tr()));
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = UserModel.fromFirestore(userSnapshot.data!);
              final postIds = user.bookmarkedPostIds ?? [];
              final productIds = user.bookmarkedProductIds ?? [];
              // [추가] 부동산 북마크 ID 필드 (UserModel에 추가 필요)
              final roomIds = user.bookmarkedRoomIds ?? [];

              // 전체가 비었는지 확인 (필터와 무관하게 데이터 자체가 없는 경우)
              if (postIds.isEmpty && productIds.isEmpty && roomIds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('myBling.bookmarks.empty'.tr(),
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return FutureBuilder<List<dynamic>>(
                // 필터 상태나 ID 목록이 바뀔 때마다 다시 fetch
                key: ValueKey(
                    '$_selectedFilter-${postIds.length}-${productIds.length}-${roomIds.length}'),
                future: _fetchBookmarkedItems(postIds, productIds, roomIds),
                builder: (context, itemsSnapshot) {
                  if (itemsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (itemsSnapshot.hasError) {
                    return Center(
                        child: Text('myBling.bookmarks.loadError'.tr()));
                  }

                  final items = itemsSnapshot.data ?? [];

                  if (items.isEmpty) {
                    // 데이터는 있는데 선택한 필터에 해당하는 아이템이 없는 경우
                    return Center(
                      child: Text(
                        'myBling.bookmarks.filterEmpty'
                            .tr(), // "해당 카테고리에 찜한 내역이 없습니다."
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (item is ProductModel) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ProductCard(product: item),
                        );
                      } else if (item is PostModel) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: PostCard(post: item),
                        );
                      } else if (item is RoomListingModel) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: RoomCard(room: item),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

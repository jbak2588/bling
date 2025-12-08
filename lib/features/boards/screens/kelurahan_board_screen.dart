// lib/features/boards/screens/kelurahan_board_screen.dart
/// ============================================================================
/// Bling DocHeader
/// Module        : Boards (동네 게시판)
/// File          : lib/features/boards/screens/kelurahan_board_screen.dart
/// Purpose       : '동네' 탭 클릭 시 표시되는 전용 피드 화면.
///                 사용자의 현재 Kelurahan 게시글만 필터링하여 보여줍니다.
///
/// Related Docs  : '하이브리드 방식 로컬 뉴스 게시글 개선 방안.md' (4. 동네 게시판)
///
/// 2025-10-30 (작업 11, 13):
///   - '하이브리드 기획안' 4)의 '피드 필터링' 로직 구현.
///   - 'locationParts.kel'을 기준으로 'posts' 컬렉션을 쿼리.
///   - (작업 13) AppBar에 채팅 아이콘 추가.
///   -  AppBar에 채팅 아이콘 클릭 시 'chat_service.getOrCreateBoardChatRoom'을 호출하고
///     'ChatRoomScreen'을 'isGroupChat: true'로 푸시하는 로직 구현.
/// ============================================================================
library;
// (파일 내용...)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/widgets/post_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/boards/models/board_model.dart';
import 'package:bling_app/core/constants/app_categories.dart';
import 'package:bling_app/features/local_news/models/post_category_model.dart';

/// '하이브리드 방식...md' 기획안 4)의 '동네 게시판' 전용 피드 화면
/// 사용자의 현재 Kelurahan을 기준으로 게시글을 필터링합니다.
class KelurahanBoardScreen extends StatefulWidget {
  final UserModel userModel;

  const KelurahanBoardScreen({super.key, required this.userModel});

  @override
  State<KelurahanBoardScreen> createState() => _KelurahanBoardScreenState();
}

class _KelurahanBoardScreenState extends State<KelurahanBoardScreen> {
  late final String _kelurahanName;
  late final String _kelKey;

  // [FIX] 작업 19: 하드코딩 필터 제거하고 AppCategories 연동
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _kelurahanName =
        widget.userModel.locationParts?['kel'] ?? 'boards.defaultTitle'.tr();

    final parts = widget.userModel.locationParts;
    if (parts != null) {
      _kelKey =
          '${parts['prov']}|${parts['kab']}|${parts['kec']}|${parts['kel']}';
    } else {
      _kelKey = '';
    }
  }

  /// 필터 상태에 따라 게시글 쿼리를 동적으로 구성합니다.
  Query<Map<String, dynamic>> _buildPostQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    final parts = widget.userModel.locationParts;

    // Kelurahan 필터링 (모든 locationParts가 존재할 때만)
    if (parts != null && _kelKey.isNotEmpty) {
      query = query
          .where('locationParts.prov', isEqualTo: parts['prov'])
          .where('locationParts.kab', isEqualTo: parts['kab'])
          .where('locationParts.kec', isEqualTo: parts['kec'])
          .where('locationParts.kel', isEqualTo: parts['kel']);
    } else {
      return query.where('userId', isEqualTo: 'INVALID_QUERY');
    }

    query = query.where('tags', isNull: false);

    // 3. [FIX] 작업 19: 카테고리 ID로 필터링 (AppCategories와 일치)
    // [FIX] 작업 20: DB 필드명 수정 ('categoryId' -> 'category')
    if (_selectedCategoryId != 'all') {
      query = query.where('category', isEqualTo: _selectedCategoryId);
    }

    return query.orderBy('createdAt', descending: true);
  }

  /// 기획안 4) 그룹 채팅 연동
  void _onChatPressed() async {
    if (_kelKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('boards.errors.noLocation'.tr())),
      );
      return;
    }

    try {
      final chatService = ChatService();
      // 채팅방 생성 또는 가져오기
      final chatRoom = await chatService.getOrCreateBoardChatRoom(
        kelKey: _kelKey,
        roomName: _kelurahanName,
        currentUser: widget.userModel,
      );

      if (!mounted) return;

      // 채팅방으로 이동
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatId: chatRoom.id,
              isGroupChat: true,
              groupName: chatRoom.groupName,
              participants: chatRoom.participants,
            ),
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('common.error'.tr(namedArgs: {'error': e.toString()}))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            // [FIX] 작업 18: 헤더 높이 축소 및 타이틀 중앙 정렬 통합
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: Text(
              '${'boards.boardHeader'.tr()} $_kelurahanName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _kelKey.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection('boards')
                      .doc(_kelKey)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                int activeUsers = 0;
                int monthlyPosts = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final board = BoardModel.fromFirestore(snapshot.data!);
                  activeUsers = board.metrics.last7dActiveUsers;
                  monthlyPosts = board.metrics.last30dPosts;
                }

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  // [FIX] 작업 23: 3줄 -> 2줄 통합 (통계 | 채팅 | 통계)
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _kelKey.isNotEmpty
                        ? FirebaseFirestore.instance
                            .collection('chats')
                            .doc(_kelKey)
                            .snapshots()
                        : null,
                    builder: (context, chatSnapshot) {
                      String activeText = activeUsers.toString();
                      // 채팅방이 존재하면 participants 길이를 전체 인원으로 표시
                      if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
                        final chatData = chatSnapshot.data!.data();
                        final List participants =
                            chatData?['participants'] ?? [];
                        if (participants.isNotEmpty) {
                          activeText = '$activeUsers / ${participants.length}';
                        }
                      }

                      return IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 색상: 선택된 카테고리일 때 테마 컬러로 통일
                            // 1. 활동 이웃 통계
                            _buildInfoItem(
                              Icons.people_alt_rounded,
                              activeText,
                              'boards.metrics.activeNeighbors'.tr(),
                              valueColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                              labelColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                            ),
                            // 구분선
                            VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: Colors.grey[200],
                                indent: 4,
                                endIndent: 4),
                            // 2. 채팅 버튼 (중앙 배치, 통계 스타일과 통일)
                            _buildChatButtonItem(
                              theme,
                              valueColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                              labelColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                            ),
                            // 구분선
                            VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: Colors.grey[200],
                                indent: 4,
                                endIndent: 4),
                            // 3. 월간 포스트 통계
                            _buildInfoItem(
                              Icons.article_rounded,
                              monthlyPosts.toString(),
                              'boards.metrics.monthlyPosts'.tr(),
                              valueColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                              labelColor: _selectedCategoryId != 'all'
                                  ? theme.primaryColor
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: 50.0,
              maxHeight: 50.0,
              child: Container(
                color: Colors.grey[50],
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  // [FIX] 작업 19: '전체' + AppCategories.postCategories 리스트 결합
                  itemCount: 1 + AppCategories.postCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    // 0번 인덱스는 '전체(All)' 칩
                    if (index == 0) {
                      final isSelected = _selectedCategoryId == 'all';
                      return ChoiceChip(
                        label: Text('boards.filter.all'.tr()),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() => _selectedCategoryId = 'all');
                          }
                        },
                        selectedColor:
                            theme.primaryColor.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            color: isSelected
                                ? theme.primaryColor
                                : Colors.grey[300]!),
                        showCheckmark: false,
                      );
                    }

                    // 나머지 인덱스는 AppCategories.postCategories 사용
                    final PostCategoryModel category =
                        AppCategories.postCategories[index - 1];
                    final isSelected =
                        _selectedCategoryId == category.categoryId;

                    return ChoiceChip(
                      // 이모지 + 카테고리명 (다국어)
                      label: Text('${category.emoji} ${category.nameKey.tr()}'),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(
                              () => _selectedCategoryId = category.categoryId);
                        }
                      },
                      selectedColor: theme.primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? theme.primaryColor : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey[300]!),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _buildPostQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'common.error'.tr(
                        namedArgs: {'error': snapshot.error.toString()},
                      ),
                    ),
                  ),
                );
              }

              final postsDocs = snapshot.data?.docs ?? [];

              if (postsDocs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feed_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'boards.emptyFeed'.tr(),
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = PostModel.fromFirestore(postsDocs[index]);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: PostCard(key: ValueKey(post.id), post: post),
                    );
                  },
                  childCount: postsDocs.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label,
      {Color? valueColor, Color? labelColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: valueColor ?? Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(color: labelColor ?? Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }

  // [Added] 작업 23: 통계 아이템과 유사한 스타일의 채팅 버튼 빌더
  Widget _buildChatButtonItem(ThemeData theme,
      {Color? valueColor, Color? labelColor}) {
    // 스타일을 좌우 통계 아이템과 동일하게 맞추기 위해
    // 아이콘 크기와 라벨 폰트 스타일을 `_buildInfoItem`과 동일한 계층으로 조정합니다.
    return InkWell(
      onTap: _onChatPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상단은 통계의 value 영역과 동일한 구성(아이콘 + 작은 여백)
            Row(
              children: [
                Icon(Icons.chat_bubble_rounded,
                    size: 16, color: valueColor ?? Colors.grey[600]),
                const SizedBox(width: 6),
                // 높이 일치를 위해 보이지 않는 값 텍스트(투명)로 동일한 폰트 사이즈/굵기 유지
                Opacity(
                  opacity: 0.0,
                  child: Text(
                    '0',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: valueColor ?? Colors.black87),
                  ),
                ),
              ],
            ),
            // 하단 라벨은 통계 라벨과 동일한 스타일
            Text(
              'boards.chatActionLabel'.tr(),
              style: TextStyle(
                  color: labelColor ?? Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

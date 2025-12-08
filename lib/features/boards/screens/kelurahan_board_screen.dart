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

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'news', 'question', 'help'];

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

    if (_selectedFilter != 'All') {
      query = query.where('tags', arrayContains: _selectedFilter);
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
            expandedHeight: 140.0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Text(
              _kelurahanName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: _onChatPressed,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(
                    'boards.chatActionLabel'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 32,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'boards.boardHeader'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.people_alt_rounded,
                        activeUsers.toString(),
                        'Active Neighbors',
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[200],
                      ),
                      _buildInfoItem(
                        Icons.article_rounded,
                        monthlyPosts.toString(),
                        'Monthly Posts',
                      ),
                    ],
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
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    String label = filter;
                    if (filter == 'All') {
                      label = 'boards.filter.all'.tr();
                    } else if (filter == 'news') {
                      label = 'boards.filter.news'.tr();
                    } else if (filter == 'question') {
                      label = 'boards.filter.question'.tr();
                    } else if (filter == 'help') {
                      label = 'boards.filter.help'.tr();
                    }

                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
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
                        color:
                            isSelected ? theme.primaryColor : Colors.grey[300]!,
                      ),
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

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
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

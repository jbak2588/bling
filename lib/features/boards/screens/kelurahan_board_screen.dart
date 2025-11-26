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
import 'package:bling_app/features/chat/data/chat_service.dart'; // [Added]
import 'package:bling_app/features/chat/screens/chat_room_screen.dart'; // [Added]

/// '하이브리드 방식...md' 기획안 4)의 '동네 게시판' 전용 피드 화면
/// 사용자의 현재 Kelurahan을 기준으로 게시글을 필터링합니다.
class KelurahanBoardScreen extends StatefulWidget {
  final UserModel userModel;

  const KelurahanBoardScreen({super.key, required this.userModel});

  @override
  State<KelurahanBoardScreen> createState() => _KelurahanBoardScreenState();
}

class _KelurahanBoardScreenState extends State<KelurahanBoardScreen> {
  late final Query<Map<String, dynamic>> _query;
  late final String _kelurahanName;

  @override
  void initState() {
    super.initState();
    _kelurahanName =
        widget.userModel.locationParts?['kel'] ?? 'boards.defaultTitle'.tr();
    _query = _buildQuery();
  }

  /// 기획안 4) 피드 필터링: 'where categoryId=='local_news' and adminParts.kel==user.kel'
  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('posts');

    final parts = widget.userModel.locationParts;

    // 1. Kelurahan 필터링 (기획안 핵심 요구사항)
    if (parts != null &&
        parts['prov'] != null &&
        parts['kab'] != null &&
        parts['kec'] != null &&
        parts['kel'] != null) {
      query = query
          .where('locationParts.prov', isEqualTo: parts['prov'])
          .where('locationParts.kab', isEqualTo: parts['kab'])
          .where('locationParts.kec', isEqualTo: parts['kec'])
          .where('locationParts.kel', isEqualTo: parts['kel']);
    } else {
      // 사용자의 Kelurahan 정보가 없으면 아무것도 반환하지 않음 (오류 방지)
      query = query.where('userId', isEqualTo: 'INVALID_QUERY_NO_KELURAHAN');
    }

    // 2. Local News 게시글만 필터링 (tags 필드가 존재하는 것으로 가정)
    // (만약 categoryId를 쓴다면: .where('categoryId', isEqualTo: 'local_news'))
    query = query.where('tags', isNull: false);

    return query.orderBy('createdAt', descending: true);
  }

  /// 기획안 4) 그룹 채팅 연동
  void _onChatPressed() async {
    final parts = widget.userModel.locationParts;
    if (parts == null || parts['kel'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('boards.errors.noLocation'.tr())),
      );
      return;
    }

    // 고유 Kelurahan ID 생성 (Prov|Kab|Kec|Kel)
    final kelKey =
        '${parts['prov']}|${parts['kab']}|${parts['kec']}|${parts['kel']}';

    try {
      final chatService = ChatService();
      // 채팅방 생성 또는 가져오기
      final chatRoom = await chatService.getOrCreateBoardChatRoom(
        kelKey: kelKey,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_kelurahanName),
        actions: [
          // 기획안 4) 그룹 채팅 연동 버튼
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: _onChatPressed,
            tooltip: 'boards.chatRoomTitle'.tr(), // '동네 채팅방'
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('common.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          final postsDocs = snapshot.data?.docs ?? [];

          if (postsDocs.isEmpty) {
            return Center(
                child: Text('boards.emptyFeed'.tr())); // '첫 번째 동네 소식을 작성해보세요!'
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            itemCount: postsDocs.length,
            itemBuilder: (context, index) {
              final post = PostModel.fromFirestore(postsDocs[index]);
              // PostCard는 이미 local_news 모듈에 구현되어 있으므로 재사용
              return PostCard(key: ValueKey(post.id), post: post);
            },
          );
        },
      ),
    );
  }
}

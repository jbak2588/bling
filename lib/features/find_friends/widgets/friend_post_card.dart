// lib/features/find_friends/widgets/friend_post_card.dart

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';

class FriendPostCard extends StatelessWidget {
  final FriendPostModel post;
  final UserModel currentUser;

  const FriendPostCard({
    super.key,
    required this.post,
    required this.currentUser,
  });

  void _onJoinChat(BuildContext context) async {
    // 1:1 채팅 또는 그룹 채팅 입장 로직 연결
    // 여기서는 간단히 ChatService를 호출하는 예시입니다.
    try {
      final chatService = ChatService();
      // post.id를 컨텍스트 ID로 사용하여 채팅방 생성/입장
      final String chatId = await chatService.createOrGetChatRoom(
        otherUserId: post.authorId,
        // contextType을 'friend_post' 등으로 확장 가능
        contextType: 'friend_post',
        // 게시글 제목 등을 채팅방 메타데이터로 활용 가능
      );

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatId: chatId,
              otherUserId: post.authorId,
              otherUserName: post.authorNickname,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 작성자 정보 & 시간
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (post.authorPhotoUrl != null &&
                          post.authorPhotoUrl!.isNotEmpty)
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: (post.authorPhotoUrl == null ||
                          post.authorPhotoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorNickname,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        // timeago 등을 사용하여 "방금 전", "10분 전" 표기 권장
                        "${timeago.format(post.createdAt.toDate())} · ${post.locationName ?? 'Unknown Location'}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (post.isMultiChat)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '그룹 ${post.currentParticipantIds.length}/${post.maxParticipants}',
                      style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 본문
            Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // 태그
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // 하단 버튼 (내가 쓴 글이면 수정/삭제, 남이 쓴 글이면 참여)
            SizedBox(
              width: double.infinity,
              child: post.authorId == currentUser.uid
                  ? OutlinedButton(
                      onPressed: () {}, // TODO: 수정/삭제 기능
                      child: const Text("내 게시글 관리"),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _onJoinChat(context),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text(post.isMultiChat ? "그룹 참여하기" : "대화하기"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

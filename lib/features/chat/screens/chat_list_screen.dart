// lib/features/chat/screens/chat_list_screen.dart

import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final String? _myUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('main.bottomNav.chat'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: _myUid == null
          ? Center(child: Text('main.errors.loginRequired'.tr()))
          : StreamBuilder<List<ChatRoomModel>>(
              stream: _chatService.getChatRoomsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('marketplace.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('chat_list.empty'.tr()));
                }

                final chatRooms = snapshot.data!;

                return ListView.separated(
                  itemCount: chatRooms.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 82),
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    final otherUid = chatRoom.participants
                        .firstWhere((uid) => uid != _myUid, orElse: () => '');

                    if (otherUid.isEmpty) return const SizedBox.shrink();

                    return FutureBuilder<UserModel>(
                      future: _chatService.getOtherUserInfo(otherUid),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text("..."));
                        }

                        final otherUser = userSnapshot.data!;

                        // V V V --- [핵심 수정] 채팅 유형을 판별합니다 --- V V V
                        final bool isProductChat = chatRoom.productId.isNotEmpty;
                        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          
                          // [수정] 채팅 유형에 따라 다른 이미지를 보여줍니다.
                          leading: isProductChat
                              ? _buildProductImage(chatRoom.productImage) // 중고거래: 상품 이미지
                              : _buildUserAvatar(otherUser.photoUrl),   // 친구채팅: 상대방 프로필 사진

                          // [수정] 채팅 유형에 따라 다른 제목을 보여줍니다.
                          title: Text(
                            isProductChat ? chatRoom.productTitle : otherUser.nickname, // 중고거래: 상품명, 친구채팅: 상대방 닉네임
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                // [수정] 친구 채팅일 경우, 부제에 상대방 닉네임을 한번 더 보여줄 필요가 없으므로 숨깁니다.
                                if (isProductChat) ...[
                                  Text(otherUser.nickname,
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[700])),
                                  const Text(' • ',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey)),
                                ],
                                Expanded(
                                  child: Text(
                                    chatRoom.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('MM/dd')
                                    .format(chatRoom.lastTimestamp.toDate()),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              if ((chatRoom.unreadCounts[_myUid] ?? 0) > 0)
                                Badge(
                                    label: Text(
                                        '${chatRoom.unreadCounts[_myUid]}')),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatRoom.id,
                                  otherUserName: otherUser.nickname,
                                  otherUserId: otherUser.uid,
                                  // [수정] 중고거래 채팅일 때만 상품명을 전달합니다.
                                  productTitle: isProductChat ? chatRoom.productTitle : null,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // [추가] 사용자 프로필 아바타 위젯
  Widget _buildUserAvatar(String? photoUrl) {
    return CircleAvatar(
      radius: 28,
      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
          ? NetworkImage(photoUrl)
          : null,
      child: (photoUrl == null || photoUrl.isEmpty)
          ? const Icon(Icons.person)
          : null,
    );
  }

  // [수정] 기존 상품 이미지 위젯 로직을 별도 함수로 분리
  Widget _buildProductImage(String productImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: productImage.isNotEmpty
          ? Image.network(
              productImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade200,
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
    );
  }
}
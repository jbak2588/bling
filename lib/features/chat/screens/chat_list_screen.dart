// lib/features/chat/screens/chat_list_screen.dart

import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// [추가] debugPrint

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

                    final otherUid = !chatRoom.isGroupChat
                        ? chatRoom.participants.firstWhere(
                            (uid) => uid != _myUid,
                            orElse: () => '')
                        : '';

                    if (!chatRoom.isGroupChat && otherUid.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return FutureBuilder<UserModel?>(
                      future: !chatRoom.isGroupChat
                          ? _chatService.getOtherUserInfo(otherUid)
                          : Future.value(null),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !chatRoom.isGroupChat) {
                          return const ListTile(title: Text("..."));
                        }

                        final otherUser = userSnapshot.data;

                        

                        if (chatRoom.isGroupChat) {
                          return _buildGroupChatItem(context, chatRoom);
                        } else if (chatRoom.roomId != null &&
                            chatRoom.roomId!.isNotEmpty) {
                          return _buildRealEstateChatItem(
                              context, chatRoom, otherUser);
                        }
                        // V V V --- [수정] Lost & Found 와 Find Friend UI 로직 추가 --- V V V
                        else if (chatRoom.lostItemId != null &&
                            chatRoom.lostItemId!.isNotEmpty) {
                          return _buildLostAndFoundChatItem(
                              context, chatRoom, otherUser);
                        } else if (chatRoom.shopId != null &&
                            chatRoom.shopId!.isNotEmpty) {
                          return _buildShopChatItem(
                              context, chatRoom, otherUser);
                        } else if (chatRoom.jobId != null &&
                            chatRoom.jobId!.isNotEmpty) {
                          return _buildJobChatItem(
                              context, chatRoom, otherUser);
                        } else if (chatRoom.productId != null &&
                            chatRoom.productId!.isNotEmpty) {
                          return _buildProductChatItem(
                              context, chatRoom, otherUser);
                        }
                        // 'direct' 또는 contextId가 없는 모든 경우는 '친구 찾기'로 간주
                        else {
                          return _buildDirectChatItem(
                              context, chatRoom, otherUser);
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  // 각 채팅 유형별 ListTile을 만드는 헬퍼 함수들

  ListTile _buildGroupChatItem(BuildContext context, ChatRoomModel chatRoom) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(imageUrl: chatRoom.groupImage, icon: Icons.groups),
      title: Text(chatRoom.groupName ?? 'Group Chat',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chatRoom.lastMessage,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, type: 'Group'),
    );
  }

  ListTile _buildRealEstateChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(
          imageUrl: chatRoom.roomImage, icon: Icons.house_outlined),
      title: Text(chatRoom.roomTitle ?? 'Real Estate',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Real Estate'),
    );
  }

  ListTile _buildLostAndFoundChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    // V V V --- [수정] Lost & Found UI 개선 --- V V V
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLostAndFoundAvatar(chatRoom.contextType),
      title: Text('Lost & Found', // 제목을 'Lost & Found'로 고정
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Lost & Found'),
    );
  }

  ListTile _buildShopChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(
          imageUrl: chatRoom.shopImage, icon: Icons.storefront_outlined),
      title: Text(chatRoom.shopName ?? 'Shop',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Shop'),
    );
  }

  ListTile _buildJobChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(icon: Icons.work_outline),
      title: Text(chatRoom.jobTitle ?? 'Job Posting',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Job'),
    );
  }

  ListTile _buildProductChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(
          imageUrl: chatRoom.productImage, icon: Icons.shopping_bag_outlined),
      title: Text(chatRoom.productTitle ?? 'Product',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Product'),
    );
  }

  ListTile _buildDirectChatItem(
      BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    if (otherUser == null) return const ListTile();
     // V V V --- [수정] Find Friend UI 개선 --- V V V
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(imageUrl: otherUser.photoUrl, icon: Icons.favorite_border), // 아이콘 변경
      title: Text('Find Friend', // 제목을 'Find Friend'로 고정
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser.nickname} • ${chatRoom.lastMessage}', // 부제에 상대방 닉네임 추가
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context,
          chatRoom: chatRoom, otherUser: otherUser, type: 'Direct/Friend'),
    );
    
  }

  // V V V --- [수정] 정밀 진단을 위한 로그 출력을 추가합니다 --- V V V
  void _navigateToChat(BuildContext context,
      {required ChatRoomModel chatRoom,
      UserModel? otherUser,
      required String type}) {
    debugPrint(
        "--- [ChatList] Tapped on '$type' chat. Navigating to ChatRoom... ---");

    final otherUid = otherUser?.uid ??
        chatRoom.participants
            .firstWhere((uid) => uid != _myUid, orElse: () => '');

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatRoomScreen(
        chatId: chatRoom.id,
        isGroupChat: chatRoom.isGroupChat,
        groupName: chatRoom.groupName,
        participants: chatRoom.participants,
        otherUserId: otherUid,
        otherUserName: otherUser?.nickname ?? 'User',
        productTitle: chatRoom.productTitle ??
            chatRoom.jobTitle ??
            chatRoom.shopName ??
            chatRoom.roomTitle,
      ),
    ));
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  Widget _buildLostAndFoundAvatar(String? type) {
    final isLost = type == 'lost';
    return CircleAvatar(
      radius: 28,
      backgroundColor: isLost ? Colors.red.shade50 : Colors.blue.shade50,
      child: Icon(
        isLost ? Icons.search_off : Icons.task_alt_outlined,
        color: isLost ? Colors.redAccent : Colors.blueAccent,
        size: 28,
      ),
    );
  }

  Widget _buildAvatar({String? imageUrl, required IconData icon}) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
          ? NetworkImage(imageUrl)
          : null,
      child: (imageUrl == null || imageUrl.isEmpty)
          ? Icon(icon, size: 28, color: Colors.grey.shade600)
          : null,
    );
  }

  Widget _buildTrailing(ChatRoomModel chatRoom) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(DateFormat('MM/dd').format(chatRoom.lastTimestamp.toDate()),
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        if ((chatRoom.unreadCounts[_myUid] ?? 0) > 0)
          Badge(label: Text('${chatRoom.unreadCounts[_myUid]}')),
      ],
    );
  }
}

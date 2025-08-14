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
                  return Center(child: Text('marketplace.error'.tr(namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('chat_list.empty'.tr()));
                }

                final chatRooms = snapshot.data!;

                return ListView.separated(
                  itemCount: chatRooms.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 82),
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    
                    final otherUid = !chatRoom.isGroupChat ? chatRoom.participants.firstWhere((uid) => uid != _myUid, orElse: () => '') : '';
                    if (!chatRoom.isGroupChat && otherUid.isEmpty) return const SizedBox.shrink();

                    return FutureBuilder<UserModel?>(
                      future: !chatRoom.isGroupChat ? _chatService.getOtherUserInfo(otherUid) : Future.value(null),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting && !chatRoom.isGroupChat) {
                          return const ListTile(title: Text("..."));
                        }

                        final otherUser = userSnapshot.data;

                        // V V V --- [핵심 수정] 채팅 유형에 따라 UI와 네비게이션 로직을 분리합니다 --- V V V
                        
                        // --- 1. 동호회 (그룹 채팅) ---
                        if (chatRoom.isGroupChat) {
                          return _buildGroupChatItem(context, chatRoom);
                        } 
                        
                        // --- 2. 지역 상점 ---
                        else if (chatRoom.shopId != null && chatRoom.shopId!.isNotEmpty) {
                           return _buildShopChatItem(context, chatRoom, otherUser);
                        }
                        
                        // --- 3. 구인구직 ---
                        else if (chatRoom.jobId != null && chatRoom.jobId!.isNotEmpty) {
                           return _buildJobChatItem(context, chatRoom, otherUser);
                        }

                        // --- 4. 중고거래 ---
                        else if (chatRoom.productId != null && chatRoom.productId!.isNotEmpty) {
                          return _buildProductChatItem(context, chatRoom, otherUser);
                        }

                        // --- 5. 친구 (1:1 직접 채팅) ---
                        else {
                          return _buildDirectChatItem(context, chatRoom, otherUser);
                        }
                        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
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
      title: Text(chatRoom.groupName ?? 'Group Chat', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chatRoom.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom),
    );
  }
  
  ListTile _buildShopChatItem(BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(imageUrl: chatRoom.shopImage, icon: Icons.storefront_outlined),
      title: Text(chatRoom.shopName ?? 'Shop', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, otherUser: otherUser),
    );
  }

  ListTile _buildJobChatItem(BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(icon: Icons.work_outline),
      title: Text(chatRoom.jobTitle ?? 'Job Posting', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, otherUser: otherUser),
    );
  }

  ListTile _buildProductChatItem(BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(imageUrl: chatRoom.productImage, icon: Icons.shopping_bag_outlined),
      title: Text(chatRoom.productTitle ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, otherUser: otherUser),
    );
  }
  
  ListTile _buildDirectChatItem(BuildContext context, ChatRoomModel chatRoom, UserModel? otherUser) {
    if (otherUser == null) return const ListTile();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(imageUrl: otherUser.photoUrl, icon: Icons.person),
      title: Text(otherUser.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chatRoom.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, otherUser: otherUser),
    );
  }

  void _navigateToChat(BuildContext context, {required ChatRoomModel chatRoom, UserModel? otherUser}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatRoomScreen(
        chatId: chatRoom.id,
        isGroupChat: chatRoom.isGroupChat,
        groupName: chatRoom.groupName,
        participants: chatRoom.participants,
        otherUserId: otherUser?.uid,
        otherUserName: otherUser?.nickname,
        productTitle: chatRoom.productTitle ?? chatRoom.jobTitle ?? chatRoom.shopName,
      ),
    ));
  }

  Widget _buildAvatar({String? imageUrl, required IconData icon}) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
      child: (imageUrl == null || imageUrl.isEmpty) ? Icon(icon, size: 28, color: Colors.grey.shade600) : null,
    );
  }
  
  Widget _buildTrailing(ChatRoomModel chatRoom) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(DateFormat('MM/dd').format(chatRoom.lastTimestamp.toDate()), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        if ((chatRoom.unreadCounts[_myUid] ?? 0) > 0)
          Badge(label: Text('${chatRoom.unreadCounts[_myUid]}')),
      ],
    );
  }
}
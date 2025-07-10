// lib/features/chat/screens/chat_list_screen.dart

import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart'; // ⭐️[수정]
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
  // ⭐️[수정] ChatService 인스턴스 생성
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
          // ⭐️[수정] StreamBuilder가 ChatService의 함수를 직접 호출
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

                    // ⭐️[수정] FutureBuilder가 ChatService의 함수를 직접 호출
                    return FutureBuilder<UserModel>(
                      future: _chatService.getOtherUserInfo(otherUid),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text("..."));
                        }

                        final otherUser = userSnapshot.data!;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: chatRoom.productImage.isNotEmpty
                                ? Image.network(
                                    chatRoom.productImage,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) =>
                                        _buildPlaceholderImage(),
                                  )
                                : _buildPlaceholderImage(),
                          ),
                          title: Text(
                            chatRoom.productTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text(otherUser.nickname,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700])),
                                const Text(' • ',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)),
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
                                  productTitle: chatRoom.productTitle,
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade200,
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
    );
  }
}

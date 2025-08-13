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
                      child: Text('marketplace.error'
                          .tr(namedArgs: {'error': snapshot.error.toString()})));
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
                    
                    // 그룹 채팅이 아닐 경우에만 otherUid를 찾습니다.
                    final otherUid = !chatRoom.isGroupChat
                        ? chatRoom.participants.firstWhere((uid) => uid != _myUid, orElse: () => '')
                        : '';

                    // 그룹 채팅이 아닌데 상대방 정보가 없으면 표시하지 않습니다.
                    if (!chatRoom.isGroupChat && otherUid.isEmpty) return const SizedBox.shrink();

                    return FutureBuilder<UserModel?>(
                      // 그룹 채팅이 아닐 때만 상대방 정보를 가져옵니다.
                      future: !chatRoom.isGroupChat ? _chatService.getOtherUserInfo(otherUid) : Future.value(null),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(title: Text("..."));
                        }

                        final otherUser = userSnapshot.data;

                       // V V V --- [핵심 수정] 채팅 유형에 따라 UI와 네비게이션 로직을 분리합니다 --- V V V

                        // --- 1. 동호회 (그룹 채팅) ---
                        if (chatRoom.isGroupChat) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: _buildGroupAvatar(chatRoom.groupImage),
                            title: Text(chatRoom.groupName ?? 'Group Chat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text(chatRoom.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: _buildTrailing(chatRoom),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatRoom.id,
                                  isGroupChat: true,
                                  groupName: chatRoom.groupName,
                                  participants: chatRoom.participants,
                                ),
                              ));
                            },
                          );
                        } 
                        
                        // --- 2. 구인구직 ---
                        else if (chatRoom.jobId != null && chatRoom.jobId!.isNotEmpty) {
                           return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: _buildJobAvatar(), // 구인구직 전용 아바타
                            title: Text(chatRoom.jobTitle ?? 'Job Posting', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: _buildTrailing(chatRoom),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatRoom.id,
                                  otherUserName: otherUser?.nickname ?? 'User',
                                  otherUserId: otherUid,
                                  productTitle: chatRoom.jobTitle, // 제목 필드 재활용
                                ),
                              ));
                            },
                          );
                        }

                        // --- 3. 중고거래 ---
                        else if (chatRoom.productId != null && chatRoom.productId!.isNotEmpty) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: _buildProductImage(chatRoom.productImage ?? ''),
                            title: Text(chatRoom.productTitle ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text('${otherUser?.nickname ?? ''} • ${chatRoom.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: _buildTrailing(chatRoom),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatRoom.id,
                                  otherUserName: otherUser?.nickname ?? 'User',
                                  otherUserId: otherUid,
                                  productTitle: chatRoom.productTitle,
                                ),
                              ));
                            },
                          );
                        }

                        // --- 4. 친구 (1:1 직접 채팅) ---
                        else {
                          if (otherUser == null) return const SizedBox.shrink();
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: _buildUserAvatar(otherUser.photoUrl),
                            title: Text(otherUser.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text(chatRoom.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: _buildTrailing(chatRoom),
                            onTap: () {
                               Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  chatId: chatRoom.id,
                                  otherUserName: otherUser.nickname,
                                  otherUserId: otherUser.uid,
                                ),
                              ));
                            },
                          );
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

  // [추가] 그룹(동호회) 아바타 위젯
  Widget _buildGroupAvatar(String? groupImageUrl) {
    return CircleAvatar(
      radius: 28,
      backgroundImage: (groupImageUrl != null && groupImageUrl.isNotEmpty)
          ? NetworkImage(groupImageUrl)
          : null,
      child: (groupImageUrl == null || groupImageUrl.isEmpty)
          ? const Icon(Icons.groups) // 그룹 기본 아이콘
          : null,
    );
  }

  // [추가] 구인구직 아바타 위젯
  Widget _buildJobAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.work_outline, color: Colors.grey.shade600),
    );
  }
  
  // [추가] 재사용을 위해 trailing 위젯을 함수로 분리
  Widget _buildTrailing(ChatRoomModel chatRoom) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat('MM/dd').format(chatRoom.lastTimestamp.toDate()),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        if ((chatRoom.unreadCounts[_myUid] ?? 0) > 0)
          Badge(label: Text('${chatRoom.unreadCounts[_myUid]}')),
      ],
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
// lib/features/chat/presentation/screens/chat_list_screen.dart

import 'package:bling_app/features/chat/domain/chat_room.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _myUid = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, String?>> _getOtherUserInfo(String otherUid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUid)
        .get();
    if (!userDoc.exists) {
      return {'nickname': 'Unknown User', 'profileImage': null};
    }
    return {
      'nickname': userDoc.data()?['nickname'] as String?,
      'profileImage': userDoc.data()?['profileImage'] as String?,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: _myUid)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'marketplace_error'.tr(args: [snapshot.error.toString()])));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('chat_list_empty'.tr()));
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatDocs.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 82),
            itemBuilder: (context, index) {
              final chatRoom = ChatRoom.fromFirestore(chatDocs[index]);
              final otherUid = chatRoom.participants.firstWhere(
                (uid) => uid != _myUid,
                orElse: () => '',
              );

              if (otherUid.isEmpty) return const SizedBox.shrink();

              return FutureBuilder<Map<String, String?>>(
                future: _getOtherUserInfo(otherUid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("..."));
                  }

                  final otherUserName = userSnapshot.data?['nickname'] ?? '사용자';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        chatRoom.productImage,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      chatRoom.productTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Text(
                            otherUserName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              chatRoom.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
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
                          DateFormat(
                            'MM/dd',
                          ).format(chatRoom.lastTimestamp.toDate()),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if ((chatRoom.unreadCounts[_myUid] ?? 0) > 0)
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              '${chatRoom.unreadCounts[_myUid]}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            chatId: chatRoom.id,
                            otherUserName: otherUserName,
                            otherUserId: otherUid,
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
}

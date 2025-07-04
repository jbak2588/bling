// lib/features/chat/presentation/screens/chat_room_screen.dart

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:bling_app/features/chat/domain/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;
  final String? productTitle;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
    this.productTitle,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _myUid = FirebaseAuth.instance.currentUser!.uid;
  final _audioPlayer = AudioPlayer();

  String? _otherUserProfileImage;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserData();
    _resetMyUnreadCount();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();
    if (mounted && userDoc.exists) {
      setState(() {
        _otherUserProfileImage = userDoc.data()?['profileImage'];
      });
    }
  }

  Future<void> _resetMyUnreadCount() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'unreadCounts.${_myUid}': 0});
  }

  Future<void> _markMessagesAsRead() async {
    final messageQuery = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId);

    final snapshot = await messageQuery.get();

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      final message = ChatMessage.fromFirestore(doc);
      if (!message.readBy.contains(_myUid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([_myUid]),
        });
      }
    }
    await batch.commit();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    _audioPlayer.play(AssetSource('sounds/send_sound.mp3'));

    final message = {
      'senderId': _myUid,
      'text': messageText,
      'timestamp': Timestamp.now(),
      'readBy': [_myUid],
    };

    final chatDocRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatDocRef.collection('messages').add(message);

    await chatDocRef.update({
      'lastMessage': messageText,
      'lastTimestamp': message['timestamp'],
      'unreadCounts.${widget.otherUserId}': FieldValue.increment(1),
    });
  }

  Widget _buildReadReceipt(ChatMessage message) {
    final bool isReadByOther = message.readBy.contains(widget.otherUserId);
    if (message.senderId != _myUid) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Icon(
        isReadByOther ? Icons.done_all : Icons.done,
        size: 16,
        color: isReadByOther ? Colors.blueAccent : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productTitle ?? widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('chat_placeholder'.tr()));
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _myUid;

                    return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: _otherUserProfileImage != null
                                ? NetworkImage(_otherUserProfileImage!)
                                : null,
                            child: _otherUserProfileImage == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.indigo[50] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(message.text),
                          ),
                        ),
                        if (isMe) _buildReadReceipt(message),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'chat_placeholder'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

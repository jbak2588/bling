// lib/features/chat/screens/chat_room_screen.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:bling_app/core/models/chat_message_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // ⭐️ [수정] ChatService 인스턴스 생성
  final ChatService _chatService = ChatService();
  UserModel? _otherUser;

  @override
  void initState() {
    super.initState();
    // AudioPlayer.global.setLogLevel(LogLevel.error); // 불필요한 로그 숨기기
    _fetchOtherUserData();
    _chatService.markMessagesAsRead(widget.chatId, widget.otherUserId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherUserData() async {
    final user = await _chatService.getOtherUserInfo(widget.otherUserId);
    if (mounted) setState(() => _otherUser = user);
  }

  // ⭐️ [수정] 모든 로직을 ChatService에 위임
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageText = _messageController.text.trim();
    _messageController.clear();

    // await _audioPlayer.setAudioContext(const AudioContext(
    //     android: AudioContextAndroid(
    //         contentType: AndroidContentType.sonification,
    //         usageType: AndroidUsageType.assistanceSonification),
    //     ios: AudioContextIOS(category: AVAudioSessionCategory.playback)));
    await _audioPlayer.play(AssetSource('sounds/send_sound.mp3'));

    await _chatService.sendMessage(
        widget.chatId, messageText, widget.otherUserId);
  }

  Widget _buildReadReceipt(ChatMessageModel message) {
    if (message.senderId != _myUid) return const SizedBox.shrink();
    final bool isReadByOther = message.readBy.contains(widget.otherUserId);
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
            // ⭐️ [수정] StreamBuilder가 ChatService를 사용
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('chat_room.placeholder'.tr()));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
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
                            backgroundImage: _otherUser?.photoUrl != null
                                ? NetworkImage(_otherUser!.photoUrl!)
                                : null,
                            child: _otherUser?.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
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
                      hintText: 'chat_room.placeholder'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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

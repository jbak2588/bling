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
  final bool isGroupChat;
  final String? groupName;
  final String? otherUserName;
  final String? otherUserId;
  final String? productTitle;
  final List<String>? participants;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    this.isGroupChat = false,
    this.groupName,
    this.otherUserName,
    this.otherUserId,
    this.productTitle,
    this.participants,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _myUid = FirebaseAuth.instance.currentUser!.uid;
  final _audioPlayer = AudioPlayer();
  final ChatService _chatService = ChatService();
  
  Map<String, UserModel> _participantsInfo = {};
  bool _isLoadingParticipants = true;

  @override
  void initState() {
    super.initState();
    _loadParticipantsData();
    if (!widget.isGroupChat && widget.otherUserId != null) {
      _chatService.markMessagesAsRead(widget.chatId, widget.otherUserId!);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipantsData() async {
    List<String> idsToFetch = widget.isGroupChat 
        ? (widget.participants ?? []) 
        : (widget.otherUserId != null ? [_myUid, widget.otherUserId!] : []);

    if (idsToFetch.isNotEmpty) {
      final usersMap = await _chatService.getParticipantsInfo(idsToFetch);
      if (mounted) setState(() { _participantsInfo = usersMap; _isLoadingParticipants = false; });
    } else {
      if (mounted) setState(() => _isLoadingParticipants = false);
    }
  }
  
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    
    _messageController.clear();
    await _audioPlayer.play(AssetSource('sounds/send_sound.mp3'));

    await _chatService.sendMessage(
      widget.chatId, messageText,
      otherUserId: widget.isGroupChat ? null : widget.otherUserId,
      allParticipantIds: widget.isGroupChat ? widget.participants : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.isGroupChat ? widget.groupName ?? 'Group Chat' : widget.productTitle ?? widget.otherUserName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: _isLoadingParticipants
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessageModel>>(
                    stream: _chatService.getMessagesStream(widget.chatId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      if (snapshot.data!.isEmpty) return Center(child: Text('chat_room.placeholder'.tr()));
                      
                      final messages = snapshot.data!;
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final sender = _participantsInfo[message.senderId];
                          final isMe = message.senderId == _myUid;
                          return _buildMessageItem(message, sender, isMe);
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
                          decoration: InputDecoration(hintText: 'chat_room.placeholder'.tr(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.send, color: Colors.teal), onPressed: _sendMessage),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageItem(ChatMessageModel message, UserModel? sender, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: (sender?.photoUrl != null && sender!.photoUrl!.isNotEmpty) ? NetworkImage(sender.photoUrl!) : null,
              child: (sender?.photoUrl == null || sender!.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && widget.isGroupChat)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                    child: Text(sender?.nickname ?? 'Unknown', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(color: isMe ? Colors.teal[50] : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                  child: Text(message.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
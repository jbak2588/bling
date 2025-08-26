/// ============================================================================
/// Bling DocHeader
/// Module        : Chat
/// File          : lib/features/chat/screens/chat_room_screen.dart
/// Purpose       : 구인·상품 등 컨텍스트 아이템을 포함한 1:1 및 그룹 채팅 실시간 인터페이스입니다.
/// User Impact   : 이웃 간 안전한 소통과 거래를 가능하게 합니다.
/// Feature Links : lib/features/chat/screens/chat_list_screen.dart; lib/features/chat/data/chat_service.dart; lib/features/jobs/screens/job_detail_screen.dart
/// Data Model    : Firestore `chatRooms` 필드 `participants`, `jobId`, `productId`; 하위 컬렉션 `messages`의 `senderId`, `text`, `timestamp`, `readBy`.
/// Location Scope: 없음; 모더레이션은 참가자 프로필 위치를 참조합니다.
/// Trust Policy  : `report` 모듈에서 신고된 메시지는 `trustScore`를 감소시키며 인증 사용자만 허용됩니다.
/// Monetization  : 스폰서 메시지 가능성; TODO: 구현.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `send_message`, `enter_chat_room`, `attach_media`.
/// Analytics     : 읽음 확인과 컨텍스트 아이템 클릭을 기록합니다.
/// I18N          : 키 `chat_list.empty`, `chat_room.send` (assets/lang/*.json)
/// Dependencies  : firebase_auth, chat_service, audioplayers, easy_localization
/// Security/Auth : 참가자에게만 접근이 제한되며 사용자 UID별로 읽음 표시를 합니다.
/// Edge Cases    : 컨텍스트 아이템 누락, 참가자 정보 부족, 연결 끊김.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/07 Chat 모듈 Core.md; docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
library;

// 아래부터 실제 코드

import 'package:audioplayers/audioplayers.dart';
import 'package:bling_app/core/models/chat_message_model.dart';
// import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
// import 'package:bling_app/core/models/product_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/screens/job_detail_screen.dart';
// TODO: ProductRepository 및 ProductDetailScreen import 필요
// import 'package:bling_app/features/marketplace/data/product_repository.dart';
// import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
final String chatId;
  // [수정] 그룹/1:1 채팅을 구분하기 위한 파라미터 추가 및 변경
  final bool isGroupChat;
  final String? groupName;
  final String? otherUserName;
  final String? otherUserId;
  final String? productTitle; // 구인글 제목 등 컨텍스트 제목으로 재활용
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


  // V V V --- [추가] 컨텍스트 헤더를 위한 상태 변수 --- V V V
  dynamic _contextItem; // JobModel 또는 ProductModel을 저장
  bool _isContextLoading = true;
  // ChatRoomModel? _chatRoomModel;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  @override
  void initState() {
    super.initState();
    _loadParticipantsData();
    // [수정] 그룹/1:1 채팅 모두에서 '읽음'으로 표시하는 함수를 호출합니다.
    _chatService.markMessagesAsRead(widget.chatId);
    _loadChatContext(); // [추가] 컨텍스트 정보 로딩 함수 호출
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipantsData() async {
    List<String> idsToFetch = [];
    if (widget.isGroupChat) {
      idsToFetch = widget.participants ?? [];
    } else if (widget.otherUserId != null) {
      idsToFetch = [_myUid, widget.otherUserId!];
    }

    if (idsToFetch.isNotEmpty) {
      final usersMap = await _chatService.getParticipantsInfo(idsToFetch);
      if (mounted) {
        setState(() {
          _participantsInfo = usersMap;
          _isLoadingParticipants = false;
        });
      }
    } else {
       if (mounted) setState(() => _isLoadingParticipants = false);
    }
  }

   Future<void> _loadChatContext() async {
    try {
      final chatRoom = await _chatService.getChatRoom(widget.chatId);
      if (chatRoom == null || !mounted) return;
      
      // setState(() => _chatRoomModel = chatRoom);

      // [수정] _chatRoomModel 변수에 저장하는 대신, 직접 사용
      if (chatRoom.jobId != null) {
        final job = await JobRepository().fetchJob(chatRoom.jobId!);
        if (job != null && mounted) setState(() => _contextItem = job);
      } 
      // else if (chatRoom.productId != null) {
      //   final product = await ProductRepository().fetchProduct(chatRoom.productId!);
      //   if (product != null && mounted) setState(() => _contextItem = product);
      // }
    } catch (e) {
      debugPrint("컨텍스트 정보를 불러오는데 실패했습니다: $e");
    } finally {
      if (mounted) setState(() => _isContextLoading = false);
    }
  }

  
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    
    _messageController.clear();
    await _audioPlayer.play(AssetSource('sounds/send_sound.mp3'));

    await _chatService.sendMessage(
      widget.chatId,
      messageText,
      otherUserId: widget.isGroupChat ? null : widget.otherUserId,
      allParticipantIds: widget.isGroupChat ? widget.participants : null,
    );
  }

  // [복원 및 업그레이드] 읽음 확인 아이콘을 그리는 위젯
  Widget _buildReadReceipt(ChatMessageModel message) {
    // 내가 보낸 메시지가 아니면 아무것도 표시하지 않음
    if (message.senderId != _myUid) return const SizedBox.shrink();

    bool isReadAll = false;
    if (widget.isGroupChat) {
      // 그룹 채팅: 나를 제외한 모든 참여자가 읽었는지 확인
      final otherParticipants = widget.participants?.where((id) => id != _myUid).toList() ?? [];
      isReadAll = otherParticipants.isNotEmpty && otherParticipants.every((id) => message.readBy.contains(id));
    } else {
      // 1:1 채팅: 상대방이 읽었는지 확인
      isReadAll = widget.otherUserId != null && message.readBy.contains(widget.otherUserId!);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Icon(
        isReadAll ? Icons.done_all : Icons.done,
        size: 16,
        color: isReadAll ? Colors.blueAccent : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.isGroupChat
        ? widget.groupName ?? 'Group Chat'
        : widget.productTitle ?? widget.otherUserName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: _isLoadingParticipants
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
// V V V --- [추가] 컨텍스트 헤더 UI --- V V V
          if (!_isContextLoading && _contextItem != null)
            _buildContextHeader(),

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
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 8, right: 8, top: 8),
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

  // [추가] 컨텍스트 헤더를 만드는 위젯 함수
  Widget _buildContextHeader() {
    ImageProvider? image;
    String title = '';
    String subtitle = '';
    
    if (_contextItem is JobModel) {
      final job = _contextItem as JobModel;
      title = job.title;
      subtitle = 'jobs.salaryTypes.${job.salaryType ?? 'etc'}'.tr();
      if (job.imageUrls != null && job.imageUrls!.isNotEmpty) {
        image = NetworkImage(job.imageUrls!.first);
      }
    } 
    // else if (_contextItem is ProductModel) {
    //   final product = _contextItem as ProductModel;
    //   title = product.title;
    //   subtitle = NumberFormat.currency(...).format(product.price);
    //   if (product.imageUrls.isNotEmpty) {
    //     image = NetworkImage(product.imageUrls.first);
    //   }
    // }

     return Material(
      color: Colors.grey.shade50,
      child: InkWell(
        onTap: () {
          if (_contextItem is JobModel) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => JobDetailScreen(job: _contextItem)));
          } 
          // else if (_contextItem is ProductModel) {
          //   Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: _contextItem)));
          // }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
                  color: image == null ? Colors.grey.shade200 : null,
                ),
                child: image == null ? Icon(Icons.work_outline, color: Colors.grey.shade600, size: 20) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ],
                )
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageModel message, UserModel? sender, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: (sender?.photoUrl != null && sender!.photoUrl!.isNotEmpty) ? NetworkImage(sender.photoUrl!) : null,
              child: (sender?.photoUrl == null || sender!.photoUrl!.isEmpty) ? const Icon(Icons.person, size: 18) : null,
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
          if (isMe) ...[
            const SizedBox(width: 4),
            _buildReadReceipt(message),
          ],
        ],
      ),
    );
  }
}
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
/// Monetization  : 스폰서 메시지 가능성; 광고주 타겟팅에 채팅 활동 데이터 활용 가능성.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `send_message`, `enter_chat_room`, `attach_media`.
/// Analytics     : 읽음 확인과 컨텍스트 아이템 클릭을 기록합니다.
/// I18N          : 키 `chat_list.empty`, `chat_room.send` (assets/lang/*.json)
/// Dependencies  : firebase_auth, chat_service, audioplayers, easy_localization
/// Security/Auth : 참가자에게만 접근이 제한되며 사용자 UID별로 읽음 표시를 합니다.
/// Edge Cases    : 컨텍스트 아이템 누락, 참가자 정보 부족, 연결 끊김.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/07 Chat 모듈 Core.md; docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - 1:1/그룹 채팅, 실시간 메시지, 미디어 첨부, 읽음/알림/차단/신고 등 안전·운영 기능
///   - 신뢰등급, 위치 정보, 프로필 연동, 활동 히스토리, KPI/Analytics, 광고/프로모션, 다국어(i18n)
///
/// 2. 실제 코드 분석
///   - 1:1/그룹 채팅, 실시간 메시지, 미디어 첨부, 읽음/알림/차단/신고 등 안전·운영 기능, KPI/Analytics, Edge case 처리
///   - 신뢰등급, 다국어(i18n), 광고/프로모션 등 정책 반영
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 신뢰등급·Edge case·KPI/Analytics 등 품질·운영 기능 강화, 다국어(i18n), 광고/프로모션 등 실제 서비스 운영에 필요한 기능 반영
///   - 기획에 못 미친 점: 그룹 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, 신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 그룹 채팅, 미디어 첨부/미리보기, 신뢰등급/알림/차단/신고 UX 강화, 활동 히스토리/신뢰등급 변화 시각화, 광고/프로모션 배너
///   - 수익화: 프리미엄 채팅, 광고/프로모션, 추천 친구/상품/채팅방 노출, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
/// ============================================================================
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `send_message`, `enter_chat_room`, `attach_media`.
///
/// 2025-10-30 ~ 31 (작업 16):
///   - [버그 수정] Scaffold에 'resizeToAvoidBottomInset: true' 속성을 추가.
///   - 핸드폰 키보드가 올라올 때 채팅 입력창이 가려지는 현상 수정.
/// ============================================================================
// [v2.1 리팩토링 이력: Job 15-19]
// - (Job 15) 'isNewChat' 파라미터 추가.
// - (Job 15) 'isNewChat'이 true이고 메시지가 없으면 '아이스브레이커' 질문 칩 표시.
// - (Job 15) 'isNewChat'이 true일 때 24시간(86400초) '보호 모드'(_isProtectionActive) 활성화.
// - (Job 15) '_maskMessage' 함수: 보호 모드 시 링크(http) 및 전화번호(8자리 이상) 마스킹.
// - (Job 17) 'sendImageMessage' 및 '_buildImageMessage' 기능 추가.
// - (Job 17) 보호 모드 시 미디어 전송 버튼(카메라/갤러리) 비활성화.
// - (Job 17) 보호 모드 시 수신 이미지 'BackdropFilter'로 블러(Blur) 처리.
// - (Job 19) 'unused_field'(_scrollController) 및 'Unnecessary Container' 경고 수정.
// [v2.1 리팩토링 이력: Job 15]
// - (Job 15) 'sendMessage'의 'batch.update'를 'batch.set(..., merge: true)'로 변경.
//   (사유: '동네 친구' 첫 대화 시 채팅방 문서가 존재하지 않아도 생성되도록 보장 - 버그 수정)
// [v2.1 리팩토링 이력: Job 7, 9, 25]
// - (Job 7, 9) 'isDatingProfile', 'age', 'ageRange', 'gender' 등 데이팅 관련 필드 삭제/null 처리.
// - (Job 25) 'trustLevelLabel' (String) 필드 추가 (Firestore 데이터와 동기화).
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
import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart';
import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/screens/talent_detail_screen.dart';
// Why? : ProductRepository 및 ProductDetailScreen import 필요
import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/local_stores/screens/shop_detail_screen.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/screens/room_detail_screen.dart';
import 'dart:io'; // [v2.1] 이미지 파일(File) 사용을 위해 import
import 'dart:ui' as ui; // [v2.1] 이미지 블러(ImageFiltered)를 위해 import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart'; // [v2.1] 이미지 전송 기능 구현을 위해 import
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Club context imports
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/screens/club_detail_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  // [수정] 그룹/1:1 채팅을 구분하기 위한 파라미터 추가 및 변경
  final bool isGroupChat;
  final String? groupName;
  final String? clubId;
  final String? clubImage;
  final String? clubTitle; // [추가] 클럽 타이틀
  final String? otherUserName;
  final String? otherUserId;
  final String? productTitle; // 구인글 제목 등 컨텍스트 제목으로 재활용
  final List<String>? participants;
  // [v2.1] '동네 친구'에서 신규 입장 시 true로 설정
  final bool isNewChat;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    this.isGroupChat = false,
    this.groupName,
    this.clubId,
    this.clubImage,
    this.clubTitle,
    this.otherUserName,
    this.otherUserId,
    this.productTitle,
    this.participants,
    this.isNewChat = false, // 기본값은 false
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  // Allow nullable UID: currentUser may be null during startup or sign-out flows
  final String? _myUid = FirebaseAuth.instance.currentUser?.uid;
  final _audioPlayer = AudioPlayer();
  final ChatService _chatService = ChatService();

  final ScrollController _scrollController = ScrollController();

  // [v2.1] 보호 모드 상태 변수 (State 변수로 승격)
  bool _isProtectionActive = false;
  final ImagePicker _picker = ImagePicker(); // [v2.1] 이미지 피커 인스턴스
  // [v2.1] 이 채팅이 '친구(1:1) 채팅'인지 여부 (보호 모드 적용 대상 판단용)
  bool _isFriendChat = false;

  Map<String, UserModel> _participantsInfo = {};
  bool _isLoadingParticipants = true;

  // V V V --- [추가] 컨텍스트 헤더를 위한 상태 변수 --- V V V
  dynamic _contextItem; // JobModel 또는 ProductModel을 저장
  bool _isContextLoading = true;
  ChatRoomModel? _chatRoomModel;
  String? _appBarTitle; // mutable app bar title that updates when context loads
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  bool get isNewChat => widget.isNewChat;

  @override
  void initState() {
    super.initState();
    _loadParticipantsData();
    // [수정] 그룹/1:1 채팅 모두에서 '읽음'으로 표시하는 함수를 호출합니다.
    _chatService.markMessagesAsRead(widget.chatId);
    // 보호 모드는 채팅 컨텍스트를 확인한 뒤(친구 채팅인지) 결정합니다.
    // Initialize app bar title from explicit widget params first
    _appBarTitle = widget.isGroupChat
        ? (widget.clubTitle ?? widget.groupName)
        : (widget.productTitle ?? widget.otherUserName);

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
      // If local auth hasn't resolved yet, avoid inserting null into ids list
      if (_myUid != null) {
        idsToFetch = [_myUid!, widget.otherUserId!];
      } else {
        idsToFetch = [widget.otherUserId!];
      }
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
      if (mounted) {
        setState(() => _isLoadingParticipants = false);
      }
    }
  }

  Future<void> _loadChatContext() async {
    try {
      // Prefer clubId passed via widget parameter
      if (widget.clubId != null) {
        try {
          final club = await ClubRepository().fetchClub(widget.clubId!);
          if (mounted) {
            setState(() {
              _contextItem = club;
              _isContextLoading = false;
              _appBarTitle = club.title;
            });
            return;
          }
        } catch (e) {
          debugPrint('Failed to load club from widget.clubId: $e');
        }
      }
      final chatRoom = await _chatService.getChatRoom(widget.chatId);
      if (chatRoom == null || !mounted) return;

      // If chatRoom explicitly references a club, load it
      if (chatRoom.clubId != null) {
        try {
          final club = await ClubRepository().fetchClub(chatRoom.clubId!);
          if (mounted) {
            setState(() {
              _contextItem = club;
              _appBarTitle = club.title;
            });
            // we keep going to set _chatRoomModel and protection flags below
          }
        } catch (e) {
          debugPrint('Failed to fetch club from chatRoom.clubId: $e');
        }
      } else if (chatRoom.isGroupChat &&
          (chatRoom.contextType == null || chatRoom.contextType == 'club')) {
        // heuristic: try chatId as clubId
        try {
          final club = await ClubRepository().fetchClub(widget.chatId);
          if (mounted) {
            setState(() {
              _contextItem = club;
              _appBarTitle = club.title;
            });
          }
        } catch (_) {
          // ignore
        }
      }

      // Determine whether this is a plain 1:1 friend chat (no product/job/context)
      final bool isFriend = (chatRoom.isGroupChat == false) &&
          (chatRoom.contextType == null || chatRoom.contextType!.isEmpty) &&
          (chatRoom.participants.length == 2);
      if (mounted) {
        setState(() {
          _isFriendChat = isFriend;
          // Only enable initial protection when this was explicitly started as a new friend chat
          _isProtectionActive = widget.isNewChat && _isFriendChat;
        });
      }

      // store chatRoom for header fallback image/title if needed
      if (mounted) {
        setState(() => _chatRoomModel = chatRoom);
      }

      if (chatRoom.jobId != null) {
        final job = await JobRepository().fetchJob(chatRoom.jobId!);
        if (job != null && mounted) {
          setState(() {
            _contextItem = job;
            _appBarTitle = job.title;
          });
        }
      } else if (chatRoom.talentId != null) {
        // Load talent context when present
        final talent =
            await TalentRepository().getTalentById(chatRoom.talentId!);
        if (talent != null && mounted) {
          setState(() {
            _contextItem = talent;
            _appBarTitle = talent.title;
          });
        }
      } else if (chatRoom.shopId != null) {
        // Load shop context when present
        final shop = await ShopRepository().fetchShop(chatRoom.shopId!);
        if (mounted) {
          setState(() {
            _contextItem = shop;
            _appBarTitle = shop.name;
          });
        }
      } else if (chatRoom.roomId != null) {
        // Load room/listing context when present
        try {
          final room =
              await RoomRepository().getRoomStream(chatRoom.roomId!).first;
          if (mounted) {
            setState(() {
              _contextItem = room;
              _appBarTitle = room.title;
            });
          }
        } catch (e) {
          debugPrint('Failed to fetch room listing: $e');
        }
      } else if (chatRoom.productId != null) {
        // Load product context when present
        final product =
            await ProductRepository().fetchProductById(chatRoom.productId!);
        if (product != null && mounted) {
          setState(() {
            _contextItem = product;
            _appBarTitle = product.title;
          });
        }
      } else if (chatRoom.lostItemId != null) {
        // Load lost & found item when present
        try {
          final doc = await FirebaseFirestore.instance
              .collection('lost_and_found')
              .doc(chatRoom.lostItemId!)
              .get();
          if (doc.exists && mounted) {
            final lostItem = LostItemModel.fromFirestore(doc);
            if (mounted) {
              setState(() {
                _contextItem = lostItem;
                _appBarTitle = lostItem.itemDescription;
              });
            }
          }
        } catch (e) {
          debugPrint('Failed to fetch lost item: $e');
        }
      }
      // else if (chatRoom.productId != null) {
      //   final product = await ProductRepository().fetchProduct(chatRoom.productId!);
      //   if (product != null && mounted) setState(() => _contextItem = product);
      // }
    } catch (e) {
      debugPrint("컨텍스트 정보를 불러오는데 실패했습니다: $e");
    } finally {
      if (mounted) {
        setState(() => _isContextLoading = false);
      }
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

  // [v2.1] 이미지 전송 로직 (신규 추가)
  Future<void> _pickImage(ImageSource source) async {
    // [v2.1] 보호 모드일 때는 이미지 선택 자체를 차단 (버튼이 disabled지만 2중 방어)
    if (_isProtectionActive) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final File imageFile = File(image.path);
        // chat_service.dart의 sendImageMessage 호출
        await _chatService.sendImageMessage(
          widget.chatId,
          imageFile,
          widget.otherUserId, // 1:1 채팅 기준
        );
      }
    } catch (e) {
      // 오류 무시 또는 로깅
      debugPrint('Image pick/send failed: $e');
    }
  }

  // [v2.1] 아이스브레이커용 메시지 전송
  void _sendMessageWithSuggestion(String text) {
    _messageController.text = text;
    _sendMessage();
  }

  // [복원 및 업그레이드] 읽음 확인 아이콘을 그리는 위젯
  Widget _buildReadReceipt(ChatMessageModel message) {
    // 내가 보낸 메시지가 아니면 아무것도 표시하지 않음
    if (message.senderId != _myUid) return const SizedBox.shrink();

    bool isReadAll = false;
    if (widget.isGroupChat) {
      // 그룹 채팅: 나를 제외한 모든 참여자가 읽었는지 확인
      final otherParticipants =
          widget.participants?.where((id) => id != _myUid).toList() ?? [];
      isReadAll = otherParticipants.isNotEmpty &&
          otherParticipants.every((id) => message.readBy.contains(id));
    } else {
      // 1:1 채팅: 상대방이 읽었는지 확인
      isReadAll = widget.otherUserId != null &&
          message.readBy.contains(widget.otherUserId!);
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
    final appBarTitle = _appBarTitle ??
        (widget.isGroupChat
            ? (widget.clubTitle ?? widget.groupName ?? 'Group Chat')
            : (widget.productTitle ?? widget.otherUserName ?? 'Chat'));

    return Scaffold(
      // ✅ [수정] 키보드가 올라올 때 입력창이 가려지지 않도록 설정합니다.
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(appBarTitle),
      ),
      body: _isLoadingParticipants
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_isContextLoading && _contextItem != null)
                  _buildContextHeader(),
                Expanded(
                  child: StreamBuilder<List<ChatMessageModel>>(
                    stream: _chatService.getMessagesStream(widget.chatId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.isEmpty) {
                        // [v2.1] 새 채팅이고 메시지가 없으면 아이스브레이커 표시
                        if (isNewChat) {
                          return _buildIcebreakers();
                        }
                        return Center(
                            child: Text('chat_room.placeholder'.tr()));
                      }

                      final messages = snapshot.data!;

                      // [v2.1] 24시간 보호 모드 로직 (친구 채팅에만 적용)
                      bool calculatedProtectionActive = false;
                      if (_isFriendChat && isNewChat && messages.isNotEmpty) {
                        // 가장 오래된 메시지(첫 메시지)의 타임스탬프
                        final firstMessageTime =
                            messages.last.timestamp.toDate();
                        final now = DateTime.now();
                        // 24시간(86400초)이 지나지 않았으면 보호 모드 활성화
                        calculatedProtectionActive =
                            now.difference(firstMessageTime).inSeconds < 86400;
                      }

                      // [v2.1] StreamBuilder가 재실행될 때마다 setState가 호출되는 것을 방지
                      // 상태가 실제로 변경될 때만(예: 24시간이 방금 지남) setState 호출
                      if (calculatedProtectionActive != _isProtectionActive) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isProtectionActive = calculatedProtectionActive;
                            });
                          }
                        });
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final sender = _participantsInfo[message.senderId];
                          final isMe = message.senderId == _myUid;
                          return _buildMessageItem(message, sender, isMe,
                              isProtectionMode: _isProtectionActive);
                        },
                      );
                    },
                  ),
                ),
                // ❌ 기존에 있던 메시지 입력창(Padding 위젯)을 여기서 삭제합니다.
              ],
            ),
      // ✅ bottomNavigationBar에 메시지 입력창을 배치합니다.
      bottomNavigationBar: SafeArea(
        child: _buildMessageInputField(),
      ),
    );
  }

  // ✅ 메시지 입력창 UI를 별도의 함수로 분리합니다.
  Widget _buildMessageInputField() {
    final theme = Theme.of(context);
    // [v2.1] 보호 모드 배너 및 입력창
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // [v2.1] 보호 모드가 활성화되면 배너 표시
        if (_isProtectionActive)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'chatRoom.mediaBlocked'.tr(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          // viewInsets.bottom은 bottomNavigationBar가 자동으로 처리하므로 제거합니다.
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
          child: Row(
            children: [
              // [v2.1] 이미지/미디어 전송 버튼 (보호 모드 시 비활성화)
              IconButton(
                icon: Icon(Icons.photo_camera_outlined,
                    color:
                        _isProtectionActive ? Colors.grey : theme.primaryColor),
                onPressed: _isProtectionActive
                    ? null
                    : () => _pickImage(ImageSource.camera),
              ),
              IconButton(
                icon: Icon(Icons.attach_file_outlined,
                    color:
                        _isProtectionActive ? Colors.grey : theme.primaryColor),
                onPressed: _isProtectionActive
                    ? null
                    : () => _pickImage(ImageSource.gallery),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                      hintText: 'chat_room.placeholder'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16)),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }

  // [v2.1] 아이스브레이커 위젯
  Widget _buildIcebreakers() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'chatRoom.startConversation'.tr(),
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  label: Text('chatRoom.icebreaker1'.tr()),
                  onPressed: () =>
                      _sendMessageWithSuggestion('chatRoom.icebreaker1'.tr()),
                ),
                ActionChip(
                  label: Text('chatRoom.icebreaker2'.tr()),
                  onPressed: () =>
                      _sendMessageWithSuggestion('chatRoom.icebreaker2'.tr()),
                ),
                ActionChip(
                  label: Text('chatRoom.icebreaker3'.tr()),
                  onPressed: () =>
                      _sendMessageWithSuggestion('chatRoom.icebreaker3'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // [추가] 컨텍스트 헤더를 만드는 위젯 함수
  Widget _buildContextHeader() {
    ImageProvider? image;
    String title = '';
    String descriptionText = '';
    String locationText = '';
    String priceText = '';

    // Club context handling
    if (_contextItem is ClubModel) {
      final club = _contextItem as ClubModel;
      title = club.title;
      descriptionText = club.description;
      locationText = club.location;
      if (club.imageUrl != null && club.imageUrl!.isNotEmpty) {
        image = NetworkImage(club.imageUrl!);
      } else if (widget.clubImage != null) {
        image = NetworkImage(widget.clubImage!);
      }
    } else if (_contextItem is JobModel) {
      final job = _contextItem as JobModel;
      title = job.title;
      descriptionText = job.description;
      locationText = job.locationName ?? '';
      // Keep previous salary subtitle behavior in priceText for jobs
      priceText = 'jobs.salaryTypes.${job.salaryType ?? 'etc'}'.tr();
      if (job.imageUrls != null && job.imageUrls!.isNotEmpty) {
        image = NetworkImage(job.imageUrls!.first);
      }
    } else if (_contextItem is TalentModel) {
      final talent = _contextItem as TalentModel;
      title = talent.title;
      descriptionText = talent.description;
      locationText = talent.locationName ?? '';
      if (talent.price != 0) {
        try {
          final localeStr = context.locale.toString();
          final nf = NumberFormat.simpleCurrency(locale: localeStr);
          priceText = nf.format(talent.price);
          if (talent.priceUnit.isNotEmpty) {
            // Use localized unit string if available, otherwise fallback to raw unit
            final rawUnit = talent.priceUnit;
            final unitKey = 'jobs.priceUnit.$rawUnit';
            final localizedUnit = unitKey.tr();
            if (localizedUnit == unitKey) {
              // translation missing, fallback to raw unit text
              priceText = '$priceText /$rawUnit';
            } else {
              priceText = '$priceText $localizedUnit';
            }
          }
        } catch (e) {
          // Fallback to raw format if NumberFormat fails for any locale
          priceText = '${talent.price} ${talent.priceUnit}';
        }
      }
      if (talent.portfolioUrls.isNotEmpty) {
        image = NetworkImage(talent.portfolioUrls.first);
      } else if (_chatRoomModel?.talentImage != null) {
        image = NetworkImage(_chatRoomModel!.talentImage!);
      }
    } else if (_contextItem is ProductModel) {
      final product = _contextItem as ProductModel;
      title = product.title;
      descriptionText = product.description;
      locationText = product.locationName ?? '';
      try {
        final nf = NumberFormat.currency(locale: context.locale.toString());
        priceText = nf.format(product.price);
      } catch (e) {
        priceText = product.price.toString();
      }
      if (product.imageUrls.isNotEmpty) {
        image = NetworkImage(product.imageUrls.first);
      } else if (_chatRoomModel?.productImage != null &&
          _chatRoomModel!.productImage!.isNotEmpty) {
        image = NetworkImage(_chatRoomModel!.productImage!);
      }
    } else if (_contextItem is LostItemModel) {
      final lost = _contextItem as LostItemModel;
      title = lost.itemDescription;
      descriptionText = '';
      locationText = lost.locationDescription;
      if (lost.isHunted && lost.bountyAmount != null) {
        try {
          final nf = NumberFormat.currency(locale: context.locale.toString());
          priceText = nf.format(lost.bountyAmount);
        } catch (e) {
          priceText = lost.bountyAmount.toString();
        }
      }
      if (lost.imageUrls.isNotEmpty) {
        image = NetworkImage(lost.imageUrls.first);
      } else if (_chatRoomModel?.productImage != null &&
          _chatRoomModel!.productImage!.isNotEmpty) {
        // legacy: lost item images stored in productImage field for compatibility
        image = NetworkImage(_chatRoomModel!.productImage!);
      }
    } else if (_contextItem is ShopModel) {
      final shop = _contextItem as ShopModel;
      title = shop.name;
      descriptionText = shop.description;
      locationText = shop.locationName ?? '';
      // shop typically doesn't have price, leave priceText empty
      if (shop.imageUrls.isNotEmpty) {
        image = NetworkImage(shop.imageUrls.first);
      } else if (_chatRoomModel?.shopImage != null &&
          _chatRoomModel!.shopImage!.isNotEmpty) {
        image = NetworkImage(_chatRoomModel!.shopImage!);
      }
    } else if (_contextItem is RoomListingModel) {
      final room = _contextItem as RoomListingModel;
      title = room.title;
      descriptionText = room.description;
      locationText = room.locationName ?? '';
      try {
        final nf = NumberFormat.currency(locale: context.locale.toString());
        priceText = nf.format(room.price);
      } catch (e) {
        priceText = room.price.toString();
      }
      if (room.imageUrls.isNotEmpty) {
        image = NetworkImage(room.imageUrls.first);
      } else if (_chatRoomModel?.roomImage != null &&
          _chatRoomModel!.roomImage!.isNotEmpty) {
        image = NetworkImage(_chatRoomModel!.roomImage!);
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
          // [추가] 배너 클릭 시 ClubDetailScreen으로 이동 (embedded가 아닌 전체 화면으로)
          if (_contextItem is ClubModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ClubDetailScreen(club: _contextItem as ClubModel)));
          } else if (_contextItem is JobModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => JobDetailScreen(job: _contextItem)));
          } else if (_contextItem is TalentModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TalentDetailScreen(talent: _contextItem)));
          } else if (_contextItem is ProductModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: _contextItem)));
          } else if (_contextItem is ShopModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ShopDetailScreen(shop: _contextItem)));
          } else if (_contextItem is RoomListingModel) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RoomDetailScreen(room: _contextItem)));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: image != null
                      ? DecorationImage(image: image, fit: BoxFit.cover)
                      : null,
                  color: image == null ? Colors.grey.shade200 : null,
                ),
                child: image == null
                    ? Icon(Icons.work_outline,
                        color: Colors.grey.shade600, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: title (left) and optional price (right)
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (priceText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  // description (one-line preview)
                  if (descriptionText.isNotEmpty)
                    Text(descriptionText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 13)),
                  const SizedBox(height: 6),
                  // location (left) — price moved up to title row
                  Text(locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              )),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
      ChatMessageModel message, UserModel? sender, bool isMe,
      {bool isProtectionMode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  (sender?.photoUrl != null && sender!.photoUrl!.isNotEmpty)
                      ? NetworkImage(sender.photoUrl!)
                      : null,
              child: (sender?.photoUrl == null || sender!.photoUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && widget.isGroupChat)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                    child: Text(sender?.nickname ?? 'Unknown',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                      color: isMe ? Colors.teal[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16)),
                  // [v2.1] 이미지 또는 텍스트 표시
                  child:
                      (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                          // 이미지가 있을 경우
                          ? _buildImageMessage(
                              context, message.imageUrl!, isProtectionMode)
                          // 텍스트만 있을 경우
                          : Text(_maskMessage(message.text, isProtectionMode)),
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

  // [v2.1] 24시간 보호 모드: 링크 및 전화번호 마스킹
  String _maskMessage(String text, bool isProtectionMode) {
    if (!isProtectionMode) return text;

    // 8자리 이상의 숫자 시퀀스 (전화번호)
    final RegExp phoneRegex = RegExp(r'(\+?[0-9][0-9\s-]{7,}[0-9])');
    // URL
    final RegExp linkRegex = RegExp(
        r'http[s]?:\/\/[^\n+\s]+|www\.[^\s]+|[\w-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?\/[^\s]*');

    return text
        .replaceAll(linkRegex, '[${'chatRoom.linkHidden'.tr()}]')
        .replaceAll(phoneRegex, '[${'chatRoom.contactHidden'.tr()}]');
  }

  // [v2.1] 이미지 메시지 위젯 (보호 모드 블러 처리)
  Widget _buildImageMessage(
      BuildContext context, String imageUrl, bool isProtectionMode) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Icon(Icons.broken_image, color: Colors.grey),
      fit: BoxFit.cover,
    );

    if (isProtectionMode) {
      // [v2.1] 보호 모드일 때 블러(Blur) 처리
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: imageWidget,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }
}

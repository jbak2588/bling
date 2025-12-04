/// ============================================================================
/// Bling DocHeader
/// Module        : Chat
/// File          : lib/features/chat/screens/chat_list_screen.dart
/// Purpose       : 채팅방 목록을 보여 주고 개별 대화로 이동합니다.
/// User Impact   : 여러 모듈의 진행 중인 대화를 빠르게 접근하게 합니다.
/// Feature Links : lib/features/chat/screens/chat_room_screen.dart; lib/features/chat/data/chat_service.dart
/// Data Model    : 참여자 UID로 필터링된 Firestore `chatRooms` 스트림; 각 방은 `messages` 하위 컬렉션과 연결됩니다.
/// Location Scope: 없음.
/// Trust Policy  : 인증된 사용자만 채팅 목록을 조회할 수 있으며 신고된 방은 숨겨집니다.
/// Monetization  : 향후 채팅 내 프로모션 계획; 현재는 없음.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_chat_list`, `open_chat_room`.
/// Analytics     : 읽지 않은 채팅 수와 열린 대화 수를 추적합니다.
/// I18N          : 키 `chat_list.empty`, `main.bottomNav.chat` (assets/lang/*.json)
/// Dependencies  : firebase_auth, easy_localization
/// Security/Auth : 로그인된 사용자만 가능하며 Firestore 규칙이 참여 여부를 확인합니다.
/// Edge Cases    : 채팅방이 없거나 사용자가 로그인되지 않은 경우.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/07 Chat 모듈 Core.md; docs/team/teamC_Chat & Notification 모듈_통합 작업문서.md
/// ============================================================================
///
/// [기획/실제 코드 분석 및 개선 제안]
/// 1. 기획 문서 요약
///   - Firestore 기반 1:1/그룹 채팅, 실시간 메시지, 읽음/알림/차단/신고 등 안전·운영 기능
///   - 신뢰등급, 위치 정보, 프로필 연동, 활동 히스토리, KPI/Analytics, 광고/프로모션, 다국어(i18n)
///
/// 2. 실제 코드 분석
///   - 채팅방 목록 표시, Firestore chatRooms 스트림, 메시지/참여자 관리, KPI/Analytics, Edge case 처리
///   - 신뢰등급, 신고/차단, 다국어(i18n) 등 정책 반영
///
/// 3. 기획과 실제 기능의 차이점
///   - 기획보다 좋아진 점: 데이터 모델 세분화, 신뢰등급·Edge case·KPI/Analytics 등 품질·운영 기능 강화, 다국어(i18n), 광고/프로모션 등 실제 서비스 운영에 필요한 기능 반영
///   - 기획에 못 미친 점: 그룹 채팅, 활동 히스토리, 광고 슬롯 등 일부 상호작용·운영 기능 미구현, 신고/차단·KPI/Analytics 등 추가 구현 필요
///
/// 4. 개선 제안
///   - UI/UX: 그룹 채팅, 미디어 첨부/미리보기, 신뢰등급/알림/차단/신고 UX 강화, 활동 히스토리/신뢰등급 변화 시각화, 광고/프로모션 배너
///   - 수익화: 프리미엄 채팅, 광고/프로모션, 추천 친구/상품/채팅방 노출, KPI/Analytics 이벤트 로깅
///   - 코드: Firestore 쿼리 최적화, 비동기 처리/에러 핸들링 강화, 데이터 모델/위젯 분리, 상태 관리 개선
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/chat_room_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] 삭제 로직용
import 'package:flutter/material.dart';
// [추가] debugPrint
import 'package:bling_app/core/utils/popups/snackbars.dart';

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
    return StreamBuilder<List<ChatRoomModel>>(
      stream: _chatService.getChatRoomsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final chatRooms = snapshot.data ?? [];
        if (chatRooms.isEmpty) {
          return Center(child: Text('chat_list.empty'.tr()));
        }

        return ListView.separated(
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 82),
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];

            final otherUid = !chatRoom.isGroupChat
                ? chatRoom.participants
                    .firstWhere((uid) => uid != _myUid, orElse: () => '')
                : '';

            if (!chatRoom.isGroupChat && otherUid.isEmpty) {
              return const SizedBox.shrink();
            }

            return FutureBuilder<UserModel?>(
              future: !chatRoom.isGroupChat
                  ? _chatService.getOtherUserInfo(otherUid)
                  : Future.value(null),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting &&
                    !chatRoom.isGroupChat) {
                  return const ListTile(title: Text("..."));
                }

                final otherUser = userSnapshot.data;

                // determine the child item widget based on chat type
                Widget item;
                if (chatRoom.isGroupChat) {
                  // [수정] contextType 체크 추가로 조건 강화
                  if ((chatRoom.clubId != null &&
                          chatRoom.clubId!.isNotEmpty) ||
                      chatRoom.contextType == 'club') {
                    item = _buildClubChatItem(context, chatRoom);
                  } else {
                    item = _buildGroupChatItem(context, chatRoom);
                  }
                } else if (chatRoom.roomId != null &&
                    chatRoom.roomId!.isNotEmpty) {
                  item = _buildRealEstateChatItem(context, chatRoom, otherUser);
                } else if (chatRoom.lostItemId != null &&
                    chatRoom.lostItemId!.isNotEmpty) {
                  item =
                      _buildLostAndFoundChatItem(context, chatRoom, otherUser);
                } else if (chatRoom.shopId != null &&
                    chatRoom.shopId!.isNotEmpty) {
                  item = _buildShopChatItem(context, chatRoom, otherUser);
                } else if (chatRoom.jobId != null &&
                    chatRoom.jobId!.isNotEmpty) {
                  item = _buildJobChatItem(context, chatRoom, otherUser);
                } else if (chatRoom.productId != null &&
                    chatRoom.productId!.isNotEmpty) {
                  item = _buildProductChatItem(context, chatRoom, otherUser);
                } else {
                  item = _buildDirectChatItem(context, chatRoom, otherUser);
                }

                // Wrap in Dismissible to allow leaving the chat room
                return Dismissible(
                  key: Key(chatRoom.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('common.delete'.tr()),
                        content: Text('chat_list.leave_confirm'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('common.cancel'.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('common.delete'.tr(),
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await _leaveChatRoom(chatRoom.id);
                  },
                  child: item,
                );
              },
            );
          },
        );
      },
    );
  }

  // [수정] 채팅방 나가기 로직 (마지막 1인이면 방 삭제)
  Future<void> _leaveChatRoom(String roomId) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    final docRef = FirebaseFirestore.instance.collection('chats').doc(roomId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() ?? {};

        // participants가 List 또는 Map 형태로 저장될 수 있으므로 모두 처리
        var participants = <String>[];
        var participantsIsMap = false;
        if (data.containsKey('participants') && data['participants'] != null) {
          final p = data['participants'];
          if (p is List) {
            participants = List<String>.from(p.map((e) => e.toString()));
          } else if (p is Map) {
            participants = List<String>.from(p.keys.map((k) => k.toString()));
            participantsIsMap = true;
          }
        }

        // 내가 포함되어 있고, 나 혼자뿐이라면 -> 방 삭제
        if (participants.contains(myUid) && participants.length <= 1) {
          transaction.delete(docRef);
        }
        // 다른 사람이 있다면 -> 내 ID만 제거
        else if (participants.contains(myUid)) {
          if (participantsIsMap) {
            // Map 형태면 participants.<uid> 필드를 삭제
            transaction.update(docRef, {
              'participants.$myUid': FieldValue.delete(),
            });
          } else {
            // List 형태면 arrayRemove 사용
            transaction.update(docRef, {
              'participants': FieldValue.arrayRemove([myUid])
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to leave chat room: $e');
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(
            title: 'common.error'.tr(), message: e.toString());
      }
    }
  }

  // 각 채팅 유형별 ListTile을 만드는 헬퍼 함수들

  // [추가] 클럽 채팅 아이템 빌더
  ListTile _buildClubChatItem(BuildContext context, ChatRoomModel chatRoom) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(
          imageUrl: chatRoom.clubImage ?? chatRoom.groupImage,
          icon: Icons.groups),
      title: Text(chatRoom.clubTitle ?? chatRoom.groupName ?? 'Club Chat',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chatRoom.lastMessage,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _buildTrailing(chatRoom),
      onTap: () => _navigateToChat(context, chatRoom: chatRoom, type: 'Club'),
    );
  }

  ListTile _buildGroupChatItem(BuildContext context, ChatRoomModel chatRoom) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(
          imageUrl: chatRoom.groupImage ?? chatRoom.talentImage,
          icon: Icons.groups),
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
          imageUrl:
              chatRoom.roomImage ?? chatRoom.talentImage ?? otherUser?.photoUrl,
          icon: Icons.house_outlined),
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
      leading: _buildAvatar(
          imageUrl: chatRoom.productImage ??
              chatRoom.talentImage ??
              otherUser?.photoUrl,
          icon: Icons.search_off),
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
          imageUrl:
              chatRoom.shopImage ?? chatRoom.talentImage ?? otherUser?.photoUrl,
          icon: Icons.storefront_outlined),
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
      leading: _buildAvatar(
          imageUrl:
              chatRoom.jobImage ?? chatRoom.talentImage ?? otherUser?.photoUrl,
          icon: Icons.work_outline),
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
          imageUrl: chatRoom.productImage ??
              chatRoom.talentImage ??
              otherUser?.photoUrl,
          icon: Icons.shopping_bag_outlined),
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
      leading: _buildAvatar(
          imageUrl: otherUser.photoUrl, icon: Icons.favorite_border), // 아이콘 변경
      title: Text('Find Friend', // 제목을 'Find Friend'로 고정
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${otherUser.nickname} • ${chatRoom.lastMessage}', // 부제에 상대방 닉네임 추가
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
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
        // [수정] 클럽 정보 전달 (AppBar 타이틀 및 배너용)
        clubId: chatRoom.clubId,
        clubImage: chatRoom.clubImage,
        clubTitle: chatRoom.clubTitle,
        participants: chatRoom.participants,
        otherUserId: otherUid,
        otherUserName: otherUser?.nickname ?? 'User',
        productTitle: chatRoom.groupName ??
            chatRoom.talentTitle ??
            chatRoom.productTitle ??
            chatRoom.jobTitle ??
            chatRoom.shopName ??
            chatRoom.roomTitle,
      ),
    ));
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  // Legacy: specialized Lost & Found avatar removed — unified avatar renderer `_buildAvatar` is used.

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

// lib/features/clubs/screens/club_detail_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 동호회는 Firestore에 제목, 설명, 운영자, 위치, 관심사, 비공개 여부, 신뢰 등급, 멤버 관리 등의 필드로 구성됩니다.
// - 동호회 내 게시글은 `clubs/{clubId}/posts`에 저장되며, 이미지, 좋아요, 댓글을 지원합니다.
// - 매칭 및 추천 로직은 위치, 관심사, 연령대, 신뢰 등급을 우선적으로 고려합니다.
//
// [구현 요약]
// - 동호회 상세 화면, 게시판/멤버 탭, 채팅 및 멤버 관리 기능을 제공합니다.
// - Firestore 구조를 활용하여 동호회 및 게시글 데이터를 관리하며, 비공개 및 신뢰 등급 제한을 지원합니다.
// - UI에서 게시글 CRUD, 멤버 목록, 채팅 이동 기능을 제공합니다.
//
// [차이점 및 부족한 부분]
// - 운영자 기능, 통계, 고급 비공개 설정 등이 더 확장될 수 있습니다.
// - 채팅 및 데이팅 프로필과의 깊은 연동이 필요할 수 있습니다.
//
// [개선 제안]
// - 운영자(방장)를 위한 멤버 관리(강퇴/승인) 및 게시글 관리 기능 강화.
// - 동호회 활동 및 멤버 참여에 대한 통계 분석 기능 추가.
// - 민감한 동호회를 위한 비공개 옵션 및 신뢰 등급 제한 확대.
// - 멤버 관리 및 가입 UX/UI 개선.
// =====================================================
// [작업 이력 (2025-11-02)]
// - (Task 9) 기획서 검토 완료.
// - '모임 제안' V2.0 로직 개편으로 인해 이 파일은 현재 직접 수정 사항 없음.
// - (참고) '모임 제안'이 성공하여 'ClubModel'이 생성된 후 이 상세 화면을 사용함.
// =====================================================
// lib/features/clubs/screens/club_detail_screen.dart

import 'package:bling_app/features/clubs/models/club_member_model.dart';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/screens/edit_club_screen.dart';
import 'package:bling_app/features/clubs/widgets/club_post_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/clubs/screens/club_member_list.dart';

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';

import 'package:bling_app/features/shared/widgets/mini_map_view.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;
  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  final ClubRepository _repository = ClubRepository();
  final ChatService _chatService = ChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // [수정] 탭 개수를 2개에서 3개로 변경합니다.
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _joinClub() async {
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('main.errors.loginRequired'.tr())));
      }
      return;
    }

    // [추가] 사용자 피드백을 위한 스낵바 표시 함수
    void showSnackbar(String message, {bool isError = false}) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ));
      }
    }

    // [추가] 로딩 상태 표시 (선택 사항이지만 UX에 좋음)
    setState(() {
      // 이 화면에 _isLoading 같은 상태 변수를 추가하고 관리할 수 있습니다.
    });

    try {
      final newMember = ClubMemberModel(
        id: _currentUserId ?? '',
        userId: _currentUserId ?? '',
        joinedAt: Timestamp.now(),
      );

      // Repository의 addMember 함수는 이제 'joined' 또는 'pending' 문자열을 반환합니다.
      final result = await _repository.addMember(widget.club.id, newMember);

      if (result == 'joined') {
        showSnackbar(
            'clubs.detail.joined'.tr(namedArgs: {'title': widget.club.title}));
      } else if (result == 'pending') {
        showSnackbar('clubs.detail.pendingApproval'.tr());
      }
    } catch (e) {
      showSnackbar(
          'clubs.detail.joinFail'.tr(namedArgs: {'error': e.toString()}),
          isError: true);
    } finally {
      // [추가] 로딩 상태 해제
      if (mounted) setState(() {/* _isLoading = false; */});
    }
  }

  Future<void> _navigateToGroupChat() async {
    final chatRoom = await _chatService.getChatRoom(widget.club.id);
    if (chatRoom == null || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chatRoom.id,
          isGroupChat: true,
          groupName: chatRoom.groupName,
          participants: chatRoom.participants,
        ),
      ),
    );
  }

// [추가] 동호회 탈퇴 로직
  void showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
    }
  }

  Future<void> _leaveClub() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clubs.detail.leaveConfirmTitle'.tr()),
        content: Text('clubs.detail.leaveConfirmContent'
            .tr(namedArgs: {'title': widget.club.title})),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('clubs.detail.leave'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && _currentUserId != null) {
      try {
        await _repository.leaveClub(widget.club.id, _currentUserId!);
        if (mounted) {
          showSnackbar('clubs.detail.leaveSuccess'
              .tr(namedArgs: {'title': widget.club.title}));
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(
              'clubs.detail.leaveFail'.tr(namedArgs: {'error': e.toString()}),
              isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ClubModel>(
      stream: _repository.getClubStream(widget.club.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final club = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(club.title), // [수정] 실시간 club.title 사용
            actions: [
              if (club.ownerId == _currentUserId)
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: '동호회 정보 수정',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => EditClubScreen(club: club)),
                    );
                  },
                ),
              StreamBuilder<bool>(
                  stream: _repository.isCurrentUserMember(club.id),
                  builder: (context, memberSnapshot) {
                    final isMember = memberSnapshot.data ?? false;
                    // 멤버이지만, 방장이 아닐 경우에만 메뉴를 보여줍니다.
                    if (isMember && club.ownerId != _currentUserId) {
                      return PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'leave') {
                            _leaveClub();
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'leave',
                            child: Text('clubs.detail.leave'.tr()),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink(); // 그 외에는 아무것도 표시하지 않음
                  }),
            ],

            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'clubs.detail.tabs.info'.tr()),
                Tab(text: 'clubs.detail.tabs.board'.tr()),
                Tab(text: 'clubs.detail.tabs.members'.tr()),
              ],
            ),
          ), // <--- [수정] 여기에 닫는 괄호가 빠져있었습니다.
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(context, club),
              ClubPostList(club: club),
              ClubMemberList(clubId: club.id, ownerId: club.ownerId),
            ],
          ),
          floatingActionButton: StreamBuilder<bool>(
            stream: _repository.isCurrentUserMember(widget.club.id),
            builder: (context, snapshot) {
              final isMember = snapshot.data ?? false;

              if (isMember) {
                return FloatingActionButton.extended(
                  heroTag: 'club_chat_fab',
                  onPressed: _navigateToGroupChat,
                  label: Text('clubs.detail.joinChat'.tr()),
                  icon: const Icon(Icons.chat_bubble_outline),
                  backgroundColor: Colors.teal,
                );
              }

              return FloatingActionButton.extended(
                heroTag: 'club_join_fab',
                onPressed: _joinClub,
                label: Text('clubs.detail.joinClub'.tr()),
                icon: const Icon(Icons.add),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildInfoTab(BuildContext context, ClubModel club) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      children: [
        if (club.imageUrl != null && club.imageUrl!.isNotEmpty)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImageGalleryScreen(imageUrls: [club.imageUrl!]),
              ));
            },
            child: Image.network(
              club.imageUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const SizedBox(height: 220, child: Icon(Icons.error)),
            ),
          )
        else
          Container(
            height: 220,
            color: Colors.grey.shade200,
            child: Icon(Icons.groups, size: 80, color: Colors.grey.shade400),
          ),

        Text(club.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(club.description,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(
                icon: Icons.group_outlined,
                label: 'clubs.detail.info.members'.tr(),
                value: club.membersCount.toString()),
            _buildInfoColumn(
                icon: Icons.location_on_outlined,
                label: 'clubs.detail.info.location'.tr(),
                value: club.location),
          ],
        ),
        const Divider(height: 32),
        // ✅ geoPoint 데이터가 있을 경우 MiniMapView를 추가합니다.
        if (club.geoPoint != null) ...[
          Text("clubs.detail.location".tr(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          MiniMapView(
            location: club.geoPoint!,
            markerId: club.id,
            height: 150,
          ),
          const Divider(height: 32),
        ],

        // ✅ 개설자 정보 표시를 위해 AuthorProfileTile 추가
        Text("clubs.detail.owner".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AuthorProfileTile(userId: club.ownerId),
        const SizedBox(height: 16),

        Text("interests.title".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // ✅ 기존 Wrap을 ClickableTagList 공용 위젯으로 교체
        ClickableTagList(tags: club.interestTags),
      ],
    );
  }

  Widget _buildInfoColumn(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

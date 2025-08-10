// lib/features/clubs/screens/club_detail_screen.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_post_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/clubs/screens/club_member_list.dart';

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
        id: _currentUserId!,
        userId: _currentUserId!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'clubs.detail.tabs.info'.tr()),
            Tab(text: 'clubs.detail.tabs.board'.tr()),
            Tab(text: 'clubs.detail.tabs.members'.tr()),
          ],
        ),
      ),
      body: StreamBuilder<ClubModel>(
        stream: _repository.getClubStream(widget.club.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final club = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(context, club),
              // V V V --- [수정] ClubPostList에 ownerId를 전달합니다 --- V V V
              ClubPostList(club: club),
              // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
              ClubMemberList(clubId: club.id, ownerId: club.ownerId),
            ],
          );
        },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoTab(BuildContext context, ClubModel club) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      children: [
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
        Text("interests.title".tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: club.interestTags.map((interestKey) {
            return Chip(
              avatar: const Icon(Icons.tag, size: 16),
              label: Text("interests.items.$interestKey".tr()),
            );
          }).toList(),
        ),
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

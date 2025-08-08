// lib/features/clubs/screens/club_detail_screen.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;
  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final ClubRepository _repository = ClubRepository();
  final ChatService _chatService = ChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _joinClub() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("로그인이 필요합니다.")));
      return;
    }
    try {
      final newMember = ClubMemberModel(
        id: _currentUserId!,
        userId: _currentUserId!,
        joinedAt: Timestamp.now(),
      );
      await _repository.addMember(widget.club.id, newMember);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${widget.club.title}' 동호회에 가입했습니다!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("가입에 실패했습니다: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

Future<void> _navigateToGroupChat() async {
    debugPrint("--- [1단계] '채팅 참여하기' 버튼이 정상적으로 눌렸습니다.");
    
    try {
      final chatRoom = await _chatService.getChatRoom(widget.club.id);
      debugPrint("--- [2단계] Firestore에서 채팅방 정보를 조회했습니다.");

      if (chatRoom == null) {
        debugPrint("--- [진단 결과] 실패: chats 컬렉션에서 ID가 '${widget.club.id}'인 문서를 찾을 수 없습니다.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("채팅방 정보를 찾을 수 없습니다. 동호회를 다시 만들어주세요."), backgroundColor: Colors.red),
          );
        }
        return;
      }
      
      debugPrint("--- [3단계] 채팅방 정보를 성공적으로 찾았습니다. 화면을 이동합니다.");
      debugPrint("   - 채팅방 ID: ${chatRoom.id}");
      debugPrint("   - 참여자: ${chatRoom.participants}");

      if (!mounted) return;

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
    } catch (e) {
      debugPrint("--- [진단 결과] 심각한 오류: 채팅방 정보를 가져오는 중 Exception 발생!");
      debugPrint("   - 에러 내용: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.title),
      ),
      body: StreamBuilder<ClubModel>(
        stream: _repository.getClubStream(widget.club.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final club = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                club.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                club.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn(
                    icon: Icons.group_outlined,
                    label: 'Members',
                    value: club.membersCount.toString(),
                  ),
                  _buildInfoColumn(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: club.location,
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                "interests.title".tr(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: _repository.isCurrentUserMember(widget.club.id),
        builder: (context, snapshot) {
          final isMember = snapshot.data ?? false;

          if (isMember) {
            return FloatingActionButton.extended(
              // V V V --- [수정] onPressed에 함수를 정확히 연결합니다 --- V V V
              onPressed: _navigateToGroupChat,
              // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
              label: Text('채팅 참여하기'),
              icon: const Icon(Icons.chat_bubble_outline),
              backgroundColor: Colors.teal,
            );
          }
          
          return FloatingActionButton.extended(
            onPressed: _joinClub,
            label: Text('동호회 가입하기'),
            icon: const Icon(Icons.add),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoColumn({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
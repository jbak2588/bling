// lib/features/lost_and_found/screens/lost_item_detail_screen.dart

import 'package:bling_app/core/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/screens/edit_lost_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class LostItemDetailScreen extends StatefulWidget {
  final LostItemModel item;
  const LostItemDetailScreen({super.key, required this.item});

  @override
  State<LostItemDetailScreen> createState() => _LostItemDetailScreenState();
}

class _LostItemDetailScreenState extends State<LostItemDetailScreen> {
  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ChatService _chatService = ChatService();

  void _startChat(BuildContext context) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        otherUserId: widget.item.userId,
        lostItemId: widget.item.id,
        lostItemTitle: widget.item.itemDescription,
        lostItemImage: widget.item.imageUrls.isNotEmpty ? widget.item.imageUrls.first : null,
        contextType: widget.item.type,
      );
      
      final otherUser = await _chatService.getOtherUserInfo(widget.item.userId);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: widget.item.itemDescription,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅을 시작할 수 없습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // [추가] 게시글 삭제 로직
  Future<void> _deleteItem() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('게시글 삭제'), // TODO: 다국어
        content: Text('정말로 이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'), // TODO: 다국어
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteItem(widget.item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게시글이 삭제되었습니다.'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제에 실패했습니다: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = widget.item.userId == currentUserId;
    final Color typeColor = widget.item.type == 'lost' ? Colors.redAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('lostAndFound.detail.title'.tr()),
        // V V V --- [추가] 작성자에게만 보이는 수정/삭제 버튼 --- V V V
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: '수정하기', // TODO: 다국어
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditLostItemScreen(item: widget.item)),
                ).then((_) => setState(() {})); // 수정 후 돌아왔을 때 화면 갱신
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '삭제하기', // TODO: 다국어
              onPressed: _deleteItem,
            ),
        ],
        // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        children: [
          if (widget.item.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.item.imageUrls.first,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Chip(
            label: Text(widget.item.type == 'lost' ? 'lostAndFound.lost'.tr() : 'lostAndFound.found'.tr()),
            backgroundColor: typeColor.withOpacity(0.1),
            labelStyle: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
            side: BorderSide(color: typeColor),
          ),
          const SizedBox(height: 8),
          Text(widget.item.itemDescription, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          _buildInfoRow(context, Icons.location_on_outlined, 'lostAndFound.detail.location'.tr(), widget.item.locationDescription),
          const Divider(height: 32),
          Text('lostAndFound.detail.registrant'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildOwnerInfo(widget.item.userId),
        ],
      ),
      // [수정] 작성자에게는 '연락하기' 버튼이 보이지 않도록 처리
      bottomNavigationBar: isOwner
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _startChat(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('lostAndFound.detail.contact'.tr()),
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 2),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOwnerInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(title: Text('사용자 정보 없음'));
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return Card(
          elevation: 0,
          color: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
            ),
            title: Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.locationName ?? ''),
          ),
        );
      },
    );
  }
}
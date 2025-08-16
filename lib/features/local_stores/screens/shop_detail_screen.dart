// lib/features/local_stores/screens/shop_detail_screen.dart

import 'package:bling_app/core/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/screens/edit_shop_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final ShopRepository _repository = ShopRepository();
  final ChatService _chatService = ChatService();

  void _startChat(BuildContext context) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        otherUserId: widget.shop.ownerId,
        shopId: widget.shop.id,
        shopName: widget.shop.name,
        shopImage: widget.shop.imageUrl,
      );

      final otherUser =
          await _chatService.getOtherUserInfo(widget.shop.ownerId);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: widget.shop.name,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('localStores.detail.startChatFail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // [추가] 상점 삭제 로직
  Future<void> _deleteShop() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('localStores.detail.deleteTitle'.tr()),
        content: Text('localStores.detail.deleteContent'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('localStores.detail.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('localStores.detail.delete'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteShop(widget.shop.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('localStores.detail.deleteSuccess'.tr()),
              backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('localStores.detail.deleteFail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = widget.shop.ownerId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.name),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: 'localStores.edit.tooltip'.tr(),
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                          builder: (_) => EditShopScreen(shop: widget.shop)),
                    )
                    .then((_) => setState(() {}));
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'localStores.detail.deleteTooltip'.tr(),
              onPressed: _deleteShop,
            ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // 하단 버튼과의 여백
        children: [
          if (widget.shop.imageUrl != null && widget.shop.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.shop.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(widget.shop.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.location_on_outlined,
              widget.shop.locationName ?? 'localStores.noLocation'.tr()),
          const SizedBox(height: 4),
          _buildInfoRow(
              context, Icons.watch_later_outlined, widget.shop.openHours),
          const SizedBox(height: 4),
          _buildInfoRow(
              context, Icons.phone_outlined, widget.shop.contactNumber),
          const Divider(height: 32),
          Text('localStores.detail.description'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(widget.shop.description,
              style: const TextStyle(fontSize: 16, height: 1.5)),
          const Divider(height: 32),
          _buildOwnerInfo(widget.shop.ownerId),
        ],
      ),
      bottomNavigationBar: isOwner
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _startChat(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('localStores.detail.inquire'.tr()),
              ),
            ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildOwnerInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(title: Text('localStores.detail.noOwnerInfo'.tr()));
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return Card(
          elevation: 0,
          color: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.locationName ?? ''),
          ),
        );
      },
    );
  }
}

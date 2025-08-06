// lib/features/my_bling/screens/blocked_users_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final FindFriendRepository _repository = FindFriendRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // 차단 해제 확인 대화상자 및 로직
  Future<void> _showUnblockConfirmationDialog(String blockedUserId, String nickname) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$nickname 님을 차단 해제할까요?'), // TODO: 다국어
          content: Text('차단을 해제하면 상대방이 회원님을 다시 찾을 수 있게 되며, 친구 요청을 보낼 수 있습니다.'), // TODO: 다국어
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('취소'), // TODO: 다국어
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('차단 해제', style: TextStyle(color: Colors.red)), // TODO: 다국어
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.unblockUser(_currentUserId!, blockedUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nickname 님의 차단을 해제했습니다.'), backgroundColor: Colors.green), // TODO: 다국어
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차단 해제에 실패했습니다: $e'), backgroundColor: Colors.red), // TODO: 다국어
        );
      }
    }
  }

  // 차단된 사용자의 상세 정보를 가져오는 함수
  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Error fetching user data for $userId: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text('로그인이 필요합니다.'))); // TODO: 다국어
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('차단 사용자 관리'), // TODO: 다국어
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentUser = UserModel.fromFirestore(snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
          final blockedUids = currentUser.blockedUsers ?? [];

          if (blockedUids.isEmpty) {
            return Center(child: Text('차단한 사용자가 없습니다.')); // TODO: 다국어
          }

          return ListView.builder(
            itemCount: blockedUids.length,
            itemBuilder: (context, index) {
              final blockedUserId = blockedUids[index];
              return FutureBuilder<UserModel?>(
                future: _getUserData(blockedUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('...'));
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text('알 수 없는 사용자'),
                      subtitle: Text(blockedUserId),
                    );
                  }

                  final blockedUser = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (blockedUser.photoUrl != null && blockedUser.photoUrl!.isNotEmpty)
                          ? NetworkImage(blockedUser.photoUrl!)
                          : null,
                       child: (blockedUser.photoUrl == null || blockedUser.photoUrl!.isEmpty)
                           ? const Icon(Icons.person)
                           : null,
                    ),
                    title: Text(blockedUser.nickname),
                    trailing: OutlinedButton(
                      onPressed: () => _showUnblockConfirmationDialog(blockedUser.uid, blockedUser.nickname),
                      child: Text('차단 해제'), // TODO: 다국어
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
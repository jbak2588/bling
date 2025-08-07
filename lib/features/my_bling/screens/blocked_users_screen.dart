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

  // [수정] '차단 해제'가 아닌 '거절 해제' 로직
  Future<void> _showUnrejectConfirmationDialog(
      String rejectedUserId, String nickname) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'rejectedUsers.unrejectDialog.title'
                .tr(namedArgs: {'nickname': nickname}),
          ),
          content: Text(
            'rejectedUsers.unrejectDialog.content'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'rejectedUsers.unreject'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        // [수정] Repository에 unrejectUser 함수를 추가해야 합니다 (다음 단계에서 진행)
        await _repository.unrejectUser(_currentUserId!, rejectedUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'rejectedUsers.unrejectSuccess'
                  .tr(namedArgs: {'nickname': nickname}),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'rejectedUsers.unrejectFailure'
                  .tr(namedArgs: {'error': e.toString()}),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
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
      return Scaffold(
          appBar: AppBar(), body: Center(child: Text('로그인이 필요합니다.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('rejectedUsers.title'.tr()),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final currentUser = UserModel.fromFirestore(
              snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
          // V V V --- [핵심 수정] 'blockedUsers'가 아닌 'rejectedUsers' 필드를 읽어옵니다 --- V V V
          final rejectedUids = currentUser.rejectedUsers ?? [];
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

          if (rejectedUids.isEmpty) {
            return Center(
              child: Text('rejectedUsers.noRejectedUsers'.tr()),
            );
          }

          return ListView.builder(
            itemCount: rejectedUids.length,
            itemBuilder: (context, index) {
              final rejectedUserId = rejectedUids[index];
              return FutureBuilder<UserModel?>(
                future: _getUserData(rejectedUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('...'));
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text('알 수 없는 사용자'),
                      subtitle: Text(rejectedUserId),
                    );
                  }

                  final rejectedUser = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (rejectedUser.photoUrl != null &&
                              rejectedUser.photoUrl!.isNotEmpty)
                          ? NetworkImage(rejectedUser.photoUrl!)
                          : null,
                      child: (rejectedUser.photoUrl == null ||
                              rejectedUser.photoUrl!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(rejectedUser.nickname),
                    trailing: OutlinedButton(
                      onPressed: () => _showUnrejectConfirmationDialog(
                          rejectedUser.uid, rejectedUser.nickname),
                      child: Text('rejectedUsers.unreject'.tr()),
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

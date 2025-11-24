// lib/features/my_bling/screens/blocked_users_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final FindFriendRepository _repository = FindFriendRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // [v2.1] '거절 해제' 로직을 '차단 해제' 로직으로 변경
  Future<void> _showUnblockConfirmationDialog(
      String blockedUserId, String nickname) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            t.blockedUsers.unblockDialog.title
                .replaceAll('{nickname}', nickname),
          ),
          content: Text(
            t.blockedUsers.unblockDialog.content
                .replaceAll('{nickname}', nickname),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.common.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                t.blockedUsers.unblock.replaceAll('{nickname}', nickname),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.updateUserProfile(_currentUserId!, {
          'blockedUsers': FieldValue.arrayRemove([blockedUserId])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.blockedUsers.unblockSuccess
                  .replaceAll('{nickname}', nickname),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.blockedUsers.unblockFailure
                  .replaceAll('{error}', e.toString()),
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
        appBar: AppBar(),
        body: Center(child: Text(t.common.loginRequired)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.blockedUsers.title),
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
          final blockedUids = currentUser.blockedUsers ?? [];

          if (blockedUids.isEmpty) {
            return Center(
              child: Text(t.blockedUsers.empty),
            );
          }

          return ListView.builder(
            itemCount: blockedUids.length,
            itemBuilder: (context, index) {
              final blockedUserId = blockedUids[index];
              return FutureBuilder<UserModel?>(
                future: _getUserData(blockedUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text(t.common.unknownUser),
                      subtitle: Text(blockedUserId),
                    );
                  }
                  final blockedUser = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (blockedUser.photoUrl != null &&
                              blockedUser.photoUrl!.isNotEmpty)
                          ? NetworkImage(blockedUser.photoUrl!)
                          : null,
                      child: (blockedUser.photoUrl == null ||
                              blockedUser.photoUrl!.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(blockedUser.nickname),
                    trailing: OutlinedButton(
                      onPressed: () => _showUnblockConfirmationDialog(
                          blockedUser.uid, blockedUser.nickname),
                      child: Text(t.blockedUsers.unblock
                          .replaceAll('{nickname}', blockedUser.nickname)),
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

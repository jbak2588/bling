// lib/features/my_bling/screens/sent_friend_requests_screen.dart

import 'package:bling_app/features/find_friends/models/friend_request_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SentFriendRequestsScreen extends StatefulWidget {
  const SentFriendRequestsScreen({super.key});

  @override
  State<SentFriendRequestsScreen> createState() =>
      _SentFriendRequestsScreenState();
}

class _SentFriendRequestsScreenState extends State<SentFriendRequestsScreen> {
  final FindFriendRepository _repository = FindFriendRepository();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // 요청 받은 사람의 상세 정보를 가져오는 함수
  Future<UserModel?> _getUserData(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // 요청 상태에 따라 다른 아이콘과 색상을 반환하는 함수
  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        // return const Icon(Icons.check_circle, color: Colors.green, semanticLabel: '수락됨');
        return Icon(Icons.check_circle,
            color: Colors.green,
            semanticLabel: 'sentFriendRequests.status.accepted'.tr());
      case 'rejected':
        // return const Icon(Icons.cancel, color: Colors.red, semanticLabel: '거절됨');
        return Icon(Icons.cancel,
            color: Colors.red,
            semanticLabel: 'sentFriendRequests.status.rejected'.tr());
      default: // 'pending'
        // return const Icon(Icons.hourglass_top, color: Colors.orange, semanticLabel: '대기중');
        return Icon(Icons.hourglass_top,
            color: Colors.orange,
            semanticLabel: 'sentFriendRequests.status.pending'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("보낸 친구 요청"),
        title: Text('myBling.sentFriendRequests'.tr()),
      ),
      body: StreamBuilder<List<FriendRequestModel>>(
        stream: _repository.getSentRequests(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // return const Center(child: Text("보낸 친구 요청이 없습니다."));
            return Center(child: Text('sentFriendRequests.noRequests'.tr()));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return FutureBuilder<UserModel?>(
                future: _getUserData(request.toUserId), // 요청 받은 사람의 정보를 가져옴
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("..."));
                  }
                  final receiver = userSnapshot.data!;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (receiver.photoUrl != null &&
                                receiver.photoUrl!.isNotEmpty)
                            ? NetworkImage(receiver.photoUrl!)
                            : null,
                        child: (receiver.photoUrl == null ||
                                receiver.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(receiver.nickname,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        // '요청 상태: ${request.status}',
                        'sentFriendRequests.statusLabel'.tr(namedArgs: {
                          'status':
                              'sentFriendRequests.status.${request.status}'.tr()
                        }),
                        style: TextStyle(
                                    color: request.status == 'accepted'
                              ? Colors.green
                              : (request.status == 'rejected'
                                  ? Colors.red
                                  : Colors.orange),
                        ),
                      ),
                      trailing: _buildStatusIcon(request.status),
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

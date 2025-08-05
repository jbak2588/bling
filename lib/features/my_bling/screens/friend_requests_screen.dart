// lib/features/my_bling/screens/friend_requests_screen.dart

import 'package:bling_app/core/models/friend_request_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FindFriendRepository _repository = FindFriendRepository();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  // [추가] 로딩 상태 관리를 위한 변수
  final Map<String, bool> _isLoading = {};

  // 요청 보낸 사람의 상세 정보를 가져오는 함수
  Future<UserModel?> _getUserData(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // [추가] 친구 요청 수락 로직
  Future<void> _acceptRequest(FriendRequestModel request) async {
    setState(() => _isLoading[request.id] = true);
    try {
      await _repository.acceptFriendRequest(request.id, request.fromUserId, request.toUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 수락했습니다."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류가 발생했습니다: $e"), backgroundColor: Colors.red),
        );
      }
    }
    // finally 블록을 사용하지 않아, 성공적으로 처리된 항목은 목록에서 사라지게 됩니다.
  }

  // [추가] 친구 요청 거절 로직
  Future<void> _rejectRequest(String requestId) async {
    setState(() => _isLoading[requestId] = true);
    try {
      await _repository.rejectFriendRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 거절했습니다.")),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("오류가 발생했습니다: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("friendRequests.title".tr()),
      ),
      body: StreamBuilder<List<FriendRequestModel>>(
        stream: _repository.getReceivedRequests(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("friendRequests.noRequests".tr()));
          }

          final requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final isLoading = _isLoading[request.id] ?? false;

              return FutureBuilder<UserModel?>(
                future: _getUserData(request.fromUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("..."));
                  }
                  final sender = userSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (sender.photoUrl != null && sender.photoUrl!.isNotEmpty)
                            ? NetworkImage(sender.photoUrl!)
                            : null,
                        child: (sender.photoUrl == null || sender.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(sender.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(sender.bio ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: isLoading 
                          ? const CircularProgressIndicator() // 로딩 중일 때 인디케이터 표시
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // V V V --- [수정] 거절 버튼 기능 연동 --- V V V
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _rejectRequest(request.id),
                                ),
                                // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
                                // V V V --- [수정] 수락 버튼 기능 연동 --- V V V
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _acceptRequest(request),
                                ),
                                // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
                              ],
                            ),
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
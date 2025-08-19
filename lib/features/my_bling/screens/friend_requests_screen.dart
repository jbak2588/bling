// lib/features/my_bling/screens/friend_requests_screen.dart

import 'package:bling_app/features/find_friends/models/friend_request_model.dart';
import 'package:bling_app/core/models/user_model.dart';
// import 'package:bling_app/features/chat/screens/chat_room_screen.dart'; // 더 이상 채팅방으로 바로 이동하지 않으므로 주석 처리하거나 삭제
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

  final Map<String, bool> _isLoading = {};

  // [삭제] 화면 내부에 있던 중복된 acceptFriendRequest 함수를 제거합니다.

  @override
  void initState() {
    super.initState();
  }

  Future<UserModel?> _getUserData(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // [수정] 친구 요청 수락 후, 이전 화면(My Bling)으로 돌아가는 로직
  Future<void> _acceptRequest(FriendRequestModel request) async {
    setState(() => _isLoading[request.id] = true);
    try {
      // 1. Repository의 acceptFriendRequest 함수를 호출하여 친구 추가 및 채팅방 생성
      await _repository.acceptFriendRequest(
          request.id, request.fromUserId, request.toUserId);

      if (mounted) {
        // 2. 성공 메시지를 보여줍니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('friendRequests.acceptSuccess'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        // 3. 현재 화면을 닫고 이전 화면(My Bling)으로 돌아갑니다.
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading[request.id] = false); // 오류 발생 시 로딩 상태 해제
        // 4. 오류 메시지를 보여줍니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'friendRequests.error'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(FriendRequestModel request) async {
    setState(() => _isLoading[request.id] = true);
    try {
      // Repository의 rejectFriendRequest 함수에 필요한 ID들을 모두 전달합니다.
      await _repository.rejectFriendRequest(
          request.id, request.fromUserId, currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'friendRequests.rejectSuccess'.tr())), // 친구 요청을 거절했다는 메시지
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading[request.id] = false); // 오류 발생 시 로딩 상태 해제
        // 오류 메시지를 보여줍니다. "friendRequests.error" 키를 사용하여 다국어 지원 -> 오류가 발생했습니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'friendRequests.error'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
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
                    return const Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child:
                          ListTile(leading: CircleAvatar(), title: Text("...")),
                    );
                  }
                  final sender = userSnapshot.data!;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (sender.photoUrl != null &&
                                sender.photoUrl!.isNotEmpty)
                            ? NetworkImage(sender.photoUrl!)
                            : null,
                        child: (sender.photoUrl == null ||
                                sender.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(sender.nickname,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(sender.bio ?? '',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // V V V --- [수정] 거절 버튼이 올바른 파라미터를 전달하도록 변경 --- V V V
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  // tooltip: '거절',
                                  tooltip: 'friendRequests.tooltip.reject'.tr(),
                                  onPressed: () => _rejectRequest(request),
                                ),
                                // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  // tooltip: '수락',
                                  tooltip: 'friendRequests.tooltip.accept'.tr(),
                                  onPressed: () => _acceptRequest(request),
                                ),
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

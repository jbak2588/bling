// lib/features/my_bling/widgets/user_friend_list.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserFriendList extends StatelessWidget {
  const UserFriendList({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return const Center(child: Text("Please log in."));

    return StreamBuilder<DocumentSnapshot>(
      // 1. 내 유저 정보를 실시간으로 감시
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("친구 목록을 불러올 수 없습니다."));
        }
        final user = UserModel.fromFirestore(
            snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        final friendUids = user.friends ?? [];

        debugPrint('--- UserFriendList Debug ---');
        debugPrint('현재 사용자 UID: $myUid');
        debugPrint(
            'Firestore에서 받은 friends 필드: ${(snapshot.data!.data() as Map<String, dynamic>?)?['friends']}');
        debugPrint('UserModel로 변환된 user.friends: ${user.friends}');
        debugPrint('최종 친구 UID 목록 (friendUids): $friendUids');
        debugPrint('--------------------------');

        if (friendUids.isEmpty) {
          return const Center(child: Text("아직 친구가 없습니다."));
        }

        // 2. 친구 UID 목록을 사용하여 각 친구의 상세 정보를 가져옴
        return ListView.builder(
          itemCount: friendUids.length,
          itemBuilder: (context, index) {
            final friendUid = friendUids[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendUid)
                  .get(),
              builder: (context, friendSnapshot) {
                if (!friendSnapshot.hasData || !friendSnapshot.data!.exists) {
                  return ListTile(title: Text("$friendUid 사용자를 찾을 수 없음"));
                }
                final friend = UserModel.fromFirestore(friendSnapshot.data!
                    as DocumentSnapshot<Map<String, dynamic>>);

                // 3. 각 친구 정보를 ListTile로 표시하고, 우측에 채팅 버튼 추가
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (friend.photoUrl != null &&
                              friend.photoUrl!.isNotEmpty)
                          ? NetworkImage(friend.photoUrl!)
                          : null,
                      child:
                          (friend.photoUrl == null || friend.photoUrl!.isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    title: Text(friend.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(friend.bio ?? '',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {
                        // 채팅 버튼을 누르면 해당 유저와의 채팅방으로 이동
                        List<String> ids = [myUid, friend.uid];
                        ids.sort();
                        String chatRoomId = ids.join('_');

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chatId: chatRoomId,
                              otherUserId: friend.uid,
                              otherUserName: friend.nickname,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

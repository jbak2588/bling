// lib/features/my_bling/widgets/user_friend_list.dart
/// DocHeader
/// [기획 요약]
/// - 내 친구 탭은 친구 목록, 채팅, 통계, 활동 내역을 제공합니다.
/// - KPI, 활동 통계, 추천/분석 기능 등 사용자 경험 강화가 목표입니다.
///
/// [실제 구현 비교]
/// - 친구 목록, 채팅, Firestore 연동, 실시간 통계, UI/UX 개선 적용됨.
///
/// [차이점 및 개선 제안]
/// 1. KPI/Analytics 기반 활동 통계, 추천/분석 기능, 프리미엄 기능(뱃지, 광고 등) 도입 검토.
/// 2. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화 등 코드 안정성/성능 개선.
/// 3. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 친구 기능 연계 강화 필요.
/// 4. 활동 내역, KPI 기반 추천/분석 기능 추가 권장.
library;


import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';

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
                        // V V V --- [수정] ListTile의 onTap 이벤트를 추가합니다 --- V V V
                    onTap: () {
                      // 탭하면 친구의 상세 프로필 화면으로 이동합니다.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FindFriendDetailScreen(
                            user: friend, // 친구의 정보
                            currentUserModel: user, // 나의 정보
                          ),
                        ),
                      );
                    },
                    // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
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

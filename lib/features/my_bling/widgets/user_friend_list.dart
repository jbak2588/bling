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
// [작업 19] '분리 및 정돈' 전략 적용
// - 친구 목록과 관심 이웃(찜한 유저)을 탭으로 분리하여 관리.
library;

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';

class UserFriendList extends StatelessWidget {
  const UserFriendList({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) {
      return Center(child: Text('main.errors.loginRequired'.tr()));
    }

    return StreamBuilder<DocumentSnapshot>(
      // 1. 내 유저 정보를 실시간으로 감시
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('myBling.friends.loadError'.tr()));
        }
        final user = UserModel.fromFirestore(
            snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        final friendUids = user.friends ?? [];
        // [작업 19] 탭 컨트롤러 적용을 위해 StreamBuilder 내부 구조 변경
        // [작업 19] 관심 이웃(찜한 유저) 목록 가져오기
        // NOTE: UserModel에는 `bookmarkedUserIds` 필드가 없으므로 안전한 대체로
        // `likesGiven`를 사용합니다(내가 좋아요한 사용자 목록).
        final starredUids = user.bookmarkedUserIds ?? [];

        // [작업 19] 2개의 탭(내 친구 / 관심 이웃)으로 분리
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: 'myBling.friendsTabs.myFriends'.tr()), // localized
                  Tab(text: 'myBling.friendsTabs.starred'.tr()), // localized
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildUserList(context, myUid, user, friendUids,
                        isStarredTab: false),
                    _buildUserList(context, myUid, user, starredUids,
                        isStarredTab: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // [작업 19] 사용자 목록 빌더 (친구/관심이웃 공용)
  Widget _buildUserList(
      BuildContext context, String myUid, UserModel myUser, List<String> uids,
      {required bool isStarredTab}) {
    if (uids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isStarredTab ? Icons.star_border : Icons.people_outline,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isStarredTab
                  ? 'myBling.friends.starredEmpty'.tr() // "찜한 이웃이 없습니다."
                  : 'myBling.friends.empty'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: uids.length,
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        final targetUid = uids[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(targetUid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const SizedBox.shrink(); // 없는 유저는 숨김
            }
            final targetUser = UserModel.fromFirestore(
                snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 0, // 플랫한 디자인
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (targetUser.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(targetUser.photoUrl!)
                      : null,
                  child: (targetUser.photoUrl?.isEmpty ?? true)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(targetUser.nickname,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: targetUser.bio?.isNotEmpty ?? false
                    ? Text(targetUser.bio!,
                        maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FindFriendDetailScreen(
                        user: targetUser,
                        currentUserModel: myUser,
                      ),
                    ),
                  );
                },
                // [Task 23] 친구/관심이웃 관리 메뉴 (채팅/삭제/차단)
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'chat') {
                      // 채팅방 이동
                      List<String> ids = [myUid, targetUser.uid];
                      ids.sort();
                      String chatRoomId = ids.join('_');
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                              chatId: chatRoomId,
                              otherUserId: targetUser.uid,
                              otherUserName: targetUser.nickname)));
                    } else if (value == 'delete') {
                      // 목록에서 삭제 (친구 끊기 또는 찜 해제)
                      final field =
                          isStarredTab ? 'bookmarkedUserIds' : 'friends';
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(myUid)
                          .update({
                        field: FieldValue.arrayRemove([targetUid])
                      });
                    } else if (value == 'add_friend') {
                      // [Task 28] 관심 이웃 -> 친구 목록 이동 (승격)
                      final batch = FirebaseFirestore.instance.batch();
                      final myRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(myUid);

                      // 1. 관심 목록에서 제거
                      batch.update(myRef, {
                        'bookmarkedUserIds': FieldValue.arrayRemove([targetUid])
                      });
                      // 2. 친구 목록에 추가
                      batch.update(myRef, {
                        'friends': FieldValue.arrayUnion([targetUid])
                      });

                      await batch.commit();
                      // UI는 StreamBuilder로 자동 갱신됩니다.
                    } else if (value == 'block') {
                      // 차단하기 (목록 삭제 + 차단 목록 추가)
                      final field =
                          isStarredTab ? 'bookmarkedUserIds' : 'friends';
                      final batch = FirebaseFirestore.instance.batch();
                      final myRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(myUid);

                      batch.update(myRef, {
                        field: FieldValue.arrayRemove([targetUid])
                      });
                      batch.update(myRef, {
                        'blockedUsers': FieldValue.arrayUnion([targetUid])
                      });

                      await batch.commit();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('blockedUsers.blocked'.tr(namedArgs: {
                          'nickname': targetUser.nickname
                        }))));
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'chat',
                      child: ListTile(
                          leading: Icon(Icons.chat_bubble_outline),
                          title: Text('common.chat'.tr()),
                          contentPadding: EdgeInsets.zero),
                    ),
                    // [Task 28] 관심 이웃 탭일 때만 '친구 추가' 메뉴 노출
                    if (isStarredTab)
                      PopupMenuItem<String>(
                        value: 'add_friend',
                        child: ListTile(
                            leading: Icon(Icons.person_add_alt_1,
                                color: Colors.blue),
                            title: Text('common.addFriend'.tr()),
                            contentPadding: EdgeInsets.zero),
                      ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('common.delete'.tr()),
                          contentPadding: EdgeInsets.zero),
                    ),
                    PopupMenuItem<String>(
                      value: 'block',
                      child: ListTile(
                          leading: Icon(Icons.block, color: Colors.red),
                          title: Text('common.block'.tr()),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

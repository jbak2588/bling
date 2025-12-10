// lib/features/find_friends/widgets/friend_post_card.dart

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:bling_app/features/find_friends/models/friend_post_model.dart';
import 'package:bling_app/features/find_friends/data/friend_post_repository.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FutureBuilder용
import 'package:easy_localization/easy_localization.dart';
// [작업 9] import 추가
import 'package:bling_app/features/find_friends/screens/create_friend_post_screen.dart';
// [작업 10] 주소 포맷터 추가
import 'package:bling_app/core/utils/address_formatter.dart';
// [작업 10] 상세화면
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
// [이미지] 친구 찾기 카드 내 프로필 미리보기 캐러셀
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';

class FriendPostCard extends StatelessWidget {
  final FriendPostModel post;
  final UserModel currentUser;

  const FriendPostCard({
    super.key,
    required this.post,
    required this.currentUser,
  });

  // 1:1 대화 또는 그룹 채팅방 입장
  void _enterChat(BuildContext context) async {
    try {
      final chatService = ChatService();
      String chatId;
      String title;

      if (post.isMultiChat) {
        // 그룹 채팅방 입장
        List<String> participants = List.from(post.currentParticipantIds);
        if (!participants.contains(post.authorId)) {
          participants.add(post.authorId);
        }

        chatId = await chatService.getOrCreatePostGroupChat(
          postId: post.id,
          postTitle: post.content,
          participants: participants,
        );
        title = post.content;
      } else {
        // 1:1 대화 입장
        chatId = await chatService.createOrGetChatRoom(
          otherUserId: post.authorId,
          contextType: 'friend_post',
        );
        title = post.authorNickname;
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatId: chatId,
              otherUserId: post.isMultiChat ? null : post.authorId, // 그룹챗은 null
              otherUserName: title,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('friendPost.genericError'
              .tr(namedArgs: {'error': e.toString()}))));
    }
  }

  // 그룹 참여 요청
  void _requestJoin(BuildContext context) async {
    try {
      await FriendPostRepository().requestToJoin(post.id, currentUser.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('friendPost.requestSent'.tr())));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('friendPost.genericError'
              .tr(namedArgs: {'error': e.toString()}))));
    }
  }

  // 요청 취소
  void _cancelRequest(BuildContext context) async {
    try {
      await FriendPostRepository().cancelRequest(post.id, currentUser.uid);
    } catch (e) {
      // ignore error
    }
  }

  // [작성자 전용] 멤버 관리 시트 표시
  void _showManageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) =>
          _ManageMembersSheet(post: post, currentUser: currentUser),
    );
  }

  // [작업 9] 게시글 수정/삭제 옵션 시트
  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('게시글 수정'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateFriendPostScreen(
                      userModel: currentUser,
                      post: post, // 수정할 포스트 전달
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('게시글 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('friendPost.menu.delete'.tr()),
        content: Text('friendPost.dialog.deleteConfirm'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('friendPost.dialog.cancel'.tr())),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FriendPostRepository().deletePost(post.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('friendPost.snackbar.deleted'.tr())),
                );
              }
            },
            child: Text('friendPost.dialog.deleteAction'.tr(),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // [작업 10] 유저 프로필로 이동하는 헬퍼 함수
  Future<void> _navigateToProfile(BuildContext context, String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("사용자를 찾을 수 없습니다.")));
        return;
      }
      final user = UserModel.fromFirestore(doc);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FindFriendDetailScreen(
              user: user,
              currentUserModel: currentUser,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Profile navigation error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = post.authorId == currentUser.uid;
    final isParticipant = post.currentParticipantIds.contains(currentUser.uid);
    final isWaiting = post.waitingParticipantIds.contains(currentUser.uid);
    final bool isFull =
        post.currentParticipantIds.length >= post.maxParticipants;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                GestureDetector(
                  // [작업 10] 작성자 프로필 이동
                  onTap: () => _navigateToProfile(context, post.authorId),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: (post.authorPhotoUrl != null &&
                            post.authorPhotoUrl!.isNotEmpty)
                        ? NetworkImage(post.authorPhotoUrl!)
                        : null,
                    child: (post.authorPhotoUrl == null ||
                            post.authorPhotoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorNickname,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "${timeago.format(post.createdAt.toDate())} · ${AddressFormatter.formatKelKabFromParts(post.locationParts).isNotEmpty ? AddressFormatter.formatKelKabFromParts(post.locationParts) : 'friendPost.unknownLocation'.tr()}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // 그룹 정보 뱃지
                if (post.isMultiChat)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${post.currentParticipantIds.length + 1}/${post.maxParticipants}명', // 작성자 포함 +1
                      style: TextStyle(
                          color: isFull ? Colors.red : Colors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 프로필 이미지 미리보기 (작성자 사진이 있는 경우에만)
            if (post.authorPhotoUrl != null &&
                post.authorPhotoUrl!.isNotEmpty) ...[
              ImageCarouselCard(
                imageUrls: [post.authorPhotoUrl!],
                storageId: 'friend_post_${post.id}_author',
                height: 160,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
            ],

            // 본문
            Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // 태그
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),

            // 액션 버튼 영역
            SizedBox(
              width: double.infinity,
              child: isAuthor
                  // 1. 작성자인 경우
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            // [작업 9] 관리 메뉴 연결
                            onPressed: () => _showPostOptions(context),
                            child: Text("friendPost.action.managePost".tr()),
                          ),
                        ),
                        if (post.isMultiChat &&
                            post.waitingParticipantIds.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showManageSheet(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.notifications_active,
                                size: 16),
                            label: Text("friendPost.action.waitingCount".tr(
                                args: [
                                  post.waitingParticipantIds.length.toString()
                                ])),
                          ),
                        ],
                      ],
                    )
                  // 2. 다른 유저인 경우
                  : _buildUserActionButton(
                      context, isParticipant, isWaiting, isFull),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActionButton(
      BuildContext context, bool isParticipant, bool isWaiting, bool isFull) {
    if (isParticipant) {
      return ElevatedButton.icon(
        onPressed: () => _enterChat(context),
        icon: const Icon(Icons.chat_bubble, size: 18),
        label: Text('friendPost.chattingLabel'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      );
    } else if (isWaiting) {
      return OutlinedButton.icon(
        onPressed: () => _cancelRequest(context),
        icon: const Icon(Icons.hourglass_empty, size: 18),
        label: Text("friendPost.action.waitingCancel".tr()), // [작업 10] 다국어 적용
      );
    } else if (post.isMultiChat) {
      return ElevatedButton(
        onPressed: isFull ? null : () => _requestJoin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFull ? Colors.grey : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: Text(isFull
            ? "friendPost.action.full".tr()
            : "friendPost.action.requestJoin".tr()), // [작업 10] 다국어 적용
      );
    } else {
      // 1:1 채팅 (바로 시작)
      return ElevatedButton.icon(
        onPressed: () => _enterChat(context),
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text('friendPost.enterChatLabel'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      );
    }
  }
}

// [내부 위젯] 멤버 관리 시트 (작성자용)
class _ManageMembersSheet extends StatelessWidget {
  final FriendPostModel post;
  final UserModel currentUser;
  const _ManageMembersSheet({required this.post, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final repo = FriendPostRepository();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('friendPost.manageRequestsTitle'.tr(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (post.waitingParticipantIds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('friendPost.noPendingRequests'.tr())),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              itemCount: post.waitingParticipantIds.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final uid = post.waitingParticipantIds[index];
                // 유저 정보 비동기 로딩
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    final user = UserModel.fromFirestore(snapshot.data!
                        as DocumentSnapshot<Map<String, dynamic>>);

                    return ListTile(
                      leading: GestureDetector(
                        // [작업 10] 신청자 프로필 이동
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FindFriendDetailScreen(
                                  user: user,
                                  // 부모에서 전달된 currentUser 사용
                                  currentUserModel: currentUser)),
                        ),
                        child: CircleAvatar(
                          backgroundImage: (user.photoUrl != null)
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: (user.photoUrl == null)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: Text(user.nickname),
                      subtitle: Text(user.bio ?? 'friendPost.noBio'.tr(),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () async {
                              try {
                                await repo.acceptJoin(post, uid, user.nickname);
                                if (context.mounted) {
                                  Navigator.pop(context); // 닫기
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('friendPost.approvedSnackbar'
                                        .tr(namedArgs: {
                                      'nickname': user.nickname
                                    })),
                                  ));
                                }
                              } catch (e) {
                                if (e.toString().contains("full")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'friendPost.fullError'.tr())));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'friendPost.genericError'.tr(
                                                  namedArgs: {
                                        'error': e.toString()
                                      }))));
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await repo.rejectJoin(post.id, uid);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      // 프로필 상세 보기 연결
                      onTap: () {
                        // [작업 15] 텍스트 영역 클릭 시에도 프로필 이동 적용
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FindFriendDetailScreen(
                              user: user,
                              // 부모에서 전달된 currentUser 사용
                              currentUserModel: currentUser,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

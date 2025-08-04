// lib/features/find_friends/screens/find_friend_detail_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] 다시 StatelessWidget으로 변경하여 코드를 단순화하고 StreamBuilder로 상태를 관리합니다.
class FindFriendDetailScreen extends StatelessWidget {
  final UserModel user;
  final UserModel? currentUserModel;
  const FindFriendDetailScreen({super.key, required this.user, this.currentUserModel});

  @override
  Widget build(BuildContext context) {
    final allImages = [user.photoUrl, ...?user.findfriendProfileImages]
        .where((url) => url != null && url.isNotEmpty)
        .toList();
    final currentUser = currentUserModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.nickname),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                itemCount: allImages.isNotEmpty ? allImages.length : 1,
                itemBuilder: (context, index) {
                  if (allImages.isEmpty) {
                    return Hero(
                      tag: 'profile-image-${user.uid}',
                      child: const Icon(Icons.person, size: 150, color: Colors.grey),
                    );
                  }
                  return Hero(
                    tag: 'profile-image-${user.uid}',
                    child: Image.network(
                      allImages[index]!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.error_outline, size: 50),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.nickname}, ${user.age ?? ''}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  if (user.locationName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.locationName!,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 32),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    Text("findFriend.bioLabel".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(user.bio!, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const Divider(height: 32),
                  ],
                  if (user.interests != null && user.interests!.isNotEmpty) ...[
                    Text("interests.title".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: user.interests!.map((interestKey) {
                        return Chip(label: Text("interests.items.$interestKey".tr()));
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // [수정] FloatingActionButton 부분을 StreamBuilder로 감싸 실시간으로 상태를 확인합니다.
      floatingActionButton: (currentUser == null || currentUser.uid == user.uid)
          ? null // 로그인 안했거나 자기 자신일 경우 버튼 없음
          : StreamBuilder<QuerySnapshot>(
              // Repository에 추가한 getRequestStatus 함수를 호출합니다.
              stream: FindFriendRepository().getRequestStatus(currentUser.uid, user.uid),
              builder: (context, snapshot) {
                // 이미 친구인 경우 (이 정보는 currentUserModel에서 가져옵니다)
                if (currentUser.friends?.contains(user.uid) ?? false) {
                  return FloatingActionButton.extended(
                    onPressed: null,
                    label: Text("friendDetail.alreadyFriends".tr()),
                    icon: const Icon(Icons.check_circle),
                    backgroundColor: Colors.grey,
                  );
                }

                // DB에서 '대기중'인 요청을 실시간으로 찾은 경우
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return FloatingActionButton.extended(
                    onPressed: null,
                    label: Text("friendDetail.requestSent".tr()),
                    icon: const Icon(Icons.hourglass_top),
                    backgroundColor: Colors.orange,
                  );
                }
                
                // 위의 모든 조건에 해당하지 않으면 '친구 요청' 버튼 표시
                return FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      await FindFriendRepository().sendFriendRequest(currentUser.uid, user.uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${"friendDetail.request".tr()} 완료")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${"friendDetail.requestFailed".tr()} $e")),
                      );
                    }
                  },
                  label: Text("friendDetail.request".tr()),
                  icon: const Icon(Icons.person_add_alt_1),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
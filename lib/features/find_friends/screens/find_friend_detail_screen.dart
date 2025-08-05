// lib/features/find_friends/screens/find_friend_detail_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class FindFriendDetailScreen extends StatefulWidget {
  final UserModel user;
  final UserModel? currentUserModel;
  const FindFriendDetailScreen({super.key, required this.user, this.currentUserModel});

  @override
  State<FindFriendDetailScreen> createState() => _FindFriendDetailScreenState();
}

class _FindFriendDetailScreenState extends State<FindFriendDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final allImages = [user.photoUrl, ...?user.findfriendProfileImages]
        .where((url) => url != null && url.isNotEmpty)
        .toList();
    final currentUser = widget.currentUserModel;

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
                    return const Icon(Icons.person, size: 150, color: Colors.grey);
                  }
                  return Image.network(
                    allImages[index]!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stack) =>
                        const Icon(Icons.error_outline, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.nickname}, ${user.age ?? ''}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
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
      floatingActionButton: (currentUser == null || currentUser.uid == user.uid)
          ? null
          : StreamBuilder<QuerySnapshot>(
              stream: FindFriendRepository().getRequestStatus(currentUser.uid, user.uid),
              builder: (context, snapshot) {
                if (currentUser.friends?.contains(user.uid) ?? false) {
                  return FloatingActionButton.extended(
                    onPressed: null,
                    label: Text("friendDetail.alreadyFriends".tr()),
                    icon: const Icon(Icons.check_circle),
                    backgroundColor: Colors.grey,
                  );
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return FloatingActionButton.extended(
                    onPressed: null,
                    label: Text("friendDetail.requestSent".tr()),
                    icon: const Icon(Icons.hourglass_top),
                    backgroundColor: Colors.orange,
                  );
                }
                
                return FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      await FindFriendRepository().sendFriendRequest(currentUser.uid, user.uid);
                      // V V V --- [수정] 화면이 살아있는지(mounted) 확인 후 SnackBar 호출 --- V V V
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("friendDetail.requestSuccess".tr())),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${"friendDetail.requestFailed".tr()} $e")),
                        );
                      }
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
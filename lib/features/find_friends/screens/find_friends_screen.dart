// lib/features/find_friends/screens/find_friends_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'findfriend_form_screen.dart';

class FindFriendsScreen extends StatelessWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    if (userModel == null) {
      // [수정] AppBar를 제거하여, 로딩 화면에서는 아무것도 보이지 않도록 합니다.
      return const Center(child: CircularProgressIndicator());
    }

    if (userModel!.isDatingProfile != true) {
      // [수정] 여기에도 AppBar를 제거하여 HomeScreen의 AppBar만 보이도록 합니다.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                "findFriend.prompt_title".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FindFriendFormScreen(userModel: userModel!)),
                  );
                },
                child: Text("findFriend.prompt_button".tr()),
              ),
            ],
          ),
        ),
      );
    }

    // Case 3: 모든 조건을 통과한 사용자에게만 친구 목록을 보여줍니다.
    return Scaffold(
      // [수정] AppBar를 완전히 제거합니다.
      // appBar: AppBar(...),

      body: StreamBuilder<List<UserModel>>(
        stream: FindFriendRepository().getUsersForFindFriends(userModel!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("findFriend.noFriendsFound".tr()));
          }

          final userList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FindFriendDetailScreen(
                          user: user, currentUserModel: userModel),
                    ),
                  );
                },
                child: FindFriendCard(user: user),
              );
            },
          );
        },
      ),
      // [추가] AppBar에서 제거된 '프로필 수정' 버튼을 FloatingActionButton으로 옮깁니다.
      floatingActionButton: FloatingActionButton(
        heroTag: 'find_friends_edit_profile',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FindFriendFormScreen(userModel: userModel!)),
          );
        },
        tooltip: "findFriend.editProfileTitle".tr(),
        child: const Icon(Icons.edit_note_outlined),
      ),
    );
  }
}

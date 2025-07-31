// lib/features/find_friends/screens/find_friends_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/find_friends/screens/findfriend_form_screen.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindFriendsScreen extends StatelessWidget {
  const FindFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("친구 찾기"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindFriendFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
          )
        ],
      ),
      // [수정] FutureBuilder를 실시간으로 데이터를 받는 StreamProvider.value로 변경
      body: StreamProvider<List<UserModel>>.value(
        value: FindFriendRepository().getUsersForFindFriends(),
        initialData: const [], // 초기 데이터는 빈 리스트
        catchError: (_, error) {
          debugPrint("친구 목록을 불러오는 중 에러 발생: $error");
          return []; // 에러 발생 시 빈 리스트 반환
        },
        // [수정] Consumer를 사용하여 Provider가 제공하는 데이터를 받아 UI를 그림
        child: Consumer<List<UserModel>>(
          builder: (context, userList, child) {
            // 로딩 중이거나 데이터가 없을 때의 처리
            if (userList.isEmpty) {
              return const Center(
                child: Text('프로필을 등록한 친구가 없습니다.'),
              );
            }
            // 데이터가 있을 때 리스트 표시
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                return FindFriendCard(user: userList[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
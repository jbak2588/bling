import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import '../data/find_friend_repository.dart';
import '../widgets/findfriend_card.dart';
import 'findfriend_form_screen.dart';

class FindFriendsScreen extends StatelessWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    if (userModel == null) {
      return const Scaffold(
        body: Center(child: Text('User info not found.')),
      );
    }

    if (userModel!.isDatingProfile == false) {
      // 친구찾기 의향 없음 → 프로필 등록 유도
      return Scaffold(
        appBar: AppBar(title: const Text('Find Friends')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'Please create your FindFriend profile to get started.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FindFriendFormScreen(userModel: userModel!),
                      ));
                },
                child: const Text('Create My Profile'),
              ),
            ],
          ),
        ),
      );
    }

    final isProfileComplete = userModel!.ageRange != null &&
        userModel!.gender != null &&
        userModel!.findfriendProfileImages != null &&
        userModel!.findfriendProfileImages!.isNotEmpty;

    if (!isProfileComplete) {
      // 프로필 불완전 (이미지 없음 등)
      return Scaffold(
        appBar: AppBar(title: const Text('Find Friends')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please complete your FindFriend profile.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FindFriendFormScreen(userModel: userModel!),
                      ));
                },
                child: const Text('Edit My Profile'),
              ),
            ],
          ),
        ),
      );
    }

    final repo = FindFriendRepository();
    final kab = userModel!.locationParts?['kab'];

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Friends')),
      body: StreamBuilder<List<UserModel>>(
        stream: repo.getNearbyFriends(kab),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data!;
          if (friends.isEmpty) {
            return const Center(child: Text('No users found nearby.'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final user = friends[index];
              return FindFriendCard(user: user);
            },
          );
        },
      ),
    );
  }
}

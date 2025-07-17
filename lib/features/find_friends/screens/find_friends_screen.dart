import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import '../data/find_friend_repository.dart';
import '../widgets/findfriend_card.dart';

class FindFriendsScreen extends StatelessWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    if (userModel == null || userModel!.locationParts == null) {
      return const Center(child: Text('Please create your FindFriend profile.'));
    }

    final repo = FindFriendRepository();
    final kab = userModel!.locationParts!['kab'];

    return StreamBuilder<List<UserModel>>(
      stream: repo.getNearbyFriends(kab),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data!;
        if (friends.isEmpty) {
          return const Center(child: Text('No users'));
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final user = friends[index];
            return FindFriendCard(user: user);
          },
        );
      },
    );
  }
}

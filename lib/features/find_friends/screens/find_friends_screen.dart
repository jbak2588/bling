import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import 'findfriend_profile_form.dart';
import '../data/findfriend_repository.dart';
import '../../../core/models/findfriend_model.dart';
import 'findfriend_profile_detail.dart';

class FindFriendsScreen extends StatelessWidget {
  final UserModel? userModel;
  final FindFriendRepository repository = FindFriendRepository();

  FindFriendsScreen({this.userModel, super.key});

  bool get _profileComplete {
    final data = userModel?.findfriend;
    if (data == null) return false;
    final profile = FindFriend.fromMap(
        Map<String, dynamic>.from(data), userModel!.uid);
    return profile.nickname.isNotEmpty &&
        profile.ageRange != null &&
        profile.gender != null &&
        profile.location != null &&
        profile.bio != null &&
        profile.interests != null && profile.interests!.isNotEmpty &&
        profile.profileImages.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Complete your profile to see nearby friends.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FindFriendProfileForm(
                      profile: userModel != null
                          ? FindFriend.fromMap(
                              Map<String, dynamic>.from(
                                  userModel!.findfriend ?? {}),
                              userModel!.uid)
                          : null,
                      onSave: (profile) {
                        repository.saveProfile(profile);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Create My Profile'),
            )
          ],
        ),
      );
    }

    return StreamBuilder<List<FindFriend>>(
      stream: repository.getNearbyFriends(),
      builder: (context, snapshot) {
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('No nearby friends'));
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final profile = list[index];
            return ListTile(
              title: Text(profile.nickname),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FindFriendProfileDetail(
                      profile: profile,
                      onSendRequest: () {
                        repository.sendFriendRequest(
                            userModel!.uid, profile.userId);
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


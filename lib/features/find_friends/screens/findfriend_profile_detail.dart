// lib/features/find_friends/screens/findfriend_profile_detail.dart
// Displays details of another user's profile

import 'package:flutter/material.dart';
import '../../../core/models/findfriend_model.dart';

class FindFriendProfileDetail extends StatelessWidget {
  final FindFriend profile;
  final VoidCallback? onSendRequest;
  const FindFriendProfileDetail({required this.profile, this.onSendRequest, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.nickname)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.bio ?? ''),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSendRequest,
              child: const Text('Send Friend Request'),
            )
          ],
        ),
      ),
    );
  }
}

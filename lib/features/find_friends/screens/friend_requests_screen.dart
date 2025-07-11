// lib/features/find_friends/screens/friend_requests_screen.dart
// Screen to display incoming and outgoing friend requests

import 'package:flutter/material.dart';
import '../data/findfriend_repository.dart';
import '../../../core/models/findfriend_model.dart';

class FriendRequestsScreen extends StatelessWidget {
  final FindFriendRepository repository;
  final String userId;
  const FriendRequestsScreen({required this.repository, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: StreamBuilder<List<FindFriend>>(
        stream: repository.getLikedMe(userId),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text('No Requests'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final profile = requests[index];
              return ListTile(
                title: Text(profile.nickname),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Accept request by creating chat room
                    // In real implementation we would pass request id
                    repository.createChatRoom(userId, profile.userId);
                  },
                  child: const Text('Accept'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// lib/features/find_friends/widgets/findfriend_card.dart

import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';

/// Card displaying basic information for a FindFriend profile.
class FindFriendCard extends StatelessWidget {
  final UserModel user;
  const FindFriendCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Hero(
              tag: 'profile-image-${user.uid}',
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child:
                    user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nickname,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  if (user.age != null)
                    Text('${user.age}',
                        style: const TextStyle(fontSize: 14)),
                  if (user.locationName != null)
                    Text(user.locationName!,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/user_model.dart';
import '../../user_profile/screens/user_profile_screen.dart';
import 'trust_level_badge.dart';

class AuthorProfileTile extends StatelessWidget {
  final String userId;

  const AuthorProfileTile({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터를 기다리는 동안 간단한 플레이스홀더를 보여줄 수 있습니다.
          return const Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 80, height: 16, child: LinearProgressIndicator()),
                  SizedBox(height: 4),
                  SizedBox(width: 120, height: 12, child: LinearProgressIndicator()),
                ],
              )
            ],
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('postCard.authorNotFound'.tr());
        }

        final user = UserModel.fromFirestore(snapshot.data!);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: userId),
            ));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, size: 22) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 4),
                        TrustLevelBadge(trustLevel: user.trustLevel, showText: false),
                      ],
                    ),
                    if(user.locationName != null && user.locationName!.isNotEmpty)
                    Text(
                      user.locationName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
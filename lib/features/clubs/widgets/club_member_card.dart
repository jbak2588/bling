// lib/features/clubs/widgets/club_member_card.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class ClubMemberCard extends StatefulWidget {
  final ClubMemberModel member;
  final String clubId;
  final String clubOwnerId;
  const ClubMemberCard({super.key, required this.member, required this.clubId, required this.clubOwnerId});

  @override
  State<ClubMemberCard> createState() => _ClubMemberCardState();
}

class _ClubMemberCardState extends State<ClubMemberCard> {
  final ClubRepository _repository = ClubRepository();

  // 멤버 강퇴 로직
  Future<void> _kickMember(BuildContext context, String memberId, String memberName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$memberName 님을 강퇴하시겠습니까?'), // TODO: 다국어
          content: const Text('강퇴된 멤버는 동호회 관련 활동에 더 이상 참여할 수 없습니다.'), // TODO: 다국어
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('강퇴하기', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _repository.removeMember(widget.clubId, memberId);
        
        // [핵심] SnackBar를 호출하기 전에, 위젯이 여전히 화면에 있는지(mounted) 확인합니다.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$memberName 님을 강퇴했습니다.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('멤버 강퇴에 실패했습니다: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final member = widget.member;
    final clubOwnerId = widget.clubOwnerId;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(member.userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('...')));
        }
        final user = UserModel.fromFirestore(snapshot.data!);

        final bool isOwner = user.uid == clubOwnerId;
        final bool amIOwner = currentUserId == clubOwnerId;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
            ),
            title: Row(
              children: [
                Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (isOwner) const Icon(Icons.shield_moon, color: Colors.amber, size: 16),
              ],
            ),
            trailing: (amIOwner && !isOwner)
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'kick') {
                        _kickMember(context, member.userId, user.nickname);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'kick', child: Text('강퇴하기')),
                    ],
                  )
                : null,
            onTap: () {
              // TODO: 멤버 프로필 보기 화면으로 이동
            },
          ),
        );
      },
    );
  }
}
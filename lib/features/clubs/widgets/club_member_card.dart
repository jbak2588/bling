// lib/features/clubs/widgets/club_member_card.dart

import 'package:bling_app/features/clubs/models/club_member_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart'; // [추가] 상세 프로필 화면 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class ClubMemberCard extends StatefulWidget {
  final ClubMemberModel member;
  final String clubId;
  final String clubOwnerId;
  const ClubMemberCard(
      {super.key,
      required this.member,
      required this.clubId,
      required this.clubOwnerId});

  @override
  State<ClubMemberCard> createState() => _ClubMemberCardState();
}

class _ClubMemberCardState extends State<ClubMemberCard> {
  final ClubRepository _repository = ClubRepository();

  // 멤버 강퇴 로직
  Future<void> _kickMember(
      BuildContext context, String memberId, String memberName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('clubs.memberCard.kickConfirmTitle'
              .tr(namedArgs: {'memberName': memberName})),
          content: Text('clubs.memberCard.kickConfirmContent'.tr()),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('common.cancel'.tr())),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('clubs.memberCard.kick'.tr(),
                    style: const TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _repository.removeMember(widget.clubId, memberId);

        // [핵심] SnackBar를 호출하기 전에, 위젯이 여전히 화면에 있는지(mounted) 확인합니다.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('clubs.memberCard.kickedSuccess'
                .tr(namedArgs: {'memberName': memberName})),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('clubs.memberCard.kickFail'
                .tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ));
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
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(member.userId)
          .get(),
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
              backgroundImage:
                  (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Row(
              children: [
                Text(user.nickname,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (isOwner)
                  const Icon(Icons.shield_moon, color: Colors.amber, size: 16),
              ],
            ),
            trailing: (amIOwner && !isOwner)
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'kick') {
                        _kickMember(context, member.userId, user.nickname);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'kick', child: Text('강퇴하기')),
                    ],
                  )
                : null,
            onTap: () async {
              if (currentUserId == null) return;
              
              // 현재 로그인한 사용자의 최신 정보를 가져옵니다.
              final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
              if (!currentUserDoc.exists || !context.mounted) return;
              final currentUserModel = UserModel.fromFirestore(currentUserDoc);

              // 상세 프로필 화면으로 이동합니다.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FindFriendDetailScreen(
                    user: user, // 탭한 멤버의 정보
                    currentUserModel: currentUserModel, // 현재 로그인한 나의 정보
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

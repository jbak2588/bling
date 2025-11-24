// lib/features/clubs/widgets/club_member_list.dart

import 'package:bling_app/features/clubs/models/club_member_model.dart';
import 'package:bling_app/features/clubs/models/club_model.dart'; // [추가] ClubModel 임포트
import 'package:bling_app/core/models/user_model.dart'; // [추가] UserModel 임포트
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/club_member_card.dart';
import 'package:bling_app/i18n/strings.g.dart';

class ClubMemberList extends StatelessWidget {
  final String clubId;
  final String ownerId;
  const ClubMemberList(
      {super.key, required this.clubId, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final ClubRepository repository = ClubRepository();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool amIOwner = currentUserId == ownerId;

    return Scaffold(
      body: StreamBuilder<ClubModel>(
        // [수정] ClubModel 전체를 감시하여 pendingMembers 목록을 가져옴
        stream: repository.getClubStream(clubId),
        builder: (context, clubSnapshot) {
          if (!clubSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final club = clubSnapshot.data!;
          final pendingMemberIds = club.pendingMembers ?? [];

          return CustomScrollView(
            slivers: [
              // --- [추가] 방장에게만 보이는 '가입 대기' 목록 ---
              if (amIOwner && pendingMemberIds.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(t.clubs.memberList.pendingMembers,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                StreamBuilder<List<UserModel>>(
                  stream: repository.fetchPendingMembers(pendingMemberIds),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final pendingMembers = snapshot.data!;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final member = pendingMembers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                  backgroundImage: (member.photoUrl != null &&
                                          member.photoUrl!.isNotEmpty)
                                      ? NetworkImage(member.photoUrl!)
                                      : null),
                              title: Text(member.nickname),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () =>
                                          repository.rejectPendingMember(
                                              clubId, member.uid)),
                                  IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () =>
                                          repository.approvePendingMember(
                                              clubId, member.uid)),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: pendingMembers.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: Divider(height: 32)),
              ],

              // --- 기존 '정식 멤버' 목록 ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(t.clubs.memberList.allMembers,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              StreamBuilder<List<ClubMemberModel>>(
                stream: repository.fetchMembers(clubId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final members = snapshot.data!;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = members[index];
                        return ClubMemberCard(
                            member: member,
                            clubId: clubId,
                            clubOwnerId: ownerId);
                      },
                      childCount: members.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

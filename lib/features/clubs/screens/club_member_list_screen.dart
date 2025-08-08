// lib/features/clubs/widgets/club_member_list.dart

import 'package:bling_app/core/models/club_member_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:flutter/material.dart';
import '../widgets/club_member_card.dart';

class ClubMemberList extends StatelessWidget {
  final String clubId;
  final String ownerId; // [추가] 방장 ID를 받습니다.
  const ClubMemberList({super.key, required this.clubId, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final ClubRepository repository = ClubRepository();
    return Scaffold(
      // [수정] 멤버 목록 화면에는 별도의 AppBar가 필요 없으므로 제거합니다.
      // appBar: AppBar(...),
      body: StreamBuilder<List<ClubMemberModel>>(
        stream: repository.fetchMembers(clubId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('멤버 목록을 불러오는 중 오류가 발생했습니다.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 멤버가 없습니다.'));
          }

          final members = snapshot.data!;
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              // [수정] 각 멤버 카드에 방장 ID를 전달합니다.
              return ClubMemberCard(
                member: member,
                clubOwnerId: ownerId,
                clubId: clubId,
              );
            },
          );
        },
      ),
    );
  }
}
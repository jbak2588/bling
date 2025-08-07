// lib/features/clubs/screens/clubs_screen.dart

import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:flutter/material.dart';
// TODO: 나중에 만들 동호회 생성 화면
// import 'create_club_screen.dart'; 

class ClubsScreen extends StatelessWidget {
  final UserModel? userModel;
  const ClubsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    // Repository 인스턴스 생성
    final ClubRepository clubRepository = ClubRepository();

    return Scaffold(
      body: StreamBuilder<List<ClubModel>>(
        // 1단계에서 만든 fetchClubs 함수를 호출하여 동호회 목록을 실시간으로 받습니다.
        stream: clubRepository.fetchClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // TODO: 다국어
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 동호회가 없습니다.')); // TODO: 다국어
          }

          final clubs = snapshot.data!;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              // 2단계에서 만든 ClubCard 위젯으로 각 동호회를 표시합니다.
              return ClubCard(club: club);
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: 동호회 생성 화면으로 이동하는 로직
      //     // Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateClubScreen()));
      //   },
      //   child: const Icon(Icons.add),
      //   tooltip: '새 동호회 만들기', // TODO: 다국어
      // ),
    );
  }
}
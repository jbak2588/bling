// lib/features/clubs/screens/clubs_screen.dart

import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubsScreen extends StatelessWidget {
  final UserModel? userModel;
  const ClubsScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ClubRepository clubRepository = ClubRepository();

    return Scaffold(
      body: StreamBuilder<List<ClubModel>>(
        stream: clubRepository.fetchClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('clubs.screen.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('clubs.screen.empty'.tr()));
          }

          final clubs = snapshot.data!;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return ClubCard(club: club);
            },
          );
        },
      ),
    );
  }
}

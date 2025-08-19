// lib/features/real_estate/screens/real_estate_screen.dart

import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:bling_app/features/real_estate/widgets/room_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_room_listing_screen.dart'; // [추가] 매물 등록 화면 임포트

class RealEstateScreen extends StatelessWidget {
  final UserModel? userModel;
  const RealEstateScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final RoomRepository roomRepository = RoomRepository();

    return Scaffold(
      body: StreamBuilder<List<RoomListingModel>>(
        stream: roomRepository.fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'realEstate.error'.tr(namedArgs: {'error': snapshot.error.toString()}),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('realEstate.empty'.tr()));
          }

          final rooms = snapshot.data!;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return RoomCard(room: room);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userModel != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CreateRoomListingScreen(userModel: userModel!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'realEstate.create'.tr(),
        child: const Icon(Icons.add_home_outlined),
      ),
    );
  }
}
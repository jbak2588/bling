// lib/features/auction/screens/auction_screen.dart

import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_auction_screen.dart';

class AuctionScreen extends StatelessWidget {
  final UserModel? userModel;
  const AuctionScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final AuctionRepository auctionRepository = AuctionRepository();

    return Scaffold(
      body: StreamBuilder<List<AuctionModel>>(
        stream: auctionRepository.fetchAuctions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('auctions.errors.fetchFailed'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('auctions.empty'.tr()));
          }

          final auctions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // FAB와의 여백 확보
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              final auction = auctions[index];
              return AuctionCard(auction: auction);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateAuctionScreen(userModel: userModel!),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'auctions.create.tooltip'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

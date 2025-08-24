// lib/features/auction/screens/auction_screen.dart

import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/auction/widgets/auction_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart'; // [추가]
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_auction_screen.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class AuctionScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;

  const AuctionScreen({
    this.userModel,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  // [추가] 화면 내부의 필터 상태를 관리합니다.
  late Map<String, String?>? _locationFilter;

  @override
  void initState() {
    super.initState();
    // [추가] HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;
  }

  // [추가] 필터 화면을 여는 함수
  void _openFilter() async {
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (result != null) {
      setState(() => _locationFilter = result);
    }
  }

  // [추가] 필터를 제거하는 함수
  void _clearFilter() {
    setState(() => _locationFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    final AuctionRepository auctionRepository = AuctionRepository();

    return Scaffold(
      body: Column(
        children: [
          // [추가] 필터 관리 UI
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_locationFilter != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filter', // TODO: 다국어
                  onPressed: _clearFilter,
                ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filter', // TODO: 다국어
                onPressed: _openFilter,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<AuctionModel>>(
              // [수정] fetchAuctions 함수에 현재 필터 상태를 전달합니다.
              stream: auctionRepository.fetchAuctions(locationFilter: _locationFilter),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateAuctionScreen(userModel: widget.userModel!),
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
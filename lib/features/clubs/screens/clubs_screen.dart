// lib/features/clubs/screens/clubs_screen.dart

import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/clubs/widgets/club_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ClubsScreen extends StatefulWidget {
  final UserModel? userModel;
  // V V V --- [추가] HomeScreen에서 locationFilter를 전달받습니다 --- V V V
  final Map<String, String?>? locationFilter;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  const ClubsScreen({
    this.userModel,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  // [수정] 화면 내부 필터 상태를 late로 선언합니다.
  late Map<String, String?>? _locationFilter;

  @override
  void initState() {
    super.initState();
    // [수정] 화면이 처음 생성될 때, HomeScreen에서 전달받은 필터 값으로 초기화합니다.
    _locationFilter = widget.locationFilter;
  }

  void _openFilter() async {
    final result = await Navigator.of(context).push<Map<String, String?>>(
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (result != null) {
      setState(() => _locationFilter = result);
    }
  }

  void _clearFilter() {
    setState(() => _locationFilter = null);
  }

  @override
  Widget build(BuildContext context) {
    final ClubRepository clubRepository = ClubRepository();

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_locationFilter != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                  onPressed: _clearFilter,
                ),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filter',
                onPressed: _openFilter,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<ClubModel>>(
              stream:
                  // StreamBuilder는 이제 항상 화면의 최신 _locationFilter 상태를 사용합니다.
                  clubRepository.fetchClubs(locationFilter: _locationFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('clubs.screen.error'.tr(
                          namedArgs: {'error': snapshot.error.toString()})));
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
          ),
        ],
      ),
    );
  }
}
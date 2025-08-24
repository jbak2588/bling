// lib/features/lost_and_found/screens/lost_and_found_screen.dart

import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_lost_item_screen.dart';

// [수정] StatelessWidget -> StatefulWidget으로 변경
class LostAndFoundScreen extends StatefulWidget {
  final UserModel? userModel;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;

  const LostAndFoundScreen({
    this.userModel,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
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
    final LostAndFoundRepository repository = LostAndFoundRepository();

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
                  tooltip: 'Clear Filter',
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
            child: StreamBuilder<List<LostItemModel>>(
              // [수정] fetchItems 함수에 현재 필터 상태를 전달합니다.
              stream: repository.fetchItems(locationFilter: _locationFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('lostAndFound.error'
                          .tr(namedArgs: {'error': snapshot.error.toString()})));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('lostAndFound.empty'.tr()));
                }

                final items = snapshot.data!;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return LostItemCard(item: item);
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateLostItemScreen(userModel: widget.userModel!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
        },
        tooltip: 'lostAndFound.create'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
// lib/features/lost_and_found/screens/lost_and_found_screen.dart

import 'package:bling_app/core/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:bling_app/features/lost_and_found/widgets/lost_item_card.dart';
import 'package:flutter/material.dart';
import 'create_lost_item_screen.dart'; // [추가] 등록 화면 임포트

class LostAndFoundScreen extends StatelessWidget {
  final UserModel? userModel;
  const LostAndFoundScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final LostAndFoundRepository repository = LostAndFoundRepository();

    return Scaffold(
      body: StreamBuilder<List<LostItemModel>>(
        stream: repository.fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // TODO: 다국어
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아직 등록된 분실/습득물이 없습니다.')); // TODO: 다국어
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // V V V --- [수정] 분실/습득물 등록 화면으로 이동하는 로직 --- V V V
          if (userModel != null) {
             Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateLostItemScreen(userModel: userModel!),
                ),
              );
          } else {
            // 로그인하지 않은 사용자에 대한 처리
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인이 필요합니다.'))); // TODO: 다국어
          }
          // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        },
        tooltip: '새 분실/습득물 등록', // TODO: 다국어
        child: const Icon(Icons.add),
      
      ),
    );
  }
}
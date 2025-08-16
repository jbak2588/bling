// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/core/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart'; // [수정] 새로 만든 비디오 플레이어 위젯

class PomScreen extends StatelessWidget {
  final UserModel? userModel;
  const PomScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ShortRepository shortRepository = ShortRepository();

    return Scaffold(
      // [추가] POM 화면에서는 AppBar가 없는 것이 일반적이므로 제거하고,
      // 상태바 아이콘이 잘 보이도록 배경색을 지정합니다.
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<List<ShortModel>>(
          stream: shortRepository.fetchShorts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('pom.errors.fetchFailed'.tr(namedArgs: {'error': snapshot.error.toString()}), style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('pom.empty'.tr(), style: const TextStyle(color: Colors.white)));
            }
      
            final shorts = snapshot.data!;
      
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: shorts.length,
              itemBuilder: (context, index) {
                final short = shorts[index];
                // [수정] 기존 Container를 ShortPlayer 위젯으로 교체합니다.
                return ShortPlayer(short: short);
              },
            );
          },
        ),
      ),
    );
  }
}
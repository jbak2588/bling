// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart';

class PomScreen extends StatelessWidget {
  final UserModel? userModel;
  const PomScreen({this.userModel, super.key});

  @override
  Widget build(BuildContext context) {

    // V V V --- [추가] 정밀 진단을 위한 로그 --- V V V
    debugPrint("--- [진단] pom_screen.dart (전체 페이지)가 다시 빌드되었습니다! ---");

    final ShortRepository shortRepository = ShortRepository();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<List<ShortModel>>(
          future: shortRepository.fetchShortsOnce(),
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
                return ShortPlayer(short: short);
              },
            );
          },
        ),
      ),
    );
  }
}
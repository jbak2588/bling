// lib/features/pom/screens/pom_detail_screen.dart
// 표준 상세 화면 패턴: AppBar + 본문

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/features/pom/screens/pom_screen.dart';
import 'package:flutter/material.dart';

class PomDetailScreen extends StatelessWidget {
  final ShortModel short;
  const PomDetailScreen({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POM'),
      ),
      body: PomScreen(
        userModel: null,
        initialShorts: [short],
        initialIndex: 0,
      ),
    );
  }
}

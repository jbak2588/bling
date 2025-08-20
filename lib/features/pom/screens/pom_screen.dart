// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart';

class PomScreen extends StatefulWidget {
  final UserModel? userModel;
  const PomScreen({this.userModel, super.key});

  @override
  State<PomScreen> createState() => _PomScreenState();
}

class _PomScreenState extends State<PomScreen> {
  final ShortRepository _shortRepository = ShortRepository();
  late Future<List<ShortModel>> _shortsFuture;
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    _shortsFuture = _shortRepository.fetchShortsOnce();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<List<ShortModel>>(
          future: _shortsFuture,
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
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: shorts.length,
              itemBuilder: (context, index) {
                return ShortPlayer(short: shorts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
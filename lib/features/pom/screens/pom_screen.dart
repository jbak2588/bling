// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 영상(POM) 목록을 위치 기반으로 탐색, 필터링, 상세 조회할 수 있습니다.
// - Firestore shorts 컬렉션 구조와 1:1 매칭, AI 인증, 신뢰 등급, 태그, 좋아요/댓글/조회수 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 위치 필터, 상세 조회, AI 인증, 신뢰 등급, 좋아요/댓글/조회수 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 필터링 로직 및 상세 화면 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 부스트, AI 인증 등).
// - 필터 설명 및 에러 메시지 강화, 신뢰 등급/차단/신고 UI 노출 및 기능 강화.
// - 크리에이터/시청자 모두를 위한 UX 개선(댓글/알림/추천 등).
// =====================================================
// lib/features/pom/screens/pom_screen.dart

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart';

class PomScreen extends StatefulWidget {
  final UserModel? userModel;
  final List<ShortModel>? initialShorts;
  final int initialIndex;
  // [추가] HomeScreen에서 locationFilter를 전달받습니다.
  final Map<String, String?>? locationFilter;

  const PomScreen({
    this.userModel,
    this.initialShorts,
    this.initialIndex = 0,
    this.locationFilter, // [추가]
    super.key
  });

  @override
  State<PomScreen> createState() => _PomScreenState();
}

class _PomScreenState extends State<PomScreen> {
  final ShortRepository _shortRepository = ShortRepository();
  late Future<List<ShortModel>>? _shortsFuture;
  late final PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    if (widget.initialShorts == null) {
      // [수정] fetchShortsOnce 함수에 locationFilter를 전달합니다.
      _shortsFuture = _shortRepository.fetchShortsOnce(locationFilter: widget.locationFilter);
    } else {
      _shortsFuture = null;
    }
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
      body: 
          widget.initialShorts != null
              ? _buildPageView(widget.initialShorts!)
              : FutureBuilder<List<ShortModel>>(
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
                  
                    return _buildPageView(shorts);
                  },
                ),
    );
  }

  Widget _buildPageView(List<ShortModel> shorts) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: shorts.length,
      itemBuilder: (context, index) {
        return ShortPlayer(short: shorts[index], userModel: widget.userModel);
      },
    );
  }
}
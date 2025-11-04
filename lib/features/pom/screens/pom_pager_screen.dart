// lib/features/pom/screens/pom_pager_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - '뽐' (Pom) 콘텐츠의 풀스크린(틱톡/릴스 스타일) 상세 뷰어.
// [V3 - 2025-11-04]
// - 'pom_card.dart' (피드 카드)에서 클릭 시 진입.
// - 'PageView.builder'를 통해 'PomPlayer' 위젯들을 상하 스크롤로 관리.
// - 'startIndex'를 받아 사용자가 선택한 항목에서 뷰어 시작.
// - 오버레이 '뒤로가기' 버튼 제공.
// =====================================================

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/features/pom/widgets/pom_player.dart';
import 'package:flutter/material.dart';

/// POM 상세 뷰어: 전달받은 POM 리스트를 상하 스와이프로 탐색 (Reels/TikTok 스타일)
class PomPagerScreen extends StatefulWidget {
  final List<PomModel> poms;
  final int startIndex;
  final UserModel? userModel;

  const PomPagerScreen({
    super.key,
    required this.poms,
    required this.startIndex,
    this.userModel,
  });

  @override
  State<PomPagerScreen> createState() => _PomPagerScreenState();
}

class _PomPagerScreenState extends State<PomPagerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.startIndex.clamp(0, widget.poms.length - 1);
    _pageController = PageController(initialPage: safeIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.poms.length,
            itemBuilder: (context, index) {
              return PomPlayer(
                pom: widget.poms[index],
                userModel: widget.userModel,
                showAppBar: false, // 상위에서 오버레이 백버튼 제공
              );
            },
          ),
          // 오버레이 뒤로가기 버튼
          Positioned(
            top: top + 8,
            left: 8,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

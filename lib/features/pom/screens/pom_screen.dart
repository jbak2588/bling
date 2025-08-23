// 파일 경로: lib/features/pom/screens/pom_screen.dart
import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/short_player.dart';

class PomScreen extends StatefulWidget {
  final UserModel? userModel;
  // [신규] 외부에서 영상 목록과 시작 인덱스를 선택적으로 전달받기 위한 파라미터
  final List<ShortModel>? initialShorts;
  final int initialIndex;

  const PomScreen({
    this.userModel,
    this.initialShorts,
    this.initialIndex = 0, // 기본값은 0
    super.key
  });

  @override
  State<PomScreen> createState() => _PomScreenState();
}

class _PomScreenState extends State<PomScreen> {
  final ShortRepository _shortRepository = ShortRepository();
  // [수정] _shortsFuture를 nullable로 변경하여, 외부 데이터가 있을 땐 초기화하지 않도록 합니다.
  late Future<List<ShortModel>>? _shortsFuture;
  late final PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    // [수정] PageController에 외부에서 받은 initialIndex를 적용합니다.
    _pageController = PageController(initialPage: widget.initialIndex);

    // [수정] 외부에서 영상 목록(initialShorts)을 받지 않았을 경우에만,
    // 기존 방식대로 Firestore에서 직접 데이터를 불러옵니다.
    if (widget.initialShorts == null) {
      _shortsFuture = _shortRepository.fetchShortsOnce();
    } else {
      _shortsFuture = null; // 외부 데이터를 사용할 것이므로 Future는 null로 설정
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
          // [수정] 외부에서 영상 목록(initialShorts)을 받았다면 그것을 바로 사용하고,
          // 받지 못했다면 기존의 안정적인 FutureBuilder 로직을 그대로 사용합니다.
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

  // [신규] PageView를 만드는 로직을 별도 메서드로 분리하여 코드 재사용성을 높입니다.
  Widget _buildPageView(List<ShortModel> shorts) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: shorts.length,
      itemBuilder: (context, index) {
        // [수정] ShortPlayer에 userModel을 전달합니다.
        return ShortPlayer(short: shorts[index], userModel: widget.userModel);
      },
    );
  }
}
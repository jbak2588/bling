// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// 지도 렌더러를 확인하는 함수
Future<void> _ensureGoogleMapRenderer() async {
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await _ensureGoogleMapRenderer();


  // 1. Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 [최종 수정] App Check 활성화 로직 변경
  // 현재 앱이 디버그 모드인지 릴리즈 모드인지에 따라
  // 올바른 App Check 제공자를 선택하도록 명확하게 설정합니다.
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity, // 배포 시 playIntegrity
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest, // 또는 .deviceCheck// 배포 시 App Attest 우선
  );

  try {
    final token = await FirebaseAppCheck.instance.getToken(true);
    debugPrint('AppCheck token (forceRefresh=true): $token');
  } catch (e) {
    debugPrint('AppCheck token fetch error: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ko')],
      path: 'assets/lang',
      fallbackLocale: const Locale('id'),
      child: const BlingApp(),
    ),
  );
}

class BlingApp extends StatelessWidget {
  const BlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bling App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(),
    );
  }
}

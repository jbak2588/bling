// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'dart:io' show Platform;

import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/core/theme/grab_theme.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_ios/google_maps_flutter_ios.dart';

import 'package:bling_app/firebase_options.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 플랫폼별 Google Maps 초기화
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (Platform.isAndroid && mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  } else if (Platform.isIOS && mapsImplementation is GoogleMapsFlutterIOS) {
    // iOS-specific renderer configuration can go here if needed
  }

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ko')],
      path: 'assets/lang',
      fallbackLocale: const Locale('id'),
      startLocale: const Locale('id'),
      child: const BlingApp(),
    ),
  );
}

class BlingApp extends StatelessWidget {
  const BlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: GrabTheme.light(),
      home: const AuthGate(),
    );
  }
}
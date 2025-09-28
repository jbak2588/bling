// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

import 'package:bling_app/firebase_options.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'package:firebase_app_check/firebase_app_check.dart'; // ✅ App Check 패키지 import
import 'package:flutter/foundation.dart'; // debugPrint를 위해 추가



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// ✅ 지도 렌더러를 최신 버전으로 강제하는 코드를 추가합니다.
  // 이 코드는 다른 초기화 코드보다 먼저 실행될 수 있습니다.
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  await EasyLocalization.ensureInitialized();
 // ✅ [핵심 수정] Firebase 초기화 직후, App Check를 활성화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// ✅ [추가] 디버그 토큰을 출력하는 리스너를 등록합니다.
  if (kDebugMode) { // 디버그 모드에서만 실행
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      if (token != null) {
        debugPrint('New App Check Debug Token: $token');
      }
      });
    }

  await FirebaseAppCheck.instance.activate(
   // ✅ 디버그 모드일 때는 debug provider를, 아닐 때는 playIntegrity provider를 사용
  androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // appleProvider: AppleProvider.appAttest, // iOS를 위한 설정
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
      title: 'Bling App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
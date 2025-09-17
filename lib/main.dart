// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bling_app/firebase_options.dart';
import 'package:bling_app/features/auth/screens/auth_gate.dart';

// App Check 토큰이 처음 발급될 때까지 잠깐 대기 (최대 6초)
Future<void> _waitForAppCheckToken({Duration timeout = const Duration(seconds: 6)}) async {
  try {
    final token = await FirebaseAppCheck.instance.onTokenChange
        .firstWhere((t) => t != null)
        .timeout(timeout);
    debugPrint('[AppCheck] first token ready: ${token!.substring(0, 12)}...');
  } catch (_) {
    // 개발 중엔 타임아웃이 나더라도 일단 진행(서버에서 막힐 수 있음)
    debugPrint('[AppCheck] token wait timed out; proceeding anyway.');
  }
}


Future<void> _ensureGoogleMapRenderer() async {
  // 안드로이드 지도의 최신 렌더러를 강제
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

Future<void> _initFirebaseAndAppCheck() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 개발 중에는 Debug Provider, 배포에선 Play Integrity / App Attest 사용
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider:
  //       kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  //   appleProvider:
  //       kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
  // );


  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  FirebaseAppCheck.instance.onTokenChange.listen((t) {
    debugPrint('[AppCheck] token ready? ${t != null}');
  });
  // 최초 토큰 1회 대기(<=6s) – 첫 호출 403 방지
  try {
    await FirebaseAppCheck.instance.onTokenChange
        .firstWhere((t) => t != null)
        .timeout(const Duration(seconds: 6));
    debugPrint('[AppCheck] first token ready');
  } catch (_) {
    debugPrint('[AppCheck] token wait timeout; proceeding');
  }

  // (선택) 디버그에서 토큰 변화를 로깅 — 콘솔 Debug Token 등록용
  if (kDebugMode) {
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      if (token != null) {
        debugPrint('[AppCheck] token length=${token.length}');
      }
    });
  }
}

Future<void> _ensureSignedIn() async {
  // AI 함수 onCall은 request.auth를 요구하므로 최소 익명 로그인 보장
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
    debugPrint('[Auth] Signed in anonymously for AI verification flow.');
  } else {
    debugPrint('[Auth] Already signed in: ${auth.currentUser?.uid}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _ensureGoogleMapRenderer();
  await EasyLocalization.ensureInitialized();

  await _initFirebaseAndAppCheck();
  // App Check 토큰이 한 번이라도 발급될 때까지 잠깐 대기(<=6s)
  await _waitForAppCheckToken();
  await _ensureSignedIn(); // (순서 동일)

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
      title: 'Bling App',
      debugShowCheckedModeBanner: false,

      // 다국어
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      // 기존 진입점 유지
      home: const AuthGate(),
    );
  }
}
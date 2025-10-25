// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'dart:async'; // ✅ uni_links 사용 위해 추가
import 'package:flutter/services.dart'; // ✅ uni_links 사용 위해 추가

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// ✅ uni_links 및 링크 처리 관련 import 추가
import 'package:uni_links/uni_links.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:bling_app/features/local_news/screens/local_news_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.appAttestWithDeviceCheckFallback, // 배포 시 App Attest 우선
  );

  try {
    final token = await FirebaseAppCheck.instance.getToken(true);
    debugPrint('AppCheck token (forceRefresh=true): $token');
  } catch (e) {
    debugPrint('AppCheck token fetch error: $e');
  }

  // ✅ 앱 시작 시 딥 링크 처리 초기화 (runApp 이전)
  await _initUniLinks();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ko')],
      path: 'assets/lang',
      fallbackLocale: const Locale('id'),
      child: const BlingApp(),
    ),
  );
}

// ✅ 네비게이터 키 (BuildContext 없이 네비게이션)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ignore: unused_element
StreamSubscription? _subUniLinks; // uni_links 리스너 구독

// ✅ uni_links 초기화 함수
Future<void> _initUniLinks() async {
  try {
    // 앱이 종료된 상태에서 링크로 열렸을 때 초기 링크 가져오기
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      // 앱 로드가 어느 정도 완료된 후 처리하기 위해 약간의 지연 추가
      // (AuthGate 등을 거쳐 메인 화면이 로드된 후 네비게이션해야 함)
      Future.delayed(
        const Duration(seconds: 2),
        () => _handleDeepLink(initialUri),
      );
    }
  } on PlatformException {
    debugPrint('[Deep Link] Failed to get initial link.');
  } on FormatException catch (e) {
    debugPrint('[Deep Link] Malformed initial link: $e');
  }

  // 앱이 실행 중/백그라운드일 때 링크 수신 리스너 설정
  _subUniLinks = uriLinkStream.listen(
    (Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    },
    onError: (err) {
      debugPrint('[Deep Link] uriLinkStream error: $err');
    },
  );
}

// ✅ 딥 링크 처리 함수
void _handleDeepLink(Uri deepLink) async {
  debugPrint('[Deep Link] Received: $deepLink');
  // 링크 경로 분석 (예: https://blingbling-app.web.app/post/{postId})
  if (deepLink.host == 'blingbling-app.web.app' &&
      deepLink.pathSegments.length >= 2 &&
      deepLink.pathSegments.first == 'post') {
    final postId = deepLink.pathSegments.last;
    debugPrint('[Deep Link] Navigating to post: $postId');

    try {
      // navigatorKey.currentContext 가 null 이 아닐 때 (= 앱 화면이 준비되었을 때) 네비게이션 실행
      if (navigatorKey.currentContext != null) {
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();
        if (postDoc.exists) {
          final post = PostModel.fromFirestore(postDoc);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => LocalNewsDetailScreen(post: post),
            ),
          );
        } else {
          debugPrint('[Deep Link] Post not found for ID: $postId');
        }
      } else {
        debugPrint(
            '[Deep Link] Navigator context not available yet. Navigation skipped.');
      }
    } catch (e) {
      debugPrint('[Deep Link] Error handling deep link: $e');
    }
  }
}

class BlingApp extends StatelessWidget {
  const BlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ 네비게이터 키 설정
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

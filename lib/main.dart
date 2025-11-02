// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'dart:async'; // ✅ StreamSubscription 사용 위해 추가

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// ✅ app_links 및 링크 처리 관련 import 추가 (uni_links 대체)
import 'package:app_links/app_links.dart';
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
  // ignore: deprecated_member_use
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
  await _initAppLinks();

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
// ✅ AppLinks 인스턴스 및 리스너 구독 (uni_links 대체)
final AppLinks _appLinks = AppLinks();
StreamSubscription<Uri>? _subAppLinks; // ignore: unused_element

// ✅ app_links 초기화 함수
Future<void> _initAppLinks() async {
  // 앱이 종료된 상태에서 링크로 열렸을 때 초기 링크 가져오기
  try {
    // 일부 버전에서는 getInitialAppLink가 존재하지 않을 수 있어 dynamic으로 안전 호출
    Uri? initialUri;
    try {
      final dynamic dyn = _appLinks;
      final result = await dyn.getInitialAppLink();
      if (result is Uri) initialUri = result;
    } catch (_) {
      initialUri = null; // 메소드 미존재 혹은 호출 실패
    }
    if (initialUri != null) {
      // debugPrint('[Deep Link] Got initial link: $initialUri');
      _handleDeepLink(initialUri); // 지연 없이 핸들러 호출
    }
  } catch (e) {
    debugPrint('[Deep Link] Error getting initial link: $e');
  }

  // 앱이 실행 중/백그라운드일 때 링크 수신 리스너 설정
  // ignore: unused_field
  _subAppLinks = _appLinks.uriLinkStream.listen(
    (Uri uri) {
      // debugPrint('[Deep Link] Got link via stream: $uri'); // 로그 위치 변경
      _handleDeepLink(uri);
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
      // ✅ Navigator context가 준비될 때까지 짧은 지연과 함께 재시도 (최대 5초)
      int attempts = 0;
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        attempts++;
        bool navigated = false;

        if (navigatorKey.currentState != null &&
            navigatorKey.currentContext != null) {
          timer.cancel();
          debugPrint(
              '[Deep Link] Navigator context ready after ${attempts * 500}ms.');
          final postDoc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          if (postDoc.exists) {
            final post = PostModel.fromFirestore(postDoc);
            debugPrint('[Deep Link] Post found, attempting navigation...');
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => LocalNewsDetailScreen(post: post),
              ),
            );
            navigated = true;
          } else {
            debugPrint('[Deep Link] Post not found for ID: $postId');
          }
        }

        // 최대 시도 횟수 초과 시 타이머 중지
        if (!navigated && attempts >= 10) {
          timer.cancel();
          debugPrint(
              '[Deep Link] Navigator context not available after ${attempts * 500}ms. Navigation skipped.');
        }
      });
    } catch (e) {
      debugPrint('[Deep Link] Error during navigation attempt: $e');
    }
  }
}

class BlingApp extends StatelessWidget {
  final bool isTest; // when true, avoid Firebase-dependent home
  const BlingApp({super.key, this.isTest = false});

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
      home: isTest ? const Scaffold(body: SizedBox()) : const AuthGate(),
    );
  }
}

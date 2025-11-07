// lib/main.dart

/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: Keluharan 기반 지역 슈퍼앱의 메인 레이아웃, Gojek 런처 UX, 직관적 인터페이스, 상단 AppBar/슬라이드탭/Drawer/BottomNavigationBar 구조
/// - 실제 코드 기능: BlingApp의 MaterialApp, 다국어 지원, AuthGate 진입점, 메인 화면 구조는 별도 위젯에서 구현
/// - 비교: 기획의 전체 레이아웃/UX 구조는 main.dart에서 직접 구현되지 않고, 각 화면/네비게이션 위젯에서 분리 관리됨. 다국어, 초기화, 진입점 등은 기획과 일치
library;

import 'dart:async'; // ✅ StreamSubscription 사용 위해 추가
import 'dart:io';

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
import 'package:device_info_plus/device_info_plus.dart';
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

// -----------------------------------------------------------------------------
// DEVELOPMENT NOTE (App Check debug toggle)
//
// This application includes a safe, opt-in toggle to force App Check into
// debug mode during development. Use the build-time flag below to enable
// the debug provider on debug builds only. Do NOT enable this flag for
// release builds and make sure CI/build scripts do not set
// --dart-define=APPCHECK_DEBUG=true for production releases.
//
// To enable while running locally:
//   flutter run -d <device> --dart-define=APPCHECK_DEBUG=true
//
// The flag is intentionally guarded with `kDebugMode` to reduce accidental
// activation, and the code logs debug-only information to help debugging.
// -----------------------------------------------------------------------------
const bool forceAppCheckDebug =
    bool.fromEnvironment('APPCHECK_DEBUG', defaultValue: false);

/// Decide whether to apply the App Check debug token on this runtime.
///
/// This uses lightweight heuristics so you can scope debug tokens to a
/// particular emulator or simulator (for example `emulator-5556`). It first
/// checks environment variables commonly set by host tooling, then falls back
/// to other approaches (commented examples using `device_info_plus`).
Future<bool> _shouldUseDebugToken() async {
  // Only consider enabling debug tokens in debug builds.
  if (!kDebugMode) return false;
  // Helpful debug output while developing: print mode and environment info.
  try {
    debugPrint('DEBUG _shouldUseDebugToken: kDebugMode=$kDebugMode');
    // Print a subset of environment keys we care about to avoid huge logs
    final env = Platform.environment;
    debugPrint(
        'DEBUG Platform.environment.ANDROID_SERIAL=${env['ANDROID_SERIAL'] ?? 'null'}, ANDROID_DEVICE=${env['ANDROID_DEVICE'] ?? 'null'}');
  } catch (_) {}

  try {
    final env = Platform.environment;

    // Android emulator/device serial reported by adb / flutter tool
    final String? androidSerial =
        env['ANDROID_SERIAL'] ?? env['ANDROID_DEVICE'];
    if (androidSerial != null) {
      // Add any test device adb serials here (e.g. 'emulator-5554').
      const allowedAndroid = ['emulator-5554', 'RR8N109B4JM', 'R52T10CZN1X'];
      if (allowedAndroid.contains(androidSerial)) {
        debugPrint(
            'AppCheck debug-token: matched environment Android serial: $androidSerial');
        return true;
      }
    }

    // iOS simulator environment (set by some host tooling)
    final String? simName =
        env['SIMULATOR_DEVICE_NAME'] ?? env['SIMULATOR_UDID'];
    if (simName != null) {
      const allowedIosSimulators = ['iPhone 14', 'iPhone 14 Pro'];
      if (allowedIosSimulators.contains(simName)) {
        debugPrint(
            'AppCheck debug-token: matched environment iOS simulator: $simName');
        return true;
      }
    }
  } catch (_) {
    // ignore
  }

  // For a more reliable approach across platforms, use device_info_plus to
  // identify devices by model or vendor id. The code below uses
  // DeviceInfoPlugin to inspect platform identifiers and compare them to
  // whitelists. Replace the placeholder IDs in `allowedAndroidIds` and
  // `allowedIosIds` with the IDs for your test devices.
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      // Debug: print multiple device_info fields to confirm which id to whitelist
      try {
        debugPrint(
            'DEBUG device_info: id=${info.id}, product=${info.product}, model=${info.model}, brand=${info.brand}, manufacturer=${info.manufacturer}');
      } catch (_) {}
      // `info.id` is a stable id on many devices; some platforms provide
      // `androidId` as well in other versions of the plugin. Replace the
      // placeholder below with the actual androidId from `adb shell settings`.
      final String androidId = info.id;
      // Whitelist device ids for debug-token activation. Add your test
      // device IDs here (e.g. 'R52T10CZN1X').
      const allowedAndroidIds = <String>[
        'RR8N109B4JM',
        '8aae416b0618741d',
        'R52T10CZN1X'
      ];
      if (allowedAndroidIds.contains(androidId)) {
        debugPrint(
            'AppCheck debug-token: matched device_info Android id: $androidId');
        return true;
      }
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final String? iosId = info.identifierForVendor;
      const allowedIosIds = <String>['00008101-000c60380A88001E'];
      if (iosId != null && allowedIosIds.contains(iosId)) {
        debugPrint('AppCheck debug-token: matched device_info iOS id: $iosId');
        return true;
      }
    }
  } catch (_) {
    debugPrint(
        'AppCheck debug-token: device_info_plus check failed or unavailable');
  }
  debugPrint(
      'AppCheck debug-token: no matching heuristic found; debug token disabled');
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await _ensureGoogleMapRenderer();

  // 1. Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check activation: allow forcing debug provider via build-time flag
  // (forceAppCheckDebug) while still requiring debug builds. This lets
  // developers enable debug App Check only when needed via
  // `--dart-define=APPCHECK_DEBUG=true`.
  // NOTE: Never enable this flag for release builds.
  final bool useDebugToken =
      (forceAppCheckDebug && kDebugMode) || await _shouldUseDebugToken();

  await FirebaseAppCheck.instance.activate(
    providerAndroid: useDebugToken
        ? const AndroidDebugProvider(
            debugToken: 'd7fc630c-5342-4f2e-85f5-fdb1ea2b1ded')
        : const AndroidPlayIntegrityProvider(),
    providerApple: useDebugToken
        ? const AppleDebugProvider(
            debugToken: 'd7fc630c-5342-4f2e-85f5-fdb1ea2b1ded')
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
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

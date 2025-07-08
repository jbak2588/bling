// lib/main.dart

import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// firebase_options.dart를 import 합니다. (flutterfire configure 시 자동 생성)
// import 'firebase_options.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩을 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization과 Firebase를 순서대로 초기화합니다.
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart를 사용할 경우 주석 해제
      );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en'), Locale('ko')],
      // 이 경로에 새로운 v2 내용의 다국어 파일들이 위치해야 합니다.
      path: 'assets/lang',
      fallbackLocale: const Locale('id'), // 기본 언어를 인도네시아어로 설정
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
        primarySwatch: Colors.teal, // 색상 가이드는 추후 적용
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // ▼▼▼▼▼ 앱 전체의 기본 폰트를 'Inter'로 설정 ▼▼▼▼▼
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

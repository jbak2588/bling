// lib/main.dart

import 'package:bling_app/features/auth/screens/auth_gate.dart';
// [추가] 우리가 만든 컨트롤러와 Provider 패키지를 임포트합니다.
import 'package:bling_app/features/find_friends/controllers/find_friend_controller.dart';
import 'package:provider/provider.dart';
// [기존 임포트]
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // [수정] runApp의 최상단을 MultiProvider로 감싸줍니다.
    MultiProvider(
      providers: [
        // [추가] 앞으로 앱 전역에서 사용할 컨트롤러(Provider)들을 이 리스트에 추가합니다.
        // 지금은 FindFriendController 하나만 등록합니다.
        ChangeNotifierProvider(create: (context) => FindFriendController()),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('id'), Locale('en'), Locale('ko')],
        path: 'assets/lang',
        fallbackLocale: const Locale('id'),
        startLocale: const Locale('id'),
        child: const BlingApp(),
      ),
    ),
  );
}

class BlingApp extends StatelessWidget {
  const BlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlingApp의 build 메소드 내부는 수정할 필요가 없습니다.
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
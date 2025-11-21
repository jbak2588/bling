// 파일 경로: lib/features/auth/screens/auth_gate.dart
/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: 인증 게이트를 통해 사용자 흐름 제어, 로그인/회원 인증 후 메인 네비게이션 진입
/// - 실제 코드 기능: Firebase 인증 상태에 따라 로그인 또는 메인 네비게이션 화면으로 분기
/// - 비교: 기획의 사용자 흐름 제어가 실제 코드에서 StreamBuilder와 상태 분기로 구현됨
library;

import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart';
import 'package:bling_app/features/user_profile/screens/profile_setup_screen.dart'; // 신규 화면 import
import 'package:bling_app/features/auth/screens/email_verification_screen.dart'; // [수정] 이메일 인증 화면 import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// [수정] 기존 HomeScreen 대신, '뼈대'와 '가구'를 모두 import 합니다.
import 'package:bling_app/features/main_screen/main_navigation_screen.dart';

import 'package:bling_app/features/auth/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // [수정] authStateChanges -> userChanges로 변경하여 이메일 인증 상태 변화 감지
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // [수정] 이메일 인증 여부 확인
          if (!snapshot.data!.emailVerified) {
            return const EmailVerificationScreen();
          }
          return AuthenticatedUserChecker(uid: snapshot.data!.uid);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class AuthenticatedUserChecker extends StatefulWidget {
  final String uid;
  const AuthenticatedUserChecker({super.key, required this.uid});

  @override
  State<AuthenticatedUserChecker> createState() =>
      _AuthenticatedUserCheckerState();
}

class _AuthenticatedUserCheckerState extends State<AuthenticatedUserChecker> {
  late Stream<DocumentSnapshot> _userDocStream;

  @override
  void initState() {
    super.initState();
    _userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDocStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          // Firestore에 유저 데이터가 없으면 동네 인증 화면으로 보냅니다.
          return const NeighborhoodPromptScreen();
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final bool isVerified = userData?['neighborhoodVerified'] ?? false;
        final bool isProfileCompleted = userData?['profileCompleted'] ?? false;

        // 1. 동네 인증이 안 된 경우
        if (!isVerified) {
          return const NeighborhoodPromptScreen();
        }

        // 2. 동네 인증은 했으나, 프로필(필수 정보)이 미완성인 경우
        if (!isProfileCompleted) {
          return const ProfileSetupScreen();
        }

        // 3. 모두 완료된 경우 메인 화면으로 이동
        return const MainNavigationScreen();
      },
    );
  }
}

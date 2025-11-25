// 파일 경로: lib/features/auth/screens/auth_gate.dart
/// [기획 문서: 00 Mainscreen & 런처 & Tab & Drawer QA.md]
/// - 기획 요약: 인증 게이트를 통해 사용자 흐름 제어, 로그인/회원 인증 후 메인 네비게이션 진입
/// - 실제 코드 기능: Firebase 인증 상태에 따라 로그인 또는 메인 네비게이션 화면으로 분기
/// - 비교: 기획의 사용자 흐름 제어가 실제 코드에서 StreamBuilder와 상태 분기로 구현됨
library;
// 파일 경로: lib/features/auth/screens/auth_gate.dart

import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart';
import 'package:bling_app/features/user_profile/screens/profile_setup_screen.dart';
import 'package:bling_app/features/auth/screens/email_verification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bling_app/features/main_screen/main_navigation_screen.dart';
import 'package:bling_app/features/auth/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // ✅ [추가] 테스트 계정 판별 함수 (user1 ~ user15)
  bool _isTestUser(String? email) {
    if (email == null) return false;
    // 정규식 설명:
    // ^user : user로 시작
    // ([1-9]|1[0-5]) : 1~9 또는 10~15 숫자
    // @bling\.com$ : @bling.com으로 끝남
    final RegExp regex = RegExp(r'^user([1-9]|1[0-5])@bling\.com$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          // ✅ [수정] 이메일 인증 확인 로직 (테스트 유저는 건너뜀)
          // "이메일 인증이 안 되어 있고(!emailVerified) AND 테스트 유저도 아니라면(!_isTestUser)"
          // -> 인증 화면으로 보냄.
          // 즉, 테스트 유저는 이 조건이 false가 되어 바로 아래(AuthenticatedUserChecker)로 통과함.
          if (!user.emailVerified && !_isTestUser(user.email)) {
            return const EmailVerificationScreen();
          }

          return AuthenticatedUserChecker(uid: user.uid);
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

// ... (아래 AuthenticatedUserChecker 클래스는 기존과 동일)
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
          return const NeighborhoodPromptScreen();
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final bool isVerified = userData?['neighborhoodVerified'] ?? false;
        final bool isProfileCompleted = userData?['profileCompleted'] ?? false;

        if (!isVerified) {
          return const NeighborhoodPromptScreen();
        }

        if (!isProfileCompleted) {
          return const ProfileSetupScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

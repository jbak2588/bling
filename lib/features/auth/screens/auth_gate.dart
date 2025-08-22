// 파일 경로: lib/features/auth/screens/auth_gate.dart
import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart';
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
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData) {
          return AuthenticatedUserChecker(uid: authSnapshot.data!.uid);
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

        if (isVerified) {
          // [수정] HomeScreen 대신 '뼈대'인 MainNavigationScreen을 반환합니다.
          // 이제 child를 전달할 필요가 없습니다.
          return const MainNavigationScreen();
        } else {
          return const NeighborhoodPromptScreen();
        }
      },
    );
  }
}
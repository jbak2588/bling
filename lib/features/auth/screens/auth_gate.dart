// lib/features/auth/presentation/screens/auth_gate.dart

import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bling_app/features/main_screen/home_screen.dart';
import 'package:bling_app/features/auth/screens/login_screen.dart';

// ▼▼▼▼▼ StatelessWidget -> StatefulWidget으로 변경 ▼▼▼▼▼
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
          // 로그인 상태일 때, '인증된 사용자 확인' 위젯을 호출
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
  // late Future<DocumentSnapshot> _userDocFuture;
  late Stream<DocumentSnapshot> _userDocStream;

  @override
  void initState() {
    super.initState();

    //  _userDocFuture =
    //     FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
        _userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    // return FutureBuilder<DocumentSnapshot>(
    //   future: _userDocFuture,
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

        if (isVerified) {
          return const HomeScreen();
        } else {
          return const NeighborhoodPromptScreen();
        }
      },
    );
  }
}

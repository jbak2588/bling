import 'dart:async';
import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      _sendVerificationEmail();

      // 3초마다 이메일 인증 상태 확인
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    // Firebase User 정보를 새로고침해야 emailVerified 상태가 업데이트됨
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      _isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      _timer?.cancel();
      // 인증 완료 시 AuthGate로 이동 (또는 AuthGate가 스트림으로 감지)
      // 여기서는 명시적 이동보다는 AuthGate가 감지하도록 둠
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        setState(() => _canResendEmail = false);
        // 1분 후 재전송 가능
        await Future.delayed(const Duration(seconds: 60));
        if (mounted) setState(() => _canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.signupFailUnknown)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이미 인증되었다면 메인으로 (AuthGate가 처리하겠지만 안전장치)
    if (_isEmailVerified) {
      return const AuthGate();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.signup.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                FirebaseAuth.instance.signOut(), // 잘못된 이메일일 경우 로그아웃
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                size: 80, color: Color(0xFF00A66C)),
            const SizedBox(height: 24),
            Text(
              t.signup.title,
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              // Use signup subtitle as a fallback and show email below
              '${t.signup.subtitle}\n${FirebaseAuth.instance.currentUser?.email ?? ''}',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _canResendEmail ? _sendVerificationEmail : null,
              icon: const Icon(Icons.email),
              label: const Text('Resend'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text(t.drawer.logout),
            ),
          ],
        ),
      ),
    );
  }
}

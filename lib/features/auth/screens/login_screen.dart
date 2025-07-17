// lib/features/auth/screens/login_screen.dart
// bling_app Version 0.4

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';

// import 'profile_edit_screen.dart'; // 삭제됨
import 'signup_screen.dart';
import '../../../core/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 이메일 로그인 로직
  Future<void> _loginWithEmail() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // ▼▼▼▼▼ 새로운 다국어 키를 사용하여 에러 메시지 처리 ▼▼▼▼▼
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential': // 일반적인 로그인 실패
          errorMessage = 'login.alerts.userNotFound'.tr();
          break;
        case 'wrong-password':
          errorMessage = 'login.alerts.wrongPassword'.tr();
          break;
        case 'invalid-email':
          errorMessage = 'login.alerts.invalidEmail'.tr();
          break;
        default:
          errorMessage = 'login.alerts.unknownError'.tr();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('login.alerts.unknownError'.tr())));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // 구글 로그인 로직 (변경 없음)
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null) {
        // 신규 가입자일 경우 UserModel 생성
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          final newUser = UserModel(
            uid: result.user!.uid,
            nickname: result.user!.displayName ?? 'Bling User',
            email: result.user!.email ?? '',
            photoUrl: result.user!.photoURL,
            createdAt: Timestamp.now(),
            isDatingProfile: false, // 추가된 필수 매개변수
          );
          await userDocRef.set(newUser.toJson());
        }
        // 로그인 성공 후 별도 라우팅 없이 AuthGate에 위임
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('login.alerts.unknownError'.tr())));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Bling 로고 그라데이션 (변경 없음)
  Shader get blingGradient => const LinearGradient(
        colors: [Color(0xFF5AE6FF), Color(0xFFFF6AA4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, 220, 80));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "BLING!",
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  foreground: Paint()..shader = blingGradient,
                ),
              ),
              const SizedBox(height: 14),
              // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
              Text(
                'login.subtitle'.tr(), // 'loginSubtitle' -> 'login.subtitle'

                style: GoogleFonts.inter(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'login.emailHint'.tr(),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      style: GoogleFonts.montserrat(),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'login.passwordHint'.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      obscureText: !_showPassword,
                      style: GoogleFonts.montserrat(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithEmail,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.teal.shade400,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
                            : Text(
                                'login.buttons.login'.tr(),
                                style: GoogleFonts.inter(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        icon: Image.asset('assets/icons/google_logo.png',
                            height: 20, width: 20),
                        // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
                        label: Text(
                          'login.buttons.google'.tr(),
                          style: GoogleFonts.montserrat(),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      child: Text.rich(
                        TextSpan(
                          // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
                          text: '${'login.links.askForAccount'.tr()} ',
                          style: GoogleFonts.montserrat(
                              color: Colors.grey.shade700),
                          children: [
                            TextSpan(
                              // ▼▼▼▼▼ 다국어 키 수정 ▼▼▼▼▼
                              text: 'login.links.signUp'.tr(),
                              style: TextStyle(
                                  color: Colors.teal.shade600,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/auth/screens/login_screen.dart
// bling_app Version 0.4

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io'; // [추가] Platform 확인용
import 'dart:math'; // [추가] Nonce 생성용
import 'dart:convert'; // [추가] SHA256 해싱용
import 'package:crypto/crypto.dart'; // [추가] SHA256
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // [추가] Apple Login

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

  // [추가] Apple 로그인용 Nonce 생성 헬퍼 함수
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // [추가] SHA256 해싱 헬퍼 함수
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // [추가] Apple 로그인 로직
  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // 1. Apple 서버에 인증 요청
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // 2. Firebase Credential 생성
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // 3. Firebase 로그인
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (result.user != null) {
        // 신규 가입자 처리 로직 (기존 구글 로그인과 동일한 패턴)
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          // Apple은 최초 로그인 시에만 email, fullName을 줍니다.
          // 닉네임 우선순위: Apple이 준 이름 > 없으면 'Apple User'
          String nickname = 'Apple User';
          if (appleCredential.givenName != null) {
            nickname =
                "${appleCredential.givenName} ${appleCredential.familyName ?? ''}"
                    .trim();
          }

          final newUser = UserModel(
            uid: result.user!.uid,
            nickname: nickname,
            email: result.user!.email ?? appleCredential.email ?? '', // 이메일 수집
            photoUrl: null, // Apple은 프로필 사진을 제공하지 않음
            createdAt: Timestamp.now(),
          );
          await userDocRef.set(newUser.toJson());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('login.alerts.unknownError'.tr())));
      }
      debugPrint("Apple Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // GoogleSignIn 7.x: singleton 사용

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

  // ✅✅✅ 핵심 수정: 최신 google_sign_in 패키지 사용법으로 변경 ✅✅✅
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. google_sign_in 7.x: 반드시 initialize()를 먼저 호출
      await GoogleSignIn.instance.initialize();

      // 2. authenticate()로 로그인 플로우 시작

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // idToken 추출 (authentication.idToken)
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
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
          );
          await userDocRef.set(newUser.toJson());
        }
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
                      color: Colors.black.withValues(alpha: 0.08),
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
                    const SizedBox(height: 14),
                    // [추가] Apple 로그인 버튼 (iOS만 표시)
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _loginWithApple,
                          icon: const Icon(Icons.apple,
                              size: 24, color: Colors.white),
                          label: Text(
                            'login.buttons.apple'.tr(),
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Apple 브랜드 컬러
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bling_app/i18n/strings.g.dart'; // [New] Import
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_google_maps_webservices/places.dart';
// import 'package:bling_app/api_keys.dart';
// ignore: unused_import
import '../../../core/models/user_model.dart'; // UserModel import

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // final _locationController = TextEditingController(); // Delayed Profile Activation 정책에 따라 위치 입력 제거
  // Map<String, dynamic>? _gpsLocationCache; // Delayed Profile Activation 정책에 따라 위치 입력 제거
  // final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey); // Delayed Profile Activation 정책에 따라 위치 입력 제거
  // bool _isGettingLocation = false; // Delayed Profile Activation 정책에 따라 위치 입력 제거
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // _locationController.dispose(); // Delayed Profile Activation 정책에 따라 위치 입력 제거
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    if (_nicknameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.auth.signup.fail.required)));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.auth.signup.fail.passwordMismatch)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // [수정] 회원가입 성공 시 이메일 인증 메일 발송 (예외 처리 강화)
      if (credential.user != null && !credential.user!.emailVerified) {
        try {
          await credential.user!.sendEmailVerification();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(t.auth.verification.failSend
                      .replaceAll('{error}', e.toString()))),
            );
          }
          // 이메일 발송 실패는 가입 실패로 간주하지 않고 진행
        }
        // ▼▼▼▼▼ UserModel을 사용하여 기본 필드가 포함된 사용자 문서 생성 ▼▼▼▼▼
        final newUser = UserModel(
          uid: credential.user!.uid,
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          createdAt: Timestamp.now(),
          // 나머지 모든 필드는 모델에 정의된 기본값(null, false, 0, [])으로 자동 설정됩니다.
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toJson());
      }

      if (mounted) {
        // [Mod] Slang generated getter contains '{email}' placeholder — replace manually
        final successMsg = t.auth.signup.successEmailSent.replaceAll(
          '{email}',
          credential.user?.email ?? _emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg)),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = t.auth.signup.fail.kDefault;
      if (e.code == 'weak-password') {
        errorMessage = t.auth.signup.fail.weakPassword;
      } else if (e.code == 'email-already-in-use') {
        errorMessage = t.auth.signup.fail.emailInUse;
      } else if (e.code == 'invalid-email') {
        errorMessage = t.auth.signup.fail.invalidEmail;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.auth.signup.fail.unknown)));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: Text(t.signup.title),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 48,
                    color: Color(0xFF4DD0E1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.signup.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ▼▼▼▼▼ 누락되었던 부제(subtitle) 키 적용 ▼▼▼▼▼
                  Text(
                    t.signup.subtitle,
                    // ▼▼▼▼▼ Inter 폰트로 변경 ▼▼▼▼▼
                    style: GoogleFonts.inter(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                          labelText: t.signup.nicknameHint,
                          prefixIcon: const Icon(Icons.face_outlined))),
                  const SizedBox(height: 18),
                  TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: t.signup.emailHint,
                          prefixIcon: const Icon(Icons.mail_outline)),
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                          labelText: t.signup.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() =>
                                  _passwordVisible = !_passwordVisible)))),
                  const SizedBox(height: 18),
                  TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                          labelText: t.signup.passwordConfirmHint,
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                              icon: Icon(_confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() =>
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible)))),
                  const SizedBox(height: 18),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.teal.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : Text(
                              t.signup.buttons.signup,
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        text: '${t.login.links.askForAccount} ',
                        style:
                            GoogleFonts.montserrat(color: Colors.grey.shade700),
                        children: [
                          TextSpan(
                            text: t.login.buttons.login,
                            style: TextStyle(
                                color: Colors.teal.shade600,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

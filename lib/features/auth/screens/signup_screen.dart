// lib/features/auth/screens/signup_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
// ignore: unused_import
import '../../../core/models/user_model.dart';

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

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // [New] 약관 동의 상태 변수
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _agreedToMarketing = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    // 1. 입력값 검증
    if (_nicknameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.signup.fail.required'.tr())));
      return;
    }

    // 2. 약관 동의 검증
    if (!_agreedToTerms || !_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('signup.agreement.requiredNotice'.tr())));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth.signup.fail.passwordMismatch'.tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Firebase Auth 계정 생성
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text);

      final user = userCredential.user;
      if (user != null) {
        // [New] 4. Firestore에 초기 사용자 정보 및 약관 동의 내역 저장
        // profile_setup_screen에서 나머지 정보를 채우겠지만, 약관 동의 시점 기록을 위해 여기서 미리 생성
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'nickname': _nicknameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'termsAgreed': true, // 필수
          'privacyAgreed': true, // 필수
          'marketingAgreed': _agreedToMarketing, // 선택
          'profileCompleted': false, // 아직 프로필 설정 전
          'trustScore': 0,
          'trustLevel': 'normal',
        });

        // 5. 이메일 인증 발송
        await user.sendEmailVerification();

        if (mounted) {
          // 회원가입 성공 -> AuthGate가 감지하여 화면 전환 (또는 이메일 인증 화면으로 이동)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('auth.verification.success'.tr())));
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'auth.signup.fail.generic'.tr();
      if (e.code == 'weak-password') {
        message = 'auth.signup.fail.weakPassword'.tr();
      } else if (e.code == 'email-already-in-use') {
        message = 'auth.signup.fail.emailInUse'.tr();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [New] 약관 동의 체크박스 위젯
  Widget _buildAgreementRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isRequired = true,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: 약관 상세 보기 바텀시트 or 페이지 이동
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(text: title),
                  TextSpan(
                    text: isRequired
                        ? 'signup.agreement.label.required'.tr()
                        : 'signup.agreement.label.optional'.tr(),
                    style: TextStyle(
                      color: isRequired
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.grey),
          onPressed: () {
            // TODO: 약관 상세 보기 구현
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('signup.title'.tr())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... [기존 입력 필드들: 닉네임, 이메일, 패스워드 등] ...
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'signup.nicknameHint'.tr(),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'signup.emailHint'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                      labelText: 'signup.passwordHint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible))),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                      labelText: 'signup.passwordConfirmHint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                          icon: Icon(_confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() =>
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible))),
                ),
                const SizedBox(height: 24),

                // [New] 약관 동의 섹션
                const Divider(),
                _buildAgreementRow(
                  title: 'signup.agreement.terms'.tr(),
                  value: _agreedToTerms,
                  isRequired: true,
                  onChanged: (v) => setState(() => _agreedToTerms = v!),
                ),
                _buildAgreementRow(
                  title: 'signup.agreement.privacy'.tr(),
                  value: _agreedToPrivacy,
                  isRequired: true,
                  onChanged: (v) => setState(() => _agreedToPrivacy = v!),
                ),
                _buildAgreementRow(
                  title: 'signup.agreement.marketing'.tr(),
                  value: _agreedToMarketing,
                  isRequired: false,
                  onChanged: (v) => setState(() => _agreedToMarketing = v!),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : Text(
                            'signup.buttons.signup'.tr(),
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

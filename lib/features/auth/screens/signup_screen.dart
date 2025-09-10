// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
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

  // Future<void> _handleGpsLocation() async {
  //   try {
  //     setState(() => _isGettingLocation = true);

  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) throw Exception('GPS service is disabled');

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission != LocationPermission.whileInUse &&
  //           permission != LocationPermission.always) {
  //         throw Exception('Location permission denied');
  //       }
  //     }

  //     final position = await Geolocator.getCurrentPosition();
  //     final lat = position.latitude;
  //     final lng = position.longitude;

  //     final response = await _places.searchByText(
  //       '$lat,$lng',
  //       location: Location(lat: lat, lng: lng),
  //       radius: 100,
  //     );
  //     if (!response.isOkay || response.results.isEmpty) {
  //       throw Exception('No reverse geocode result');
  //     }

  //     final detail =
  //         await _places.getDetailsByPlaceId(response.results.first.placeId);
  //     if (!detail.isOkay || detail.result.geometry == null) {
  //       throw Exception('No geometry');
  //     }

  //     final location = detail.result.geometry!.location;
  //     final components = detail.result.addressComponents;

  //     String formatted = detail.result.formattedAddress ?? '';
  //     final fullAddress =
  //         formatted.replaceAll(RegExp(r'^[A-Z0-9+]{6,},?\s*'), '');

  //     String district = '';
  //     for (final type in [
  //       'neighborhood',
  //       'sublocality',
  //       'locality',
  //       'administrative_area_level_2',
  //     ]) {
  //       final match = components.firstWhere(
  //         (c) => c.types.contains(type),
  //         orElse: () => AddressComponent(
  //           longName: '',
  //           shortName: '',
  //           types: [],
  //         ),
  //       );
  //       if (match.longName.isNotEmpty) {
  //         district = match.longName;
  //         break;
  //       }
  //     }

  //     if (!mounted) return;
  //     setState(() {
  //       _locationController.text = fullAddress;
  //       _gpsLocationCache = {
  //         'location': fullAddress,
  //         'district': district,
  //         'latitude': location.lat,
  //         'longitude': location.lng,
  //         'neighborhoodVerified': true,
  //       };
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('location_setting_error'.tr(args: [e.toString()]))),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isGettingLocation = false);
  //   }
  // }

  Future<void> _signUp() async {
    if (_isLoading) return;

    if (_nicknameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('signup_fail_required'.tr())));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('signup_fail_password_mismatch'.tr())));
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

      if (credential.user != null) {
        // ▼▼▼▼▼ UserModel을 사용하여 기본 필드가 포함된 사용자 문서 생성 ▼▼▼▼▼
        final newUser = UserModel(
          uid: credential.user!.uid,
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          createdAt: Timestamp.now(),
          isDatingProfile: false, // 추가된 필수 매개변수
          // 나머지 모든 필드는 모델에 정의된 기본값(null, false, 0, [])으로 자동 설정됩니다.
        );

        await FirebaseFirestore.instance
           .collection('users')
           .doc(credential.user!.uid)
           .set(newUser.toJson());
     
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('signup.alerts.signupSuccessLoginNotice'.tr())));
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'signup_fail_default'.tr();
      if (e.code == 'weak-password') {
        errorMessage = 'signup_fail_weak_password'.tr();
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'signup_fail_email_in_use'.tr();
      } else if (e.code == 'invalid-email') {
        errorMessage = 'signup_fail_invalid_email'.tr();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('signup_fail_unknown'.tr())));
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
        title: Text('signup.title'.tr()),
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
                    color: Colors.black.withOpacity(0.08),
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
                    'signup.title'.tr(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ▼▼▼▼▼ 누락되었던 부제(subtitle) 키 적용 ▼▼▼▼▼
                  Text(
                    'signup.subtitle'.tr(),
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
                          labelText: 'signup.nicknameHint'.tr(),
                          prefixIcon: const Icon(Icons.face_outlined))),
                  const SizedBox(height: 18),
                  TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'signup.emailHint'.tr(),
                          prefixIcon: const Icon(Icons.mail_outline)),
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                          labelText: 'signup.passwordHint'.tr(),
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
                          labelText: 'signup.passwordConfirmHint'.tr(),
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                              icon: Icon(_confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(() =>
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible)))),
                  const SizedBox(height: 18),
                  // ▼▼▼▼▼ 위치 입력 UI 및 안내문구 제거 (Delayed Profile Activation) ▼▼▼▼▼
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //         controller: _locationController,
                  //         decoration: InputDecoration(
                  //           labelText: 'signup.locationHint'.tr(),
                  //           prefixIcon: const Icon(Icons.location_on_outlined),
                  //         ),
                  //       ),
                  //     ),
                  //     IconButton(
                  //       icon: const Icon(Icons.my_location, color: Colors.teal),
                  //       onPressed:
                  //           _isGettingLocation ? null : _handleGpsLocation,
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  //   child: Text(
                  //     'signup.locationNotice'.tr(),
                  //     style: Theme.of(context)
                  //         .textTheme
                  //         .bodySmall
                  //         ?.copyWith(color: Colors.grey[600]),
                  //   ),
                  // ),
                  // ▲▲▲▲▲ 위치 입력 UI 및 안내문구 제거 (Delayed Profile Activation) ▲▲▲▲▲
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
      ),
    );
  }
}

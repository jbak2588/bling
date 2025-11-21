import 'dart:async';
import 'package:bling_app/features/auth/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    // 1. 화면 빌드 후 애니메이션 시작 (Fade In + Scale Up)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // 2. 3초 후 AuthGate(로그인 분기 화면)로 이동
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          curve: Curves.easeOut,
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(seconds: 2),
            curve: Curves.elasticOut,
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // [로고 심볼]
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00A66C).withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.diamond_rounded, // Bling을 상징하는 다이아몬드 아이콘
                    size: 80,
                    color: Color(0xFF00A66C),
                  ),
                ),
                const SizedBox(height: 24),
                // [앱 이름 텍스트]
                Text(
                  'Bling',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00A66C),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                // [슬로건]
                Text(
                  'Find your treasure nearby',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
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

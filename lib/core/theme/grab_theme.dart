import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrabColors {
  static const primary = Color(0xFF00B14F);
  static const primaryDark = Color(0xFF008D40);
  static const secondary = Color(0xFF22C7B8);
  static const accent = Color(0xFFFFC107);
  static const subtext = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const surface = Color(0xFFF8FAFC);
  static const headerGradient = [
    Color(0xFF7CE4A0), Color(0xFF2CD4C7),
  ];
}

class GrabTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: GrabColors.primary,
        primary: GrabColors.primary,
        secondary: GrabColors.secondary,
        surface: GrabColors.surface,
      ),
      scaffoldBackgroundColor: GrabColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: GrabColors.primary,
        unselectedItemColor: GrabColors.subtext,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme),
    );
  }
}

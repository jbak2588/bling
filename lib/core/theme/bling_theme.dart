import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlingColors {
  // Gemini Style Gradient Colors
  static const geminiBlue = Color(0xFF2E67F8);
  static const geminiPink = Color(0xFFE34689);
  static const geminiDeep = Color(0xFF1A1F2C);

  // Main Gradient (Use this for Headers, FABs, Primary Buttons)
  static const primaryGradient = LinearGradient(
    colors: [geminiBlue, geminiPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondary = Color(0xFF6C63FF);
  static const accent = Color(0xFFFFC107);
  static const subtext = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);
  static const surface = Color(0xFFF8FAFC);
  static const error = Color(0xFFEF4444);
}

class BlingTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    // Modern Sans-serif Font
    final TextTheme baseTextTheme =
        GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: BlingColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BlingColors.geminiBlue,
        primary: BlingColors.geminiBlue,
        secondary: BlingColors.secondary,
        surface: BlingColors.surface,
        error: BlingColors.error,
        onSurface: BlingColors.geminiDeep,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: BlingColors.geminiDeep),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: BlingColors.geminiDeep,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: BlingColors.geminiBlue,
        unselectedItemColor: BlingColors.subtext,
        showUnselectedLabels: true,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BlingColors.geminiBlue,
        foregroundColor: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
            color: BlingColors.geminiDeep, fontWeight: FontWeight.bold),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
            color: BlingColors.geminiDeep, fontWeight: FontWeight.bold),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
            color: BlingColors.geminiDeep, fontWeight: FontWeight.bold),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: BlingColors.geminiDeep, fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: BlingColors.geminiDeep, fontWeight: FontWeight.w600),
        bodyLarge:
            baseTextTheme.bodyLarge?.copyWith(color: BlingColors.geminiDeep),
        bodyMedium:
            baseTextTheme.bodyMedium?.copyWith(color: BlingColors.geminiDeep),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: BlingColors.geminiBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: BlingColors.subtext),
      ),
    );
  }
}

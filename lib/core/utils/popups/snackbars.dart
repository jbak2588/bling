// lib/core/utils/popups/snackbars.dart
// NOTE (Engineering Decision):
// This utility currently uses GetX's `Get.snackbar(...)` implementation.
//
// Rationale & migration notes:
// - The codebase contains many Snackbar usages (approx. 218 call-sites across
//   ~58 files, per recent workspace audit). Converting all call-sites to use
//   the `ScaffoldMessenger` pattern (navigatorKey +
//   `ScaffoldMessenger.of(context).showSnackBar(...)`) is a non-trivial,
//   high-risk effort that can introduce numerous runtime errors if done
//   piecemeal (missing contexts, different lifecycles, or assumptions about
//   app-level wrappers like `GetMaterialApp`).
// - To avoid causing an "error bomb" across the app during the current V3 AI
//   verification work, we intentionally defer that migration. If/when we
//   perform the migration, prefer a single coordinated change:
//     1) Add a global `navigatorKey` to `MaterialApp`.
//     2) Replace this helper implementation with a `ScaffoldMessenger`-based
//        implementation that uses the navigatorKey to obtain a context.
//     3) Run automated tests and a repo-wide analysis to update any call-sites
//        that rely on `Get`-specific behavior.
// - For now: keep GetX snackbars to minimize risk and focus on the AI
//   verification V3 changes. Document this decision here so future
//   refactorers understand the trade-offs and where to start.
//
// TODO: Schedule and perform the coordinated migration to ScaffoldMessenger
// as part of a dedicated refactor/cleanup sprint. See issue: TKT-REPLACE-SNACKBAR

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX 기반의 공용 스낵바 유틸리티
class BArtSnackBar {
  /// 성공 메시지를 표시합니다.
  static void showSuccessSnackBar(
      {required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[700],
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// 오류 메시지를 표시합니다.
  static void showErrorSnackBar(
      {required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[800],
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4), // 오류는 조금 더 길게
    );
  }
}

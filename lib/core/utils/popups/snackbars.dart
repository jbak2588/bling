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
    // [Task 86 HOTFIX] 'pending' 성공 스낵바가 비동기 catch 블록에서
    // Get.context null 크래시를 일으키는 것을 방지합니다.
    if (Get.context != null && Get.isSnackbarOpen == false) {
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
    } else {
      debugPrint(
          "SNACKBAR FALLBACK LOG (Get.context is null): $title - $message");
    }
  }

  /// 오류 메시지를 표시합니다.
  static void showErrorSnackBar({required String title, String message = ''}) {
    // [V3 HOTFIX] catch 블록 등에서 Get.context가 null이 되어 발생하는
    // 'Null check operator' 크래시를 방지합니다.
    // Get.context가 유효하고, 스낵바가 이미 열려있지 않을 때만 Get.snackbar를 호출합니다.
    if (Get.context != null && Get.isSnackbarOpen == false) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(15),
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } else {
      // GetX 스낵바를 띄울 수 없는 최악의 경우, 최소한 콘솔에는 로그를 남깁니다.
      debugPrint(
          "SNACKBAR FALLBACK LOG (Get.context is null): $title - $message");
    }
  }
}

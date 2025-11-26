// lib/core/utils/popups/snackbars.dart
// [Refactor] Cleaned up migration TODOs — GetX `Get.snackbar` remains in use
// for now to minimize risk. See issue: TKT-REPLACE-SNACKBAR for planned work.

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

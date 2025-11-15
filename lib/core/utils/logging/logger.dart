// lib/core/utils/logging/logger.dart
import 'package:flutter/foundation.dart';

/// 디버그 콘솔에 포맷팅된 로그를 출력하는 간단한 유틸리티 클래스
class Logger {
  // ANSI SGR (Select Graphic Rendition) codes for terminal colors
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';

  /// 정보 (Info) 레벨 로그 (파란색)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_blueℹ️ [INFO] $message$_reset');
    }
  }

  /// 성공 (Success) 레벨 로그 (초록색)
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('$_green✅ [SUCCESS] $message$_reset');
    }
  }

  /// 경고 (Warning) 레벨 로그 (노란색)
  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('$_yellow⚠️ [WARN] $message$_reset');
    }
  }

  /// 오류 (Error) 레벨 로그 (빨간색)
  /// [error] 객체와 [stackTrace]를 선택적으로 받아 상세 내용을 출력합니다.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('$_red❌ [ERROR] $message$_reset');
      if (error != null) {
        debugPrint('$_red     Error: $error$_reset');
      }
      if (stackTrace != null) {
        debugPrint('$_red     Stack: $stackTrace$_reset');
      }
    }
  }
}

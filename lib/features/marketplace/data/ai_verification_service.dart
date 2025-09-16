import 'dart:convert';                 // base64Encode
import 'package:camera/camera.dart';   // XFile
import 'package:cloud_functions/cloud_functions.dart';
// lib/features/ai_verification/ai_verification_service.dart
//
// Bling - AI Verification Client Service
// - Cloud Functions (onCall) 호출부를 안전하게 감싸는 서비스 레이어
// - 로그인 보장 + App Check 토큰 대기 + 타임아웃 + 상세 로그 + 예외 매핑
//
// Dependencies:
//   cloud_functions: ^5.x
//   firebase_auth: ^5.x
//   firebase_app_check: ^0.2.x
//
// Usage (예시):
//   final res = await AiVerificationService.verifyFile(File(path));
//   debugPrint('AI result: ${res.toMap()}');
//
//   // 네트워크/프로젝트/리전/이름 즉시 확인
//   await AiVerificationService.ping();

import 'dart:async';
import 'dart:io';


import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Cloud Functions 결과를 도메인 모델로 매핑
class AiVerificationResult {
  final String detectedCategory;
  final String detectedBrand;
  final List<String> detectedFeatures;
  final Map<String, dynamic> priceSuggestion;
  final List<dynamic> damageReports;
  final DateTime lastInspected;

  AiVerificationResult({
    required this.detectedCategory,
    required this.detectedBrand,
    required this.detectedFeatures,
    required this.priceSuggestion,
    required this.damageReports,
    required this.lastInspected,
  });

  factory AiVerificationResult.fromMap(Map<String, dynamic> map) {
    return AiVerificationResult(
      detectedCategory: (map['detectedCategory'] ?? 'Unknown').toString(),
      detectedBrand: (map['detectedBrand'] ?? 'Unknown').toString(),
      detectedFeatures: (map['detectedFeatures'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      priceSuggestion:
          Map<String, dynamic>.from(map['priceSuggestion'] ?? const {}),
      damageReports: (map['damageReports'] as List<dynamic>? ?? const []),
      lastInspected: DateTime.tryParse(map['lastInspected']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'detectedCategory': detectedCategory,
        'detectedBrand': detectedBrand,
        'detectedFeatures': detectedFeatures,
        'priceSuggestion': priceSuggestion,
        'damageReports': damageReports,
        'lastInspected': lastInspected.toIso8601String(),
      };
}

/// Functions 호출 에러를 명확히 전달하기 위한 예외
class AiVerificationException implements Exception {
  final String code;
  final String message;
  final dynamic details;
  AiVerificationException(this.code, this.message, [this.details]);
  @override
  String toString() =>
      'AiVerificationException(code=$code, message=$message, details=$details)';
}

/// AI 검수 호출부 (안전 가드 + 상세 로그 + 타임아웃)
class AiVerificationService {
  // 리전 명시(서버와 일치)
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  /// 네트워크/프로젝트/함수 이름/리전 확인용 핑
  static Future<void> ping({Duration timeout = const Duration(seconds: 10)}) async {
    final sw = Stopwatch()..start();
    debugPrint('[PING] start');
    try {
      await _bootstrap(tokenTimeout: const Duration(seconds: 6));
      final res = await _functions
          .httpsCallable('ping')
          .call()
          .timeout(timeout);
      sw.stop();
      debugPrint('[PING] ok in ${sw.elapsedMilliseconds} ms: ${res.data}');
    } on TimeoutException {
      sw.stop();
      debugPrint('[PING] TIMEOUT after ${sw.elapsedMilliseconds} ms');
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      sw.stop();
      debugPrint(
          '[PING] ERROR in ${sw.elapsedMilliseconds} ms code=${e.code} message=${e.message} details=${e.details}');
      throw AiVerificationException(e.code, e.message ?? 'Functions error', e.details);
    } catch (e, st) {
      sw.stop();
      debugPrint('[PING] UNKNOWN ERROR in ${sw.elapsedMilliseconds} ms: $e\n$st');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> requestAiVerification(
    XFile capturedImage, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    try {
      // 이미지 → base64 (data URL prefix 불필요)
      final bytes = await capturedImage.readAsBytes();
      final b64 = base64Encode(bytes);

      // Functions 리전은 서버와 맞춤(us-central1)
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('onAiVerificationRequest');

      final resp = await callable
          .call(<String, dynamic>{'imageBase64': b64})
          .timeout(timeout);

      return Map<String, dynamic>.from(resp.data as Map);
    } on TimeoutException {
      debugPrint('[AI_CALL] TIMEOUT (client-side)');
      return null;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[AI_CALL] ERROR code=${e.code} message=${e.message} details=${e.details}');
      return null;
    } catch (e, st) {
      debugPrint('[AI_CALL] UNKNOWN ERROR: $e\n$st');
      return null;
    }
  }

  /// 파일에서 읽어 Base64로 변환 후 호출
  static Future<AiVerificationResult> verifyFile(
    File imageFile, {
    bool addDataUrlPrefix = false,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final payload =
        addDataUrlPrefix ? 'data:image/jpeg;base64,$b64' : b64;
    return verifyBase64(payload, timeout: timeout);
  }

  /// 이미 Base64가 준비된 경우(권장: dataURL prefix 없이 순수 base64)
  static Future<AiVerificationResult> verifyBase64(
    String imageBase64, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    await _bootstrap(tokenTimeout: const Duration(seconds: 6));

    // 호출 직전 상태 로그
    debugPrint('[AI_CALL] uid=${FirebaseAuth.instance.currentUser?.uid}');
    final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
    debugPrint('[AI_CALL] appCheckToken? ${appCheckToken != null}');
    debugPrint('[AI_CALL] base64 length=${imageBase64.length}');

    final data = <String, dynamic>{'imageBase64': imageBase64};
    final sw = Stopwatch()..start();
    debugPrint('[AI_CALL] call start');

    try {
      final callable =
          _functions.httpsCallable('onAiVerificationRequest');
      final resp = await callable.call(data).timeout(timeout);
      sw.stop();
      debugPrint('[AI_CALL] SUCCESS in ${sw.elapsedMilliseconds} ms');
      final map = Map<String, dynamic>.from(resp.data as Map);
      return AiVerificationResult.fromMap(map);
    } on TimeoutException {
      sw.stop();
      debugPrint('[AI_CALL] TIMEOUT after ${sw.elapsedMilliseconds} ms');
      rethrow;
    } on FirebaseFunctionsException catch (e) {
      sw.stop();
      debugPrint(
          '[AI_CALL] ERROR in ${sw.elapsedMilliseconds} ms code=${e.code} message=${e.message} details=${e.details}');
      throw AiVerificationException(e.code, e.message ?? 'Functions error', e.details);
    } catch (e, st) {
      sw.stop();
      debugPrint('[AI_CALL] UNKNOWN ERROR in ${sw.elapsedMilliseconds} ms: $e\n$st');
      rethrow;
    }
  }

  /* ───────────────────────────── Private Helpers ─────────────────────────── */

  /// 로그인 보장 + App Check 토큰 1회 수신
  static Future<void> _bootstrap({Duration tokenTimeout = const Duration(seconds: 6)}) async {
    await _ensureSignedIn();
    await _waitForAppCheckToken(timeout: tokenTimeout);
  }

  /// 익명 로그인 보장 (이미 로그인 시 그대로 사용)
  static Future<void> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      debugPrint('[AI_SVC] Signed in anonymously: ${auth.currentUser?.uid}');
    } else {
      debugPrint('[AI_SVC] Using uid=${auth.currentUser!.uid}');
    }
  }

  /// App Check 토큰이 최초로 발급될 때까지 잠깐 대기
  static Future<void> _waitForAppCheckToken({Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final token = await FirebaseAppCheck.instance.onTokenChange
          .firstWhere((t) => t != null)
          .timeout(timeout);
      debugPrint('[AI_SVC] AppCheck token ready: ${token!.substring(0, 12)}...');
    } catch (_) {
      // 대기 타임아웃 시 강제 토큰 갱신 시도(개발 중 편의)
      final token = await FirebaseAppCheck.instance.getToken(true);
      debugPrint('[AI_SVC] getToken fallback => ${token != null}');
    }
  }

  /// 필요 시 data URL 프리픽스 제거(서버도 제거하지만 클라에서 한 번 더 보수적으로 확인)
  static String stripDataUrlPrefix(String base64) {
    return base64.replaceFirst(RegExp(r'^data:image/\w+;base64,'), '');
    // 서버 index.js에서도 같은 작업을 수행하므로 중복되어도 안전합니다.
  }
}

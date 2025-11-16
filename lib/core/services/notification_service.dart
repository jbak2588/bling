// lib/core/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // [Task 114] Get.snackbar 스타일링(Colors)을 위해 추가
import 'package:get/get.dart';

// 알림 클릭 시 이동할 화면들을 임포트합니다.
// (보스께서 Task 77, 78에 업로드하신 파일 기준)
import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart';
import 'package:bling_app/features/admin/screens/report_detail_screen.dart';
// (상품 상세 화면 - 경로는 보스의 프로젝트 구조에 맞게 조정 필요)
import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';

import 'package:bling_app/core/utils/logging/logger.dart';

class NotificationService {
  // --- Singleton Pattern ---
  NotificationService._();
  static final instance = NotificationService._();
  // --- Firebase Instances ---
  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 앱 시작 시 호출할 메인 초기화 함수
  Future<void> init() async {
    // 1. (iOS/Web) 권한 요청
    await _requestPermission();

    // 2. 리스너 설정 (포그라운드, 백그라운드)
    await _initListeners();

    // 3. FCM 토큰을 가져와서 Firestore에 저장
    final token = await _fcm.getToken();
    await _saveTokenToDatabase(token);

    // 4. 토큰 갱신 시 자동 저장 리스너
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  /// 1. 권한 요청
  Future<void> _requestPermission() async {
    if (kIsWeb) return; // 웹은 권한 방식이 다름
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('FCM: User granted permission');
    } else {
      Logger.warn('FCM: User declined or has not accepted permission');
    }
  }

  /// 2. 토큰 저장 (Task 79 백엔드가 가정하는 'fcmTokens' 필드 사용)
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null) return;
    final user = _auth.currentUser;
    if (user == null) return; // 로그인 상태가 아니면 저장 불가

    try {
      // 'fcmTokens' 필드에 이 기기의 토큰을 배열로 추가 (중복 방지)
      await _db.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token])
      });
      Logger.info('FCM: Token saved to Firestore.');
    } catch (e) {
      Logger.error('FCM: Error saving token', error: e);
    }
  }

  /// 3. 알림 리스너 초기화
  Future<void> _initListeners() async {
    // 3a. 앱이 포그라운드(열려있음)일 때
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('FCM: Got a message whilst in the foreground!');
      if (message.notification != null) {
        // [Task 114 HOTFIX] Copilot이 발견한 잠재적 크래시 수정.
        // Task 87/113과 동일하게 Get.context/isSnackbarOpen 안전장치 추가.
        if (Get.context != null && Get.isSnackbarOpen == false) {
          try {
            Get.snackbar(
              message.notification!.title ?? 'New Notification',
              message.notification!.body ?? '',
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 5),
              backgroundColor:
                  Colors.black.withValues(alpha: 0.8), // (UX 일관성을 위해 스타일 추가)
              colorText: Colors.white,
              margin: const EdgeInsets.all(10),
              borderRadius: 8,
            );
          } catch (e) {
            Logger.error('FCM: Error showing Get.snackbar', error: e);
          }
        } else {
          Logger.warn(
              "FCM: Foreground snackbar skipped (context null or snackbar open)");
        }
      }
    });

    // 3b. 앱이 백그라운드/종료 상태에서 알림을 "탭"했을 때
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  /// 4. 알림 탭 시 내비게이션 처리 (Task 79의 'type' 사용)
  void _handleMessageNavigation(RemoteMessage message) {
    Logger.info('FCM: Message tapped, handling navigation...');
    final String? type = message.data['type'];
    final String? productId = message.data['productId'];
    final String? reportId = message.data['reportId'];
    // Use Get navigation only if Get.context (and thus GetMaterialApp) is available.
    if (Get.context != null) {
      try {
        if (type == 'ADMIN_PRODUCT_PENDING' && productId != null) {
          // 관리자: 상품 검토 화면으로 이동
          Get.to(() => AdminProductDetailScreen(productId: productId));
        } else if (type == 'USER_PRODUCT_PENDING' && productId != null) {
          // 판매자: 내 상품 상세 화면으로 이동
          Get.to(() => ProductDetailScreen(productId: productId));
        } else if (type == 'USER_REPORT_SUBMITTED' && reportId != null) {
          // (보너스) 사용자 신고 알림 처리 (Task 78 첨부 파일 기반)
          Get.to(() => ReportDetailScreen(reportId: reportId));
        }
      } catch (e) {
        Logger.error('FCM: Navigation failed using Get.to', error: e);
      }
    } else {
      // 앱이 GetMaterialApp 없이 실행 중이면 강제 네비게이션을 시도하지 않습니다.
      Logger.warn(
          'FCM: Cannot navigate on notification tap because Get.context is null. Message data: ${message.data}');
    }
  }
}

// lib/features/notifications/screens/notification_list_screen.dart
import 'package:bling_app/features/admin/screens/admin_product_detail_screen.dart';
import 'package:bling_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bling_app/features/location/providers/location_provider.dart';

/// Task 95: 사용자의 알림 내역을 보여주는 화면
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final String? _myUid = FirebaseAuth.instance.currentUser?.uid;

  /// 알림을 탭했을 때 처리하는 로직
  void _handleNotificationTap(QueryDocumentSnapshot notification) {
    final data = notification.data() as Map<String, dynamic>;
    final String? type = data['type'];
    final String? productId = data['productId'];
    // (보너스) Task 78의 신고 관련 알림
    final String? reportId = data['reportId'];

    // 1. 알림을 '읽음' 상태로 변경
    if (data['isRead'] == false) {
      notification.reference.update({'isRead': true});
    }

    // 2. [Task 101] Get.to() 대신 표준 Navigator.of(context)를 직접 사용합니다.
    // 이 context는 build 메서드에서 제공되므로 항상 유효합니다.
    if (type == 'ADMIN_PRODUCT_PENDING' && productId != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AdminProductDetailScreen(productId: productId)));
    } else if (type == 'USER_PRODUCT_PENDING' && productId != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId)));
    } else if (type == 'USER_REPORT_SUBMITTED' && reportId != null) {
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: reportId)));
    }
  }

  // [Task 101] _fallbackNavigate 함수는 _handleNotificationTap에 통합되었으므로 제거합니다.

  @override
  Widget build(BuildContext context) {
    // Debug: log localization context to diagnose missing key warnings
    try {
      debugPrint('NotificationListScreen.build - locale: ${context.locale}');
      debugPrint(
          'NotificationListScreen.build - supportedLocales: ${context.supportedLocales}');
      debugPrint(
          'NotificationListScreen.build - localizationDelegates: ${context.localizationDelegates}');
      // Calling .tr() intentionally to show what EasyLocalization resolves at runtime
      final trResult = 'notifications.title'.tr();
      debugPrint(
          "NotificationListScreen.build - 'notifications.title'.tr(): $trResult");
      // Note: avoid calling EasyLocalization.of(context)?.tr(...) as analyzer
      // may not expose a .tr method on the provider type. Use the String.tr() extension above.
    } catch (e, st) {
      debugPrint('NotificationListScreen.build - localization debug error: $e');
      debugPrint('$st');
    }
    if (_myUid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('notifications.title'.tr())),
        body: Center(child: Text('main.errors.loginRequired'.tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()), // "알림"
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Task 94에서 저장한 'notifications' 하위 컬렉션을 실시간으로 읽음
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_myUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50) // 최근 50개만 표시
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('notifications.error'.tr()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            final isNational = context.watch<LocationProvider>().mode ==
                LocationSearchMode.national;
            if (!isNational) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('notifications.empty'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('search.empty.checkSpelling'.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: Text('search.empty.expandToNational'.tr()),
                        onPressed: () => context
                            .read<LocationProvider>()
                            .setMode(LocationSearchMode.national),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('notifications.empty'.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notifDoc = notifications[index];
              final notif = notifDoc.data() as Map<String, dynamic>;

              final String title = notif['title'] ?? '...';
              final String body = notif['body'] ?? '...';
              final Timestamp? timestamp = notif['createdAt'];
              final bool isRead = notif['isRead'] ?? true;
              final String type = notif['type'] ?? '';

              // [Step 2] 관리자 결정 상태 파싱
              final String? status = notif['status']; // 'resolved' etc
              final String? adminDecision =
                  notif['adminDecision']; // 'approved' | 'rejected'

              // [Step 2] 상태에 따른 UI 분기
              IconData iconData = _getIconForType(type);
              Color? iconColor;
              String displayTitle = title;

              if (status == 'resolved') {
                if (adminDecision == 'approved') {
                  iconData = Icons.check_circle;
                  iconColor = Colors.green;
                  displayTitle = '$title (승인됨)';
                } else if (adminDecision == 'rejected') {
                  iconData = Icons.cancel;
                  iconColor = Colors.red;
                  displayTitle = '$title (거절됨)';
                }
              }

              return ListTile(
                // 읽지 않은 알림은 파란색 점 표시
                leading: isRead
                    ? Icon(iconData, color: iconColor)
                    : Badge(
                        child: Icon(iconData, color: iconColor),
                      ),
                title: Text(displayTitle,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: isRead ? Colors.grey[800] : Colors.black,
                      decoration: (adminDecision == 'rejected')
                          ? TextDecoration.lineThrough
                          : null, // 거절된 건은 취소선 효과 (선택 사항)
                      decorationColor: Colors.red,
                    )),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body),
                    if (timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                isThreeLine: true,
                onTap: () => _handleNotificationTap(notifDoc),
              );
            },
          );
        },
      ),
    );
  }

  /// 알림 타입에 맞는 아이콘 반환 (예시)
  IconData _getIconForType(String type) {
    switch (type) {
      case 'ADMIN_PRODUCT_PENDING':
        return Icons.admin_panel_settings_outlined;
      case 'USER_PRODUCT_PENDING':
        return Icons.hourglass_top_outlined;
      case 'USER_REPORT_SUBMITTED':
        return Icons.flag_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  /// 간단한 시간 포맷 함수
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }
}

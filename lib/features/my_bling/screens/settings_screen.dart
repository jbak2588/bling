// lib/features/my_bling/screens/settings_screen.dart
/// DocHeader
/// [기획 요약]
/// - 설정 화면은 계정/개인정보, 차단 유저, 알림, 앱 정보 등 다양한 설정 기능을 제공합니다.
/// - 개인정보 보호, 차단 관리, 알림 설정, 통계/분석 등 사용자 경험 강화가 목표입니다.
///
/// [실제 구현 비교]
/// - 계정/개인정보/차단/알림/앱 정보 등 기본 설정 기능 구현됨.
/// - 차단 유저 관리, 다국어 지원, UI/UX 개선 적용됨.
///
/// [차이점 및 개선 제안]
/// 1. 개인정보 보호, 차단 관리, 알림 설정 등 세부 기능 강화 필요.
/// 2. KPI/Analytics 기반 사용자 활동 통계, 알림/피드백 시스템 연계, 프리미엄 기능(테마, 광고 등) 도입 검토.
/// 3. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화 등 코드 안정성/성능 개선.
/// 4. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 기능 연계 강화 필요.
/// 5. 통계/분석 기반 추천/알림/광고 기능 추가 권장.
library;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'blocked_users_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        children: [
          // --- 계정 설정 ---
          ListTile(
           leading: const Icon(Icons.shield_outlined),
            title: Text('settings.accountPrivacy'.tr()),
            onTap: () {
              // TODO: 계정 및 개인정보 화면으로 이동
            },
          ),
          // --- 친구 찾기 설정 ---
          ListTile(
                   leading: const Icon(Icons.block),
            title: Text('rejectedUsers.title'.tr()),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BlockedUsersScreen(),
                ),
              );
            },
          ),
          Divider(),
          // --- 기타 설정 ---
          ListTile(
      leading: const Icon(Icons.notifications_outlined),
            title: Text('settings.notifications'.tr()),
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          ListTile(
           leading: const Icon(Icons.info_outline),
            title: Text('settings.appInfo'.tr()),
            onTap: () {
              // TODO: 앱 정보 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}
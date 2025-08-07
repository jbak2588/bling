// lib/features/my_bling/screens/settings_screen.dart

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
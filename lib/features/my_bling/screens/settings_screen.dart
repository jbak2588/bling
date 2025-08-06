// lib/features/my_bling/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'blocked_users_screen.dart'; // 방금 만든 차단 사용자 관리 화면 import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'), // TODO: 다국어
      ),
      body: ListView(
        children: [
          // --- 계정 설정 ---
          ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('계정 및 개인정보'), // TODO: 다국어
            onTap: () {
              // TODO: 계정 및 개인정보 화면으로 이동
            },
          ),
          // --- 친구 찾기 설정 ---
          ListTile(
            leading: Icon(Icons.block),
            title: Text('친구요청 거절 사용자 관리'), // TODO: 다국어
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
            leading: Icon(Icons.notifications_outlined),
            title: Text('알림 설정'), // TODO: 다국어
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('앱 정보'), // TODO: 다국어
            onTap: () {
              // TODO: 앱 정보 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}
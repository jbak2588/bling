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
/// ============================================================================
/// Bling DocHeader
/// Module        : MyBling
/// File          : lib/features/my_bling/screens/settings_screen.dart
/// Purpose       : 앱 전반적인 설정(언어, 알림, 개인정보 등)을 관리하는 화면입니다.
/// User Impact   : 사용자가 앱 환경을 자신의 선호에 맞게 최적화할 수 있습니다.
/// Feature Links : NotificationSettingsScreen, AccountPrivacyScreen, AppInfoScreen
/// Data Model    : EasyLocalization (언어), SharedPrefs (기타 설정 - 추후)
/// ============================================================================

library;

import 'package:bling_app/features/my_bling/screens/account_privacy_screen.dart';
import 'package:bling_app/features/my_bling/screens/app_info_screen.dart';
import 'package:bling_app/features/my_bling/screens/blocked_users_screen.dart';
import 'package:bling_app/features/my_bling/screens/notification_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()), // "설정"
      ),
      body: ListView(
        children: [
          // 1. 계정 및 보안
          _buildSectionHeader(context, 'settings.account'.tr()), // "계정"
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('settings.privacy'.tr()), // "개인정보 보호"
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AccountPrivacyScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: Text('settings.blockedUsers'.tr()), // "차단된 사용자"
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const BlockedUsersScreen()));
            },
          ),

          const Divider(),

          // 2. 앱 설정 (알림, 언어)
          _buildSectionHeader(context, 'settings.app'.tr()), // "앱 설정"
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            // JSON 구조에 따라 'settings.notifications'가 객체일 수 있으므로 'settings.notificationsTitle'로 안전하게 사용합니다.
            title: Text(_t('settings.notificationsTitle', '알림 설정')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen()));
            },
          ),
          // ✅ [신규] 언어 설정 메뉴 추가
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text('settings.language'.tr()), // "언어 설정"
            subtitle: Text(_getCurrentLanguageName(context)), // 현재 언어 표시
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSelector(context),
          ),

          const Divider(),

          // 3. 정보 및 지원
          _buildSectionHeader(context, 'settings.info'.tr()), // "정보"
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('settings.appInfo'.tr()), // "앱 정보"
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppInfoScreen()));
            },
          ),

          const SizedBox(height: 24),

          // 로그아웃 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('settings.logout.confirmTitle'.tr()),
                    content: Text('settings.logout.confirmBody'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('common.cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('common.confirm'.tr()),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    // 로그인 화면으로 돌아가기 위해 모든 라우트 제거
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: Text('settings.logout.button'.tr()), // "로그아웃"
            ),
          ),
          const SizedBox(height: 12),

          // 계정 탈퇴 요청 버튼 (즉시 삭제 대신 요청 상태로 기록)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('settings.deleteAccount.confirmTitle'.tr()),
                    content: Text('settings.deleteAccount.confirmBody'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('common.cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('common.confirm'.tr()),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      // ✅ [작업 14] 즉시 삭제 대신 '탈퇴 요청' 상태로 변경
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({
                        'isDeletionRequested': true,
                        'deletionRequestedAt': FieldValue.serverTimestamp(),
                      });

                      // 로그아웃 처리
                      await FirebaseAuth.instance.signOut();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'settings.deleteAccount.requested'.tr())),
                        );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    }
                  } catch (e) {
                    // 실패 시 간단한 피드백
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('common.error_occurred'.tr())),
                      );
                    }
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: Text('settings.deleteAccount.button'.tr()),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getCurrentLanguageName(BuildContext context) {
    final code = context.locale.languageCode;
    switch (code) {
      case 'ko':
        return '한국어';
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
      default:
        return 'English';
    }
  }

  String _t(String key, String defaultValue) {
    final translated = key.tr();
    if (translated == key || translated.isEmpty) return defaultValue;
    return translated;
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _t('settings.languageSelect', '언어 선택'), // 키 이름 변경 (중첩 방지)
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('한국어'),
                trailing: context.locale.languageCode == 'ko'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('ko'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Bahasa Indonesia'),
                trailing: context.locale.languageCode == 'id'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('id'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: context.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

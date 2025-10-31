/// ============================================================================
/// Bling DocHeader
/// Module        : My Bling / Settings
/// File          : lib/features/my_bling/screens/notification_settings_screen.dart
/// Purpose       : 사용자가 앱의 알림 설정을 관리하는 화면입니다.
///
/// 2025-10-30 (작업 4, 7):
///   - '하이브리드 기획안' 3) 푸시 구독 스키마 구현.
///   - 기존 placeholder를 StatefulWidget으로 변경.
///   - Firestore에서 'users.pushPrefs'를 로드하여 UI에 바인딩.
///   - '알림 범위(scope)' Dropdown 및 '구독 태그(tags)' ChoiceChip UI 구현.
///   - 설정 저장 시 'pushPrefs' 맵을 'PushPrefsModel'을 사용해 업데이트.
/// ============================================================================
/// /// 2025-10-31 (작업 4, 7):
///   - '하이브리드 기획안' 3) 푸시 구독 스키마 구현.
///   - 기존 placeholder를 StatefulWidget으로 변경.
///   - Firestore에서 'users.pushPrefs'를 로드하여 UI에 바인딩.
///   - '알림 범위(scope)' Dropdown 및 '구독 태그(tags)' ChoiceChip UI 구현.
///   - 설정 저장 시 'pushPrefs' 맵을 'PushPrefsModel'을 사용해 업데이트.
/// ============================================================================
library;
// (파일 내용...)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// ✅ [푸시 스키마] 태그 목록을 가져오기 위해 AppTags를 import 합니다.
import '../../../core/models/push_prefs_model.dart';
import '../../../core/constants/app_tags.dart';

// ✅ [푸시 스키마] StatelessWidget을 StatefulWidget으로 변경
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true; // 데이터 로딩 상태
  bool _isSaving = false; // 데이터 저장 상태
  // ❌ [수정] Map 대신 PushPrefsModel을 사용합니다.
  // late Map<String, dynamic> _pushPrefs;
  late PushPrefsModel _pushPrefs;
  String _selectedScope = 'kel'; // UI용: 선택된 알림 범위
  Set<String> _selectedTags = {}; // UI용: 선택된 태그 목록

  // 알림 범위 옵션 (기획안 기반)
  final List<String> _scopeOptions = ['rt', 'rw', 'kel', 'kec'];

  // 필터링에 사용할 태그 목록 (local_news_screen.dart와 동일한 로직)
  late final List<TagInfo> _filterableTags;

  @override
  void initState() {
    super.initState();
    // 필터링 UI에 표시할 태그 목록 정의
    const List<String> filterableTagIds = [
      'power_outage',
      'water_outage',
      'traffic_control',
      'weather_warning',
      'flood_alert',
      'air_quality',
      'disease_alert',
      'community_event',
      'question',
      'daily_life',
    ];
    _filterableTags = AppTags.localNewsTags
        .where((tag) => filterableTagIds.contains(tag.tagId))
        .toList();

    _loadSettings();
  }

  // Firestore에서 현재 설정 로드
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // 로그인되지 않은 경우, 기본값 사용
        _pushPrefs = PushPrefsModel(); // ✅
        _selectedScope = 'kel';
        _selectedTags = <String>{};
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['pushPrefs'] != null) {
          // ✅ [수정] Firestore 맵을 PushPrefsModel로 변환
          _pushPrefs = PushPrefsModel.fromMap(
              Map<String, dynamic>.from(doc.data()!['pushPrefs']));
        } else {
          // 사용자는 있지만 pushPrefs가 없는 경우, 기본값 사용
          _pushPrefs = PushPrefsModel();
        }

        // ✅ [수정] 모델에서 UI 상태 로드
        _selectedScope = _pushPrefs.scope;
        _selectedTags = _pushPrefs.tags.toSet();
      }
    } catch (e) {
      debugPrint("Error loading notification settings: $e");
      // 에러 발생 시에도 기본값으로 UI를 초기화
      _pushPrefs = PushPrefsModel(); // ✅
      _selectedScope = 'kel';
      _selectedTags = <String>{};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('settings.notifications.loadError'.tr()),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 변경된 설정 저장
  Future<void> _saveSettings() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // ✅ [수정] 기존 _pushPrefs 모델에서 copyWith를 사용해 변경된 값만 업데이트
      final newPushPrefs = _pushPrefs.copyWith(
        scope: _selectedScope,
        tags: _selectedTags.toList(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'pushPrefs': newPushPrefs.toMap()}); // ✅ .toMap() 사용

      // 원본 상태(_pushPrefs)도 새 설정으로 업데이트
      _pushPrefs = newPushPrefs;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.notifications.saveSuccess'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // 저장 후 뒤로가기
      }
    } catch (e) {
      debugPrint("Error saving notification settings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('settings.notifications.saveError'.tr()),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.notifications'.tr()),
        actions: [
          // 저장 버튼
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white))
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveSettings,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. 알림 범위(Scope) 설정
                Text(
                  'settings.notifications.scopeTitle'.tr(), // '알림 범위'
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'settings.notifications.scopeDescription'
                      .tr(), // '어느 지역 범위까지 알림을 받을지 선택합니다.'
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedScope,
                  items: _scopeOptions.map((scope) {
                    return DropdownMenuItem<String>(
                      value: scope,
                      // 'kel' -> 'Kelurahan', 'rt' -> 'RT' 등으로 표시 (다국어 키 필요)
                      child: Text('settings.notifications.scope.$scope'.tr()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Ignore if null or unchanged
                    if (value == null || value == _selectedScope) return;
                    setState(() {
                      _selectedScope = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText:
                        'settings.notifications.scopeLabel'.tr(), // '범위 선택'
                    border: const OutlineInputBorder(),
                  ),
                ),

                const Divider(height: 48),

                // 2. 동네 소식 태그 구독 설정
                Text(
                  'settings.notifications.tagsTitle'.tr(), // '동네 소식 구독'
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'settings.notifications.tagsDescription'
                      .tr(), // '선택한 주제의 동네 소식이 올라올 때만 알림을 받습니다.'
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _filterableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag.tagId);
                    return ChoiceChip(
                      label:
                          Text('${tag.emoji ?? ''} ${tag.nameKey.tr()}'.trim()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag.tagId);
                          } else {
                            _selectedTags.remove(tag.tagId);
                          }
                        });
                      },
                      selectedColor:
                          Theme.of(context).chipTheme.selectedColor ??
                              Theme.of(context).colorScheme.primary,
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

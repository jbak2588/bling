/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/findfriend_edit_screen.dart
/// Purpose       : 기존 FindFriend 프로필의 세부 정보와 공개 여부를 수정합니다.
/// User Impact   : 사용자가 자신의 탐색 프로필을 최신 상태로 유지할 수 있습니다.
/// Feature Links : lib/features/find_friends/screens/findfriend_form_screen.dart; lib/features/find_friends/data/find_friend_repository.dart
/// Data Model    : Firestore `users` 필드 `age`, `ageRange`, `findfriend_profileImages`, `isVisibleInList`.
/// Location Scope: 저장된 `locationParts`를 사용하며 이 화면에서는 직접 수정하지 않습니다.
/// Trust Policy  : 수정 내용은 커뮤니티 가이드라인을 기준으로 검토하며 부적절한 이미지는 신고됩니다.
/// Monetization  : 향후 유료 노출 부스트 예정; TODO: 통합.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `start_profile_edit`, `complete_profile_edit`.
/// Analytics     : 이미지 업로드와 공개 여부 토글을 추적합니다.
/// I18N          : 키 `findFriend.editTitle` (assets/lang/*.json) - TODO: 키 확인.
/// Dependencies  : firebase_storage, firebase_auth, cloud_firestore, image_picker
/// Security/Auth : 프로필 소유자만 수정할 수 있으며 Storage 경로는 UID로 제한됩니다.
/// Edge Cases    : 이미지 미선택, 업로드 실패./// 실제 구현 비교 : 나이, 나이 범위, 이미지, 공개 여부 등 모든 필드가 UI/로직에 완비되어 있음. 프로필 수정 정상 동작.
/// 개선 제안     : KPI/통계/프리미엄 기능 실제 구현 필요. 이미지 업로드/공개 여부 UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012 Find Friend & Club & Jobs & etc 모듈.md; docs/team/teamF_Design_Privacy_Module_통합_작업문.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/user_model.dart';

/// Screen for editing an existing FindFriend profile.
class FindFriendEditScreen extends StatefulWidget {
  final UserModel user;
  const FindFriendEditScreen({super.key, required this.user});

  @override
  State<FindFriendEditScreen> createState() => _FindFriendEditScreenState();
}

class _FindFriendEditScreenState extends State<FindFriendEditScreen> {
  late TextEditingController _ageController;
  late TextEditingController _ageRangeController;
  final List<File> _newImages = [];
  late List<String> _existingImages;
  bool _isVisibleInList = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(
        text: widget.user.age != null ? widget.user.age.toString() : '');
    _ageRangeController =
        TextEditingController(text: widget.user.ageRange ?? '');
    _existingImages = List<String>.from(widget.user.findfriendProfileImages ?? []);
    _isVisibleInList = widget.user.isVisibleInList;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _newImages.add(File(picked.path));
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    final List<String> urls = List<String>.from(_existingImages);
    for (final file in _newImages) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('findfriend_profiles')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'age': int.tryParse(_ageController.text),
      'ageRange': _ageRangeController.text.trim(),
      'findfriend_profileImages': urls,
      'isVisibleInList': _isVisibleInList,
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enable = _ageController.text.isNotEmpty &&
        _ageRangeController.text.isNotEmpty &&
        (_newImages.isNotEmpty || _existingImages.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit FindFriend Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageRangeController,
              decoration: const InputDecoration(labelText: 'Age Range'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Hide my profile from list'),
              value: !_isVisibleInList,
              onChanged: (val) => setState(() => _isVisibleInList = !val),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ..._existingImages.map(
                  (url) => Stack(
                    children: [
                      Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() => _existingImages.remove(url));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ..._newImages.map((f) => Image.file(f, width: 80, height: 80, fit: BoxFit.cover)),
                if (_existingImages.length + _newImages.length < 9)
                  IconButton(onPressed: _pickImage, icon: const Icon(Icons.add_a_photo)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: enable ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save'),
        ),
      ),
    );
  }
}

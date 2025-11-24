// lib/features/my_bling/screens/profile_edit_screen.dart
/// DocHeader
/// [기획 요약]
/// - 프로필 편집 화면은 닉네임, 소개, 사진, 관심사, 위치, 신뢰등급 등 사용자 정보 편집 기능을 제공합니다.
/// - 신뢰점수, 활동 통계, KPI 등 사용자 경험/신뢰 기반 정보 제공이 목표입니다.
///
/// [실제 구현 비교]
/// - 닉네임/소개/사진/관심사/위치 등 편집, 신뢰등급 표시, Firestore 연동, 다국어 지원, UI/UX 개선 적용됨.
/// - 신뢰점수, KPI, 활동 통계 등은 일부 구현/표시되나, 상세 분석/시각화는 미흡.
///
/// [차이점 및 개선 제안]
/// 1. 신뢰점수, KPI, 활동 통계 등 상세 시각화 및 변화 추이 제공 필요.
/// 2. 프로필 편집 시 실시간 미리보기, 추천 관심사, 신뢰등급 변화 안내, 프리미엄 기능(뱃지, 테마 등) 도입 검토.
/// 3. Firestore 연동 로직 분리, 에러 핸들링 강화, 비동기 최적화, 불필요한 rebuild 최소화 등 코드 안정성/성능 개선.
/// 4. 사용자별 맞춤형 통계/알림/피드백 시스템, 추천 친구/게시물/상품 기능 연계 강화 필요.
/// 5. 신뢰등급 변화, KPI 기반 추천/분석 기능 추가 권장.
library;

import 'dart:io';

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  UserModel? _userModel;
  File? _selectedImage;
  String? _initialPhotoUrl;
  List<String> _interests = [];
  bool _showLocationOnMap = true;
  bool _allowFriendRequests = true;
  bool _isVisibleInList = false; // [v2.1] '동네 친구' 리스트 노출 여부 상태 변수
  bool _isLoading = true;
  bool _isSaving = false;

  final Map<String, List<String>> _interestCategories = {
    'category_creative': [
      'drawing',
      'instrument',
      'photography',
      'writing',
      'crafting',
      'gardening'
    ],
    'category_sports': [
      'soccer',
      'hiking',
      'camping',
      'running',
      'biking',
      'golf',
      'workout'
    ],
    'category_food_drink': [
      'foodie',
      'cooking',
      'baking',
      'coffee',
      'wine',
      'tea'
    ],
    'category_entertainment': ['movies', 'music', 'concerts', 'gaming'],
    'category_growth': ['reading', 'investing', 'language', 'coding'],
    'category_lifestyle': ['travel', 'pets', 'volunteering', 'minimalism'],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists && mounted) {
      _userModel = UserModel.fromFirestore(doc);
      setState(() {
        final um = _userModel;
        _nicknameController.text = um?.nickname ?? '';
        _bioController.text = um?.bio ?? '';
        _phoneController.text = um?.phoneNumber ?? '';
        // ✅✅✅ 핵심 수정: locationParts 맵에서 rt와 rw 값을 가져옵니다. ✅✅✅
        _rtController.text = um?.locationParts?['rt'] ?? '';
        _rwController.text = um?.locationParts?['rw'] ?? '';
        _initialPhotoUrl = um?.photoUrl;
        _interests = List<String>.from(um?.interests ?? []);
        _showLocationOnMap = um?.privacySettings?['showLocationOnMap'] ?? true;
        _allowFriendRequests =
            um?.privacySettings?['allowFriendRequests'] ?? true;
        // [v2.1] 기존 설정값으로 초기화
        _isVisibleInList = um?.isVisibleInList ?? false;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _openLocationSetting() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NeighborhoodPromptScreen()),
    );
    // 돌아오면 간단히 사용자 위치 데이터만 다시 로드
    await _refreshUserData();
  }

  // [작업 9] 동네 설정 화면에서 복귀 시 최신 데이터 로드
  Future<void> _refreshUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        final updatedUser = UserModel.fromFirestore(userDoc);
        setState(() {
          _userModel = updatedUser;
          // 화면에 표시되는 위치 관련 필드들을 갱신
          _rtController.text = updatedUser.locationParts?['rt'] ?? '';
          _rwController.text = updatedUser.locationParts?['rw'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Failed to refresh user data: $e");
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.profileEdit.errors.noUser)));
        setState(() => _isSaving = false);
      }
      return;
    }

    try {
      String? newPhotoUrl = _initialPhotoUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(user.uid);
        await ref.putFile(_selectedImage!);
        newPhotoUrl = await ref.getDownloadURL();
      }

      final Map<String, dynamic> updatedLocationParts =
          Map<String, dynamic>.from(_userModel?.locationParts ?? {});
      updatedLocationParts['rt'] = _rtController.text.trim();
      updatedLocationParts['rw'] = _rwController.text.trim();

      final Map<String, dynamic> dataToUpdate = {
        'nickname': _nicknameController.text.trim(),
        'bio': _bioController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'photoUrl': newPhotoUrl,
        'interests': _interests,
        'locationParts': updatedLocationParts,
        'privacySettings': {
          ...?_userModel?.privacySettings,
          'showLocationOnMap': _showLocationOnMap,
          'allowFriendRequests': _allowFriendRequests,
        },
        // [v2.1] '동네 친구' 노출 여부 저장
        'isVisibleInList': _isVisibleInList,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.profileEdit.successMessage)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.profileEdit.errors.updateFailed
                .replaceAll('{0}', e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.profileEdit.title),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (_initialPhotoUrl != null &&
                                            _initialPhotoUrl!.isNotEmpty
                                        ? NetworkImage(_initialPhotoUrl!)
                                        : null) as ImageProvider<Object>?,
                                child: (_selectedImage == null &&
                                        (_initialPhotoUrl == null ||
                                            _initialPhotoUrl!.isEmpty))
                                    ? const Icon(Icons.person,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon:
                                        const Icon(Icons.camera_alt, size: 20),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                              labelText: t.profileEdit.nicknameHint),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: t.profileEdit.phoneHint),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          decoration: InputDecoration(
                              labelText: t.profileEdit.bioHint),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.profileEdit.locationTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: Colors.grey[600], size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _userModel?.locationName ??
                                          t.profileEdit.locationNotSet,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _openLocationSetting,
                                    child:
                                        Text(t.profileEdit.changeLocation),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _rtController,
                                      decoration: const InputDecoration(
                                        labelText: 'RT',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: _rwController,
                                      decoration: const InputDecoration(
                                        labelText: 'RW',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t.interests.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${_interests.length}/10',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal)),
                          ],
                        ),
                        Text(t.interests.limitInfo,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 8),
                        ..._interestCategories.entries.map((entry) {
                          final categoryKey = entry.key;
                          final interestKeys = entry.value;
                          return ExpansionTile(
                            title: Text(t['interests.$categoryKey'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: interestKeys.map((interestKey) {
                                    final isSelected =
                                        _interests.contains(interestKey);
                                    return FilterChip(
                                      // TODO: Refactor dynamic key above these lines.
                                      label: Text(
                                          t['interests.items.$interestKey'] ?? ''),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            if (_interests.length < 10) {
                                              _interests.add(interestKey);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(t[
                                                        'interests.limit_reached'])),
                                              );
                                            }
                                          } else {
                                            _interests.remove(interestKey);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          );
                        }),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(t.profileEdit.privacy.title,
                            style: theme.textTheme.titleMedium),
                        SwitchListTile(
                          title: Text(t.profileEdit.privacy.showLocation),
                          value: _showLocationOnMap,
                          onChanged: (val) =>
                              setState(() => _showLocationOnMap = val),
                        ),
                        SwitchListTile(
                          title: Text(t.profileEdit.privacy.allowRequests),
                          value: _allowFriendRequests,
                          onChanged: (val) {
                            setState(() {
                              _allowFriendRequests = val;
                            });
                          },
                        ),
                        // [v2.1] '동네 친구' 리스트 노출 토글 (findfriend_form_screen.dart에서 이관)
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text(t.findFriend.showProfileLabel),
                          subtitle: Text(t.findFriend.showProfileSubtitle),
                          value: _isVisibleInList,
                          onChanged: (value) {
                            setState(() => _isVisibleInList = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(t.profileEdit.saveButton),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

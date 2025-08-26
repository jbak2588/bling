/// ============================================================================
/// Bling DocHeader
/// Module        : Find Friend
/// File          : lib/features/find_friends/screens/findfriend_form_screen.dart
/// Purpose       : 관심사와 인구통계를 포함한 FindFriend 프로필을 생성하거나 업데이트합니다.
/// User Impact   : 주민이 취미가 비슷한 동료를 찾는 데 도움을 줍니다.
/// Feature Links : lib/features/find_friends/screens/find_friend_detail_screen.dart; lib/features/find_friends/data/find_friend_repository.dart
/// Data Model    : Firestore `users` 필드 `bio`, `age`, `gender`, `interests`, `findfriend_profileImages`, `ageRange`, `privacySettings.genderPreference`, `isVisibleInList`.
/// Location Scope: 사용자 `locationParts`를 활용해 근접 매칭하며 수동 위치 선택은 없습니다.
/// Trust Policy  : 프로필 공개는 `trustLevel`에 따라 달라지며 부적절한 내용은 신고됩니다.
/// Monetization  : 프로필 노출을 위한 프리미엄 부스트 가능성; TODO: 가격 책정.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `start_profile_create`, `complete_profile_create`, `upload_profile_photo`.
/// Analytics     : 관심사 선택과 공개 여부 토글을 추적합니다.
/// I18N          : 키 `interests.items.*`, `findFriend.bioLabel` (assets/lang/*.json)
/// Dependencies  : firebase_storage, cloud_firestore, image_picker, easy_localization, uuid
/// Security/Auth : 인증된 사용자만 가능하며 Storage 경로는 UID로 제한됩니다.
/// Edge Cases    : 이미지 제한 초과, 나이 범위 미완성.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/012 Find Friend & Club & Jobs & etc 모듈.md; docs/team/teamF_Design_Privacy_Module_통합_작업문.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart'; // import 추가

class FindFriendFormScreen extends StatefulWidget {
  // [수정] super.key 문법 적용
  final UserModel userModel;
  const FindFriendFormScreen({super.key, required this.userModel});

  @override
  State<FindFriendFormScreen> createState() => _FindFriendFormScreenState();
}

class _FindFriendFormScreenState extends State<FindFriendFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 모든 입력 필드를 위한 컨트롤러 및 상태 변수
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  String? _selectedGender;
  List<String> _selectedInterests = [];
  bool _isVisibleInList = true;
  List<dynamic> _profileImages = [];
  RangeValues _currentAgeRange = const RangeValues(20, 40);
  String _selectedGenderPreference = 'all';

  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  final FindFriendRepository _repository = FindFriendRepository();

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
    final user = widget.userModel;
    _bioController = TextEditingController(text: user.bio ?? '');
    _ageController = TextEditingController(text: user.age?.toString() ?? '');
    _selectedGender = user.gender;
    _selectedInterests = user.interests ?? [];
    _isVisibleInList = user.isVisibleInList;
    _profileImages = [user.photoUrl, ...?user.findfriendProfileImages]
        .where((url) => url != null && url.isNotEmpty)
        .toList();
    if (user.ageRange != null && user.ageRange!.contains('-')) {
      final parts = user.ageRange!.split('-');
      _currentAgeRange =
          RangeValues(double.parse(parts[0]), double.parse(parts[1]));
    }
    _selectedGenderPreference =
        user.privacySettings?['genderPreference'] ?? 'all';
  }

  @override
  void dispose() {
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 6 - _profileImages.length);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _profileImages
            .addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final existingUrls = _profileImages.whereType<String>().toList();
      final newFiles = _profileImages.whereType<File>().toList();

      final List<String> newImageUrls = [];
      for (var imageFile in newFiles) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('find_friend_images')
            .child(widget.userModel.uid)
            .child(fileName);
        await ref.putFile(imageFile);
        newImageUrls.add(await ref.getDownloadURL());
      }
      final allImageUrls = [...existingUrls, ...newImageUrls];

      final dataToUpdate = {
        'bio': _bioController.text,
        'interests': _selectedInterests,
        'age': int.tryParse(_ageController.text),
        'gender': _selectedGender,
        'isVisibleInList': _isVisibleInList,
        'ageRange':
            '${_currentAgeRange.start.round()}-${_currentAgeRange.end.round()}',
        'findfriendProfileImages': allImageUrls,
        'isDatingProfile': true,
        'privacySettings.findFriendEnabled': true,
        'privacySettings.genderPreference': _selectedGenderPreference,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _repository.updateUserProfile(widget.userModel.uid, dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("findFriend.saveSuccess".tr())));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${"findFriend.saveFailed".tr()} $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("findFriend.editProfileTitle".tr()),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _saveProfile, child: Text("findFriend.save".tr())),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text("findFriend.profileImagesLabel".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount:
                      _profileImages.length < 6 ? _profileImages.length + 1 : 6,
                  itemBuilder: (context, index) {
                    if (index == _profileImages.length) {
                      return InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey.shade400, size: 32),
                        ),
                      );
                    }
                    final image = _profileImages[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image is String
                              ? Image.network(image, fit: BoxFit.cover)
                              : Image.file(image as File, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () =>
                                setState(() => _profileImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text("findFriend.bioLabel".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "findFriend.bioHint".tr(),
                  ),
                ),
                const SizedBox(height: 24),
                Text("findFriend.ageLabel".tr(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "findFriend.ageHint".tr(),
                  ),
                ),
                const SizedBox(height: 24),
                Text("findFriend.genderLabel".tr(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['male', 'female']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label == 'male'
                                ? "findFriend.genderMale".tr()
                                : "findFriend.genderFemale".tr()), // 수정
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "findFriend.genderHint".tr(),
                  ),
                ),
                const SizedBox(height: 24),

                // V V V --- 이 부분을 아래 코드로 교체해주세요 --- V V V
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("interests.title".tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_selectedInterests.length}/10',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
                Text("interests.limit_info".tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                // 불필요한 toList()를 제거하여 경고를 해결했습니다.
                ..._interestCategories.entries.map((entry) {
                  final categoryKey = entry.key;
                  final interestKeys = entry.value;
                  return ExpansionTile(
                    title: Text("interests.$categoryKey".tr(),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: interestKeys.map((interestKey) {
                            final isSelected =
                                _selectedInterests.contains(interestKey);
                            return FilterChip(
                              label: Text("interests.items.$interestKey".tr()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    if (_selectedInterests.length < 10) {
                                      _selectedInterests.add(interestKey);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "interests.limit_reached"
                                                    .tr())),
                                      );
                                    }
                                  } else {
                                    _selectedInterests.remove(interestKey);
                                  }
                                });
                              },
                            );
                          }).toList(), // Wrap의 children에는 toList()가 필요합니다.
                        ),
                      )
                    ],
                  );
                }),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("findFriend.preferredAgeLabel".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    // [수정] .tr() 함수를 문자열 밖으로 빼내어 올바르게 호출하도록 수정합니다.
                    Text(
                      '${_currentAgeRange.start.round()} - ${_currentAgeRange.end.round()}${"findFriend.preferredAgeUnit".tr()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _currentAgeRange,
                  min: 18,
                  max: 60,
                  divisions: 42,
                  labels: RangeLabels(_currentAgeRange.start.round().toString(),
                      _currentAgeRange.end.round().toString()),
                  onChanged: (RangeValues values) {
                    setState(() => _currentAgeRange = values);
                  },
                ),
                const SizedBox(height: 16),
                Text("findFriend.genderLabel".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'all',
                        label: Text("findFriend.preferredGenderAll".tr()),
                        icon: Icon(Icons.all_inclusive)),
                    ButtonSegment(
                        value: 'male',
                        label: Text("findFriend.genderMale".tr()),
                        icon: Icon(Icons.male)),
                    ButtonSegment(
                        value: 'female',
                        label: Text("findFriend.genderFemale".tr()),
                        icon: Icon(Icons.female)),
                  ],
                  selected: {_selectedGenderPreference},
                  onSelectionChanged: (newSelection) {
                    setState(
                        () => _selectedGenderPreference = newSelection.first);
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("findFriend.showProfileLabel".tr()),
                  value: _isVisibleInList,
                  onChanged: (value) =>
                      setState(() => _isVisibleInList = value),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black54,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}

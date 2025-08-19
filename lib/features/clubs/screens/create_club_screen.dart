// lib/features/clubs/screens/create_club_screen.dart

import 'dart:io'; // [추가] File 클래스 사용
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // [추가] Firebase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // [추가] image_picker
import 'package:uuid/uuid.dart'; // [추가] 고유 파일명 생성
import 'package:easy_localization/easy_localization.dart';

class CreateClubScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateClubScreen({super.key, required this.userModel});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _selectedInterests = [];
  bool _isPrivate = false;
  bool _isSaving = false;
   Map<String, String?>? _selectedLocationParts;

  // V V V --- [추가] 이미지 관련 상태 변수 --- V V V
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  final ClubRepository _repository = ClubRepository();

// [수정] find_friend와 동일한 전체 관심사 목록을 사용합니다.
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // [추가] 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

    Future<void> _selectLocation() async {
    final result = await Navigator.of(context)
        .push<Map<String, String?>>(
            MaterialPageRoute(builder: (_) => const LocationFilterScreen()));
    if (result != null) {
      setState(() => _selectedLocationParts = result);
    }
  }


  // [수정] 동호회 생성 로직 구현

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('clubs.createClub.selectAtLeastOneInterest'.tr())),
      );
      return;
    }
      if (_selectedLocationParts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select location')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl;
      // [수정] 이미지가 선택되었으면 Storage에 업로드
      if (_selectedImage != null) {
        final fileName = const Uuid().v4();
        final ref =
            FirebaseStorage.instance.ref().child('club_images/$fileName');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      final newClub = ClubModel(
        id: '', // ID는 Firestore에서 자동으로 생성됩니다.
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: widget.userModel.uid,
          location: _selectedLocationParts?['kel'] ??
            _selectedLocationParts?['kec'] ??
            _selectedLocationParts?['kab'] ??
            _selectedLocationParts?['kota'] ??
            _selectedLocationParts?['prov'] ??
            'Unknown',
        locationParts: _selectedLocationParts,
        // interests: _selectedInterests, // Removed or renamed as per ClubModel definition
        isPrivate: _isPrivate,
        createdAt: Timestamp.now(),
        membersCount: 1, // 개설자는 자동으로 멤버 1명이 됩니다.
        imageUrl: imageUrl, // [수정] 업로드된 이미지 URL 전달
        mainCategory: _selectedInterests.isNotEmpty
            ? _interestCategories.entries
                .firstWhere(
                  (entry) => entry.value.contains(_selectedInterests.first),
                  orElse: () => _interestCategories.entries.first,
                )
                .key
            : '', // 첫 번째 선택된 관심사의 카테고리, 없으면 빈 문자열
        interestTags: _selectedInterests, // 선택된 관심사 리스트
      );

      await _repository.createClub(newClub);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.createClub.success'.tr()),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'clubs.createClub.fail'.tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ));
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
        title: Text('clubs.createClub.title'.tr()),
        actions: [
          // [수정] _isSaving 상태에 따라 버튼 활성화/비활성화
          if (!_isSaving)
            TextButton(
              onPressed: _createClub,
              child: Text('common.done'.tr()),
            )
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // V V V --- [추가] 대표 이미지 선택 UI --- V V V
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : null,
                        child: _selectedImage == null
                            ? Icon(Icons.groups,
                                size: 40, color: Colors.grey[600])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'clubs.createClub.nameLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'clubs.createClub.nameError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'clubs.createClub.descriptionLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'clubs.createClub.descriptionError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                    ListTile(
                  title: const Text('Location'),
                  subtitle: Text(
                    _selectedLocationParts?['kel'] ??
                        _selectedLocationParts?['kec'] ??
                        _selectedLocationParts?['kab'] ??
                        _selectedLocationParts?['kota'] ??
                        _selectedLocationParts?['prov'] ??
                        'Select location',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectLocation,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("interests.title".tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_selectedInterests.length}/3',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)), // 동호회는 최대 3개로 제한
                  ],
                ),
                const SizedBox(height: 8),
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
                                    if (_selectedInterests.length < 3) {
                                      // 최대 3개 제한
                                      _selectedInterests.add(interestKey);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'clubs.createClub.maxInterests'
                                                    .tr())),
                                      );
                                    }
                                  } else {
                                    _selectedInterests.remove(interestKey);
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
                SwitchListTile(
                  title: Text('clubs.createClub.privateClub'.tr()),
                  subtitle: Text('clubs.createClub.privateDescription'.tr()),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

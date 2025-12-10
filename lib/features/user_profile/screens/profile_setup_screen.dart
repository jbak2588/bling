// lib/features/user_profile/screens/profile_setup_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel? userModel;
  final bool isEditMode;

  const ProfileSetupScreen(
      {super.key, this.userModel, this.isEditMode = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  // 메인 프로필 (1장)
  File? _selectedImageFile;
  String? _currentProfileImageUrl;

  // [추가] 친구 찾기용 추가 사진 (최대 10장)
  List<String> _currentSocialImageUrls = [];
  List<File> _newSocialImageFiles = [];

  bool _isVisibleInList = false;
  bool _isPhoneVerified = false;

  final List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    '운동',
    '여행',
    '맛집',
    '독서',
    '게임',
    '음악',
    '영화',
    '공부',
    '반려동물',
    '카페'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userModel != null) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    final user = widget.userModel!;
    _nicknameController.text = user.nickname;
    _bioController.text = user.bio ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _currentProfileImageUrl = user.photoUrl;

    // [추가] 소셜 이미지 로드
    if (user.findfriendProfileImages != null) {
      _currentSocialImageUrls = List.from(user.findfriendProfileImages!);
    }

    _isVisibleInList = user.isVisibleInList ?? false;
    _isPhoneVerified =
        (user.phoneNumber != null && user.phoneNumber!.isNotEmpty);
    if (user.interests != null) {
      _selectedInterests.addAll(user.interests!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImageFile = File(picked.path));
    }
  }

  // [추가] 소셜용 다중 이미지 선택
  Future<void> _pickSocialImages() async {
    final picker = ImagePicker();
    final int currentCount =
        _currentSocialImageUrls.length + _newSocialImageFiles.length;

    if (currentCount >= 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("최대 10장까지만 등록 가능합니다.")));
      return;
    }

    final List<XFile> pickedList = await picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        int spaceLeft = 10 - currentCount;
        int takeCount =
            pickedList.length > spaceLeft ? spaceLeft : pickedList.length;
        for (int i = 0; i < takeCount; i++) {
          _newSocialImageFiles.add(File(pickedList[i].path));
        }
      });
    }
  }

  void _removeSocialImage(int index, {required bool isNew}) {
    setState(() {
      if (isNew) {
        _newSocialImageFiles.removeAt(index);
      } else {
        _currentSocialImageUrls.removeAt(index);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isVisibleInList) {
      if (_bioController.text.trim().length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("profile.error.bioShort".tr())));
        return;
      }
      if (_selectedInterests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("profile.error.interestEmpty".tr())));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("profile.error.loginRequired".tr());

      // 1. 메인 프로필 사진 업로드 (규칙 준수: userId 폴더 사용)
      String? photoUrl = _currentProfileImageUrl;
      if (_selectedImageFile != null) {
        final ext = p.extension(_selectedImageFile!.path);
        // [Fix] 경로 수정: /{feature}/{userId}/{fileName}
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images/$uid/main_profile$ext');
        await ref.putFile(_selectedImageFile!);
        photoUrl = await ref.getDownloadURL();
      }

      // 2. [추가] 소셜 이미지 업로드
      List<String> finalSocialUrls = List.from(_currentSocialImageUrls);
      if (_newSocialImageFiles.isNotEmpty) {
        for (var file in _newSocialImageFiles) {
          final String fileName =
              "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
          // [Fix] 경로 수정: /{feature}/{userId}/{fileName}
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images/$uid/social/$fileName');
          await ref.putFile(file);
          final String downloadUrl = await ref.getDownloadURL();
          finalSocialUrls.add(downloadUrl);
        }
      }

      final userData = {
        'uid': uid,
        'nickname': _nicknameController.text.trim(),
        'photoUrl': photoUrl,
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'isVisibleInList': _isVisibleInList,
        'bio': _isVisibleInList ? _bioController.text.trim() : null,
        'interests': _isVisibleInList ? _selectedInterests : [],
        // [추가] DB 필드 저장
        'findfriendProfileImages': finalSocialUrls,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!widget.isEditMode) ...{
          'createdAt': FieldValue.serverTimestamp(),
          'trustScore': 0,
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
        }
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("profile.setup.saved".tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? "profile.setup.editTitle".tr()
            : "profile.setup.title".tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... [기존 메인 사진 및 닉네임, 전화번호 UI 유지] ...
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImageFile != null
                        ? FileImage(_selectedImageFile!)
                        : (_currentProfileImageUrl != null
                            ? NetworkImage(_currentProfileImageUrl!)
                            : null) as ImageProvider?,
                    child: (_selectedImageFile == null &&
                            _currentProfileImageUrl == null)
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                    labelText: "profile.field.nickname".tr(),
                    border: const OutlineInputBorder()),
                validator: (val) => (val == null || val.length < 2)
                    ? "profile.error.nicknameShort".tr()
                    : null,
              ),
              const SizedBox(height: 24),
              const Divider(),
              Text("profile.section.trust".tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "profile.field.phone".tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      enabled: !_isPhoneVerified,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isPhoneVerified)
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("profile.desc.smsTodo".tr())));
                        setState(() => _isPhoneVerified = true);
                      },
                      child: Text("profile.field.verify".tr()),
                    )
                  else
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 24),

              // 3. 소셜 프로필 설정 (여기에 다중 이미지 피커 추가)
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("profile.section.social".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("profile.desc.social".tr()),
                value: _isVisibleInList,
                activeThumbColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  setState(() {
                    _isVisibleInList = val;
                  });
                },
              ),

              if (_isVisibleInList) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // [추가] 사진 10장 업로드 UI
                      Text("추가 사진 (최대 10장)",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // 추가 버튼
                            if ((_currentSocialImageUrls.length +
                                    _newSocialImageFiles.length) <
                                10)
                              GestureDetector(
                                onTap: _pickSocialImages,
                                child: Container(
                                  width: 80,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.add_photo_alternate,
                                      color: Colors.grey),
                                ),
                              ),
                            // 기존 이미지들
                            ..._currentSocialImageUrls
                                .asMap()
                                .entries
                                .map((entry) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(entry.value,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeSocialImage(entry.key,
                                          isNew: false),
                                      child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close,
                                              size: 12, color: Colors.white)),
                                    ),
                                  )
                                ],
                              );
                            }),
                            // 새 이미지들
                            ..._newSocialImageFiles
                                .asMap()
                                .entries
                                .map((entry) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(entry.value,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeSocialImage(entry.key,
                                          isNew: true),
                                      child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close,
                                              size: 12, color: Colors.white)),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text("profile.field.bio".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "profile.field.bioHint".tr(),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (val) {
                          if (_isVisibleInList &&
                              (val == null || val.length < 5)) {
                            return "profile.error.bioShort".tr();
                          }
                          return null;
                        },
                      ),
                      // ... [기존 관심사 UI 유지] ...
                      const SizedBox(height: 16),
                      Text("profile.field.interests".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _availableInterests.map((tag) {
                          final isSelected = _selectedInterests.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(tag);
                                } else {
                                  _selectedInterests.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEditMode
                              ? "profile.setup.save".tr()
                              : "profile.setup.start".tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

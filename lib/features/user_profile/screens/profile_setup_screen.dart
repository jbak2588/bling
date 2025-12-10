// lib/features/user_profile/screens/profile_setup_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/location/screens/neighborhood_prompt_screen.dart'; // 위치 설정 연동
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

  // 기본 정보 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rtController = TextEditingController(); // RT 추가
  final TextEditingController _rwController = TextEditingController(); // RW 추가

  // 소셜 정보 컨트롤러
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = false;

  // 메인 프로필 (1장)
  File? _selectedImageFile;
  String? _currentProfileImageUrl;

  // 소셜용 추가 사진 (최대 10장)
  List<String> _currentSocialImageUrls = [];
  final List<File> _newSocialImageFiles = [];

  bool _isVisibleInList = false;
  bool _isPhoneVerified = false;
  bool _showLocationOnMap = true; // 프라이버시 설정
  bool _allowFriendRequests = true; // 프라이버시 설정

  final List<String> _selectedInterests = [];

  // [New] 마케팅 동의 상태 변수
  bool _marketingAgreed = false;
  // [I18n] 다국어 키로 변경 (값은 키, 화면 표시는 tr())
  final List<String> _availableInterestKeys = [
    'sports',
    'travel',
    'foodie',
    'reading',
    'gaming',
    'music',
    'movie',
    'study',
    'pet',
    'cafe'
  ];

  @override
  void initState() {
    super.initState();
    // 데이터 로드: 전달받은 모델이 있으면 사용, 없으면(수정 모드인데 null인 경우) fetch 시도
    if (widget.userModel != null) {
      _loadUserData(widget.userModel!);
    } else if (widget.isEditMode) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _loadUserData(UserModel.fromFirestore(doc));
      }
    }
  }

  void _loadUserData(UserModel user) {
    setState(() {
      _nicknameController.text = user.nickname;
      _bioController.text = user.bio ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _rtController.text = user.locationParts?['rt'] ?? '';
      _rwController.text = user.locationParts?['rw'] ?? '';

      _currentProfileImageUrl = user.photoUrl;
      if (user.findfriendProfileImages != null) {
        _currentSocialImageUrls = List.from(user.findfriendProfileImages!);
      }

      _isVisibleInList = user.isVisibleInList ?? false;
      _isPhoneVerified =
          (user.phoneNumber != null && user.phoneNumber!.isNotEmpty);
      _showLocationOnMap = user.privacySettings?['showLocationOnMap'] ?? true;
      _allowFriendRequests =
          user.privacySettings?['allowFriendRequests'] ?? true;

      // [New] 마케팅 동의 로드
      _marketingAgreed = user.marketingAgreed ?? false;
      if (user.interests != null) {
        _selectedInterests.addAll(user.interests!);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImageFile = File(picked.path));
    }
  }

  Future<void> _pickSocialImages() async {
    final picker = ImagePicker();
    final int currentCount =
        _currentSocialImageUrls.length + _newSocialImageFiles.length;

    if (currentCount >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("profile.error.maxImages".tr(args: ['10']))));
      return;
    }

    final List<XFile> pickedList =
        await picker.pickMultiImage(imageQuality: 80);
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

      // [Storage 룰 통일] 1. 메인 프로필: profile_images/{uid}/main_avatar.{ext}
      String? photoUrl = _currentProfileImageUrl;
      if (_selectedImageFile != null) {
        final ext = p.extension(_selectedImageFile!.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images/$uid/main_avatar$ext'); // 고정 이름 사용 권장
        await ref.putFile(_selectedImageFile!);
        photoUrl = await ref.getDownloadURL();
      }

      // [Storage 룰 통일] 2. 소셜 이미지: profile_images/{uid}/social/{timestamp}.{ext}
      List<String> finalSocialUrls = List.from(_currentSocialImageUrls);
      if (_newSocialImageFiles.isNotEmpty) {
        for (var file in _newSocialImageFiles) {
          final String fileName =
              "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images/$uid/social/$fileName');
          await ref.putFile(file);
          final String downloadUrl = await ref.getDownloadURL();
          finalSocialUrls.add(downloadUrl);
        }
      }

      // 위치 정보 업데이트 (기존 정보 유지하며 RT/RW 수정)
      Map<String, dynamic> locationParts =
          widget.userModel?.locationParts ?? {};
      if (_rtController.text.isNotEmpty) {
        locationParts['rt'] = _rtController.text.trim();
      }
      if (_rwController.text.isNotEmpty) {
        locationParts['rw'] = _rwController.text.trim();
      }

      final userData = {
        'uid': uid,
        'nickname': _nicknameController.text.trim(),
        'photoUrl': photoUrl,
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'locationParts': locationParts, // RT/RW 업데이트 반영

        // Social Fields
        'isVisibleInList': _isVisibleInList,
        'bio': _isVisibleInList ? _bioController.text.trim() : null,
        'interests': _isVisibleInList ? _selectedInterests : [],
        'findfriendProfileImages': finalSocialUrls,

        // Privacy
        'privacySettings': {
          'showLocationOnMap': _showLocationOnMap,
          'allowFriendRequests': _allowFriendRequests,
        },

        // [New] 마케팅 동의 정보 업데이트
        'marketingAgreed': _marketingAgreed,

        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),

        // Initial Fields
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
        // 성공 시 true 반환 (화면 갱신용)
        Navigator.pop(context, true);
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
            ? "profile.setup.editTitle".tr() // "프로필 수정"
            : "profile.setup.title".tr()), // "프로필 설정"
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 메인 프로필 섹션
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
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
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // [New] 2.5 알림 및 마케팅 설정
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('profile.marketing.title'.tr()),
                subtitle: Text('profile.marketing.subtitle'.tr()),
                value: _marketingAgreed,
                activeThumbColor: Theme.of(context).primaryColor,
                onChanged: (val) => setState(() => _marketingAgreed = val),
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                    labelText: "profile.field.nickname".tr(),
                    border: const OutlineInputBorder()),
                validator: (val) => (val == null || val.length < 2)
                    ? "profile.error.nicknameShort".tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 2. 위치 및 인증 섹션
              const Divider(),
              Text("profile.section.locationTrust".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // 위치 정보 (동네 인증된 곳)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.userModel?.locationName ??
                        "profileEdit.locationNotSet".tr()),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NeighborhoodPromptScreen()),
                      );
                      _fetchUserData(); // 위치 변경 후 데이터 갱신
                    },
                    child: Text("profileEdit.changeLocation".tr()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // RT/RW 입력
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rtController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "RT", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rwController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "RW", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 전화번호 인증
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
                      enabled: !_isPhoneVerified, // 인증 완료 시 수정 불가
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isPhoneVerified)
                    ElevatedButton(
                      onPressed: () {
                        // [추후 연동] Phone Auth Logic
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

              // 3. 소셜 프로필 설정
              const Divider(thickness: 4),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("profile.section.social".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("profile.desc.social".tr()),
                value: _isVisibleInList,
                activeThumbColor: Theme.of(context).primaryColor,
                onChanged: (val) {
                  setState(() => _isVisibleInList = val);
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
                      // 사진 10장 업로드
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("profile.field.photos".tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              "${_currentSocialImageUrls.length + _newSocialImageFiles.length} / 10",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
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
                            ..._currentSocialImageUrls
                                .asMap()
                                .entries
                                .map((entry) {
                              return _buildImageThumb(
                                  entry.value,
                                  () => _removeSocialImage(entry.key,
                                      isNew: false),
                                  isFile: false);
                            }),
                            ..._newSocialImageFiles
                                .asMap()
                                .entries
                                .map((entry) {
                              return _buildImageThumb(
                                  entry.value,
                                  () => _removeSocialImage(entry.key,
                                      isNew: true),
                                  isFile: true);
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
                      const SizedBox(height: 16),
                      Text("interests.title".tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _availableInterestKeys.map((key) {
                          final isSelected = _selectedInterests.contains(key);
                          return FilterChip(
                            label: Text("interests.items.$key".tr()), // i18n 적용
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(key);
                                } else {
                                  _selectedInterests.remove(key);
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
              // 프라이버시 설정
              const Divider(),
              SwitchListTile(
                title: Text('profileEdit.privacy.showLocation'.tr()),
                value: _showLocationOnMap,
                onChanged: (val) => setState(() => _showLocationOnMap = val),
              ),
              SwitchListTile(
                title: Text('profileEdit.privacy.allowRequests'.tr()),
                value: _allowFriendRequests,
                onChanged: (val) => setState(() => _allowFriendRequests = val),
              ),

              const SizedBox(height: 24),
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

  Widget _buildImageThumb(dynamic source, VoidCallback onDelete,
      {required bool isFile}) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isFile
                ? Image.file(source as File, fit: BoxFit.cover)
                : Image.network(source as String, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: onDelete,
            child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 12, color: Colors.white)),
          ),
        )
      ],
    );
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
}

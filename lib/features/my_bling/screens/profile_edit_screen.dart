// lib/features/my_bling/screens/profile_edit_screen.dart

import 'dart:io';

import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../location/screens/location_setting_screen.dart';

// [수정] 클래스 이름을 표준화합니다.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // --- 모든 컨트롤러를 통합합니다 ---
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  // --- 모든 상태 변수를 통합합니다 ---
  UserModel? _userModel;
  File? _selectedImage;
  String? _initialPhotoUrl;
  List<String> _interests = [];
  bool _showLocationOnMap = true;
  bool _allowFriendRequests = true;
  bool _isLoading = true;
  bool _isSaving = false;

  // [추가] 표준화된 관심사 카테고리
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

  // [수정] 모든 필드를 불러오도록 로직 통합
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
        _nicknameController.text = _userModel!.nickname;
        _bioController.text = _userModel!.bio ?? '';
        _phoneController.text = _userModel!.phoneNumber ?? '';
        _rtController.text = _userModel!.rt ?? '';
        _rwController.text = _userModel!.rw ?? '';
        _initialPhotoUrl = _userModel!.photoUrl;
        _interests = List<String>.from(_userModel!.interests ?? []);
        _showLocationOnMap =
            _userModel!.privacySettings?['showLocationOnMap'] ?? true;
        _allowFriendRequests =
            _userModel!.privacySettings?['allowFriendRequests'] ?? true;
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
      MaterialPageRoute(builder: (_) => const LocationSettingScreen()),
    );
    await _loadUserData(); // 위치 변경 후 데이터를 다시 불러옵니다.
  }

  // [수정] 모든 필드를 저장하도록 로직 통합
  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profileEdit.errors.noUser'.tr())));
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

      // 2. RT와 RW 값을 추가하거나 업데이트합니다.
      updatedLocationParts['rt'] = _rtController.text.trim();
      updatedLocationParts['rw'] = _rwController.text.trim();

      final Map<String, dynamic> dataToUpdate = {
        'nickname': _nicknameController.text.trim(),
        'bio': _bioController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'photoUrl': newPhotoUrl,
        'interests': _interests,
        'locationParts':
            updatedLocationParts, // 3. 수정된 locationParts 맵 전체를 저장합니다.
        'privacySettings': {
          ...?_userModel?.privacySettings,
          'showLocationOnMap': _showLocationOnMap,
          'allowFriendRequests': _allowFriendRequests,
        },
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('profileEdit.successMessage'.tr())));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'profileEdit.errors.updateFailed'.tr(args: [e.toString()]))));
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
        title: Text('profileEdit.title'.tr()),
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
                              labelText: 'profileEdit.nicknameHint'.tr()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: 'profileEdit.phoneHint'.tr()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bioController,
                          decoration: InputDecoration(
                              labelText: 'profileEdit.bioHint'.tr()),
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
                                "Alamat Terdaftar", // TODO: 다국어
                                style: TextStyle(
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
                                          "Belum diatur", // TODO: 다국어
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _openLocationSetting,
                                    child: const Text("Ubah"), // TODO: 다국어
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
                            Text("interests.title".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${_interests.length}/10',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal)),
                          ],
                        ),
                        Text("interests.limit_info".tr(),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 8),
                        ..._interestCategories.entries.map((entry) {
                          final categoryKey = entry.key;
                          final interestKeys = entry.value;
                          return ExpansionTile(
                            title: Text("interests.$categoryKey".tr(),
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
                                      label: Text(
                                          "interests.items.$interestKey".tr()),
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
                                                    content: Text(
                                                        "interests.limit_reached"
                                                            .tr())),
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
                        Text('profileEdit.privacy.title'.tr(),
                            style: theme.textTheme.titleMedium),
                        SwitchListTile(
                          title: Text('profileEdit.privacy.showLocation'.tr()),
                          value: _showLocationOnMap,
                          onChanged: (val) =>
                              setState(() => _showLocationOnMap = val),
                        ),
                        SwitchListTile(
                          title: Text('profileEdit.privacy.allowRequests'.tr()),
                          value: _allowFriendRequests,
                          onChanged: (val) {
                            setState(() {
                              _allowFriendRequests = val;
                            });
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
                          : Text('profileEdit.saveButton'.tr()),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

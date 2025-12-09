// [Diff/Full] lib/features/user_profile/screens/profile_setup_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart'; // i18n

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
  File? _selectedImageFile;
  String? _currentProfileImageUrl;

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

      String? photoUrl = _currentProfileImageUrl;
      if (_selectedImageFile != null) {
        final ext = p.extension(_selectedImageFile!.path);
        final ref =
            FirebaseStorage.instance.ref().child('profile_images/$uid$ext');
        await ref.putFile(_selectedImageFile!);
        photoUrl = await ref.getDownloadURL();
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
              // 1. 기본 정보
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

              // 2. 신뢰 인증
              const Divider(),
              Text("profile.section.trust".tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("profile.desc.trust".tr(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 12),
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
                        setState(() => _isPhoneVerified = true); // 임시 인증 처리
                      },
                      child: Text("profile.field.verify".tr()),
                    )
                  else
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 24),

              // 3. 소셜 프로필
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
                      if (_isVisibleInList && _selectedInterests.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text("profile.desc.socialPlaceholder".tr(),
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12)),
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

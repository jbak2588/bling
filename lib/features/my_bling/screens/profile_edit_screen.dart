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

class MyProfileEditScreen extends StatefulWidget {
  const MyProfileEditScreen({super.key});

  @override
  State<MyProfileEditScreen> createState() => _MyProfileEditScreenState();
}

class _MyProfileEditScreenState extends State<MyProfileEditScreen> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _interestController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _locationName;

  File? _selectedImage;
  String? _initialPhotoUrl;
  List<String> _interests = [];
  bool _showLocationOnMap = true;
  bool _allowFriendRequests = true;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _interestController.dispose();
    _phoneController.dispose();
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
      final userModel = UserModel.fromFirestore(doc);
      setState(() {
        _nicknameController.text = userModel.nickname;
        _bioController.text = userModel.bio ?? '';
        _initialPhotoUrl = userModel.photoUrl;
        _interests = List<String>.from(userModel.interests ?? []);
        _phoneController.text = userModel.phoneNumber ?? '';
        _locationName = userModel.locationName;
        _showLocationOnMap =
            userModel.privacySettings?['showLocationOnMap'] ?? true;
        _allowFriendRequests =
            userModel.privacySettings?['allowFriendRequests'] ?? true;
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

  void _addInterest() {
    final input = _interestController.text;
    final newItems = input.split(',');
    setState(() {
      for (var item in newItems) {
        final normalized = item.trim().toLowerCase();
        if (normalized.isNotEmpty && !_interests.contains(normalized)) {
          _interests.add(normalized);
        }
      }
      _interestController.clear();
    });
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  Future<void> _openLocationSetting() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationSettingScreen()),
    );
    await _loadUserData();
  }

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

      final Map<String, dynamic> dataToUpdate = {
        'nickname': _nicknameController.text.trim(),
        'bio': _bioController.text.trim(),
        'photoUrl': newPhotoUrl,
        'phoneNumber': _phoneController.text.trim(),
        'interests': _interests,
        'privacySettings': {
          'showLocationOnMap': _showLocationOnMap,
          'allowFriendRequests': _allowFriendRequests,
        },
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'profileEdit.locationTitle'.tr(),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: _openLocationSetting,
                              child: Text('profileEdit.changeLocation'.tr()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_locationName ?? 'location.locationNotSet'.tr()),
                        const SizedBox(height: 24),
                        // const Divider(),
                        const SizedBox(height: 16),
                        Text('profileEdit.interests.title'.tr(),
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _interestController,
                                decoration: InputDecoration(
                                    hintText:
                                        'profileEdit.interests.hint'.tr(),
                                        hintStyle: const TextStyle(color: Colors.grey),),
                                onSubmitted: (_) => _addInterest(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addInterest,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _interests
                              .map((interest) => Chip(
                                    label: Text(interest),
                                    onDeleted: () => _removeInterest(interest),
                                  ))
                              .toList(),
                        ),
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

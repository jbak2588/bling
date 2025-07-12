// lib/features/find_friends/screens/findfriend_profile_form.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/user_model.dart';
import '../../location/screens/location_setting_screen.dart';

import '../../../core/models/findfriend_model.dart';

class FindFriendProfileForm extends StatefulWidget {
  final FindFriend? profile;
  final void Function(FindFriend profile)? onSave;

  const FindFriendProfileForm({this.profile, this.onSave, super.key});

  @override
  State<FindFriendProfileForm> createState() => _FindFriendProfileFormState();
}

class _FindFriendProfileFormState extends State<FindFriendProfileForm> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _interestController = TextEditingController();

  String? _selectedAgeRange;
  String? _selectedGender;
  String? _locationName;
  Map<String, dynamic>? _locationParts;

  final List<XFile> _images = [];
  List<String> _profileImageUrls = [];
  List<String> _interests = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      final p = widget.profile!;
      _nicknameController.text = p.nickname;
      _bioController.text = p.bio ?? '';
      _selectedAgeRange = p.ageRange;
      _selectedGender = p.gender;
      _locationName = p.location;
      _profileImageUrls = List<String>.from(p.profileImages);
      _interests = List<String>.from(p.interests ?? []);
    } else {
      _loadUserProfile();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return;

    final userModel = UserModel.fromFirestore(doc);
    final profileData = userModel.findfriend ?? {};

    setState(() {
      _nicknameController.text = userModel.nickname;
      _bioController.text = profileData['bio'] ?? '';
      _selectedAgeRange = profileData['ageRange'];
      _selectedGender = profileData['gender'];
      _locationName = userModel.locationName;
      _locationParts = userModel.locationParts;
      _profileImageUrls =
          List<String>.from(profileData['profileImages'] ?? []);
      _interests = List<String>.from(profileData['interests'] ?? []);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 70, limit: 5);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.take(5 - _images.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
    await _loadUserProfile();
  }

  Future<List<String>> _uploadImages(String uid) async {
    List<String> urls = [];
    for (var image in _images) {
      final fileName = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref('friend_profile/$uid/$fileName');
      await ref.putFile(File(image.path));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;
    if ((_selectedAgeRange == null || _selectedGender == null || _locationName == null) ||
        (_profileImageUrls.isEmpty && _images.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user');

      final newUrls = await _uploadImages(user.uid);
      _profileImageUrls.addAll(newUrls);

      final profile = FindFriend(
        userId: user.uid,
        nickname: _nicknameController.text.trim(),
        profileImages: _profileImageUrls,
        location: _locationName,
        interests: _interests,
        ageRange: _selectedAgeRange,
        gender: _selectedGender,
        bio: _bioController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'findfriend': profile.toJson(),
        'locationName': _locationName,
        'locationParts': _locationParts,
      }, SetOptions(merge: true));
      widget.onSave?.call(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Friend Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAgeRange,
              decoration: const InputDecoration(labelText: 'Age Range'),
              items: const [
                DropdownMenuItem(value: '18-25', child: Text('18-25')),
                DropdownMenuItem(value: '26-35', child: Text('26-35')),
                DropdownMenuItem(value: '36-45', child: Text('36-45')),
                DropdownMenuItem(value: '46+', child: Text('46+')),
              ],
              onChanged: (val) => setState(() => _selectedAgeRange = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _locationName ?? 'Location not set',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: _openLocationSetting,
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _interestController,
                    decoration: const InputDecoration(hintText: 'Add interests'),
                    onSubmitted: (_) => _addInterest(),
                  ),
                ),
                IconButton(onPressed: _addInterest, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _interests
                  .map((e) => Chip(
                        label: Text(e),
                        onDeleted: () => _removeInterest(e),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photos'),
            ),
            const SizedBox(height: 8),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_images[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

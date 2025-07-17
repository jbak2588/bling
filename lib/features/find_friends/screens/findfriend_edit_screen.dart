// lib/features/find_friends/screens/findfriend_edit_screen.dart

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
  List<File> _newImages = [];
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

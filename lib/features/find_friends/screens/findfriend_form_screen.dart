// lib/features/find_friends/screens/findfriend_form_screen.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for creating the initial FindFriend profile when the user does not
/// have one yet.
class FindFriendFormScreen extends StatefulWidget {
  const FindFriendFormScreen({super.key});

  @override
  State<FindFriendFormScreen> createState() => _FindFriendFormScreenState();
}

class _FindFriendFormScreenState extends State<FindFriendFormScreen> {
  final _ageController = TextEditingController();
  final _ageRangeController = TextEditingController();
  List<File> _images = [];
  bool _saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
      });
    }
  }

  Future<void> _save() async {
    if (_saving || _images.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    final List<String> urls = [];
    for (final file in _images) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('findfriend_profiles')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'isDatingProfile': true,
      'age': int.tryParse(_ageController.text),
      'ageRange': _ageRangeController.text.trim(),
      'findfriend_profileImages': urls,
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enable = _ageController.text.isNotEmpty &&
        _ageRangeController.text.isNotEmpty &&
        _images.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('FindFriend Profile')),
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
            Wrap(
              spacing: 8,
              children: [
                ..._images.map((f) => Image.file(f, width: 80, height: 80, fit: BoxFit.cover)),
                if (_images.length < 9)
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

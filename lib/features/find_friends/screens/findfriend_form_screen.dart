import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/user_model.dart';

class FindFriendFormScreen extends StatefulWidget {
  final UserModel userModel;
  const FindFriendFormScreen({super.key, required this.userModel});

  @override
  State<FindFriendFormScreen> createState() => _FindFriendFormScreenState();
}

class _FindFriendFormScreenState extends State<FindFriendFormScreen> {
  final _ageController = TextEditingController();
  final _ageRangeController = TextEditingController();
  String? _selectedGender;
  bool _isPublic = true;
  final List<File> _images = [];
  bool _saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
      });
    }
  }

  Future<void> _save() async {
    if (_saving || _images.isEmpty) return;
    setState(() => _saving = true);

    final List<String> urls = [];
    for (final file in _images) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('findfriend_profiles')
          .child(widget.userModel.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .update({
      'isDatingProfile': true,
      'age': int.tryParse(_ageController.text),
      'ageRange': _ageRangeController.text.trim(),
      'gender': _selectedGender,
      'findfriend_profileImages': urls,
      'isPublic': _isPublic,
      'privacySettings.allowFriendRequests': true,
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enable = _ageController.text.isNotEmpty &&
        _ageRangeController.text.isNotEmpty &&
        _selectedGender != null &&
        _images.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('FindFriend Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nickname: ${widget.userModel.nickname}'),
            Text('Location: ${widget.userModel.locationParts?['kab'] ?? '-'}'),
            const Divider(),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age (본인 나이)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageRangeController,
              decoration: const InputDecoration(labelText: 'FindFriend 허용 나이대'),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _selectedGender,
              hint: const Text('성별을 선택하세요'),
              items: ['male', 'female', 'other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 20),
            const Text('추가 프로필 이미지 (최대 9장)'),
            Wrap(
              spacing: 8,
              children: [
                ..._images.map((f) =>
                    Image.file(f, width: 80, height: 80, fit: BoxFit.cover)),
                if (_images.length < 9)
                  IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo)),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('FindFriend 리스트에 내 프로필 표시하기'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
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
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Save My Profile'),
        ),
      ),
    );
  }
}

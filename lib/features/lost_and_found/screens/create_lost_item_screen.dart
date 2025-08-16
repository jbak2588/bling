// lib/features/lost_and_found/screens/create_lost_item_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateLostItemScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateLostItemScreen({super.key, required this.userModel});

  @override
  State<CreateLostItemScreen> createState() => _CreateLostItemScreenState();
}

class _CreateLostItemScreenState extends State<CreateLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemDescriptionController = TextEditingController();
  final _locationDescriptionController = TextEditingController();

  String _type = 'lost';
  final List<XFile> _images = [];
  bool _isSaving = false;

  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _itemDescriptionController.dispose();
    _locationDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 5 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }
  
  void _removeImage(int index) {
      setState(() => _images.removeAt(index));
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진을 1장 이상 첨부해주세요.'))); // TODO: 다국어
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
        setState(() => _isSaving = false);
        return;
    }

    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child('lost_and_found/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newItem = LostItemModel(
        id: '',
        userId: user.uid,
        type: _type,
        itemDescription: _itemDescriptionController.text.trim(),
        locationDescription: _locationDescriptionController.text.trim(),
        geoPoint: widget.userModel.geoPoint,
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
      );

      // [수정] 주석을 해제하여 DB 저장 기능을 활성화합니다.
      await _repository.createItem(newItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록되었습니다.'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록에 실패했습니다: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('분실/습득물 등록'), // TODO: 다국어
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _submitItem, child: Text('등록')), // TODO: 다국어
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'lost', label: Text('분실했어요')), // TODO: 다국어
                    ButtonSegment<String>(value: 'found', label: Text('주웠어요')), // TODO: 다국어
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) => setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 24),

                // V V V --- [복원] 이미지 선택 및 취소 기능이 포함된 UI --- V V V
                Text('사진 등록 (최대 5장)', style: Theme.of(context).textTheme.titleMedium), // TODO: 다국어
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final xfile = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(xfile.path), width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12, backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_images.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                // ^ ^ ^ --- 여기까지 복원 --- ^ ^ ^
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _itemDescriptionController,
                  decoration: const InputDecoration(labelText: '어떤 물건인가요?', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '물건 설명을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _locationDescriptionController,
                  decoration: const InputDecoration(labelText: '어디서 잃어버렸거나 주우셨나요?', border: OutlineInputBorder()),
                   validator: (value) => (value == null || value.trim().isEmpty) ? '장소 설명을 입력해주세요.' : null,
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(color: Colors.black.withOpacity(0.5), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
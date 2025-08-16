// lib/features/lost_and_found/screens/edit_lost_item_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class EditLostItemScreen extends StatefulWidget {
  final LostItemModel item;
  const EditLostItemScreen({super.key, required this.item});

  @override
  State<EditLostItemScreen> createState() => _EditLostItemScreenState();
}

class _EditLostItemScreenState extends State<EditLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemDescriptionController;
  late final TextEditingController _locationDescriptionController;

  late String _type;
  final List<dynamic> _images = [];
  bool _isSaving = false;

  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _itemDescriptionController = TextEditingController(text: widget.item.itemDescription);
    _locationDescriptionController = TextEditingController(text: widget.item.locationDescription);
    _type = widget.item.type;
    _images.addAll(widget.item.imageUrls);
  }

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

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진을 1장 이상 첨부해주세요.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance.ref().child('lost_and_found/${widget.item.userId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      final updatedItem = LostItemModel(
        id: widget.item.id,
        userId: widget.item.userId,
        type: _type,
        itemDescription: _itemDescriptionController.text.trim(),
        locationDescription: _locationDescriptionController.text.trim(),
        imageUrls: imageUrls,
        createdAt: widget.item.createdAt,
        geoPoint: widget.item.geoPoint,
      );

      await _repository.updateItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정되었습니다.'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('수정에 실패했습니다: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('분실/습득물 수정'),
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _updateItem, child: Text('저장')),
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
                    ButtonSegment<String>(value: 'lost', label: Text('분실했어요')),
                    ButtonSegment<String>(value: 'found', label: Text('주웠어요')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) => setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 24),
                // V V V --- [복원] 누락되었던 이미지 선택/수정 UI --- V V V
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        ImageProvider imageProvider;
                        if (image is XFile) {
                          imageProvider = FileImage(File(image.path));
                        } else {
                          imageProvider = NetworkImage(image as String);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image(image: imageProvider, width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4, right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 16)),
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
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
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
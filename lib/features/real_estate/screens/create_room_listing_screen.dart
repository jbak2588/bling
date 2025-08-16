// lib/features/real_estate/screens/create_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateRoomListingScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateRoomListingScreen({super.key, required this.userModel});

  @override
  State<CreateRoomListingScreen> createState() => _CreateRoomListingScreenState();
}

class _CreateRoomListingScreenState extends State<CreateRoomListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _type = 'kos'; // 'kos', 'kontrakan', 'sewa'
  String _priceUnit = 'monthly'; // 'monthly', 'yearly'
  final List<XFile> _images = [];
  final Set<String> _amenities = {};
  bool _isSaving = false;

  final RoomRepository _repository = RoomRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사진을 1장 이상 첨부해주세요.')));
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
        final ref = FirebaseStorage.instance.ref().child('room_listings/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newListing = RoomListingModel(
        id: '',
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        locationName: widget.userModel.locationName,
        locationParts: widget.userModel.locationParts,
        geoPoint: widget.userModel.geoPoint,
        price: int.tryParse(_priceController.text) ?? 0,
        priceUnit: _priceUnit,
        imageUrls: imageUrls,
        amenities: _amenities.toList(),
        createdAt: Timestamp.now(),
      );

      await _repository.createRoomListing(newListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매물이 등록되었습니다.'), backgroundColor: Colors.green));
       // V V V --- [수정] 등록 성공 신호(true)와 함께 화면을 닫습니다 --- V V V
        Navigator.of(context).pop(true);
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
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
        title: const Text('새 매물 등록'), // TODO: 다국어
        actions: [
          if (!_isSaving) TextButton(onPressed: _submitListing, child: const Text('등록')), // TODO: 다국어
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- 사진 등록 ---
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(image.path), width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_images.length < 10)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- 매물 종류 ---
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'kos', label: Text('하숙')), // TODO: 다국어
                    ButtonSegment(value: 'kontrakan', label: Text('월세')),
                    ButtonSegment(value: 'sewa', label: Text('임대')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) => setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 16),
                // --- 가격 정보 ---
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: '가격', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? '가격을 입력하세요' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _priceUnit,
                      items: const [
                        DropdownMenuItem(value: 'monthly', child: Text('/월')),
                        DropdownMenuItem(value: 'yearly', child: Text('/년')),
                      ],
                      onChanged: (val) => setState(() => _priceUnit = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // --- 제목 및 설명 ---
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()), // TODO: 다국어
                  validator: (v) => (v == null || v.isEmpty) ? '제목을 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '상세 설명', border: OutlineInputBorder()), // TODO: 다국어
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // --- 편의시설 ---
                Text('편의시설', style: Theme.of(context).textTheme.titleMedium), // TODO: 다국어
                Wrap(
                  spacing: 8.0,
                  children: ['wifi', 'ac', 'parking', 'kitchen'].map((amenity) { // TODO: 다국어
                    return FilterChip(
                      label: Text(amenity),
                      selected: _amenities.contains(amenity),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) _amenities.add(amenity);
                          else _amenities.remove(amenity);
                        });
                      },
                    );
                  }).toList(),
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
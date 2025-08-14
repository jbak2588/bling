// lib/features/local_stores/screens/edit_shop_screen.dart

import 'dart:io';
import 'package:bling_app/core/models/shop_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditShopScreen extends StatefulWidget {
  final ShopModel shop;
  const EditShopScreen({super.key, required this.shop});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contactController;
  late final TextEditingController _hoursController;

  XFile? _selectedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  final ShopRepository _repository = ShopRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 기존 상점 정보로 UI 상태를 초기화합니다.
    _nameController = TextEditingController(text: widget.shop.name);
    _descriptionController = TextEditingController(text: widget.shop.description);
    _contactController = TextEditingController(text: widget.shop.contactNumber);
    _hoursController = TextEditingController(text: widget.shop.openHours);
    _existingImageUrl = widget.shop.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _existingImageUrl = null; // 새 이미지를 선택하면 기존 이미지는 무시됩니다.
      });
    }
  }

  Future<void> _updateShop() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    
    setState(() => _isSaving = true);

    try {
      String? imageUrl = _existingImageUrl;
      // 새 이미지가 선택되었으면 Storage에 업로드합니다.
      if (_selectedImage != null) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child('shop_images/${widget.shop.ownerId}/$fileName');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      // ShopModel 객체를 업데이트된 정보로 새로 만듭니다.
      final updatedShop = ShopModel(
        id: widget.shop.id, // ID는 기존 ID를 그대로 사용합니다.
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        contactNumber: _contactController.text.trim(),
        openHours: _hoursController.text.trim(),
        imageUrl: imageUrl,
        // 수정되지 않는 필드들은 기존 값을 그대로 사용합니다.
        ownerId: widget.shop.ownerId,
        locationName: widget.shop.locationName,
        locationParts: widget.shop.locationParts,
        geoPoint: widget.shop.geoPoint,
        createdAt: widget.shop.createdAt,
      );

      await _repository.updateShop(updatedShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상점 정보가 수정되었습니다.'), backgroundColor: Colors.green));
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
        title: Text('상점 정보 수정'), // TODO: 다국어
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _updateShop, child: Text('저장')), // TODO: 다국어
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: (_selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                                    ? NetworkImage(_existingImageUrl!)
                                    : const AssetImage('assets/placeholder.png'))) // Fallback to a placeholder asset
                            as ImageProvider,
                      ),
                    ),
                    child: (_selectedImage == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                        ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey))
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '상점 이름', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '상점 이름을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '상점 소개', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty) ? '상점 소개를 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: '연락처', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  decoration: const InputDecoration(labelText: '영업 시간', hintText: '예) 09:00 - 18:00', border: OutlineInputBorder()),
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
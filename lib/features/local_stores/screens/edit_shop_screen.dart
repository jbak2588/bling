// ===================== DocHeader =====================
// [기획 요약]
// - 상점 정보 수정, 이미지 업로드, 연락처/영업시간 등 다양한 필드 편집 지원.
//
// [실제 구현 비교]
// - 상점 정보 수정, 이미지 업로드, 연락처/영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(상점 부스트, 조회수, 리뷰 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// lib/features/local_stores/screens/edit_shop_screen.dart

import 'dart:io';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

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

  // [수정] 기존 URL(String)과 새로운 파일(XFile)을 모두 담는 List
  final List<dynamic> _images = [];
  bool _isSaving = false;
  bool _isPickingImages = false;

  final ShopRepository _repository = ShopRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _descriptionController = TextEditingController(text: widget.shop.description);
    _contactController = TextEditingController(text: widget.shop.contactNumber);
    _hoursController = TextEditingController(text: widget.shop.openHours);
    _images.addAll(widget.shop.imageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

   Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= 10) return;
    setState(() => _isPickingImages = true);
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 10 - _images.length);
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _images.addAll(pickedFiles));
      }
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  // [수정] 선택한 이미지를 제거하는 함수
  void _removeImage(int index) {
    if (mounted) {
      setState(() => _images.removeAt(index));
    }
  }

  Future<void> _updateShop() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    
    setState(() => _isSaving = true);

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          final fileName = Uuid().v4();
          final ref = FirebaseStorage.instance.ref().child('shop_images/${widget.shop.ownerId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      final updatedShop = ShopModel(
        id: widget.shop.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        contactNumber: _contactController.text.trim(),
        openHours: _hoursController.text.trim(),
        imageUrls: imageUrls, // [수정]
        ownerId: widget.shop.ownerId,
        locationName: widget.shop.locationName,
        locationParts: widget.shop.locationParts,
        geoPoint: widget.shop.geoPoint,
        createdAt: widget.shop.createdAt,
        products: widget.shop.products,
        trustLevelVerified: widget.shop.trustLevelVerified,
        viewsCount: widget.shop.viewsCount,
        likesCount: widget.shop.likesCount,
      );

      await _repository.updateShop(updatedShop);

      if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('localStores.edit.success'.tr()), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('localStores.edit.fail'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('localStores.edit.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(onPressed: _updateShop, child: Text('localStores.edit.save'.tr())),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
               // --- [수정] 다중 이미지 수정 UI ---
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
                      if (_images.length < 10)
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
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'localStores.form.nameLabel'.tr(), border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'localStores.form.nameError'.tr() : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'localStores.form.descriptionLabel'.tr(), border: const OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'localStores.form.descriptionError'.tr() : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'localStores.form.contactLabel'.tr(), border: const OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  decoration: InputDecoration(labelText: 'localStores.form.hoursLabel'.tr(), hintText: 'localStores.form.hoursHint'.tr(), border: const OutlineInputBorder()),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}
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
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) 확장된 ShopModel에 맞춰 수정 UI 필드 추가.
// 2. '업종 카테고리' (category): DropdownButtonFormField 추가 (기존 값 로드).
// 3. '대표 상품/서비스' (products): 쉼표(,)로 구분하여 입력받는 TextFormField 추가 (기존 값 로드).
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
import 'package:bling_app/core/utils/search_helper.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

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
  // [추가] 카테고리/상품 편집을 위한 상태와 컨트롤러
  final List<String> _shopCategories = [
    'food',
    'cafe',
    'massage',
    'beauty',
    'nail',
    'auto',
    'kids',
    'hospital',
    'etc'
  ];
  late String _selectedCategory;
  late final TextEditingController _productsController;
  late List<String> _tags;

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
    _descriptionController =
        TextEditingController(text: widget.shop.description);
    _contactController = TextEditingController(text: widget.shop.contactNumber);
    _hoursController = TextEditingController(text: widget.shop.openHours);
    _selectedCategory = widget.shop.category;
    _productsController =
        TextEditingController(text: (widget.shop.products ?? []).join(', '));
    _images.addAll(widget.shop.imageUrls);
    _tags = List.from(widget.shop.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    _productsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isPickingImages || _images.length >= 10) return;
    setState(() => _isPickingImages = true);
    try {
      final pickedFiles = await _picker.pickMultiImage(
          imageQuality: 70, limit: 10 - _images.length);
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
          final ref = FirebaseStorage.instance
              .ref()
              .child('shop_images/${widget.shop.ownerId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      // [추가] 검색 키워드 생성
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _nameController.text,
        description: _descriptionController.text,
        tags: _productsController.text.trim().isEmpty
            ? _tags
            : {
                ..._productsController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty),
                ..._tags
              }.toList(),
      );

      final updatedShop = ShopModel(
        id: widget.shop.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory, // [추가]
        contactNumber: _contactController.text.trim(),
        openHours: _hoursController.text.trim(),
        imageUrls: imageUrls, // [수정]
        ownerId: widget.shop.ownerId,
        locationName: widget.shop.locationName,
        locationParts: widget.shop.locationParts,
        geoPoint: widget.shop.geoPoint,
        createdAt: widget.shop.createdAt,
        products: _productsController.text.trim().isEmpty
            ? []
            : _productsController.text
                .trim()
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(), // [추가]
        tags: _tags,
        trustLevelVerified: widget.shop.trustLevelVerified,
        viewsCount: widget.shop.viewsCount,
        likesCount: widget.shop.likesCount,
        searchIndex: searchKeywords,
      );

      await _repository.updateShop(updatedShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localStores.edit.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'localStores.edit.fail'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red));
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
            TextButton(
                onPressed: _updateShop,
                child: Text('localStores.edit.save'.tr(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold))),
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
                                child: Image(
                                    image: imageProvider,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 16)),
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
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.nameLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'localStores.form.nameError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.descriptionLabel'.tr(),
                      border: const OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'localStores.form.descriptionError'.tr()
                      : null,
                ),
                // [추가] 카테고리 선택
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.categoryLabel'.tr(),
                      border: const OutlineInputBorder()),
                  items: _shopCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text('localStores.categories.$category'.tr()),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                  validator: (value) => value == null
                      ? 'localStores.form.categoryError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.contactLabel'.tr(),
                      border: const OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.hoursLabel'.tr(),
                      hintText: 'localStores.form.hoursHint'.tr(),
                      border: const OutlineInputBorder()),
                ),
                // [추가] 대표 상품/서비스 입력
                const SizedBox(height: 16),
                TextFormField(
                  controller: _productsController,
                  decoration: InputDecoration(
                      labelText: 'localStores.form.productsLabel'.tr(),
                      hintText: 'localStores.form.productsHint'.tr(),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                CustomTagInputField(
                  hintText: 'tag_input.help'.tr(),
                  initialTags: _tags,
                  titleController: _nameController,
                  onTagsChanged: (tags) => setState(() {
                    _tags
                      ..clear()
                      ..addAll(tags);
                  }),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _updateShop,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text('localStores.edit.save'.tr()),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black54,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}

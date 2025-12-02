// ===================== DocHeader =====================
// [기획 요약]
// - 상점 등록, 이미지 업로드, 연락처/영업시간/카테고리 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 상점 등록, 이미지 업로드, 연락처/영업시간/카테고리 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(상점 부스트, 조회수, 리뷰 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// lib/features/local_stores/screens/create_shop_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 상점 등록, 이미지 업로드, 연락처/영업시간/카테고리 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 상점 등록, 이미지 업로드, 연락처/영업시간/카테고리 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(상점 부스트, 조회수, 리뷰 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================

// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 1) 확장된 ShopModel에 맞춰 등록 UI 필드 추가.
// 2. '업종 카테고리' (category): DropdownButtonFormField 추가.
// 3. '대표 상품/서비스' (products): 쉼표(,)로 구분하여 입력받는 TextFormField 추가.
// =====================================================
// lib/features/local_stores/screens/create_shop_screen.dart

import 'dart:io';
import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/models/bling_location.dart';
import 'package:bling_app/features/shared/widgets/address_map_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
// search index generation removed to avoid extra background work
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateShopScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateShopScreen({super.key, required this.userModel});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _hoursController = TextEditingController();

  // [추가] 상점 카테고리 목록 (기획서 기반 [cite: 1102])
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
  String _selectedCategory = 'food'; // 기본값

  // [추가] 기획서의 '대표 상품/서비스'  입력을 위한 컨트롤러
  final _productsController = TextEditingController();
  // 사용자 정의 태그 저장
  final List<String> _tags = [];

  // V V V --- [수정] 단일 이미지(XFile)에서 이미지 목록(List<XFile>)으로 변경 --- V V V
  final List<XFile> _images = [];
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  bool _isSaving = false;
  BlingLocation? _shopLocation;

  final ShopRepository _repository = ShopRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _hoursController.dispose();
    _productsController.dispose(); // [추가]
    super.dispose();
  }

  // [수정] 여러 이미지를 선택하는 함수
  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  // [추가] 선택한 이미지 제거 함수
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('localStores.form.imageError'.tr())));
      return;
    }
    if (_shopLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('localStores.form.shopLocationError'.tr())));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Prefer freshest user location data at submit time: fetch users/{uid}
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      UserModel? freshUserModel;
      if (userDocSnapshot.exists) {
        try {
          freshUserModel = UserModel.fromFirestore(userDocSnapshot);
        } catch (_) {
          freshUserModel = null;
        }
      }

      // [수정] 여러 이미지를 업로드하는 로직
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop_images/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      // [추가] 태그/검색 키워드 생성
      final productsList = _productsController.text.trim().isEmpty
          ? <String>[]
          : _productsController.text
              .trim()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final combinedTags = {
        ...productsList,
        ..._tags,
      }.toList();

      final shopLoc = _shopLocation;
      final shopAddressText = shopLoc?.shortLabel ?? shopLoc?.mainAddress ?? '';

      final newShop = ShopModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: user.uid,
        // Prefer freshly-read user profile if available, fallback to widget.userModel
        locationName:
            freshUserModel?.locationName ?? widget.userModel.locationName,
        locationParts:
            freshUserModel?.locationParts ?? widget.userModel.locationParts,
        geoPoint: freshUserModel?.geoPoint ?? widget.userModel.geoPoint,
        shopLocation: shopLoc,
        shopAddress: shopAddressText.isNotEmpty ? shopAddressText : null,
        category: _selectedCategory, // [추가]
        products: _productsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .toList(), // [추가] 쉼표로 구분
        tags: combinedTags,
        contactNumber: _contactController.text.trim(),
        openHours: _hoursController.text.trim(),
        imageUrls: imageUrls, // [수정]
        createdAt: Timestamp.now(),
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
      );

      await _repository.createShop(newShop);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localStores.create.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localStores.create.fail'
                .tr(namedArgs: {'error': e.toString()})),
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
        title: Text('localStores.create.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _submitShop,
            icon: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // V V V --- [수정] 다중 이미지 선택 UI --- V V V
                Text(
                    'localStores.form.photoLabel'
                        .tr(namedArgs: {'count': '10'}),
                    style: Theme.of(context).textTheme.titleMedium),
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
                                child: Image.file(File(xfile.path),
                                    width: 100, height: 100, fit: BoxFit.cover),
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
                // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
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
                const SizedBox(height: 24),
                AddressMapPicker(
                  initialValue: _shopLocation,
                  userGeoPoint: widget.userModel.geoPoint,
                  labelText: 'localStores.form.shopLocationLabel'.tr(),
                  hintText: 'localStores.form.shopLocationHint'.tr(),
                  onChanged: (loc) {
                    setState(() => _shopLocation = loc);
                  },
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
                      child: Text(
                          'localStores.categories.$category'.tr()), // 번역 키 사용
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
                  hintText: 'tag_input.addHint'.tr(),
                  initialTags: _tags,
                  titleController: _nameController,
                  onTagsChanged: (tags) => setState(() {
                    _tags
                      ..clear()
                      ..addAll(tags);
                  }),
                ),
                const SizedBox(height: 88),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _submitShop,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('localStores.create.submit'.tr()),
          ),
        ),
      ),
    );
  }
}

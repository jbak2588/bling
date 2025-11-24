/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/product_registration_screen.dart
/// Purpose       : 판매자가 이미지와 위치를 포함한 새 상품을 등록하는 폼입니다.
/// User Impact   : 주민이 주변 동네에 판매할 물품을 등록할 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/marketplace/widgets/product_card.dart
/// Data Model    : Firestore `products` 필드 `title`, `description`, `price`, `negotiable`, `imageUrls`, `locationName`, `locationParts`, `geoPoint`, `transactionPlace`, `condition`, `isAiVerified`.
/// Location Scope: 사용자 `locationParts`(Prov→Kab/Kota→Kec→Kel)를 기본으로 사용하며, 반경 검색을 위해 GeoPoint를 저장합니다.
/// Trust Policy  : 전화번호 검증 및 trustScore 100 초과 사용자만 등록 가능하며 신고 시 `trustScore`가 감소합니다.
/// Monetization  : 거래 수수료와 선택형 프로모션 슬롯을 제공합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `start_product_listing`, `complete_product_listing`, `upload_product_photo`.
/// Analytics     : 이미지 업로드와 폼 작성 시간을 기록합니다.
/// I18N          : 키 `marketplace.errors.noPhoto`, `marketplace.errors.noCategory` (assets/lang/*.json)
/// Dependencies  : firebase_auth, cloud_firestore, firebase_storage, image_picker, uuid, easy_localization
/// Security/Auth : 인증된 사용자만 가능하며 Storage 규칙이 사용자 UID별 경로를 제한합니다.
/// Edge Cases    : 업로드 실패, 위치 미입력, 사진 제한 초과.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md; docs/team/teamB_Feed_CRUD_Module_통합 작업문서.md
///
/// 2025년 8월 30일 : 공용위젯인 테그 위젯, 검색화 도입 및 이미지 갤러리 위젯 작업 진행
/// ============================================================================
library;
// 아래부터 실제 코드

import 'dart:io';
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/categories/screens/parent_category_screen.dart';
import 'package:bling_app/features/marketplace/services/ai_verification_service.dart';
import '../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Removed direct UUID/path usage for uploads; using shared helper instead
// ignore: unused_import
import 'package:uuid/uuid.dart';
// [V3 REFACTOR] 'AI 룰 엔진' 모델 종속성 완전 삭제

// ✅ [추가] UserModel을 사용하기 위해 import 합니다.
import '../../../../core/models/user_model.dart';
// ✅ 공용 태그 위젯 import
import '../../shared/widgets/custom_tag_input_field.dart'; // 2025년 8월 30일
import 'package:bling_app/core/utils/upload_helpers.dart';
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() =>
      _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final _aiVerificationService = AiVerificationService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _transactionPlaceController = TextEditingController();

  List<XFile> _images = [];
  bool _isNegotiable = false;
  bool _isLoading = false;

  // ✅ 태그 목록을 관리할 상태 변수 추가  : 2025년 8월 30일
  List<String> _tags = [];

  Category? _selectedCategory;

  // 선택된 카테고리의 ID만 필요할 때 사용할 안전한 게터

  // 현재 상품 상태 및 추가 입력값
  String _condition = 'used';

  // [추가] AI 검수 관련 상태
  // [작업 68] bool _isSaving -> String? _loadingStatus로 변경
  String? _loadingStatus;
  // [V3 REFACTOR] 'AI 룰 엔진' 종속성(AiVerificationRule) 제거

  // 1. [추가] 대/소분류 이름을 저장할 상태 변수
  String? _selectedParentCategoryName;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _transactionPlaceController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final userModel = UserModel.fromFirestore(doc);
      if (mounted) {
        setState(() {
          _addressController.text = userModel.locationName ?? '';
        });
      }
    }
  }

  void _selectCategory() async {
    final result = await Navigator.of(context).push<Category>(
      MaterialPageRoute(builder: (context) => const ParentCategoryScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result;
      });
      // [V3 REFACTOR] 'loadAiRule' 호출 로직 완전 삭제
      if (result.parentId != null && result.parentId!.isNotEmpty) {
        final names = await _aiVerificationService.getCategoryNames(
            result.id, result.parentId!);
        if (!mounted) return;
        setState(() {
          _selectedParentCategoryName = names['parentCategoryName'];
        });
      } else {
        if (!mounted) return;
        setState(() {
          _selectedParentCategoryName = null;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage(
      limit: 10,
      imageQuality: 80, // [Fix] Warning #4: 품질 80%
      maxWidth: 1024, // [Fix] Warning #4: 최대 너비 1024px
    );
    if (pickedImages.isNotEmpty) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.marketplace.errors.noPhoto)));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.marketplace.errors.noCategory)));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 현재 사용자의 프로필 정보를 가져와서 위치 데이터를 확보
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception(t.marketplace.errors.userNotFound);
      }
      final userModel = UserModel.fromFirestore(userDoc);

      // 이미지 업로드 (공용 helper 사용)
      final uploadedUrls = await uploadAllProductImages(_images, user.uid);

      // [추가] 검색 키워드 생성
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags,
      );

      final newProductId =
          FirebaseFirestore.instance.collection('products').doc().id;

      final newProduct = ProductModel(
        id: newProductId,
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text,
        imageUrls: uploadedUrls,
        categoryId: _selectedCategory!.id,
        categoryParentId: _selectedCategory!.parentId,
        price: int.tryParse(_priceController.text) ?? 0,
        negotiable: _isNegotiable,
        tags: _tags,
        locationName: userModel.locationName,
        locationParts: userModel.locationParts,
        geoPoint: userModel.geoPoint,
        transactionPlace: _transactionPlaceController.text,
        condition: _condition,
        status: 'selling',
        isAiVerified: false,
        searchIndex: searchKeywords, // [추가] searchIndex 저장
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        userUpdatedAt: Timestamp.now(),
        isNew: true,
      );

      // 1. 상품 문서 저장
      await FirebaseFirestore.instance
          .collection('products')
          .doc(newProductId)
          .set(newProduct.toJson());

      // 2. ✅ [핵심 추가] 사용자의 productIds 배열에 새 상품 ID 추가
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'productIds': FieldValue.arrayUnion([newProductId]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.marketplace.registration.success)),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.marketplace.registration.fail
                .replaceAll('{0}', e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCategoryName(BuildContext context, Category? category) {
    if (category == null) {
      return t.selectCategory;
    }
    final langCode = Localizations.localeOf(context).languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      default:
        return category.nameEn;
    }
  }

  // [수정] AI 검수 시작 함수: Cloud Function을 직접 호출하는 방식으로 변경
  Future<void> _startAiVerification() async {
    // 유효성 검사 강화
    if (!_formKey.currentState!.validate() ||
        _selectedCategory ==
            null || // [V3 REFACTOR] '_selectedAiRule' 대신 '_selectedCategory'로 검증
        _images.isEmpty ||
        _selectedParentCategoryName == null) {
      // [V3 REFACTOR] 이름이 로드되었는지 확인
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.aiFlow.cta.missingRequiredFields)),
      );
      return;
    }

    // [작업 68] 로딩 상태 텍스트 설정
    setState(() =>
        _loadingStatus = 'Saving product information...'); // "상품 정보 저장 중..."
    try {
      final productId =
          FirebaseFirestore.instance.collection('products').doc().id;
      // ... (기존 _saveProduct 로직) ...
      // 1. 이미지 업로드
      // ...existing code...
      // [작업 68] 로딩 상태 텍스트 변경
      setState(() => _loadingStatus =
          'AI is analyzing (may take up to 1 minute)...'); // "AI가 1차 분석 중... (최대 1분)"
      await _aiVerificationService.startVerificationFlow(
        context: context,
        // [V3 REFACTOR] 'rule' 파라미터 완전 제거
        productId: productId,
        categoryId: _selectedCategory!.id, // V3는 서브 카테고리 ID를 직접 사용
        initialImages: _images, // XFile 리스트 그대로 전달하면 서비스가 업로드 처리
        productName: _titleController.text,
        productDescription: _descriptionController.text,
        productPrice: _priceController.text,
      );
    } finally {
      if (mounted) setState(() => _loadingStatus = null); // [작업 68]
    }
  }

  // 기존 수동 흐름(_navigateToEvidenceCollection/_generateReportDirectly)은
  // 서비스 기반으로 대체되었습니다.

  // 이미지 업로드는 공용 helper(uploadProductImage)를 사용합니다.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.marketplace.registration.title),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitProduct,
            child: _isLoading
                ? const CircularProgressIndicator() // Use default (theme) color
                : Text(
                    t.marketplace.registration.done,
                    style: TextStyle(
                      color: theme
                          .primaryColor, // [Fix] Use primaryColor for visibility
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [Fix] 하단에 '일반 등록' 버튼 추가 (UX 일관성)
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Text(t.marketplace.registration.done),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _images.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(4.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(_images[index].path),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: t.marketplace.registration.titleHint),
                validator: (value) => value == null || value.isEmpty
                    ? t.marketplace.errors.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: _selectCategory,
                title: Text(_getCategoryName(context, _selectedCategory)),
                leading: const Icon(Icons.category_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                readOnly: true, // 사용자가 직접 수정하지 못하도록 설정
                decoration: InputDecoration(
                  labelText: t.marketplace.registration.addressHint,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                // validator 제거 (자동으로 가져오므로)
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionPlaceController,
                decoration: InputDecoration(
                    labelText: t.marketplace.registration.addressDetailHint),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: t.marketplace.registration.priceHint),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? t.marketplace.errors.requiredField
                    : null,
              ),
              SwitchListTile(
                title: Text(t.marketplace.registration.negotiable),
                value: _isNegotiable,
                onChanged: (value) => setState(() => _isNegotiable = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _condition,
                decoration:
                    InputDecoration(labelText: t.marketplace.condition.label),
                items: [
                  DropdownMenuItem(
                      value: 'new', child: Text(t.marketplace.condition.kNew)),
                  DropdownMenuItem(
                      value: 'used', child: Text(t.marketplace.condition.used)),
                ],
                onChanged: (value) =>
                    setState(() => _condition = value ?? 'used'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: t.marketplace.registration.descriptionHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => (value == null || value.isEmpty)
                    ? t.marketplace.errors.requiredField
                    : null,
              ),
              const SizedBox(height: 16), // [간격 확대]
              // ✅ 공용 태그 위젯 추가
              CustomTagInputField(
                hintText: t.shared.tagInput.defaultHint,
                onTagsChanged: (tags) {
                  setState(() {
                    _tags = tags;
                  });
                },
              ),
              const SizedBox(height: 24),

              // [Fix] 하단에 '일반 등록' 버튼 추가 (UX 일관성)
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Text(t.marketplace.registration.done),
              ),
              const SizedBox(height: 16),

              // [V2 핵심 추가] AI 검수 옵션 섹션
              const Divider(height: 32),
              Text(t.aiFlow.cta.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(t.aiFlow.cta.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              // [핵심 수정] 버튼 활성/비활성 및 동작 구현
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleController,
                builder: (context, value, _) {
                  final isReady = value.text.isNotEmpty &&
                      _selectedCategory !=
                          null && // [V3 REFACTOR] use selected category
                      _images.isNotEmpty &&
                      _selectedParentCategoryName != null; // 이름까지 로드되었는지 확인
                  return OutlinedButton.icon(
                    onPressed: (isReady && _loadingStatus == null)
                        ? _startAiVerification
                        : null,
                    icon: const Icon(Icons.shield_outlined),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                    ),
                    label: _loadingStatus != null
                        ? Column(
                            // [Task 87] UI 개선: 텍스트 + 진행 바로 변경
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_loadingStatus!),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(),
                            ],
                          )
                        : Text(t.aiFlow.cta.startButton),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

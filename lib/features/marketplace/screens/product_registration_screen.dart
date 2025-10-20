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
import '../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Removed direct UUID/path usage for uploads; using shared helper instead
// ignore: unused_import
import 'package:uuid/uuid.dart';
import 'package:bling_app/features/marketplace/screens/ai_evidence_collection_screen.dart'; // [추가] 증거 수집 화면
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart'; // [추가] AI 규칙 모델

// ✅ [추가] UserModel을 사용하기 위해 import 합니다.
import '../../../../core/models/user_model.dart';
// ✅ 공용 태그 위젯 import
import 'ai_final_report_screen.dart';
import '../../shared/widgets/custom_tag_input_field.dart'; // 2025년 8월 30일
import 'package:bling_app/core/utils/upload_helpers.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() =>
      _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
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
  String? get _selectedCategoryId => _selectedCategory?.id;

  // 현재 상품 상태 및 추가 입력값
  String _condition = 'used';

  // [추가] AI 검수 관련 상태
  bool _isSaving = false;
  AiVerificationRule? _selectedAiRule;

  // 1. [추가] 대/소분류 이름을 저장할 상태 변수
  String? _selectedParentCategoryName;
  String? _selectedSubCategoryName;

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
      // [수정] 카테고리 선택 시, 규칙과 함께 이름도 조회합니다.
      if (result.parentId != null && result.parentId!.isNotEmpty) {
        _loadAiRule(result.id);
        _fetchCategoryNames(result.id, result.parentId!);
      } else {
        debugPrint("선택된 카테고리에 parentId가 없습니다.");
      }
    }
  }

  // [추가] 카테고리 ID를 이용해 대/소분류 이름을 가져오는 함수
  Future<void> _fetchCategoryNames(
      String subCategoryId, String parentCategoryId) async {
    try {
      final subDoc = await FirebaseFirestore.instance
          .collection('categories_v2')
          .doc(subCategoryId)
          .get();
      final parentDoc = await FirebaseFirestore.instance
          .collection('categories_v2')
          .doc(parentCategoryId)
          .get();
      if (mounted) {
        setState(() {
          _selectedSubCategoryName = subDoc.data()?['name_ko'];
          _selectedParentCategoryName = parentDoc.data()?['name_ko'];
        });
      }
    } catch (e) {
      debugPrint("카테고리 이름을 가져오는 중 오류 발생: $e");
    }
  }

  Future<void> _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage(limit: 10);
    if (pickedImages.isNotEmpty) {
      setState(() {
        _images = pickedImages;
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.errors.noPhoto'.tr())));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.errors.noCategory'.tr())));
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
        throw Exception('marketplace.errors.userNotFound'.tr());
      }
      final userModel = UserModel.fromFirestore(userDoc);

      // 이미지 업로드 (공용 helper 사용)
      List<String> imageUrls = [];
      for (var image in _images) {
        imageUrls.add(await uploadProductImage(image, user.uid));
      }

      final newProductId =
          FirebaseFirestore.instance.collection('products').doc().id;

      final newProduct = ProductModel(
        id: newProductId,
        userId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrls: imageUrls,
        categoryId: _selectedCategory!.id,
        price: int.tryParse(_priceController.text) ?? 0,
        negotiable: _isNegotiable,
        tags: _tags, // ✅ _tags 상태를 모델에 전달  // 2025년 8월 30일
        locationName: userModel.locationName,
        locationParts: userModel.locationParts,
        geoPoint: userModel.geoPoint,
        transactionPlace: _transactionPlaceController.text,
        condition: _condition,
        status: 'selling',
        isAiVerified: false,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isNew: true, // <-- 이 부분을 추가하여 '신품'임을 명시합니다.
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
          SnackBar(content: Text('marketplace.registration.success'.tr())),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('marketplace.registration.fail'.tr(args: [e.toString()])),
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
      return 'selectCategory'.tr();
    }
    final langCode = context.locale.languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      default:
        return category.nameEn;
    }
  }

  // [수정] AI 규칙 로딩 함수: 전용 규칙이 없으면 범용 규칙('generic_v2')을 불러옵니다.
  Future<void> _loadAiRule(String? categoryId) async {
    if (categoryId == null) {
      setState(() => _selectedAiRule = null);
      return;
    }
    try {
      // 1. 카테고리 전용 규칙을 먼저 시도
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('ai_verification_rules')
          .doc(categoryId)
          .get();

      // 2. 전용 규칙이 없으면, 범용 규칙을 시도
      if (!snap.exists) {
        snap = await FirebaseFirestore.instance
            .collection('ai_verification_rules')
            .doc('generic_v2')
            .get();
      }

      if (snap.exists) {
        setState(() {
          _selectedAiRule = AiVerificationRule.fromSnapshot(snap);
        });
      } else {
        // 전용 규칙도, 범용 규칙도 없으면 null 처리
        setState(() => _selectedAiRule = null);
        debugPrint("AI 검수 규칙을 찾을 수 없습니다 (범용 규칙 포함).");
      }
    } catch (e) {
      setState(() => _selectedAiRule = null);
      debugPrint("AI 규칙 로딩 중 오류: $e");
    }
  }

  // [수정] AI 검수 시작 함수: Cloud Function을 직접 호출하는 방식으로 변경
  Future<void> _startAiVerification() async {
    // 유효성 검사 강화
    if (!_formKey.currentState!.validate() ||
        _selectedCategoryId == null ||
        _images.isEmpty ||
        _selectedAiRule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상품명, 카테고리, 이미지를 모두 입력해주세요.")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // [V2 스마트 로직] 규칙에 따라 흐름을 분기합니다.
      if (_selectedAiRule!.requiredShots.isNotEmpty) {
        await _navigateToEvidenceCollection();
      } else {
        await _generateReportDirectly();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 증거 수집 화면으로 이동하는 기존 로직
  Future<void> _navigateToEvidenceCollection() async {
    try {
      // 1단계: 상품명 예측 (초기 이미지 업로드 후 URL 사용)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      final List<String> imageUrls =
          await uploadAllProductImages(_images, user.uid);

      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'us-central1')
              .httpsCallable('initialproductanalysis');
      final result = await callable.call(<String, dynamic>{
        'imageUrls': imageUrls,
        'ruleId': _selectedAiRule!.id,
      });

      final confirmedProductName = result.data['prediction'] as String?;
      if (confirmedProductName == null || !mounted) {
        throw Exception("AI가 상품명을 인식하지 못했습니다.");
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AiEvidenceCollectionScreen(
          productId: FirebaseFirestore.instance.collection('products').doc().id,
          categoryId: _selectedCategory!.id, // [핵심 추가]
          rule: _selectedAiRule!,
          initialImages: _images,
          confirmedProductName: confirmedProductName,
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
    }
  }

  // 증거 수집 화면을 건너뛰고 바로 리포트를 생성하는 신규 로직
  Future<void> _generateReportDirectly() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      // 1. 초기 이미지 업로드
      final List<String> initialImageUrls =
          await uploadAllProductImages(_images, user.uid);

      // 2. 최종 리포트 생성 함수 호출
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'us-central1')
              .httpsCallable('generatefinalreport');
      final result = await callable.call(<String, dynamic>{
        'imageUrls': {'initial': initialImageUrls, 'guided': {}},
        'ruleId': _selectedAiRule!.id,
        'confirmedProductName': _titleController.text,
        'categoryName': _selectedParentCategoryName,
        'subCategoryName': _selectedSubCategoryName,
        'userPrice': _priceController.text,
        'userDescription': _descriptionController.text,
      });

      // [핵심 수정] 서버에서 온 generic Map을 안전하게 Map<String, dynamic>으로 변환합니다.
      final dynamic reportRaw = result.data['report'];
      if (reportRaw is! Map) {
        throw Exception("AI가 유효한 리포트를 생성하지 못했습니다.");
      }
      final reportData = Map<String, dynamic>.from(reportRaw);

      // 새 상품 ID를 미리 생성하고, 선택된 카테고리 ID를 전달합니다.
      final productId =
          FirebaseFirestore.instance.collection('products').doc().id;
      final categoryId = _selectedCategory!.id;

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AiFinalReportScreen(
            productId: productId,
            categoryId: categoryId,
            finalReport: reportData,
            rule: _selectedAiRule!,
            initialImages: _images,
            takenShots: const {},
            confirmedProductName: _titleController.text,
            userPrice: _priceController.text, // [추가]
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
      }
    }
  }

  // 이미지 업로드는 공용 helper(uploadProductImage)를 사용합니다.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('marketplace.registration.title'.tr()),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitProduct,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'marketplace.registration.done'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
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
                    labelText: 'marketplace.registration.titleHint'.tr()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'marketplace.errors.requiredField'.tr()
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
                  labelText: 'marketplace.registration.addressHint'.tr(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                // validator 제거 (자동으로 가져오므로)
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionPlaceController,
                decoration: InputDecoration(
                    labelText:
                        'marketplace.registration.addressDetailHint'.tr()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: 'marketplace.registration.priceHint'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'marketplace.errors.requiredField'.tr()
                    : null,
              ),
              SwitchListTile(
                title: Text('marketplace.registration.negotiable'.tr()),
                value: _isNegotiable,
                onChanged: (value) => setState(() => _isNegotiable = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _condition,
                decoration: InputDecoration(
                    labelText: 'marketplace.condition.label'.tr()),
                items: [
                  DropdownMenuItem(
                      value: 'new',
                      child: Text('marketplace.condition.new'.tr())),
                  DropdownMenuItem(
                      value: 'used',
                      child: Text('marketplace.condition.used'.tr())),
                ],
                onChanged: (value) =>
                    setState(() => _condition = value ?? 'used'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'marketplace.registration.descriptionHint'.tr(),
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'marketplace.errors.requiredField'.tr()
                    : null,
              ),
              // ✅ 공용 태그 위젯 추가
              CustomTagInputField(
                hintText: 'marketplace.registration.tagsHint'.tr(),
                onTagsChanged: (tags) {
                  setState(() {
                    _tags = tags;
                  });
                },
              ),
              const SizedBox(height: 24),

              // [V2 핵심 추가] AI 검수 옵션 섹션
              const Divider(height: 32),
              Text(
                "🤖 AI 검수로 신뢰도 높이기 (선택 사항)", // TODO: 다국어 키 추가
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "AI 검증 뱃지를 받아 구매자의 신뢰를 얻고 더 빨리 판매하세요. 상품 정보를 모두 입력한 후 시작할 수 있습니다.", // TODO: 다국어 키 추가
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // [핵심 수정] 버튼 활성/비활성 및 동작 구현
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _titleController,
                builder: (context, value, _) {
                  final isReady = value.text.isNotEmpty &&
                      _selectedCategoryId != null &&
                      _images.isNotEmpty &&
                      _selectedAiRule != null &&
                      _selectedParentCategoryName != null; // 이름까지 로드되었는지 확인
                  return OutlinedButton.icon(
                    onPressed:
                        (isReady && !_isSaving) ? _startAiVerification : null,
                    icon: const Icon(Icons.shield_outlined),
                    label: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("AI 검수 시작하기"), // TODO: 다국어 키 추가
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

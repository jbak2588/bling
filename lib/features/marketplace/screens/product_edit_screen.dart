/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/product_edit_screen.dart
/// Purpose       : 기존 상품의 세부 정보, 이미지, 위치를 수정합니다.
/// User Impact   : 판매자가 정확한 정보를 유지하고 오류를 수정할 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_detail_screen.dart; lib/features/marketplace/widgets/product_card.dart
/// Data Model    : Firestore `products` 필드 `title`, `description`, `price`, `negotiable`, `imageUrls`, `locationName`, `locationParts`, `geoPoint`, `transactionPlace`, `condition`.
/// Location Scope: LocationSettingScreen을 통해 Prov→Kec→Kel 재설정을 허용합니다.
/// Privacy Note : 피드(목록/카드) 또는 요약 뷰에서는 `locationParts['street']` 및 전체 `locationName`을 사용자 동의 없이 노출하지 마세요. 목록에서는 행정구역을 축약형(`kel.`, `kec.`, `kab.`, `prov.`)으로 표시하세요.
/// Trust Policy  : trustScore 100 초과의 상품 소유자만 수정할 수 있으며 수정 내용은 모더레이션 로그에 기록됩니다.
/// Monetization  : 수정 후 프리미엄 부스트 적용 가능; TODO: 부스트 과금 정의.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `start_product_edit`, `complete_product_edit`.
/// Analytics     : 이미지 삭제와 가격 변화를 추적합니다.
/// I18N          : 키 `marketplace.error`, `marketplace.success` (assets/lang/*.json)
/// Dependencies  : firebase_auth, cloud_firestore, firebase_storage, image_picker, easy_localization
/// Security/Auth : 인증된 사용자가 `product.userId`와 일치해야 합니다.
/// Edge Cases    : 이미지 업로드 실패, 카테고리 불일치.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// 2025년 8월 30일 : 공용위젯인 테그 위젯, 검색화 도입 및 이미지 갤러리 위젯 작업 진행
/// ============================================================================
library;

// 아래부터 실제 코드

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/utils/upload_helpers.dart';

import '../models/product_model.dart';
// import '../../../core/models/user_model.dart';
import '../../categories/domain/category.dart';
import '../../categories/screens/parent_category_screen.dart';
import '../../location/screens/location_filter_screen.dart';

// ✅ 공용 태그 위젯 import  : 2025년 8월 30일
import '../../shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/features/marketplace/widgets/ai_verification_badge.dart'; // [추가] AI 뱃지
// search index generation removed to avoid background indexing costs
// [V3 REFACTOR] 'AI 룰 엔진' 모델 종속성 완전 삭제

import 'package:bling_app/features/marketplace/services/ai_verification_service.dart';

class ProductEditScreen extends StatefulWidget {
  final ProductModel product;
  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _aiVerificationService = AiVerificationService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _transactionPlaceController = TextEditingController();

  bool _isNegotiable = false;
  List<String> _existingImageUrls = [];
  final List<XFile> _images = [];
  // bool _isLoading = false; // [작업 68] _loadingStatus로 대체
  String? _loadingStatus; // 저장 또는 AI 시작 시
  String _status = 'selling'; // [Fix] Add status state variable
  Category? _selectedCategory;
  Category? _selectedParentCategory; // [작업 72] 부모 카테고리 저장용
  String _condition = 'used';

  // ✅ 태그 목록을 관리할 상태 변수 추가 : 2025년 8월 30일
  List<String> _tags = [];

  // [추가] AI 검증 여부
  bool _isAiVerified = false;
  // [V3 REFACTOR] 'AI 룰 엔진' 종속성(AiVerificationRule) 제거
  // [핵심 추가] AI 검수 진행 상태를 추적하는 변수
  bool _isCancellingAi = false;
  // [작업 71] 선택된(또는 저장된) 카테고리 관련 상태
  String? _selectedCategoryId;
  // bool _isAiLoading = false; // [작업 68] _loadingStatus로 대체

  // [작업 8] 위치 정보 상태 관리 추가
  Map<String, dynamic>? _locationParts;
  GeoPoint? _geoPoint;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.product.title;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
    _addressController.text = widget.product.locationName ?? '';
    _locationParts = widget.product.locationParts; // 초기화
    _geoPoint = widget.product.geoPoint; // 초기화
    _transactionPlaceController.text = widget.product.transactionPlace ?? '';
    _isNegotiable = widget.product.negotiable;
    _existingImageUrls = List<String>.from(widget.product.imageUrls);

    // ✅ [Fix] Load existing tags from the product into the local state so the
    // CustomTagInputField shows previously saved tags when editing.
    try {
      _tags = List<String>.from(widget.product.tags);
    } catch (_) {
      _tags = [];
    }

    // [Fix] Dropdown 크래시 방어 코드 (작업 32 적용)
    final dbCondition = widget.product.condition;
    if (dbCondition == 'new' || dbCondition == 'used') {
      _condition = dbCondition;
    } else {
      debugPrint(
          "Warning: Invalid condition value '$dbCondition' for ${widget.product.id}. Defaulting to 'used'.");
      _condition = 'used'; // 오염된 값이면 'used'로 강제
    }

    // 초기 카테고리 ID 설정 후 비동기로 카테고리/규칙을 로드합니다.
    // Prefer subcategory id (product.categoryId) first for lookups and rule loading
    _selectedCategoryId = widget.product.categoryId;
    // 초기 AI 검증 상태를 로드합니다.
    _isAiVerified = widget.product.isAiVerified;
    _loadInitialCategory();
    // [V3 REFACTOR] '_loadCategoryDetails' (룰 로딩 함수) 호출 제거
  }

  // [V3 REFACTOR] 'loadAiRule'에 의존하던 '_loadCategoryDetails' 함수 (약 20줄) 완전 삭제

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _loadInitialCategory() async {
    // Defensive: normalize and validate the stored category id before querying.
    final dynamic raw = widget.product.categoryId;
    if (raw == null) return; // nothing to do

    String? id;
    if (raw is String) {
      id = raw.trim();
      if (id.isEmpty) id = null;
      // If a full path was stored (e.g. "categories/parentId"), extract last segment
      if (id != null && id.contains('/')) {
        id = id.split('/').last;
      }
    } else {
      // In rare cases older documents might contain a DocumentReference-like value.
      try {
        final maybeId = (raw as dynamic).id;
        if (maybeId is String && maybeId.isNotEmpty) {
          id = maybeId;
        } else {
          id = raw.toString().split('/').last;
        }
      } catch (_) {
        id = raw.toString().split('/').last;
      }
    }

    if (id == null) return;

    // Resolve category using the stored `categoryId` on the product.
    // ProductModel may include `categoryParentId`; `categoryId` may be a
    // parent or a subcategory id. Strategy:
    // 1) Try to load a parent document at categories_v2/{categoryId}.
    // 2) If not found, search collectionGroup('subCategories') for a matching
    //    doc id and then load its parent using the child's parentId.
    final String catId = widget.product.categoryId;

    // If product explicitly stores parent id, use it first (preferred)
    final String? prodParentId = widget.product.categoryParentId;
    if (prodParentId != null && prodParentId.isNotEmpty) {
      try {
        final parentDoc = await FirebaseFirestore.instance
            .collection('categories_v2')
            .doc(prodParentId)
            .get();
        if (parentDoc.exists) {
          // try to load sub doc under the parent
          final subDoc = await FirebaseFirestore.instance
              .collection('categories_v2')
              .doc(prodParentId)
              .collection('subCategories')
              .doc(catId)
              .get();

          if (subDoc.exists) {
            setState(() {
              _selectedParentCategory = Category.fromFirestore(parentDoc);
              _selectedCategory = Category.fromFirestore(subDoc);
              _selectedCategoryId = catId;
            });
            return;
          }

          // If subDoc doesn't exist, but parent exists and catId equals parentId,
          // treat product category as the parent
          if (prodParentId == catId) {
            setState(() {
              _selectedParentCategory = Category.fromFirestore(parentDoc);
              _selectedCategory = _selectedParentCategory;
              _selectedCategoryId = catId;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('Error loading category via product.categoryParentId: $e');
      }
    }

    try {
      // 1) Parent doc lookup
      final parentDoc = await FirebaseFirestore.instance
          .collection('categories_v2')
          .doc(catId)
          .get();
      if (parentDoc.exists) {
        setState(() {
          _selectedParentCategory = Category.fromFirestore(parentDoc);
          _selectedCategory = _selectedParentCategory; // parent selected
          _selectedCategoryId = catId;
        });
        return;
      }

      // 2) Fallback: find subcategory document by id across subCategories
      try {
        final q = await FirebaseFirestore.instance
            .collectionGroup('subCategories')
            .where(FieldPath.documentId, isEqualTo: catId)
            .limit(1)
            .get();

        if (q.docs.isNotEmpty) {
          final subDoc = q.docs.first;
          final subCategory = Category.fromFirestore(subDoc);
          final parentId = subCategory.parentId;

          if (parentId != null && parentId.isNotEmpty) {
            final parentDoc2 = await FirebaseFirestore.instance
                .collection('categories_v2')
                .doc(parentId)
                .get();
            if (parentDoc2.exists) {
              setState(() {
                _selectedParentCategory = Category.fromFirestore(parentDoc2);
                _selectedCategory = subCategory;
                _selectedCategoryId = catId;
              });
              return;
            }
          }

          // parent not found, but set the subcategory so UI shows something
          setState(() {
            _selectedCategory = subCategory;
            _selectedCategoryId = catId;
          });
          return;
        }
      } catch (e) {
        debugPrint('collectionGroup by docId failed for id=$catId: $e');
      }

      debugPrint('Warning: Could not resolve category for id=$catId');
    } catch (e) {
      debugPrint('Failed _loadInitialCategory: $e');
    }
  }

  void _selectCategory() async {
    final result = await Navigator.of(context).push<Category>(
      MaterialPageRoute(builder: (context) => const ParentCategoryScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result;
        // [작업 74] 부모/자식 카테고리를 선택 스크린에서 올바르게 받아왔다고 가정
        _selectedParentCategory = (result.isParent) ? result : null;
        _selectedCategoryId = result.id;
        // [V3 REFACTOR] 'loadAiRule'을 호출하던 '_loadCategoryDetails' 제거
      });
    }
  }

  Future<void> _resetLocation() async {
    // 0번 탭(행정구역)을 기본으로 엽니다.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const LocationFilterScreen(initialTabIndex: 0)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // 주소 문자열 조합 (예: Kel. A, Kec. B, Kab. C)
        final kKel = result['kel'] != null ? "Kel. ${result['kel']}" : "";
        final kKec = result['kec'] != null ? "Kec. ${result['kec']}" : "";
        final kKab = (result['kab'] ?? "").toString().startsWith("KOTA") ||
                (result['kab'] ?? "").toString().startsWith("KAB")
            ? result['kab']
            : "Kab. ${result['kab'] ?? ''}";

        final newAddress =
            [kKel, kKec, kKab].where((s) => s.toString().isNotEmpty).join(', ');

        _addressController.text = newAddress;
        _locationParts = result;
        _geoPoint = null; // 행정구역 선택은 좌표가 없으므로 null 처리 (필요 시 별도 지오코딩)
      });
    }
  }

  String _getCategoryName(BuildContext context, Category? category) {
    if (category == null) return 'selectCategory'.tr();
    final langCode = context.locale.languageCode;
    // [작업 74] 부모 이름 + 자식 이름 (예: 디지털기기 > 스마트폰)
    if (_selectedParentCategory != null && !category.isParent) {
      return "${_selectedParentCategory!.displayName(langCode)} > ${category.displayName(langCode)}";
    }
    // 부모를 찾지 못했거나, 부모 카테고리 자체인 경우
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      default:
        return category.nameEn;
    }
  }

  Future<void> _saveProduct() async {
    if (_loadingStatus != null) return;
    if (_existingImageUrls.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marketplace.errors.noPhoto'.tr())),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loadingStatus = 'marketplace.edit.saving'.tr();
    });

    try {
      // 새로 추가된 이미지 업로드 (user-scoped path)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('marketplace.errors.loginRequired'.tr());
      }
      final List<String> uploadedUrls =
          await uploadAllProductImages(_images, user.uid);

      // 기존 이미지 + 새로 업로드된 이미지 합치기
      final allImageUrls = [..._existingImageUrls, ...uploadedUrls];

      // Search index generation removed (resource optimization)

      // [작업 8] 사용자 프로필 위치로 덮어쓰는 로직 제거.
      // 대신 화면에서 편집된(_resetLocation 통해) 정보를 사용합니다.
      // final userDoc = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(user.uid)
      //     .get();
      // if (!userDoc.exists) {
      //   throw Exception('marketplace.errors.userNotFound'.tr());
      // }
      // final userModel = UserModel.fromFirestore(userDoc);

      // ✅ [핵심 수정] copyWith 대신, Map을 직접 만들어 업데이트합니다.
      final updatedData = {
        'title': _titleController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text,
        'transactionPlace': _transactionPlaceController.text,
        'negotiable': _isNegotiable,
        'imageUrls': allImageUrls,
        'categoryId': _selectedCategory?.id ?? widget.product.categoryId,
        'categoryParentId':
            _selectedCategory?.parentId ?? widget.product.categoryParentId,
        'condition': _condition,
        'status': _status, // [Fix] Save the updated status

        'tags': _tags, // ✅ 수정된 태그를 업데이트 데이터에 포함 : 2025년 8월 30일
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
        'updatedAt': Timestamp.now(),
        'userUpdatedAt': Timestamp.now(), // [Fix #40] 사용자가 직접 저장했으므로 '끌어올리기'

        // [작업 8] 수정된 위치 정보 반영
        'locationName': _addressController.text,
        'locationParts': _locationParts,
        'geoPoint': _geoPoint,
      };

// ✅ [핵심 수정] toJson() 대신 생성한 Map을 사용하여 update합니다.
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.edit.success'.tr())),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('marketplace.edit.fail'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingStatus = null);
    }
  }

  // [리팩토링] AI 검수 시작 로직을 서비스 클래스로 위임
  Future<void> _startAiVerification() async {
    // [V3 REFACTOR] '_aiRule' 체크 대신 '_selectedCategoryId' 체크로 변경
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marketplace.errors.noCategory'.tr())),
      );
      return;
    }

    setState(() => _loadingStatus = 'ai_flow.status.analyzing'.tr());

    try {
      await _aiVerificationService.startVerificationFlow(
        // [V3 REFACTOR] 'rule' 파라미터 완전 제거
        context: context,
        productId: widget.product.id,
        // Prefer the product's subcategory id so AI rules are loaded per-subcategory.
        categoryId: _selectedCategoryId!, // V3는 현재 선택된 카테고리 ID를 사용
        initialImages: widget.product.imageUrls,
        productName: _titleController.text,
        productDescription: _descriptionController.text,
        productPrice: _priceController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ai_flow.common.error'
                  .tr(namedArgs: {'error': e.toString()}))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingStatus = null);
      }
    }
  }

  /// [개편안 1] AI 검수 취소 로직
  Future<void> _cancelAiVerification() async {
    // 1회만 취소 가능
    if (widget.product.aiCancelCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marketplace.ai.cancel_limit'.tr())),
      );
      return;
    }

    setState(() => _isCancellingAi = true);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({
        'isAiVerified': false,
        'aiVerificationStatus': 'none',
        'aiCancelCount': FieldValue.increment(1),
        // aiReport, aiReportSource... 등은 재사용을 위해 삭제하지 않음
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.ai.cancel_success'.tr())),
        );
        // 화면 갱신을 위해 pop (또는 product 모델 리로드)
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('marketplace.ai.cancel_error'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancellingAi = false);
      }
    }
  }

  /// Show confirmation dialog before cancelling AI verification.
  Future<void> _confirmCancelAi() async {
    // Button should be disabled when aiCancelCount > 0, but guard anyway
    if (widget.product.aiCancelCount > 0) return;
    // Use a two-step confirmation: explanatory text + checkbox acknowledgement
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool ackChecked = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('marketplace.ai.cancel_confirm'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('marketplace.ai.cancel_limit'.tr()),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: ackChecked,
                      onChanged: (v) => setState(() => ackChecked = v ?? false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('marketplace.ai.cancel_ack_charge'.tr()),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('common.cancel'.tr()),
              ),
              TextButton(
                onPressed:
                    ackChecked ? () => Navigator.of(context).pop(true) : null,
                child: Text('common.confirm'.tr()),
              ),
            ],
          );
        });
      },
    );

    if (confirmed == true) {
      await _cancelAiVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('marketplace.edit.title'.tr()),
        actions: [
          IconButton(
            onPressed: _loadingStatus != null ? null : _saveProduct,
            icon: _loadingStatus != null
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.save,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 이미지 섹션
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // 기존 이미지
                      ...List.generate(_existingImageUrls.length, (index) {
                        final url = _existingImageUrls[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeExistingImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // 새로 추가한 이미지
                      ...List.generate(_images.length, (index) {
                        final img = _images[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(img.path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeNewImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // 추가 버튼
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final List<XFile> picked =
                                await picker.pickMultiImage();
                            if (picked.isNotEmpty && mounted) {
                              setState(() {
                                _images.addAll(picked);
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'marketplace.edit.titleHint'.tr(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'marketplace.errors.requiredField'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                // [작업 71] 1. 카테고리 로딩 중이 아닐 때만 선택기 표시
                if (_loadingStatus == 'ai_flow.status.loading_category'.tr())
                  ListTile(
                    title: const Text("카테고리 정보 로딩 중..."),
                    leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
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
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'marketplace.edit.priceHint'.tr(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'marketplace.errors.requiredField'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'marketplace.edit.descriptionHint'.tr(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'marketplace.errors.requiredField'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'marketplace.edit.addressHint'.tr(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetLocation,
                    child: Text('marketplace.edit.resetLocation'.tr()),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transactionPlaceController,
                  decoration: InputDecoration(
                    labelText:
                        'marketplace.registration.addressDetailHint'.tr(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('marketplace.edit.negotiable'.tr()),
                    Switch(
                      value: _isNegotiable,
                      onChanged: (value) {
                        setState(() {
                          _isNegotiable = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  decoration: InputDecoration(
                    labelText: 'marketplace.condition.label'.tr(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'new',
                      child: Text('marketplace.condition.new'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'used',
                      child: Text('marketplace.condition.used'.tr()),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _condition = value ?? 'used'),
                ),
                const SizedBox(height: 16),
                // [Fix] Re-add the Status selection dropdown
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: 'marketplace.status.label'.tr(),
                    // [Fix] AI 안심 예약으로 예약된 경우, 비활성화하고 안내 문구 표시
                    helperText:
                        (widget.product.isAiVerified && _status == 'reserved')
                            ? 'marketplace.errors.aiReserved'.tr()
                            : null,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'selling',
                      child: Text('marketplace.status.selling'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'reserved',
                      child: Text('marketplace.status.reserved'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'sold',
                      child: Text('marketplace.status.sold'.tr()),
                    ),
                  ],
                  // [Fix] AI 안심 예약으로 예약된 상품은 판매자가 상태 변경 불가
                  onChanged: (widget.product.isAiVerified &&
                          _status == 'reserved')
                      ? null // AI에 의해 예약된 경우 비활성화
                      : (value) => setState(() => _status = value ?? 'selling'),
                ),

                const SizedBox(height: 16),
                CustomTagInputField(
                  initialTags: _tags,
                  hintText: 'tag_input.addHint'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),

                // AI 검수 섹션
                if (!_isAiVerified) ...[
                  const Divider(height: 32),
                  Text(
                    'ai_flow.cta.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ai_flow.cta.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed:
                        _loadingStatus != null ? null : _startAiVerification,
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
                        : Text('ai_flow.cta.start_button'.tr()),
                  ),
                ] else ...[
                  const Divider(height: 32),
                  const AiVerificationBadge(),
                  const SizedBox(height: 8),
                  // [개편안 1] AI 검수 취소 버튼
                  if (_isCancellingAi)
                    const Center(child: CircularProgressIndicator())
                  else
                    TextButton(
                      onPressed: (widget.product.aiCancelCount > 0)
                          ? null
                          : _confirmCancelAi,
                      child: Text(
                        'marketplace.ai.cancel_confirm'.tr(),
                        style: TextStyle(
                          color: (widget.product.aiCancelCount > 0)
                              ? Colors.grey
                              : Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 72),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _loadingStatus != null ? null : _saveProduct,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _loadingStatus != null
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('marketplace.edit.save'.tr()),
          ),
        ),
      ),
    );
  }
}

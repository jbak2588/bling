import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// ✅ [신뢰-경매] 1. 경매 모델, 레포지토리, 카테고리 import
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/core/constants/app_categories.dart';

class AiFinalReportScreen extends StatefulWidget {
  final String productId; // [수정] 새 상품이면 새 ID, 수정이면 기존 ID
  final String categoryId; // [핵심 추가] 상품이 속한 실제 카테고리 ID
  final Map<String, dynamic> finalReport;
  final AiVerificationRule rule;
  final List<dynamic> initialImages;
  final Map<String, XFile> takenShots;
  final String confirmedProductName;
  final String? userPrice; // [추가] 사용자가 입력한 가격(선택)
  // TODO: 이전 화면들로부터 가격, 설명 등 다른 필드들도 전달받아야 함

  const AiFinalReportScreen({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.finalReport,
    required this.rule,
    required this.initialImages,
    required this.takenShots,
    required this.confirmedProductName,
    this.userPrice, // [추가]
  });

  @override
  State<AiFinalReportScreen> createState() => _AiFinalReportScreenState();
}

class _AiFinalReportScreenState extends State<AiFinalReportScreen> {
  final Map<String, TextEditingController> _specsControllers = {};
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _priceSuggestionController =
      TextEditingController();
  final TextEditingController _buyerNotesController = TextEditingController();
  // [복원] 상품 제목, 가격, 설명을 위한 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // ✅ 거래 장소 입력 컨트롤러 (경매 시 선택 사항)
  final TextEditingController _transactionPlaceController =
      TextEditingController();

  List<dynamic> _allImages = [];
  bool _isSubmitting = false;
  UserModel? _currentUserModel;

  // ✅ [신뢰-경매] 2. 경매/판매 토글 및 기간 상태 변수
  RegistrationType _registrationType = RegistrationType.sale;
  int _durationInDays = 3; // 경매 기간
  final AuctionRepository _auctionRepository = AuctionRepository();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _allImages = [...widget.initialImages, ...widget.takenShots.values];
    // 사용자 위치/신뢰 정보 미리 로드
    _fetchUserModel();
  }

  void _initializeControllers() {
    _titleController.text = widget.confirmedProductName;
    _summaryController.text = widget.finalReport['verification_summary'] ?? '';
    _buyerNotesController.text = widget.finalReport['notes_for_buyer'] ?? '';
    _conditionController.text = widget.finalReport['condition_check'] ?? '';
    _itemsController.text =
        (widget.finalReport['included_items'] as List<dynamic>? ?? [])
            .join(', ');

    // [수정] 가격 컨트롤러 초기화 로직 변경
    // 판매 가격은 사용자가 입력한 가격을 기본값으로 설정
    _priceController.text = widget.userPrice ?? '';
    // AI 추천 가격은 별도의 컨트롤러로 관리 (suggested_price 우선, 그다음 price_suggestion)
    _priceSuggestionController.text =
        widget.finalReport['suggested_price']?.toString() ??
            widget.finalReport['price_suggestion']?.toString() ??
            '';

    // [핵심 수정] 중첩된 key_specs 맵을 안전하게 Map<String, dynamic>으로 변환합니다.
    final dynamic rawSpecs = widget.finalReport['key_specs'];
    final Map<String, dynamic> specs =
        (rawSpecs is Map) ? Map<String, dynamic>.from(rawSpecs) : {};
    specs.forEach((key, value) {
      _specsControllers[key] = TextEditingController(text: value.toString());
    });

    // [핵심 로직 복원] 컨트롤러 초기화 후, 상세 설명 필드를 자동으로 채웁니다.
    _applyAllSuggestionsToDescription(isInitial: true);
  }

  // ✅ [신뢰-경매] 4. 현재 사용자 정보(위치 등)를 가져오는 함수
  Future<void> _fetchUserModel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() => _currentUserModel = UserModel.fromFirestore(userDoc));
      }
    } catch (e) {
      debugPrint("User model fetch error: $e");
    }
  }

  // [핵심 로직 복원] 모든 AI 분석 결과를 조합하여 상세 설명 필드를 채우는 함수
  void _applyAllSuggestionsToDescription({bool isInitial = false}) {
    String specsText = _specsControllers.entries
        .map((e) => "- ${e.key}: ${e.value.text}")
        .join('\n');

    setState(() {
      _descriptionController.text = '''[AI 검증 요약]
${_summaryController.text}

[주요 사양]
$specsText

[상태 점검]
${_conditionController.text}

[구성품]
${_itemsController.text.split(',').map((e) => "- ${e.trim()}").join('\n')}
''';
    });

    if (!isInitial) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 제안이 상세 설명에 적용되었습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _conditionController.dispose();
    _itemsController.dispose();
    _priceSuggestionController.dispose();
    _buyerNotesController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _transactionPlaceController.dispose();
    for (var controller in _specsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<String> _uploadImage(XFile image, String userId) async {
    final fileName = '${const Uuid().v4()}${p.extension(image.path)}';
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/$userId/$fileName');
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  // ✅ [신뢰-경매] 8-1. 경매 등록 확인 다이얼로그
  Future<void> _showAuctionConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auctions.create.confirmTitle'.tr()),
        content: Text('auctions.create.confirmContent'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _registrationType = RegistrationType.auction;
      });
    }
  }

  // ✅ [신뢰-경매] 8-2. 세그먼트 버튼 선택 변경 로직
  // ignore: unused_element
  void _onRegistrationTypeChanged(Set<RegistrationType> newSelection) {
    final selectedType = newSelection.first;

    // 이미 경매 상태이거나 판매 선택이면 즉시 변경, 그 외에는 확인창 표시
    if (selectedType == RegistrationType.sale ||
        _registrationType == RegistrationType.auction) {
      setState(() {
        _registrationType = selectedType;
      });
    } else {
      _showAuctionConfirmationDialog();
    }
  }

  // ✅ [신뢰-경매] 등록 유형 선택에 따른 최종 처리
  Future<void> _finalizeListing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('main.errors.userNotFound'.tr())));
      return;
    }

    // 필수 입력: 경매 선택 시 거래 희망 장소가 비어있으면 제출 불가
    if (_registrationType == RegistrationType.auction &&
        _transactionPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.errors.requiredField'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 1) 모든 이미지를 업로드/정규화
      final List<String> allImageUrls = [];
      for (final image in _allImages) {
        if (image is String) {
          allImageUrls.add(image);
        } else if (image is XFile) {
          allImageUrls.add(await _uploadImage(image, user.uid));
        }
      }

      // 2) 유형 분기
      if (_registrationType == RegistrationType.sale) {
        await _submitProductSale(user, allImageUrls);
      } else {
        await _submitProductAuction(user, allImageUrls);
      }

      // 3) 완료 처리
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('ai_flow.final_report.success'.tr())),
      );
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content:
                Text('ai_flow.final_report.fail'.tr(args: [e.toString()]))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ✅ 일반 판매 저장
  Future<void> _submitProductSale(User user, List<String> allImageUrls) async {
    // V2 UI 컨트롤러들로부터 최종 AI 리포트 객체 구성(간단 버전)
    final int userSelectedPrice = int.tryParse(_priceController.text) ?? 0;
    final int aiSuggestedPrice =
        int.tryParse(_priceSuggestionController.text) ?? 0;
    final finalAiReport = {
      'verification_summary': _summaryController.text,
      'condition_check': _conditionController.text,
      'included_items':
          _itemsController.text.split(',').map((e) => e.trim()).toList(),
      'notes_for_buyer': _buyerNotesController.text,
      'suggested_price': aiSuggestedPrice,
      'price_suggestion': aiSuggestedPrice,
      'ai_recommended_price': aiSuggestedPrice,
      'user_selected_price': userSelectedPrice,
      'key_specs':
          _specsControllers.map((key, value) => MapEntry(key, value.text)),
    };

    final product = ProductModel(
      id: widget.productId,
      userId: user.uid,
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrls: allImageUrls,
      categoryId: widget.categoryId,
      // 판매가는 사용자가 입력한 값이 있으면 우선 사용, 없으면 AI 추천가 사용
      price: (userSelectedPrice > 0) ? userSelectedPrice : aiSuggestedPrice,
      negotiable: false,
      tags: const [],
      locationName: _currentUserModel?.locationName,
      locationParts: _currentUserModel?.locationParts,
      geoPoint: _currentUserModel?.geoPoint,
      status: 'selling',
      condition: _conditionController.text.isNotEmpty
          ? _conditionController.text.toLowerCase()
          : 'used',
      transactionPlace: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isAiVerified: true,
      aiVerificationStatus: 'approved',
      aiVerificationData: finalAiReport,
      aiReport: widget.finalReport,
    );

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .set(product.toJson(), SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'productIds': FieldValue.arrayUnion([widget.productId])
    });
  }

  // ✅ 경매 등록 저장
  Future<void> _submitProductAuction(
      User user, List<String> allImageUrls) async {
    final mappedAuctionCategory =
        _mapMarketCategoryToAuctionCategory(widget.categoryId);
    final startPrice = int.tryParse(_priceSuggestionController.text) ?? 0;
    final now = Timestamp.now();
    final endAt = Timestamp.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch +
          Duration(days: _durationInDays).inMilliseconds,
    );

    final newAuction = AuctionModel(
      id: '',
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : widget.confirmedProductName,
      description: _descriptionController.text,
      images: allImageUrls,
      startPrice: startPrice,
      currentBid: startPrice,
      bidHistory: const [],
      location:
          _currentUserModel?.locationName ?? 'postCard.locationNotSet'.tr(),
      transactionPlace: _transactionPlaceController.text,
      locationParts: _currentUserModel?.locationParts,
      geoPoint: _currentUserModel?.geoPoint,
      startAt: now,
      endAt: endAt,
      ownerId: user.uid,
      category: mappedAuctionCategory,
      tags: const [],
      isAiVerified: true,
      trustLevelVerified: _currentUserModel?.trustLevel == 'trusted' ||
          _currentUserModel?.trustLevel == 'verified',
    );

    await _auctionRepository.createAuction(newAuction);
  }

  // ✅ 카테고리 매핑: 마켓플레이스 카테고리 → 경매 카테고리
  String _mapMarketCategoryToAuctionCategory(String marketplaceCategoryId) {
    // 1) 동일 ID가 경매에 존재하면 그대로 사용
    final exists = AppCategories.auctionCategories
        .any((c) => c.categoryId == marketplaceCategoryId);
    if (exists) return marketplaceCategoryId;
    // 2) 간단한 매핑 규칙 (필요 시 확장)
    final id = marketplaceCategoryId.toLowerCase();
    if (id.contains('collect') || id.contains('figure')) return 'collectibles';
    if (id.contains('digital') ||
        id.contains('elect') ||
        id.contains('gadget')) {
      return 'digital';
    }
    if (id.contains('fashion') || id.contains('cloth') || id.contains('wear')) {
      return 'fashion';
    }
    if (id.contains('vintage') || id.contains('classic')) return 'vintage';
    if (id.contains('art') || id.contains('craft')) return 'art_craft';
    // 3) 기본값
    return 'etc';
  }

  @override
  Widget build(BuildContext context) {
    // ... UI 코드는 작업 101과 거의 동일하게 유지 ...
    // 단, TextFormField 들이 _titleController, _priceController, _descriptionController를 사용하도록 변경
    return Scaffold(
      appBar: AppBar(title: Text('ai_flow.final_report.title'.tr())),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _allImages.length,
                  itemBuilder: (context, index) {
                    final image = _allImages[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: image is XFile
                          ? Image.file(File(image.path),
                              width: 100, height: 100, fit: BoxFit.cover)
                          : Image.network(image.toString(),
                              width: 100, height: 100, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // [복원] 상품 제목, 가격, 설명 필드
              TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'marketplace.registration.titleHint'.tr(),
                      border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                      labelText: 'marketplace.registration.priceHint'.tr(),
                      border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const Divider(height: 32),
              // [추가] AI 추천 가격을 별도로 표시 (편집 불가)
              TextFormField(
                  controller: _priceSuggestionController,
                  decoration: InputDecoration(
                      labelText: tr('ai_flow.final_report.suggested_price',
                          args: ['Rp']),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.auto_awesome))),
              // 판매 유형 선택 (일반 판매 / 경매)
              const SizedBox(height: 24),
              Text('auctions.create.registrationType'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<RegistrationType>(
                segments: [
                  ButtonSegment(
                      value: RegistrationType.sale,
                      label: Text('auctions.create.type.sale'.tr()),
                      icon: const Icon(Icons.storefront_outlined)),
                  ButtonSegment(
                      value: RegistrationType.auction,
                      label: Text('auctions.create.type.auction'.tr()),
                      icon: const Icon(Icons.gavel_outlined)),
                ],
                selected: {_registrationType},
                onSelectionChanged: _onRegistrationTypeChanged,
              ),
              // 경매 선택 시 기간 설정 UI
              if (_registrationType == RegistrationType.auction) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _durationInDays,
                  decoration: InputDecoration(
                      labelText: 'auctions.create.form.duration'.tr(),
                      border: const OutlineInputBorder()),
                  items: [3, 5, 7]
                      .map((days) => DropdownMenuItem(
                            value: days,
                            child: Text('auctions.create.form.durationOption'
                                .tr(namedArgs: {'days': days.toString()})),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _durationInDays = value);
                    }
                  },
                ),
              ],
              const Divider(height: 32),
              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                    labelText: 'ai_flow.final_report.summary'.tr(),
                    border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // [V2.1] 구매자 안내 노트 표시 및 편집 가능
              TextFormField(
                controller: _buyerNotesController,
                decoration: InputDecoration(
                    labelText: 'ai_flow.final_report.buyer_notes'.tr(),
                    border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildReportSection(
                  'ai_flow.final_report.key_specs'.tr(),
                  _specsControllers.entries
                      .map((e) => MapEntry(e.key, e.value))
                      .toList()),
              const SizedBox(height: 16),
              TextFormField(
                controller: _conditionController,
                decoration: InputDecoration(
                    labelText: 'ai_flow.final_report.condition'.tr(),
                    border: const OutlineInputBorder()),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _itemsController,
                  decoration: InputDecoration(
                      labelText: 'ai_flow.final_report.included_items'.tr(),
                      border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'ai_flow.final_report.final_description'.tr(),
                    border: const OutlineInputBorder()),
                maxLines: 12,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionPlaceController,
                decoration: InputDecoration(
                    labelText:
                        'marketplace.registration.addressDetailHint'.tr(),
                    border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'marketplace.errors.requiredField'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
              // [수정] isInitial 플래그를 사용하여 버튼 클릭 시에만 스낵바가 표시되도록 합니다.
              ElevatedButton.icon(
                onPressed: () => _applyAllSuggestionsToDescription(),
                icon: const Icon(Icons.auto_fix_high),
                label: Text('ai_flow.final_report.apply_suggestions'.tr()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _finalizeListing,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_registrationType == RegistrationType.sale
                  ? 'ai_flow.final_report.submit_button'.tr()
                  : 'auctions.create.submit_button'.tr()),
        ),
      ),
    );
  }

  Widget _buildReportSection(
    String title,
    List<MapEntry<String, TextEditingController>> controllers,
  ) {
    // ... 이 위젯은 변경 없음 ...
    if (controllers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const Divider(),
        ...controllers.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: entry.value,
              decoration: InputDecoration(
                labelText: entry.key,
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ✅ 등록 유형 구분을 위한 enum
enum RegistrationType { sale, auction }

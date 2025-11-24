/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/ai_final_report_screen.dart
/// Purpose       : AI가 생성한 최종 보고서를 폼에 채워넣고, 사용자가 검토 후
///                 최종 상품(또는 경매)을 등록하는 화면입니다.
///
/// [V2.1/V2.2 주요 변경 사항 (Job 30, 32, 33)]
/// 1. [CRITICAL FIX] 데이터 오염 방지:
///    - 이 화면은 `_submitProductSale` 실행 시, 사용자의 원본 `description`과
///      `condition` ('used'/'new') 필드가 AI의 분석 내용으로 덮어쓰기되는
///      치명적인 버그가 있었습니다.
///    - [Fix] `description` 필드에 `widget.userDescription` (원본 설명)을
///      저장하도록 수정했습니다.
///    - [Fix] `condition` 필드에 AI의 긴 텍스트 대신 'used' (고정값)를
///      저장하도록 수정했습니다. (작업 31 크래시 해결)
///    - [Fix] AI 요약본을 description에 강제 적용하던 `_applyAllSuggestions...`
///      버튼 및 `initState` 호출을 제거했습니다.
///
/// 2. [개편안 1] 보고서 스냅샷 저장:
///    - 상품 저장 시, `isAiFreeTierUsed: true`를 설정하고,
///    - `aiReportSourceDescription` 및 `aiReportSourceImages` 필드에
///      현재의 설명과 이미지 목록을 '스냅샷'으로 저장하여 '보고서 재사용' 로직을 지원합니다.
/// ============================================================================
///
library;

import 'dart:io';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/widgets/ai_report_viewer.dart'; // [V3] 리포트 뷰어 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
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
  // [V3 REFACTOR] '룰 엔진' 종속성(rule, takenShots) 제거
  // final AiVerificationRule rule;
  // final Map<String, XFile> takenShots;
  final List<String> initialImageUrls;
  final Map<String, String> guidedImageUrls;
  final String confirmedProductName;
  final String? userPrice; // [추가] 사용자가 입력한 가격(선택)
  // TODO: 이전 화면들로부터 가격, 설명 등 다른 필드들도 전달받아야 함

  final String? userDescription; // [개편안 1] 원본 설명
  final bool skipUserFetch; // test-friendly flag to skip Firebase user fetch
  const AiFinalReportScreen({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.finalReport,
    // [V3 REFACTOR]
    required this.initialImageUrls,
    required this.guidedImageUrls,
    required this.confirmedProductName,
    this.userPrice, // [추가]
    this.userDescription, // [개편안 1] 원본 설명
    this.skipUserFetch = false,
  });

  @override
  State<AiFinalReportScreen> createState() => _AiFinalReportScreenState();
}

class _AiFinalReportScreenState extends State<AiFinalReportScreen> {
  // [V3 REFACTOR] 'key_specs'와 'included_items'는 'condition'으로 통합됨
  // final Map<String, TextEditingController> _specsControllers = {};
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  // final TextEditingController _itemsController = TextEditingController();
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
  late final AuctionRepository _auctionRepository;

  @override
  void initState() {
    super.initState();
    _auctionRepository = AuctionRepository();
    _initializeControllers();
    // [V3 REFACTOR] 'takenShots'(XFile) 대신 'guidedImageUrls'(String) 사용
    _allImages = [...widget.initialImageUrls, ...widget.guidedImageUrls.values];
    // [Fix] 원본 설명을 컨트롤러에 설정
    _descriptionController.text = widget.userDescription ?? '';
    // 사용자 위치/신뢰 정보 미리 로드 (테스트 환경에서는 건너뜁니다)
    if (!widget.skipUserFetch) {
      try {
        _fetchUserModel();
      } catch (e) {
        debugPrint('Skipping _fetchUserModel (no Firebase in test): $e');
      }
    }
  }

  /// [V3 REFACTOR] '단순 감정 엔진' V3 JSON 스키마(Task 62)를 파싱하도록 전면 재작성
  void _initializeControllers() {
    _titleController.text = widget.confirmedProductName;
    // [V3 REFACTOR] price controller initialization
    _priceController.text = widget.userPrice ?? '';

    // 1. Summary
    final dynamic summaryValue =
        widget.finalReport['verificationSummary'] ?? '';
    if (summaryValue is String && summaryValue.isNotEmpty) {
      _summaryController.text = summaryValue;
    } else {
      _summaryController.text = ''; // V3는 플레이스홀더 대신 빈 값
    }

    // 2. Notes for Buyer
    final dynamic notesValue = widget.finalReport['notesForBuyer'] ?? '';
    if (notesValue is String && notesValue.isNotEmpty) {
      _buyerNotesController.text = notesValue.trim();
    } else {
      _buyerNotesController.text = t.aiFlow.finalReport.notesPlaceholder;
    }

    // 3. Price Assessment
    final dynamic priceMap = widget.finalReport['priceAssessment'] ?? '';
    if (priceMap is Map) {
      final min = priceMap['suggestedMin']?.toString();
      final max = priceMap['suggestedMax']?.toString();
      if (min != null && max != null) {
        _priceSuggestionController.text = 'Rp $min ~ $max';
      } else if (min != null) {
        _priceSuggestionController.text = 'Rp $min';
      } else {
        _priceSuggestionController.text = '';
      }
    } else {
      _priceSuggestionController.text = '';
    }

    // 4. Condition (Grade + Details)
    final dynamic conditionMap = widget.finalReport['condition'] ?? '';
    final List<String> conditionLines = [];
    if (conditionMap is Map) {
      final String? grade = conditionMap['grade'] as String?;
      final String? gradeReason = conditionMap['gradeReason'] as String?;
      if (grade != null && grade.isNotEmpty) {
        conditionLines.add('AI 등급: $grade (${gradeReason ?? ''})');
      }

      final dynamic detailsList = conditionMap['details'];
      if (detailsList is List) {
        for (var item in detailsList) {
          if (item is Map) {
            String label = item['label']?.toString() ?? '';
            String value = item['value']?.toString() ?? 'N/A';
            if (label.isNotEmpty) {
              conditionLines.add('$label: $value');
            }
          }
        }
      }
    }
    _conditionController.text = conditionLines.join('\n'); // Join with newlines

    // [V3 REFACTOR] 'key_specs'와 'included_items' 컨트롤러 초기화 로직 삭제
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

  @override
  void dispose() {
    _summaryController.dispose();
    _conditionController.dispose();
    _priceSuggestionController.dispose();
    _buyerNotesController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _transactionPlaceController.dispose();
    // [V3 REFACTOR] disposed controllers for _itemsController and
    // _specsControllers removed because those controls were removed.
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
        title: Text(t.auctions.create.confirmTitle),
        content: Text(t.auctions.create.confirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.confirm),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.main.errors.userNotFound)));
      return;
    }

    // [V3 ADMIN VERIFICATION] Read the AI's trust verdict
    final String trustVerdict =
        widget.finalReport['trustVerdict'] ?? '' as String? ?? 'clear';
    final bool isSuspicious = trustVerdict != 'clear';

    // 필수 입력: 경매 선택 시 거래 희망 장소가 비어있으면 제출 불가
    if (_registrationType == RegistrationType.auction &&
        _transactionPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.marketplace.errors.requiredField)));
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
        await _submitProductSale(user, allImageUrls,
            isSuspicious: isSuspicious);
      } else {
        await _submitProductAuction(user, allImageUrls);
      }

      // 3) 완료 처리
      // [V3 ADMIN VERIFICATION] Show different message on success
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(isSuspicious
              ? t.aiFlow.finalReport.successPending
              : t.aiFlow.finalReport.success),
        ),
      );
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text(
                t.aiFlow.finalReport.fail.replaceAll('{0}', e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ✅ 일반 판매 저장
  Future<void> _submitProductSale(User user, List<String> allImageUrls,
      {required bool isSuspicious}) async {
    // V2 UI 컨트롤러들로부터 최종 AI 리포트 객체 구성(간단 버전)
    final int userSelectedPrice = int.tryParse(_priceController.text) ?? 0;
    final int aiSuggestedPrice = int.tryParse(
            (widget.finalReport['suggested_price'] ??
                    widget.finalReport['price_suggestion'] ??
                    '0')
                .toString()) ??
        0;

    // Use the V3 report directly and augment with runtime fields
    final Map<String, dynamic> finalAiReport =
        Map<String, dynamic>.from(widget.finalReport);
    finalAiReport['user_selected_price'] = userSelectedPrice;
    finalAiReport['suggested_price'] = aiSuggestedPrice;
    finalAiReport['price_suggestion'] = aiSuggestedPrice;
    finalAiReport['ai_recommended_price'] = aiSuggestedPrice;

    // [Fix] .set()은 createdAt을 덮어쓰므로 .update() 또는 .set(merge:true)와 Map을 사용
    final Map<String, dynamic> productData = {
      'id': widget.productId,
      'userId': user.uid,
      'title': _titleController.text,
      // [Fix #A] AI 요약본이 아닌, 사용자가 입력한 원본 설명을 저장합니다.
      'description': widget.userDescription ?? _descriptionController.text,
      'imageUrls': allImageUrls,
      'categoryId': widget.categoryId,
      'price': (userSelectedPrice > 0) ? userSelectedPrice : aiSuggestedPrice,
      'negotiable': false,
      'tags': const [], // TODO: Add tag input
      'locationName': _currentUserModel?.locationName,
      'locationParts': _currentUserModel?.locationParts,
      'geoPoint': _currentUserModel?.geoPoint,
      'status': isSuspicious ? 'pending' : 'selling', // [V3 ADMIN VERIFICATION]
      // [Fix #B] AI 상세 리포트가 아닌, 'used' 또는 'new'를 저장합니다.
      'condition': 'used', // TODO: 'new'/'used' 선택 UI 추가 필요
      'transactionPlace': null,
      'updatedAt': Timestamp.now(),
      'isAiVerified': !isSuspicious, // [V3 ADMIN VERIFICATION]
      'aiVerificationStatus': isSuspicious
          ? 'pending_admin'
          : 'approved', // [V3 ADMIN VERIFICATION]

      // [Fix #C] aiReport(레거시)와 aiVerificationData(신규)에 동일 데이터 저장 (모델 호환성 유지)
      'aiReport': finalAiReport,
      'aiVerificationData': finalAiReport,

      // [개편안 1] 스냅샷 데이터 저장 (Job 25)
      'isAiFreeTierUsed': true, // 무료 티어 사용 완료
      'aiReportSourceDescription':
          widget.userDescription ?? _descriptionController.text, // 현재 설명을 스냅샷
      'aiReportSourceImages': allImageUrls, // 현재 이미지 목록을 스냅샷
    };

    // .set(merge:true)는 createdAt을 덮어쓰지 않도록 product.toJson() 대신 Map을 사용
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .set(productData, SetOptions(merge: true));

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
      location: _currentUserModel?.locationName ?? t.postCard.locationNotSet,
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
    // Create a lightweight ProductModel wrapper so `AiReportViewer` can
    // consume the V3 report via the existing API without larger refactors.
    final ProductModel viewerProduct = ProductModel(
      id: widget.productId,
      userId: '',
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : widget.confirmedProductName,
      description: widget.userDescription ?? _descriptionController.text,
      imageUrls: widget.initialImageUrls.map((e) => e.toString()).toList(),
      categoryId: widget.categoryId,
      price: int.tryParse(_priceController.text) ?? 0,
      negotiable: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isAiVerified: true,
      aiReport: Map<String, dynamic>.from(widget.finalReport),
      aiVerificationData: Map<String, dynamic>.from(widget.finalReport),
    );
    // ... UI 코드는 작업 101과 거의 동일하게 유지 ...
    // 단, TextFormField 들이 _titleController, _priceController, _descriptionController를 사용하도록 변경
    return Scaffold(
      appBar: AppBar(title: Text(t.aiFlow.finalReport.title)),
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
              // V3: Show structured AI report viewer for finalReview
              AiReportViewer(
                aiReport:
                    Map<String, dynamic>.from(viewerProduct.aiReport ?? {}),
              ),
              const SizedBox(height: 16),
              // [복원] 상품 제목, 가격, 설명 필드
              TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: t.marketplace.registration.titleHint,
                      border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                      labelText: t.marketplace.registration.priceHint,
                      border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const Divider(height: 32),
              // [추가] AI 추천 가격을 별도로 표시 (편집 불가)
              TextFormField(
                  controller: _priceSuggestionController,
                  decoration: InputDecoration(
                      labelText: t.aiFlow.finalReport.suggestedPrice
                          .replaceAll('{0}', 'Rp'),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.auto_awesome))),
              // 판매 유형 선택 (일반 판매 / 경매)
              const SizedBox(height: 24),
              Text(t.auctions.create.registrationType,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<RegistrationType>(
                segments: [
                  ButtonSegment(
                      value: RegistrationType.sale,
                      label: Text(t.auctions.create.type.sale),
                      icon: const Icon(Icons.storefront_outlined)),
                  ButtonSegment(
                      value: RegistrationType.auction,
                      label: Text(t.auctions.create.type.auction),
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
                      labelText: t.auctions.create.form.duration,
                      border: const OutlineInputBorder()),
                  items: [3, 5, 7]
                      .map((days) => DropdownMenuItem(
                            value: days,
                            child: Text(t.auctions.create.form.durationOption
                                .replaceAll('{days}', days.toString())),
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
                    labelText: t.aiFlow.finalReport.summary,
                    border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // [V2.1] 구매자 안내 노트 표시 및 편집 가능
              TextFormField(
                key: const Key('buyerNotesField'),
                controller: _buyerNotesController,
                decoration: InputDecoration(
                    labelText: t.aiFlow.finalReport.buyerNotes,
                    border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // [V3 REFACTOR] 'key_specs' 섹션(_buildReportSection) 제거
              TextFormField(
                controller: _conditionController,
                decoration: InputDecoration(
                    labelText: t.aiFlow.finalReport.condition,
                    border: const OutlineInputBorder()),
                maxLines: 8, // V3에서는 더 많은 정보가 표시되므로 늘림
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: t.aiFlow.finalReport.finalDescription,
                    border: const OutlineInputBorder()),
                maxLines: 12,
              ),
              // [Fix] "AI 제안 적용" 버튼 제거 (데이터 오염 방지)
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
                  ? t.aiFlow.finalReport.submitButton
                  : t.auctions.create.submitButton),
        ),
      ),
    );
  }

  // [V3 REFACTOR] 'key_specs' 컨트롤러가 사라졌으므로
  // 'buildReportSection' 헬퍼 함수도 더 이상 필요 없습니다.
}

// ✅ 등록 유형 구분을 위한 enum
enum RegistrationType { sale, auction }

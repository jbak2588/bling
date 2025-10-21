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

  List<dynamic> _allImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _allImages = [...widget.initialImages, ...widget.takenShots.values];
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

  // [핵심 복원 및 수정] V1의 안정적인 저장 로직과 V2 데이터를 결합
  Future<void> _submitProduct() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      // 1. UserModel을 사용하여 사용자 정보 가져오기 (위치 등)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) throw Exception("User data not found.");
      final currentUserModel = UserModel.fromFirestore(userDoc);

      // 2. 모든 이미지를 URL 목록으로 변환 (필요시 업로드)
      List<String> finalImageUrls = [];
      for (final image in _allImages) {
        if (image is String) {
          finalImageUrls.add(image);
        } else if (image is XFile) {
          final url = await _uploadImage(image, user.uid);
          finalImageUrls.add(url);
        }
      }

      // 3. V2 UI의 컨트롤러들로부터 최종 AI 리포트 객체 생성
      final int userSelectedPrice = int.tryParse(_priceController.text) ?? 0;
      final int aiSuggestedPrice =
          int.tryParse(_priceSuggestionController.text) ?? 0;
      final finalAiReport = {
        'verification_summary': _summaryController.text,
        'condition_check': _conditionController.text,
        'included_items':
            _itemsController.text.split(',').map((e) => e.trim()).toList(),
        'notes_for_buyer': _buyerNotesController.text,
        // [수정] AI 추천가와 사용자가 선택한 가격을 모두 저장
        // 호환성을 위해 suggested_price와 price_suggestion 둘 다 저장합니다.
        'suggested_price': aiSuggestedPrice,
        'price_suggestion': aiSuggestedPrice,
        'ai_recommended_price': aiSuggestedPrice,
        'user_selected_price': userSelectedPrice,
        'key_specs':
            _specsControllers.map((key, value) => MapEntry(key, value.text)),
      };

      // 4. ProductModel을 사용하여 최종 상품 객체 생성
      final product = ProductModel(
        id: widget.productId, // 이전 화면에서 전달받은 ID
        userId: user.uid, // [핵심] userId 포함
        title: _titleController.text,
        description: _descriptionController.text,
        price: userSelectedPrice,
        imageUrls: finalImageUrls,
        categoryId: widget.categoryId, // [핵심] 실제 카테고리 ID
        status: 'selling',
        isAiVerified: true,
        aiVerificationStatus: 'verified',
        aiReport: finalAiReport, // [V2 데이터 적용]
        negotiable: false, // TODO: 이전 화면에서 값 전달 필요
        tags: const [], // TODO: 이전 화면에서 값 전달 필요
        locationName: currentUserModel.locationName,
        locationParts: currentUserModel.locationParts,
        geoPoint: currentUserModel.geoPoint,
        condition: 'used', // TODO: 이전 화면에서 값 전달 필요
        createdAt: Timestamp.now(), // 새 상품일 경우
        likesCount: 0,
        chatsCount: 0,
        viewsCount: 0,
        updatedAt: Timestamp.now(),
        // ... 나머지 ProductModel 필드들
      );

      // 5. ProductModel을 사용하여 Firestore에 상품 저장 (set, merge:true로 생성/업데이트 겸용)
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .set(product.toJson(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('AI 검수 완료! 상품 정보가 저장되었습니다.')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('오류 발생: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: tr('ai_flow.final_report.suggested_price',
                          args: ['Rp']),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.auto_awesome))),
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
          onPressed: _isSubmitting ? null : _submitProduct,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('ai_flow.final_report.submit_button'.tr()),
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

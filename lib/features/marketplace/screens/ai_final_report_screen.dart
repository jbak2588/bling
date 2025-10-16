// lib/features/marketplace/screens/ai_final_report_screen.dart

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

class AiFinalReportScreen extends StatefulWidget {
  // [추가] 이전 화면에서 생성된 최종 리포트와 확정 상품명
  final Map<String, dynamic> finalReport;
  final AiVerificationRule rule;
  final List<XFile> initialImages;
  final Map<String, XFile> takenShots;
  final String confirmedProductName; // [추가]

  const AiFinalReportScreen({
    super.key,
    required this.finalReport,
    required this.rule,
    required this.initialImages,
    required this.takenShots,
    required this.confirmedProductName, // [추가]
  });

  @override
  State<AiFinalReportScreen> createState() => _AiFinalReportScreenState();
}

class _AiFinalReportScreenState extends State<AiFinalReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _specsControllers = {};
  final Map<String, TextEditingController> _conditionControllers = {};
  final List<TextEditingController> _itemsControllers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _populateFieldsFromReport();
  }

  void _populateFieldsFromReport() {
    final report = widget.finalReport;

    // [변경] AI 제안 대신 사용자가 확정한 상품명 사용
    _titleController.text = widget.confirmedProductName;

    // [유지] 상세 설명에 사양을 합쳐 기본값 구성
    String baseDescription = report['description'] as String? ?? '';
    final specs = report['specs'] as Map<String, dynamic>?;
    if (specs != null) {
      final specsText =
          specs.entries.map((e) => "- ${e.key}: ${e.value}").join('\n');
      baseDescription += '\n\n[상세 사양]\n$specsText';
    }
    _descriptionController.text = baseDescription;

    // 가격 안전 파싱
    final priceValue = report['price_suggestion'];
    if (priceValue is num) {
      _priceController.text = priceValue.toString();
    } else if (priceValue is String) {
      _priceController.text = priceValue.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (report['specs'] is Map) {
      (report['specs'] as Map).forEach((k, v) {
        _specsControllers[k] = TextEditingController(text: v.toString());
      });
    }
    if (report['condition_check'] is Map) {
      (report['condition_check'] as Map).forEach((k, v) {
        _conditionControllers[k] = TextEditingController(text: v.toString());
      });
    }
    if (report['included_items'] is List) {
      for (var item in (report['included_items'] as List)) {
        _itemsControllers.add(TextEditingController(text: item.toString()));
      }
    }
  }

  void _applyAllSuggestionsToDescription() {
    // [변경] 중복 누적 방지: 항상 AI 리포트의 기본 설명에서 시작
    final report = widget.finalReport;
    String baseDescription = report['description'] as String? ?? '';

    String specsText = _specsControllers.entries
        .map((e) => "- ${e.key}: ${e.value.text}")
        .join('\n');
    String conditionText = _conditionControllers.entries
        .map((e) => "- ${e.key}: ${e.value.text}")
        .join('\n');
    String itemsText =
        _itemsControllers.map((c) => "- ${c.text.trim()}").join('\n');

    setState(() {
      _descriptionController.text = '''$baseDescription

[상세 사양]
$specsText

[상태 점검]
$conditionText

[구성품]
$itemsText
''';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 제안이 상세 설명에 적용되었습니다.')),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _specsControllers.forEach((_, controller) => controller.dispose());
    _conditionControllers.forEach((_, controller) => controller.dispose());
    for (var controller in _itemsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) throw Exception("User data not found in Firestore.");
      final currentUserModel = UserModel.fromFirestore(userDoc);

      // 업로드
      final storage = FirebaseStorage.instance;
      final allImages = [...widget.initialImages, ...widget.takenShots.values];
      final imageUrls = await Future.wait(allImages.map((file) async {
        final ref = storage.ref(
          'product_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}',
        );
        await ref.putFile(File(file.path));
        return ref.getDownloadURL();
      }));

      // 상품 생성
      final newProduct = ProductModel(
        id: FirebaseFirestore.instance.collection('products').doc().id,
        userId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        imageUrls: imageUrls,
        categoryId: widget.rule.id,
        status: 'selling',
        isAiVerified: true,
        aiVerificationStatus: 'verified',
        aiReport: widget.finalReport,
        negotiable: false,
        tags: const [],
        locationName: currentUserModel.locationName ?? 'Unknown Location',
        locationParts: currentUserModel.locationParts,
        geoPoint: currentUserModel.geoPoint,
        condition: 'used',
        likesCount: 0,
        chatsCount: 0,
        viewsCount: 0,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(newProduct.id)
          .set(newProduct.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품이 성공적으로 등록되었습니다!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('등록 실패: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.final_report.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // [수정] 안정적인 API 사용
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "AI가 생성한 판매글 초안입니다. 각 항목을 자유롭게 수정하고, '상세 설명에 적용' 버튼을 눌러 내용을 합친 후 최종 등록해주세요.",
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
              const SizedBox(height: 24),
              Text("기본 정보", style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '제목을 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '판매 가격 (IDR)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return '가격을 입력하세요.';
                  if (int.tryParse(value) == null) return '숫자만 입력하세요.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildReportSection(
                "상세 사양 (Specs)",
                _specsControllers.entries
                    .map((e) => MapEntry(e.key, e.value))
                    .toList(),
              ),
              _buildReportSection(
                "상태 점검 (Condition)",
                _conditionControllers.entries
                    .map((e) => MapEntry(e.key, e.value))
                    .toList(),
              ),
              _buildReportSection(
                "구성품 (Included Items)",
                _itemsControllers
                    .asMap()
                    .entries
                    .map((e) => MapEntry('품목 ${e.key + 1}', e.value))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text("최종 판매 설명", style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '상세 설명',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '설명을 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _applyAllSuggestionsToDescription,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text("수정한 내용으로 상세 설명 업데이트"),
              ),
              const SizedBox(height: 24),
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
        const SizedBox(height: 16),
      ],
    );
  }
}

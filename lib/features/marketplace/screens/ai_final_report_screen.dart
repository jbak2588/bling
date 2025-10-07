// lib/features/marketplace/screens/ai_final_report_screen.dart

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

class AiFinalReportScreen extends StatefulWidget {
  final AiVerificationRule rule;
  final List<XFile> initialImages;
  final Map<String, XFile> takenShots;
  final String confirmedProductName;

  const AiFinalReportScreen({
    super.key,
    required this.rule,
    required this.initialImages,
    required this.takenShots,
    required this.confirmedProductName,
  });

  @override
  State<AiFinalReportScreen> createState() => _AiFinalReportScreenState();
}

class _AiFinalReportScreenState extends State<AiFinalReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  Map<String, dynamic>? _aiReport;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasError = false;

  late List<String> _initialImageUrls;
  late Map<String, String> _guidedImageUrls;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _initialImageUrls = await _uploadImages(widget.initialImages);
      _guidedImageUrls = await _uploadImageMap(widget.takenShots);

      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('generateFinalReport');
      final result = await callable.call<Map<String, dynamic>>({
        'imageUrls': {'initial': _initialImageUrls, 'guided': _guidedImageUrls},
        'ruleId': widget.rule.id,
        'confirmedProductName': widget.confirmedProductName,
      });

      if (result.data['success'] == true) {
        setState(() {
          _aiReport = result.data['report'];
          _titleController.text = _aiReport?['title'] ?? '';
          _descriptionController.text = _aiReport?['description'] ?? '';
          _priceController.text =
              _aiReport?['suggested_price']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception(result.data['error']);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<String> _uploadSingleImage(XFile image) async {
    final fileName = const Uuid().v4();
    final ref =
        FirebaseStorage.instance.ref().child('product_images').child(fileName);
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    return await Future.wait(
        images.map((image) => _uploadSingleImage(image)).toList());
  }

  Future<Map<String, String>> _uploadImageMap(Map<String, XFile> images) async {
    final urls = <String, String>{};
    for (final entry in images.entries) {
      urls[entry.key] = await _uploadSingleImage(entry.value);
    }
    return urls;
  }

  Future<void> _submitProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final productRef =
          FirebaseFirestore.instance.collection('products').doc();
      final allImageUrls = [..._initialImageUrls, ..._guidedImageUrls.values];

      final product = ProductModel(
        id: productRef.id,
        userId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        imageUrls: allImageUrls,
        categoryId: widget.rule.id,
        negotiable: false,
        isNew: false,
        isAiVerified: true,
        aiReport: _aiReport,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await productRef.set(product.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상품이 최종 등록되었습니다!')),
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
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.final_report.title'.tr()),
        actions: [
          TextButton(
            onPressed: _isLoading || _isSubmitting ? null : _submitProduct,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : Text('ai_flow.final_report.submit_button'.tr()),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('ai_flow.final_report.loading'.tr())
                ]))
          : _hasError
              ? Center(child: Text('ai_flow.final_report.error'.tr()))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('ai_flow.final_report.guide'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: '상품명')),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _priceController,
                          decoration:
                              const InputDecoration(labelText: '판매 가격 (IDR)'),
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: '상세 설명'),
                          maxLines: 10),
                      const SizedBox(height: 24),
                      // TODO: AI 리포트의 다른 항목들(상태, 구성품 등)도 보여주고 수정할 수 있는 UI 추가
                    ],
                  ),
                ),
    );
  }
}

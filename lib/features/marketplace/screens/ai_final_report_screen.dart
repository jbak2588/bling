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
  // AI가 생성한 데이터를 담을 컨트롤러들
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // 기타 AI 리포트 데이터를 저장할 Map
  Map<String, dynamic>? _aiReport;
  bool _isLoading = true;
  bool _hasError = false;

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
      // 1. 모든 이미지들을 Storage에 업로드하고 URL을 받습니다.
      final initialImageUrls = await _uploadImages(widget.initialImages);
      final guidedImageUrls = await _uploadImageMap(widget.takenShots);

      // 2. Cloud Function 'generateFinalReport' 호출
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('generateFinalReport');
      final result = await callable.call<Map<String, dynamic>>({
        'imageUrls': {
          'initial': initialImageUrls,
          'guided': guidedImageUrls,
        },
        'ruleId': widget.rule.id,
        'confirmedProductName': widget.confirmedProductName,
        // TODO: 사용자 희망 가격, 간단 설명도 전달하면 좋습니다.
        'userPrice': '',
        'userDescription': '',
      });

      if (result.data['success'] == true) {
        setState(() {
          _aiReport = result.data['report'];
          // 컨트롤러에 초기값 설정
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
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // 이미지 리스트(XFile)를 Storage에 업로드하고 URL 리스트 반환
  Future<List<String>> _uploadImages(List<XFile> images) async {
    List<String> urls = [];
    for (final image in images) {
      final url = await _uploadSingleImage(image);
      urls.add(url);
    }
    return urls;
  }

  // 이미지 맵(Map<String, XFile>)을 Storage에 업로드하고 URL 맵 반환
  Future<Map<String, String>> _uploadImageMap(Map<String, XFile> images) async {
    Map<String, String> urls = {};
    for (final entry in images.entries) {
      final url = await _uploadSingleImage(entry.value);
      urls[entry.key] = url;
    }
    return urls;
  }

  // 단일 이미지 업로드 로직
  Future<String> _uploadSingleImage(XFile image) async {
    final fileName = const Uuid().v4();
    final ref =
        FirebaseStorage.instance.ref().child('product_images').child(fileName);
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  Future<void> _submitProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // product_model.dart의 필드와 타입에 맞춰 ProductModel 객체를 생성합니다.
      final productRef =
          FirebaseFirestore.instance.collection('products').doc();
      final allImageUrls = [
        ...widget.initialImages
            .map((f) => f.path), // 임시로 로컬 경로 사용, 실제로는 업로드된 URL 사용
        ...widget.takenShots.values.map((f) => f.path)
      ];

      final product = ProductModel(
        id: productRef.id,
        userId: user.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        // ▼▼▼▼▼ [수정 1] double -> int 로 타입 변경 ▼▼▼▼▼
        price: int.tryParse(_priceController.text) ?? 0,
        imageUrls: allImageUrls, // 최종 저장 시에는 업로드된 URL 리스트로 교체
        categoryId: widget.rule.id,
        // ▼▼▼▼▼ [수정 2] 필수 파라미터 'negotiable' 추가 ▼▼▼▼▼
        negotiable: false, // 신품/AI검수품은 가격 제안 불가로 기본값 설정
        isNew: false,
        isAiVerified: true,
        aiReport: _aiReport,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        // product_model.dart에 있는 나머지 nullable 필드들은 null로 자동 처리됩니다.
      );

      // ▼▼▼▼▼ [수정 3] toMap() -> toJson() 으로 메소드명 변경 ▼▼▼▼▼
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
          _isLoading = false;
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
            onPressed: _isLoading ? null : _submitProduct,
            child: Text('ai_flow.final_report.submit_button'.tr()),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
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

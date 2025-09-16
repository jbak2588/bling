// lib/features/marketplace/screens/ai_inspection_result_screen.dart

import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bling_app/core/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AiInspectionResultScreen extends StatefulWidget {
  final Map<String, dynamic> aiReport;

  // ✅ [추가] 촬영된 이미지를 받아오기 위한 생성자 파라미터 추가
  final List<XFile> capturedImages;

  const AiInspectionResultScreen({
    super.key,
    required this.aiReport,
    required this.capturedImages, // ✅ 파라미터 추가
  });

  @override
  State<AiInspectionResultScreen> createState() =>
      _AiInspectionResultScreenState();
}

class _AiInspectionResultScreenState extends State<AiInspectionResultScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // AI가 제안한 최대 가격을 기본값으로 설정
    final suggestedMaxPrice = widget.aiReport['priceSuggestion']?['max'] ?? 0;
    _priceController =
        TextEditingController(text: suggestedMaxPrice.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ✅ [수정 시작] _submitProduct 함수의 내용을 아래 코드로 전체 교체합니다.
  Future<void> _submitProduct() async {
    // 폼 유효성 검사를 통과하지 못하면 아무것도 하지 않습니다.
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 로딩 상태 시작
    setState(() {
      _isLoading = true;
    });

    try {
      // ... (기존의 user, userModel, repository, imageUrls, newProduct 생성 로직은 동일) ...
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userModel = UserModel.fromFirestore(userDoc);

      final productRepository = ProductRepository();
      final imageUrls = await productRepository.uploadImages(
        userId: user.uid,
        images: widget.capturedImages,
      );

      final newProduct = ProductModel(
        id: '',
        userId: user.uid,
        title: widget.aiReport['detectedBrand'] as String? ?? 'AI Verified Product',
        description: _commentController.text,
        imageUrls: imageUrls,
        categoryId: widget.aiReport['detectedCategory'] as String? ?? 'etc',
        price: int.parse(_priceController.text),
        negotiable: false,
        status: 'selling',
        condition: 'used',
        tags: List<String>.from(widget.aiReport['detectedFeatures'] as List? ?? []),
        locationName: userModel.locationName,
        locationParts: userModel.locationParts,
        geoPoint: userModel.geoPoint,
        transactionPlace: userModel.locationName,
        isAiVerified: true,
        aiVerificationStatus: 'pending',
        aiReport: widget.aiReport,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await productRepository.addProduct(newProduct);

      // ✅ [핵심 수정] 화면 이동 전에, 위젯이 살아있는지 반드시 확인합니다.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 검수 상품 등록이 요청되었습니다.')),
      );
      // 화면을 완전히 빠져나갑니다.
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      // ✅ [핵심 수정] 에러 처리 전에도 위젯 존재 여부를 확인합니다.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록에 실패했습니다: $e')),
      );
      // 에러가 발생했으므로, 로딩 상태를 해제합니다.
      setState(() {
        _isLoading = false;
      });
    }
    // ✅ [핵심 수정] 성공적으로 화면을 빠져나간 후에는 더 이상 setState를 호출하지 않으므로,
    // finally 블록이 필요 없습니다. 에러 발생 시에만 catch 블록에서 로딩을 해제합니다.
  }
  // ✅ [수정 끝]

  @override
  Widget build(BuildContext context) {
    final numberFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final suggestedMin = widget.aiReport['priceSuggestion']?['min'] ?? 0;
    final suggestedMax = widget.aiReport['priceSuggestion']?['max'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 분석 결과 확인'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'AI 분석 정보'),
              _buildInfoCard(
                '인식된 카테고리',
                widget.aiReport['detectedCategory'] ?? '분석 정보 없음',
                Icons.category_outlined,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                '인식된 브랜드',
                widget.aiReport['detectedBrand'] ?? '분석 정보 없음',
                Icons.label_outline,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                '주요 특징 (태그)',
                (widget.aiReport['detectedFeatures'] as List?)?.join(', ') ??
                    '분석 정보 없음',
                Icons.style_outlined,
              ),
              const Divider(height: 40),
              _buildSectionTitle(context, '가격 결정'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 추천 가격 범위',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${numberFormat.format(suggestedMin)} ~ ${numberFormat.format(suggestedMax)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: '최종 판매 가격',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '가격을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),
              _buildSectionTitle(context, '추가 정보 입력'),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: '상품 설명 및 특이사항',
                  hintText: 'AI가 발견하지 못한 상품의 장점이나, 구매자가 알아야 할 정보를 자유롭게 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitProduct,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_outline),
          label: Text(_isLoading ? '등록 요청 중...' : '모두 확인 후 등록 요청하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(
          content,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

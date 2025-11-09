// lib/features/admin/screens/admin_product_detail_screen.dart

import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const AdminProductDetailScreen({super.key, required this.product});

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  final ProductRepository _repository = ProductRepository();
  bool _isLoading = false;

  Future<void> _approveProduct() async {
    setState(() => _isLoading = true);
    await _repository.updateProductStatus(
        productId: widget.product.id, status: 'approved');
    if (mounted) Navigator.pop(context);
  }

  Future<void> _rejectProduct() async {
    // TODO: 거절 사유를 입력받는 팝업 구현
    setState(() => _isLoading = true);
    await _repository.updateProductStatus(
        productId: widget.product.id,
        status: 'rejected',
        rejectionReason: '관리자 거절');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('검수 요청 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: 여기에 상품 상세 정보 및 AI 리포트 표시 UI 구현
            Text(widget.product.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.product.description),
            const Divider(height: 30),
            Text('AI 분석 리포트', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.product.aiReport.toString()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _rejectProduct,
                      icon: const Icon(Icons.close),
                      label: const Text('거절'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _approveProduct,
                      icon: const Icon(Icons.check),
                      label: const Text('승인'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

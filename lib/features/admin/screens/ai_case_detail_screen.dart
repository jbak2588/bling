// lib/features/admin/screens/ai_case_detail_screen.dart

import 'dart:convert';
import 'package:bling_app/features/admin/models/ai_case_model.dart';
import 'package:bling_app/features/marketplace/data/product_repository.dart'; // Product 조회용
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:easy_localization/easy_localization.dart';

class AiCaseDetailScreen extends StatefulWidget {
  final AiCaseModel aiCase;

  const AiCaseDetailScreen({super.key, required this.aiCase});

  @override
  State<AiCaseDetailScreen> createState() => _AiCaseDetailScreenState();
}

class _AiCaseDetailScreenState extends State<AiCaseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProductModel? _product;
  bool _isLoadingProduct = true;

  @override
  void initState() {
    super.initState();
    // 탭: 0=Summary, 1=Evidence(현장), 2=Original(원본), 3=Raw JSON
    _tabController = TabController(length: 4, vsync: this);
    _loadLinkedProduct();
  }

  /// 연결된 상품 정보(원본 사진 등)를 가져옵니다.
  Future<void> _loadLinkedProduct() async {
    try {
      // ProductRepository 사용 (기존 코드 재사용)
      // 만약 ProductRepository가 없거나 수정이 필요하면 Firestore 직접 호출로 대체 가능
      final repo = ProductRepository();
      final product = await repo.fetchProductById(widget.aiCase.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load product: $e");
      if (mounted) setState(() => _isLoadingProduct = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('ai_case.title')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: tr('ai_case.tabs.summary')),
            Tab(text: tr('ai_case.tabs.takeover_photos')),
            Tab(text: tr('ai_case.tabs.original_photos')),
            Tab(text: tr('ai_case.tabs.raw_json')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildPhotoGrid(widget.aiCase.evidenceImageUrls, "현장 인수 사진 (Buyer)"),
          _buildOriginalPhotosTab(),
          _buildJsonViewer(),
        ],
      ),
    );
  }

  // --- Tab 1: Summary ---
  Widget _buildSummaryTab() {
    final result = widget.aiCase.aiResult;
    final reason = result?['reason'] ?? 'No reason provided';
    final verdict = widget.aiCase.verdict;
    final match = result?['match'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard("Verdict", verdict ?? 'Unknown',
              color: verdict == 'match_confirmed' ? Colors.green : Colors.red),
          const SizedBox(height: 10),
          _buildInfoCard("Match Status", "$match",
              color: match == true ? Colors.green : Colors.orange),
          const SizedBox(height: 10),
          const Text("Reasoning:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(reason, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 20),
          if (result?['discrepancies'] != null &&
              (result!['discrepancies'] as List).isNotEmpty) ...[
            const Text("Discrepancies (불일치 내역):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...((result['discrepancies'] as List).map((e) => ListTile(
                  leading:
                      const Icon(Icons.error_outline, color: Colors.orange),
                  title: Text(e.toString()),
                  dense: true,
                ))),
          ],
          const Divider(height: 40),
          _buildCopyableField("Case ID", widget.aiCase.caseId),
          _buildCopyableField("Product ID", widget.aiCase.productId),
          _buildCopyableField("Seller ID", widget.aiCase.sellerId),
          _buildCopyableField("Buyer ID", widget.aiCase.buyerId ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? color}) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildCopyableField(String label, String value) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$label copied!")));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text("$label: ",
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold)),
            Expanded(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'monospace'))),
            const Icon(Icons.copy, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- Tab 2 & 3: Photos ---
  Widget _buildOriginalPhotosTab() {
    if (_isLoadingProduct) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_product == null || _product!.imageUrls.isEmpty) {
      return const Center(child: Text("원본 사진을 찾을 수 없습니다."));
    }
    return _buildPhotoGrid(_product!.imageUrls, "판매자 원본 사진 (Seller)");
  }

  Widget _buildPhotoGrid(List<String> urls, String title) {
    if (urls.isEmpty) {
      return Center(child: Text("$title 없음"));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullImage(context, urls[index]),
                child: Hero(
                  tag: urls[index],
                  child: Image.network(urls[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: Center(child: InteractiveViewer(child: Image.network(url))),
      ),
    ));
  }

  // --- Tab 4: JSON Viewer ---
  Widget _buildJsonViewer() {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(widget.aiCase.aiResult ?? {});
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        jsonStr,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}

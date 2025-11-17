// lib/features/admin/screens/admin_product_detail_screen.dart
// lib/features/admin/screens/admin_product_detail_screen.dart

import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [Task 104] Get Admin UID
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [Task 102] For copying IDs
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

// [Task 91] AI 리포트 뷰어 및 판매자 정보 위젯 임포트
import 'package:bling_app/features/marketplace/widgets/ai_report_viewer.dart';
import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/core/utils/popups/snackbars.dart'; // [Task 102] For copy snackbar

class AdminProductDetailScreen extends StatefulWidget {
  // [V3 NOTIFICATION] ID 또는 객체로 화면을 로드할 수 있도록 허용
  final ProductModel? product;
  final String? productId;
  const AdminProductDetailScreen({super.key, this.product, this.productId})
      : assert(product != null || productId != null,
            'product 또는 productId 중 하나는 필수입니다.');

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  // [V3 NOTIFICATION] 상태 변수 추가
  ProductModel? _product;
  // [Task 105] ProductRepository is no longer used.
  bool _isLoading = false; // 버튼 로딩용
  bool _isLoadingProduct = false; // 화면 로딩용

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product;
    } else {
      _isLoadingProduct = true;
      _loadProduct(widget.productId!);
    }
  }

  // [Task 102] ID 복사 기능을 포함한 헬퍼 위젯
  Widget _buildIdTile(BuildContext context, String title, String value) {
    return Card(
      elevation: 0.5,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.labelSmall),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        trailing: IconButton(
          icon: const Icon(Icons.copy_all_outlined, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            BArtSnackBar.showSuccessSnackBar(
                title: 'Copied!', message: '$title copied to clipboard.');
          },
        ),
      ),
    );
  }

  Future<void> _loadProduct(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (doc.exists && mounted) {
        setState(() {
          // [Task 105] Re-add explicit cast for type safety
          _product = ProductModel.fromFirestore(doc);
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _approveProduct() async {
    // [Task 102 FIX] 'updateProductStatus'는 'status'만 변경.
    // 'pending' 승인을 위해서는 'isAiVerified'와 'aiVerificationStatus'도 함께 업데이트해야 함.
    // Repository를 수정하는 대신, 여기서 직접 update를 호출하여 모든 필드를 보장.
    setState(() => _isLoading = true);
    // [Task 104] 관리자 작업 로그 추가
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    final adminLog = {
      'adminId': adminUid,
      'action': 'approved',
      'timestamp': FieldValue.serverTimestamp(),
      'reason': null,
    };

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_product!.id)
          .update({
        'status': 'selling',
        'isAiVerified': true,
        'aiVerificationStatus':
            'approved_by_admin', // 명확성을 위해 'approved' -> 'approved_by_admin'
        'updatedAt': FieldValue.serverTimestamp(),
        'adminActionLog': adminLog, // [Task 104] 로그 저장
      });

      // [Step 2] 판매자 알림 상태 동기화 (승인)
      await _updateSellerNotifications(decision: 'approved');
      if (mounted) {
        Navigator.pop(context, true); // Pop with 'true' to signal refresh
      }
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(title: 'Error', message: e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectProduct() async {
    // [Task 104] 1. 거절 사유 팝업 호출
    final String? reason = await _showRejectionDialog();

    // 2. 사용자가 팝업을 닫거나 사유를 입력하지 않으면 중단
    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);

    // [Task 104] 3. 관리자 로그 생성
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    final adminLog = {
      'adminId': adminUid,
      'action': 'rejected',
      'timestamp': FieldValue.serverTimestamp(),
      'reason': reason,
    };

    try {
      // [Task 104] 4. Firestore 문서 업데이트
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_product!.id)
          .update({
        'status': 'rejected', // [Task 103]
        'isAiVerified': false, // 거절됨
        'aiVerificationStatus': 'rejected_by_admin',
        'rejectionReason': reason, // [Task 104] 사유 저장
        'updatedAt': FieldValue.serverTimestamp(),
        'adminActionLog': adminLog, // [Task 104] 로그 저장
      });

      // [Step 2] 판매자 알림 상태 동기화 (거절)
      await _updateSellerNotifications(decision: 'rejected', reason: reason);
      if (mounted) {
        Navigator.pop(context, true); // Pop with 'true' to signal refresh
      }
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(title: 'Error', message: e.toString());
        setState(() => _isLoading = false);
      }
    }
  }

  /// [Step 2] 판매자의 알림 내역 중, 이 상품과 관련된 알림을 찾아 상태를 업데이트합니다.
  Future<void> _updateSellerNotifications(
      {required String decision, String? reason}) async {
    if (_product == null) return;

    try {
      final sellerId = _product!.userId; // ProductModel의 판매자 ID
      final notificationsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .collection('notifications');

      // 이 상품(productId)과 관련된 모든 알림 쿼리
      final snapshot = await notificationsRef
          .where('productId', isEqualTo: _product!.id)
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'resolved', // 처리 완료 상태
          'adminDecision': decision, // approved | rejected
          'adminComment': reason, // 거절 사유 등
          'isRead': false, // [Option] 결과를 다시 확인하도록 안 읽음 처리
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      // 알림 업데이트 실패가 관리자 작업을 막지 않도록 로그만 출력
      debugPrint('Failed to update seller notifications: $e');
    }
  }

  // duplicate removed

  // [Task 104] 거절 사유 입력 팝업
  Future<String?> _showRejectionDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('admin.aiApproval.rejectTitle'.tr()), // '거절 사유 입력'
          content: TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'admin.aiApproval.rejectReasonHint'.tr(), // '거절 사유'
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(ctx).pop(reason);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text('common.confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // [V3 NOTIFICATION] 상품 로드 전 로딩 화면 표시
    if (_isLoadingProduct || _product == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text('admin.aiApproval.detailTitle'.tr()), // '검수 요청 상세'
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [Task 102] 1. ID 정보 (개선 요청 사항)
            Text('admin.aiApproval.idInfo'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildIdTile(context, 'User ID', _product!.userId),
            _buildIdTile(context, 'Product ID', _product!.id),
            const Divider(height: 30),

            // [Task 91] 2. 판매자 정보
            Text('admin.aiApproval.sellerInfo'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AuthorProfileTile(userId: _product!.userId),
            const Divider(height: 30),

            // [Task 91] 2. 상품 원본 정보
            Text('admin.aiApproval.itemInfo'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_product!.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(_product!.description,
                style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 30),

            // [Task 91] 3. AI 리포트 뷰어 (사용자와 동일한 UI)
            Text('admin.aiApproval.aiReport'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AiReportViewer(
              aiReport: Map<String, dynamic>.from(
                  _product!.aiReport ?? _product!.aiVerificationData ?? {}),
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

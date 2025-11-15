/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace (AI 인수 V2.2)
/// File          : lib/features/marketplace/screens/ai_takeover_screen.dart
/// Purpose       : AI 인수 2단계: '현장 동일성 검증' UI
///
/// [기능 요약 (Job 5, 6)]
/// 1. 이 화면은 'AI 안심 예약'을 완료한 구매자만 진입할 수 있습니다.
/// 2. `AiReportViewer`를 통해 판매자가 등록한 '원본 AI 보고서'를 표시합니다.
/// 3. 구매자는 현장에서 실제 상품의 사진을 촬영합니다 (`_pickPhotos`).
/// 4. 'AI 동일성 검증 시작' 버튼을 누르면:
///    - 현장 사진을 업로드하고 (`_startOnSiteVerification`)
///    - 백엔드 `verifyProductOnSite` 함수를 호출합니다.
/// 5. AI의 `match: true/false` 결과에 따라 다이얼로그를 표시합니다.
///    - [Match] -> `_finalizeTakeover` (product_repository.completeTakeover 호출)
///    - [No Match] -> `_cancelReservation` (product_repository.cancelReservation 호출)
/// ============================================================================
// lib/features/marketplace/screens/ai_takeover_screen.dart
library;

import 'dart:io';
import 'package:bling_app/core/utils/upload_helpers.dart';
import 'package:bling_app/features/marketplace/data/product_repository.dart';
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/widgets/ai_report_viewer.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// AI 인수 2단계: 현장 동일성 검증 화면
class AiTakeoverScreen extends StatefulWidget {
  final ProductModel product;
  const AiTakeoverScreen({super.key, required this.product});

  @override
  State<AiTakeoverScreen> createState() => _AiTakeoverScreenState();
}

class _AiTakeoverScreenState extends State<AiTakeoverScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _newPhotos = [];
  bool _isVerifying = false;

  /// 현장에서 새 사진 촬영
  Future<void> _pickPhotos() async {
    final List<XFile> picked = await _picker.pickMultiImage(
      limit: 5,
      imageQuality: 80, // [Fix] Warning #4: 품질 80%
      maxWidth: 1024, // [Fix] Warning #4: 최대 너비 1024px
    );
    if (picked.isNotEmpty) {
      setState(() {
        _newPhotos.addAll(picked);
      });
    }
  }

  /// AI 동일성 검증 시작
  Future<void> _startOnSiteVerification() async {
    if (_newPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.takeover.errors.noPhoto'.tr())));
      return;
    }

    setState(() => _isVerifying = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isVerifying = false);
      return;
    }

    try {
      // 1. 현장 사진 업로드
      final List<String> newImageUrls =
          await uploadAllProductImages(_newPhotos, user.uid);

      // 2. 백엔드 'verifyProductOnSite' 함수 호출
      final callable = FirebaseFunctions.instanceFor(region: 'asia-southeast2')
          .httpsCallable('verifyProductOnSite');
      final result = await callable.call(<String, dynamic>{
        'productId': widget.product.id,
        'newImageUrls': newImageUrls,
        'locale': context.locale.languageCode,
      });

      final verificationData = result.data?['verification'];
      if (verificationData is Map<String, dynamic>) {
        _showVerificationResult(verificationData);
      } else {
        throw Exception('AI가 유효한 검증 결과를 반환하지 못했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// AI 검증 결과 다이얼로그 표시
  void _showVerificationResult(Map<String, dynamic> result) {
    final bool match = result['match'] ?? false;
    final String reason = result['reason'] ?? 'No reason provided.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          match ? Icons.check_circle_outline : Icons.error_outline,
          color: match ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(match
            ? 'marketplace.takeover.dialog.matchTitle'.tr()
            : 'marketplace.takeover.dialog.noMatchTitle'.tr()),
        content: Text(reason),
        actions: [
          if (match)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _finalizeTakeover(); // [3단계] 최종 인수 확정
              },
              child: Text('marketplace.takeover.dialog.finalize'.tr()),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _cancelReservation(); // [3단계] 거래 취소 (환불)
                  },
                  child: Text('marketplace.takeover.dialog.cancelDeal'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('marketplace.dialog.close'.tr()),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// [3단계-A] 최종 인수 확정 (Repository 호출)
  Future<void> _finalizeTakeover() async {
    setState(() => _isVerifying = true);
    try {
      final productRepository = ProductRepository();
      await productRepository.completeTakeover(productId: widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('marketplace.takeover.success.finalized'.tr())));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  /// [3단계-B] 예약 취소 및 환불 (Repository 호출)
  Future<void> _cancelReservation() async {
    setState(() => _isVerifying = true);
    try {
      // TODO: PG사 환불 API 호출
      // (환불 성공 시)
      final productRepository = ProductRepository();
      await productRepository.cancelReservation(productId: widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('marketplace.takeover.success.cancelled'.tr())));
        Navigator.of(context).pop(); // 상세 화면으로 복귀
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('marketplace.takeover.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'marketplace.takeover.guide.title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('marketplace.takeover.guide.subtitle'.tr()),
            const SizedBox(height: 16),
            // [AI 리팩토링] 공용 위젯을 사용하여 원본 리포트 표시
            AiReportViewer(
              aiReport: Map<String, dynamic>.from(widget.product.aiReport ??
                  widget.product.aiVerificationData ??
                  {}),
            ),

            const Divider(height: 32),
            // 사진 촬영 섹션
            Text(
              'marketplace.takeover.photoTitle'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._newPhotos.map((file) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(file.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )),
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isVerifying ? null : _startOnSiteVerification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Text('marketplace.takeover.buttonVerify'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/core/utils/upload_helpers.dart';

class AiEvidenceSuggestionScreen extends StatefulWidget {
  final String productId;
  final String categoryId;
  final String ruleId;
  final AiVerificationRule rule;
  final List<String> initialImageUrls;
  final String confirmedProductName;
  final String? userPrice;
  final String? userDescription;
  final String? categoryName;
  final String? subCategoryName;
  final List<String> missingEvidenceKeys;

  const AiEvidenceSuggestionScreen({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.ruleId,
    required this.rule,
    required this.initialImageUrls,
    required this.confirmedProductName,
    this.userPrice,
    this.userDescription,
    this.categoryName,
    this.subCategoryName,
    required this.missingEvidenceKeys,
  });

  @override
  State<AiEvidenceSuggestionScreen> createState() =>
      _AiEvidenceSuggestionScreenState();
}

class _AiEvidenceSuggestionScreenState
    extends State<AiEvidenceSuggestionScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;
  // Map from key -> optional image file picked
  final Map<String, XFile?> _addedPhotos = {};
  // Track explicit skips
  final Set<String> _skipped = {};

  Future<void> _pick(String key) async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // [Fix] Warning #4: 품질 80%
      maxWidth: 1024, // [Fix] Warning #4: 최대 너비 1024px
    );
    if (img != null) {
      setState(() {
        _addedPhotos[key] = img;
        _skipped.remove(key);
      });
    }
  }

  void _skip(String key) {
    setState(() {
      _addedPhotos.remove(key);
      _skipped.add(key);
    });
  }

  Future<void> _continue() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      // 1) 업로드 준비: 사용자 확인
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      // 2) 가이드 사진 업로드 (건너뛴 항목 제외)
      final Map<String, String> guided = {};
      final Map<String, XFile> takenShots = {};
      for (final entry in _addedPhotos.entries) {
        final key = entry.key;
        final file = entry.value;
        if (file != null && !_skipped.contains(key)) {
          final url = await uploadProductImage(file, user.uid);
          guided[key] = url;
          takenShots[key] = file;
        }
      }

      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('generatefinalreport');

      final result = await callable.call(<String, dynamic>{
        'imageUrls': {
          'initial': widget.initialImageUrls,
          'guided': guided,
        },
        'ruleId': widget.ruleId,
        'confirmedProductName': widget.confirmedProductName,
        'categoryName': widget.categoryName,
        'subCategoryName': widget.subCategoryName,
        'userPrice': widget.userPrice,
        'userDescription': widget.userDescription,
        'skipped_items': _skipped.toList(),
        'locale': context.locale.languageCode,
      });

      // [Fix] Cast-Safety: result.data['report'] is Map<dynamic, dynamic>
      final reportRaw = (result.data as Map<dynamic, dynamic>?)?['report'];
      final report = (reportRaw != null && reportRaw is Map)
          ? Map<String, dynamic>.from(reportRaw)
          : null;
      if (report == null) {
        throw Exception('AI가 유효한 리포트를 생성하지 못했습니다.');
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AiFinalReportScreen(
          productId: widget.productId,
          categoryId: widget.categoryId,
          finalReport: report,
          rule: widget.rule,
          initialImages: widget.initialImageUrls,
          takenShots: takenShots,
          confirmedProductName: widget.confirmedProductName,
          userPrice: widget.userPrice,
          userDescription: widget.userDescription, // [Fix #3] 원본 설명 전달 누락 수정
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = widget.missingEvidenceKeys;
    return Scaffold(
      appBar: AppBar(title: Text('ai_flow.guided_camera.title'.tr())),
      body: keys.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ai_flow.guided_camera.guide'.tr()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final k = keys[index];
                final picked = _addedPhotos[k];
                final skipped = _skipped.contains(k);
                // Visual hint: try to show a small thumbnail or an icon per key
                Widget leading;
                // 1) If user already took a photo for this key, show its thumbnail
                if (picked != null) {
                  leading = Image.file(
                    File(picked.path),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  );
                } else {
                  // 2) If rule has suggestedShots metadata, pick an icon by key
                  final shot = widget.rule.suggestedShots[k];
                  IconData icon = Icons.photo_camera_outlined;
                  if (shot != null) {
                    final keyLower = k.toLowerCase();
                    if (keyLower.contains('imei')) {
                      icon = Icons.qr_code_2;
                    } else if (keyLower.contains('battery')) {
                      icon = Icons.battery_full;
                    } else if (keyLower.contains('screen') ||
                        keyLower.contains('display')) {
                      icon = Icons.phone_iphone;
                    } else if (keyLower.contains('serial')) {
                      icon = Icons.confirmation_number_outlined;
                    }
                  }
                  leading = Icon(icon, size: 32, color: Colors.grey[700]);
                }
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: leading,
                    title: Text(k),
                    subtitle: picked != null
                        ? Text(tr('ai_flow.common.added_photo',
                            args: [picked.name]))
                        : skipped
                            ? Text('ai_flow.common.skipped'.tr())
                            : Text('ai_flow.guided_camera.guide'.tr()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () => _pick(k),
                            child: Text('ai_flow.common.add_photo'.tr())),
                        const SizedBox(width: 8),
                        TextButton(
                            onPressed: () => _skip(k),
                            child: Text('ai_flow.common.skip'.tr())),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitting ? null : _continue,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('ai_flow.guided_camera.next_button'.tr()),
        ),
      ),
    );
  }
}

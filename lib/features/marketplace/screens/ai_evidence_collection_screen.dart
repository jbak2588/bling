import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'ai_final_report_screen.dart';

class AiEvidenceCollectionScreen extends StatefulWidget {
  final String productId;
  final AiVerificationRule rule;
  final String categoryId; // [핵심 추가] 카테고리 ID를 전달받습니다.
  // [핵심 수정] XFile과 String(URL)을 모두 받을 수 있도록 dynamic 타입으로 변경
  final List<dynamic> initialImages;
  final String? confirmedProductName;

  const AiEvidenceCollectionScreen({
    super.key,
    required this.productId,
    required this.rule,
    required this.categoryId,
    required this.initialImages,
    this.confirmedProductName,
  });

  @override
  State<AiEvidenceCollectionScreen> createState() =>
      _AiEvidenceCollectionScreenState();
}

class _AiEvidenceCollectionScreenState
    extends State<AiEvidenceCollectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, XFile> _evidenceShots = {};
  bool _isLoading = false;

  bool get _allShotsTaken =>
      _evidenceShots.length == widget.rule.requiredShots.length;

  Future<void> _takePicture(String shotKey) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _evidenceShots[shotKey] = image;
      });
    }
  }

  Future<void> _submitForVerification() async {
    if (!_allShotsTaken && widget.rule.requiredShots.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ai_flow.evidence.all_shots_required'.tr())),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      // [핵심 수정] initialImages의 타입에 따라 다르게 처리하는 로직
      final List<String> initialImageUrls = [];
      for (final image in widget.initialImages) {
        if (image is String) {
          // 이미 URL이면 그대로 추가
          initialImageUrls.add(image);
        } else if (image is XFile) {
          // XFile이면 업로드 후 URL 추가
          final url = await _uploadImage(image, user.uid);
          initialImageUrls.add(url);
        }
      }

      // 증거 사진 업로드
      final Map<String, String> uploadedGuidedUrls = {};
      for (final entry in _evidenceShots.entries) {
        final url = await _uploadImage(entry.value, user.uid);
        uploadedGuidedUrls[entry.key] = url;
      }

      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'asia-northeast3')
              .httpsCallable('generatefinalreport');

      final result = await callable.call(<String, dynamic>{
        'imageUrls': {
          'initial': initialImageUrls, // 강화된 로직으로 생성된 URL 목록
          'guided': uploadedGuidedUrls,
        },
        'ruleId': widget.rule.id,
        'confirmedProductName': widget.confirmedProductName,
        // TODO: 가격, 설명 등 다른 정보들도 전달
      });

      final reportData = result.data['report'] as Map<String, dynamic>?;
      if (reportData == null) {
        throw Exception("AI failed to generate a valid report.");
      }

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AiFinalReportScreen(
            productId: widget.productId,
            categoryId:
                widget.categoryId, // [핵심 수정] 전달받은 categoryId를 그대로 넘겨줍니다.
            finalReport: reportData,
            rule: widget.rule,
            // AiFinalReportScreen에는 URL 목록을 전달
            initialImages:
                initialImageUrls.map((e) => XFile(e)).toList(), // 임시 변환
            takenShots: _evidenceShots,
            confirmedProductName: widget.confirmedProductName ?? '',
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'ai_flow.error.report_generation'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(XFile image, String userId) async {
    final fileName = '${const Uuid().v4()}${p.extension(image.path)}';
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/$userId/$fileName');
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ai_flow.evidence.title'.tr())),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.rule.requiredShots.length,
        itemBuilder: (context, index) {
          final shotKey = widget.rule.requiredShots.keys.elementAt(index);
          final shotRule = widget.rule.requiredShots[shotKey]!;
          final takenImage = _evidenceShots[shotKey];
          final isCompleted = takenImage != null;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                isCompleted ? Icons.check_circle : Icons.camera_alt_outlined,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 40,
              ),
              title: Text(shotRule.nameKo.tr()),
              subtitle: Text(shotRule.descKo.tr()),
              trailing: takenImage != null
                  ? Image.file(File(takenImage.path),
                      width: 50, height: 50, fit: BoxFit.cover)
                  : null,
              onTap: () => _takePicture(shotKey),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (_allShotsTaken || widget.rule.requiredShots.isEmpty) &&
                  !_isLoading
              ? _submitForVerification
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('ai_flow.evidence.submit_button'.tr()),
        ),
      ),
    );
  }
}

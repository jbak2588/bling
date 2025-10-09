// lib/features/marketplace/screens/ai_gallery_upload_screen.dart

import 'dart:io';
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_prediction_screen.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class AiGalleryUploadScreen extends StatefulWidget {
  final AiVerificationRule rule;

  const AiGalleryUploadScreen({super.key, required this.rule});

  @override
  State<AiGalleryUploadScreen> createState() => _AiGalleryUploadScreenState();
}

class _AiGalleryUploadScreenState extends State<AiGalleryUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final bool _isLoading = false;

  // 갤러리에서 여러 이미지 선택
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
    }
  }

  // 다음 단계로 진행
  void _goToNextStep() {
    if (_images.length < widget.rule.minGalleryPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ai_flow.gallery_upload.min_photo_error'.tr(
              args: [widget.rule.minGalleryPhotos.toString()],
            ),
          ),
        ),
      );
      return;
    }

    // ✅ 기존에 있던 'rule:' 파라미터는 제거하고, 'ruleId:'로 전달
    // ✅ pickedImages 대신, 실제 너의 리스트 변수명을 넣어줘. (예: _images, _imageFiles 등)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiPredictionScreen(
          ruleId: widget.rule.id,
          images: _images.cast<Object>(), // ← 여기서 _images 를 네가 실제로 쓰는 리스트 이름으로!
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _images.length >= widget.rule.minGalleryPhotos;

    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.gallery_upload.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ai_flow.gallery_upload.instruction'.tr(
                namedArgs: {
                  'category': context.locale.languageCode == 'ko'
                      ? widget.rule.nameKo
                      : widget.rule.nameId
                },
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'ai_flow.gallery_upload.min_photo_guide'.tr(
                args: [widget.rule.minGalleryPhotos.toString()],
              ),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildImagePicker(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: canProceed && !_isLoading ? _goToNextStep : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('ai_flow.gallery_upload.next_button'.tr()),
        ),
      ),
    );
  }

  // 이미지 선택 위젯 (product_registration_screen.dart와 유사)
  Widget _buildImagePicker() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == _images.length) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: const Icon(Icons.add_a_photo_outlined, size: 40),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_images[index].path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

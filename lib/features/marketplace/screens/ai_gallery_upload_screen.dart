// lib/features/marketplace/screens/ai_gallery_upload_screen.dart

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_prediction_screen.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [추가] 사용자 ID를 가져오기 위해 import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
// for kDebugMode

class AiGalleryUploadScreen extends StatefulWidget {
  final AiVerificationRule rule;

  const AiGalleryUploadScreen({super.key, required this.rule});

  @override
  State<AiGalleryUploadScreen> createState() => _AiGalleryUploadScreenState();
}

class _AiGalleryUploadScreenState extends State<AiGalleryUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  // [추가] 로딩 및 에러 상태 관리
  bool _isLoading = false;

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
  Future<void> _goToNextStep() async {
    if (_images.length < widget.rule.minGalleryPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ai_flow.gallery_upload.min_photo_error'
              .tr(args: ['${widget.rule.minGalleryPhotos}'])),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. 이미지 업로드 및 URL 변환
      final imageUrls = await _uploadImagesAndGetUrls(_images);

      // 2. Cloud Function 호출
      final predictedName =
          await _callInitialAnalysis(widget.rule.id, imageUrls);

      // 3. 결과와 함께 다음 화면으로 이동
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AiPredictionScreen(
              rule: widget.rule,
              initialImages: _images,
              predictedName: predictedName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ai_flow.common.error'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// [추가] 이미지들을 Storage에 업로드하고 URL 목록을 반환
  Future<List<String>> _uploadImagesAndGetUrls(List<XFile> images) async {
    // [추가] 현재 로그인한 사용자 정보를 가져옵니다.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in.");
    }

    final storage = FirebaseStorage.instance;
    final List<Future<String>> uploadTasks = [];

    for (final image in images) {
      final file = File(image.path);
      final fileName = p.basename(file.path);
      // [수정] 보안 규칙에 맞게 userId를 경로에 포함시킵니다.
      final ref = storage.ref(
        'ai_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-$fileName',
      );

      uploadTasks.add(ref.putFile(file).then((_) => ref.getDownloadURL()));
    }
    return await Future.wait(uploadTasks);
  }

  /// [추가] Cloud Function 'initialproductanalysis' 호출
  Future<String> _callInitialAnalysis(
      String ruleId, List<String> imageUrls) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    // [수정] 실제 배포된 함수를 테스트할 때는 에뮬레이터 코드를 주석 처리해야 합니다.
    // if (kDebugMode) {
    //   functions.useFunctionsEmulator('localhost', 5001);
    // }
    final callable = functions.httpsCallable('initialproductanalysis');
    final response = await callable.call<Map<String, dynamic>>({
      'ruleId': ruleId,
      'imageUrls': imageUrls,
    });
    final data = response.data;
    if (data['success'] != true) {
      throw StateError(data['error'] ?? 'Unknown error from function');
    }
    return data['prediction'] as String? ?? 'ai_flow.prediction.no_name'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final minPhotos = widget.rule.minGalleryPhotos;

    return Scaffold(
      appBar: AppBar(
        title: Text('ai_flow.gallery_upload.title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ai_flow.gallery_upload.guide'.tr(args: ['$minPhotos']),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '(${_images.length}/$minPhotos)',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildImageGrid(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // [수정] 로딩 중일 때 버튼 비활성화
              onPressed: _isLoading ? null : _goToNextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('ai_flow.gallery_upload.next_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 선택 위젯
  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      // 이미지 추가 버튼을 위해 아이템 개수 +1
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

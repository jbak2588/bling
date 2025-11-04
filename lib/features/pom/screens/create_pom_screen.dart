// ===================== DocHeader =====================
// [기획 요약]
// - 숏폼 이미지(POM) 등록, 다중 이미지 업로드, 제목/설명 등 입력 지원.
//
// [실제 구현 비교]
// - 다중 이미지 업로드 및 기본 메타 저장 동작.
// - UI/UX 기본 구현, 입력값 유효성 검사와 저장 로직 포함.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능(조회수, 부스트, AI 인증 등) 추가.
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// [기획 요약]
// - '뽐' (Pom) 콘텐츠(사진/비디오) 생성 및 업로드 화면.
// [V2 - 2025-11-03]
// - 'create_short_screen'에서 리네이밍 및 '멀티 콘텐츠' 지원.
// - 'SegmentedButton'으로 '사진' / '비디오' 업로드 선택 UI 구현.
// [V3 - 2025-11-04]
// - 업로드 성공 시 'Navigator.pop(true)'를 반환하여 피드 자동 갱신.
// - 'searchIndex' (검색 토큰) 생성 로직 추가.
// - 비디오 미리보기(LayoutBuilder)의 화면 비율 왜곡 문제 수정.
// =====================================================

// [V2] lib/features/pom/screens/create_pom_screen.dart

import 'dart:io';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart'; // [V2] Re-added
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreatePomScreen extends StatefulWidget {
  final UserModel userModel;
  const CreatePomScreen({super.key, required this.userModel});

  @override
  State<CreatePomScreen> createState() => _CreatePomScreenState();
}

class _CreatePomScreenState extends State<CreatePomScreen> {
  final _titleController = TextEditingController(); // [V2]
  final _descriptionController = TextEditingController(); // [V2]
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedTags = [];

  // [V2] 비디오 -> 다중 이미지로 변경
  List<XFile> _imageFiles = [];
  XFile? _videoFile; // [V2] Re-added
  VideoPlayerController? _videoController; // [V2] Re-added
  bool _isSaving = false;

  // [V2] Media type selection
  PomMediaType _selectedType = PomMediaType.image;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose(); // [V2] Re-added
    super.dispose();
  }

  // [V2] 비디오 피커 -> 다중 이미지 피커
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80, // 압축
      // limit: 10, // pickMultiImage에 limit 파라미터가 없다면 제거
    );
    if (pickedFiles.isNotEmpty) {
      // 최대 10장만 유지
      final limited =
          pickedFiles.length > 10 ? pickedFiles.sublist(0, 10) : pickedFiles;
      setState(() {
        _imageFiles = limited;
      });
    }
  }

  // [V2] Re-added video picker
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(pickedFile.path))
        ..initialize().then((_) {
          setState(() {
            _videoFile = pickedFile;
            _videoController?.play();
            _videoController?.setLooping(true);
          });
        });
    }
  }

  Future<void> _submitShort() async {
    if ((_imageFiles.isEmpty && _videoFile == null) || _isSaving) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. [V2] 미디어 업로드 (이미지/비디오)
      List<String> mediaUrls = [];
      String thumbnailUrl = '';

      if (_selectedType == PomMediaType.image) {
        // --- 이미지 업로드 ---
        for (final imageFile in _imageFiles) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('pom/${user.uid}/$fileName.jpg'); // pom 컬렉션으로
          final uploadTask = ref.putFile(File(imageFile.path));
          final snapshot = await uploadTask.whenComplete(() {});
          final imageUrl = await snapshot.ref.getDownloadURL();
          mediaUrls.add(imageUrl);
        }
        if (mediaUrls.isNotEmpty) {
          thumbnailUrl = mediaUrls.first;
        }
      } else {
        // --- 비디오 업로드 ---
        if (_videoFile == null) throw Exception("Video file not selected");
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('pom/${user.uid}/$fileName.mp4'); // [V2] 비디오 경로
        final uploadTask = ref.putFile(File(_videoFile!.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final videoUrl = await snapshot.ref.getDownloadURL();
        mediaUrls.add(videoUrl);
        // TODO: (Optional) 비디오 썸네일 생성 (Cloud Function 추천)
        thumbnailUrl = '';
      }

      // 2. [V2] PomModel 생성 (멀티 콘텐츠)
      final newShort = PomModel(
        id: '',
        userId: user.uid,
        mediaType: _selectedType, // [V2] Fix
        mediaUrls: mediaUrls, // [V2] Fix
        thumbnailUrl: thumbnailUrl, // [V2] Fix
        title: _titleController.text.trim(), // [V2] Fix
        description: _descriptionController.text.trim(),
        location: widget.userModel.locationName ?? 'Unknown',
        locationParts: widget.userModel.locationParts,
        geoPoint: widget.userModel.geoPoint,
        tags: List<String>.from(_selectedTags),
        createdAt: Timestamp.now(),
      );

      // 3. Firestore에 저장 (검색 인덱스 포함)
      final data = newShort.toJson();
      // 간단한 검색 인덱스(searchIndex): 제목/설명 토큰 + 태그, 모두 소문자 정규화
      List<String> buildSearchIndex(
          {required String title,
          required String description,
          required List<String> tags}) {
        String norm(String s) => s
            .toLowerCase()
            .replaceAll(RegExp(r'[^\p{L}\p{N}\s\-_/]', unicode: true), '')
            .trim();
        final t = norm(title).split(RegExp(r"\s+")).where((e) => e.isNotEmpty);
        final d =
            norm(description).split(RegExp(r"\s+")).where((e) => e.isNotEmpty);
        final all = <String>{}
          ..addAll(t)
          ..addAll(d)
          ..addAll(tags.map(norm));
        // 짧은 토큰만 유지 (길이 2 이상) 및 최대 50개 제한
        final filtered = all.where((e) => e.length >= 2).take(50).toList();
        return filtered;
      }

      data['searchIndex'] = buildSearchIndex(
        title: newShort.title,
        description: newShort.description,
        tags: newShort.tags ?? const [],
      );

      await FirebaseFirestore.instance.collection('pom').add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('pom.create.success'.tr()), // TODO: i18n ensure
            backgroundColor: Colors.green));
        // Return a simple success flag to trigger feed refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('pom.create.fail'
                .tr(namedArgs: {'error': e.toString()})), // TODO: i18n ensure
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pom.create.title'.tr()), // [V2] 새 뽐
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _submitShort, child: Text('pom.create.submit'.tr())),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // [V2] 미디어 타입 선택 UI
              SegmentedButton<PomMediaType>(
                segments: [
                  ButtonSegment(
                    value: PomMediaType.image,
                    label: Text('pom.create.photo'.tr()), // TODO: i18n ensure
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                  ButtonSegment(
                    value: PomMediaType.video,
                    label: Text('pom.create.video'.tr()), // TODO: i18n ensure
                    icon: const Icon(Icons.videocam_outlined),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<PomMediaType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    // 미디어 초기화
                    _imageFiles = [];
                    _videoFile = null;
                    _videoController?.dispose();
                    _videoController = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // [V2] 미디어 프리뷰 영역 (비디오: 가로폭 기준 비율 유지)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isVideo = _selectedType == PomMediaType.video;
                  final isVideoReady = _videoController != null &&
                      _videoController!.value.isInitialized;
                  // Fit-to-width for video to avoid horizontal stretching; otherwise fixed height
                  final double targetHeight = (isVideo && isVideoReady)
                      ? (constraints.maxWidth /
                          _videoController!.value.aspectRatio)
                      : 300;

                  return GestureDetector(
                    onTap: _selectedType == PomMediaType.image
                        ? _pickImages
                        : _pickVideo,
                    child: Container(
                      height: targetHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: _buildMediaPreview(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController, // [V2]
                decoration: InputDecoration(
                  labelText: 'pom.create.form.titleLabel'.tr(), // [V2]
                  border: const OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController, // [V2]
                decoration: InputDecoration(
                  labelText: 'pom.create.form.descriptionLabel'.tr(), // [V2]
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // [V2] 공용 태그 입력기 추가
              Text('Tags', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTagInputField(
                hintText: 'pom.search.hint'.tr(),
                titleController: _titleController,
                onTagsChanged: (tags) {
                  _selectedTags
                    ..clear()
                    ..addAll(tags.map((e) => e.toLowerCase()));
                },
                maxTags: 5,
              ),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // [V2] 선택된 미디어를 표시하는 위젯
  Widget _buildMediaPreview() {
    if (_selectedType == PomMediaType.image) {
      // --- 이미지 그리드 ---
      if (_imageFiles.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            padding: const EdgeInsets.all(4),
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) =>
                Image.file(File(_imageFiles[index].path), fit: BoxFit.cover),
          ),
        );
      } else {
        return const Center(
            child:
                Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey));
      }
    } else {
      // --- 비디오 플레이어 ---
      if (_videoController != null && _videoController!.value.isInitialized) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // Parent container height preserves aspect ratio; expand child to fill
          child: SizedBox.expand(child: VideoPlayer(_videoController!)),
        );
      } else {
        return const Center(
            child:
                Icon(Icons.video_call_outlined, size: 60, color: Colors.grey));
      }
    }
  }
}

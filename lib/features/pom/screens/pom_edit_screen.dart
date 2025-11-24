// ===================== DocHeader =====================
// [기획 요약]
// - 기존 POM 게시글 수정 화면.
// - 제목, 설명, 태그 수정 및 이미지 추가/삭제 지원 (영상은 교체만 가능).
// [V1 - 2025-11-22]
// - create_pom_screen.dart 기반으로 생성.
// - PomModel을 받아 초기값 설정.
// =====================================================
// lib/features/pom/screens/pom_edit_screen.dart

import 'dart:io';
import 'package:bling_app/features/pom/data/pom_repository.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// compat shim removed; using Slang `t` accessors
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/core/utils/search_helper.dart';

class PomEditScreen extends StatefulWidget {
  final PomModel pom;

  const PomEditScreen({super.key, required this.pom});

  @override
  State<PomEditScreen> createState() => _PomEditScreenState();
}

class _PomEditScreenState extends State<PomEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  final PomRepository _repository = PomRepository();

  List<String> _selectedTags = [];

  // 기존 미디어
  List<String> _existingMediaUrls = [];

  // 새로 추가된 미디어
  final List<XFile> _newImageFiles = [];
  XFile? _newVideoFile;
  VideoPlayerController? _videoController;

  bool _isSaving = false;
  late PomMediaType _mediaType;

  @override
  void initState() {
    super.initState();
    _mediaType = widget.pom.mediaType;
    _titleController = TextEditingController(text: widget.pom.title);
    _descriptionController =
        TextEditingController(text: widget.pom.description);
    _existingMediaUrls = List.from(widget.pom.mediaUrls);
    if (widget.pom.tags != null) {
      _selectedTags = List.from(widget.pom.tags!);
    }

    // 비디오인 경우 기존 URL로 컨트롤러 초기화
    if (_mediaType == PomMediaType.video && _existingMediaUrls.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(_existingMediaUrls.first))
            ..initialize().then((_) {
              if (mounted) setState(() {});
            });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final currentCount = _existingMediaUrls.length + _newImageFiles.length;
    if (currentCount >= 10) return;

    final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      final availableSlots = 10 - currentCount;
      final toAdd = pickedFiles.length > availableSlots
          ? pickedFiles.sublist(0, availableSlots)
          : pickedFiles;

      setState(() {
        _newImageFiles.addAll(toAdd);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(pickedFile.path))
        ..initialize().then((_) {
          setState(() {
            _newVideoFile = pickedFile;
            _videoController?.play();
            _videoController?.setLooping(true);
            // 비디오는 교체 방식이므로 기존 URL 리스트 비움 (UI상 표시용)
            _existingMediaUrls.clear();
          });
        });
    }
  }

  void _removeExistingMedia(int index) {
    setState(() {
      _existingMediaUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  Future<void> _submitUpdate() async {
    if (_isSaving) return;
    // 이미지는 최소 1장 이상 있어야 함 (기존 + 신규)
    if (_mediaType == PomMediaType.image &&
        (_existingMediaUrls.isEmpty && _newImageFiles.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("최소 1장의 이미지가 필요합니다.")));
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<String> finalMediaUrls = List.from(_existingMediaUrls);
      String thumbnailUrl = widget.pom.thumbnailUrl;

      // 1. 신규 미디어 업로드
      if (_mediaType == PomMediaType.image) {
        for (final imageFile in _newImageFiles) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('pom/${user.uid}/$fileName.jpg');
          final uploadTask = ref.putFile(File(imageFile.path));
          final snapshot = await uploadTask.whenComplete(() {});
          final imageUrl = await snapshot.ref.getDownloadURL();
          finalMediaUrls.add(imageUrl);
        }
        // 썸네일 갱신 (첫 번째 이미지)
        if (finalMediaUrls.isNotEmpty) {
          thumbnailUrl = finalMediaUrls.first;
        }
      } else {
        // 비디오 교체 시
        if (_newVideoFile != null) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('pom/${user.uid}/$fileName.mp4');
          final uploadTask = ref.putFile(File(_newVideoFile!.path));
          final snapshot = await uploadTask.whenComplete(() {});
          final videoUrl = await snapshot.ref.getDownloadURL();
          finalMediaUrls = [videoUrl]; // 비디오는 1개만
          // 썸네일은 일단 빈값 혹은 클라우드 함수 처리. 여기선 기존 유지하거나 빈값.
          thumbnailUrl = '';
        }
      }

      // 2. 검색 인덱스 생성
      final searchIndex = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _selectedTags,
      );

      // 3. 업데이트 데이터 구성
      final updateData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'tags': _selectedTags,
        'mediaUrls': finalMediaUrls,
        'thumbnailUrl': thumbnailUrl,
        'searchIndex': searchIndex,
        // 'updatedAt': FieldValue.serverTimestamp(), // 필요 시 추가
      };

      await _repository.updatePom(widget.pom.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.pom.create.success), // "성공적으로 저장되었습니다" (재사용)
            backgroundColor: Colors.green));
        Navigator.of(context).pop(true); // true 반환하여 갱신 유도
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(t.pom.create.fail.replaceAll('{error}', e.toString())),
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
        title: Text('${t.common.edit} ${t.pom.title}'),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _submitUpdate,
              child: Text(t['common.save'] ?? '', // "저장"
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 미디어 미리보기 영역
              if (_mediaType == PomMediaType.image)
                _buildImageEditor()
              else
                _buildVideoEditor(),

              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: t.pom.create.form.titleLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: t.pom.create.form.descriptionLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Tags', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              CustomTagInputField(
                initialTags: _selectedTags,
                hintText: t.pom.search.hint,
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
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildImageEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 기존 이미지들
              ..._existingMediaUrls.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(entry.value,
                            width: 120, height: 120, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingMedia(entry.key),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
              // 신규 이미지들
              ..._newImageFiles.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(entry.value.path),
                            width: 120, height: 120, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(entry.key),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
              // 추가 버튼
              if ((_existingMediaUrls.length + _newImageFiles.length) < 10)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoEditor() {
    return GestureDetector(
      onTap: _pickVideo, // 탭하면 비디오 교체
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 40),
                    Text("비디오 교체하기", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

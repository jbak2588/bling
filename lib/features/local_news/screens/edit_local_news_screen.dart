// lib/features/local_news/screens/edit_local_news_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';


// 🗑️ 문제가 발생한 외부 패키지 import를 모두 제거합니다.

import '../../../core/constants/app_categories.dart';
import '../models/post_category_model.dart';
import '../models/post_model.dart';


class EditLocalNewsScreen extends StatefulWidget {
  final PostModel post;
  const EditLocalNewsScreen({super.key, required this.post});

  @override
  State<EditLocalNewsScreen> createState() => _EditLocalNewsScreenState();
}

class _EditLocalNewsScreenState extends State<EditLocalNewsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  // ✅ 커스텀 태그 입력을 위한 컨트롤러
  final _tagInputController = TextEditingController();
  List<String> _tags = [];

  final List<XFile> _newSelectedImages = [];
  final List<String> _existingImageUrls = [];
  final _picker = ImagePicker();

  PostCategoryModel? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title ?? '';
    _contentController.text = widget.post.body;
    _tags = List<String>.from(widget.post.tags);

    if (widget.post.mediaUrl != null) {
        _existingImageUrls.addAll(widget.post.mediaUrl!);
    }

    _selectedCategory = AppCategories.postCategories.firstWhere(
      (c) => c.categoryId == widget.post.category,
      orElse: () => AppCategories.postCategories.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose(); // ✅ 컨트롤러 해제
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedImages =
        await _picker.pickMultiImage(imageQuality: 70, limit: 10);
    if (pickedImages.isNotEmpty) {
      setState(() {
        _newSelectedImages.addAll(pickedImages
            .take(10 - _existingImageUrls.length - _newSelectedImages.length));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newSelectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    for (var image in _newSelectedImages) {
      final ref = FirebaseStorage.instance.ref(
          'post_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      await ref.putFile(File(image.path));
      downloadUrls.add(await ref.getDownloadURL());
    }
    return downloadUrls;
  }

  Future<void> _updatePost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('localNewsCreate.alerts.contentRequired'.tr())));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('localNewsCreate.alerts.categoryRequired'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newImageUrls = await _uploadImages();
      final finalImageUrls = [..._existingImageUrls, ...newImageUrls];

      final updatedData = {
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        'mediaUrl': finalImageUrls,
        'mediaType': finalImageUrls.isNotEmpty ? 'image' : null,
        'category': _selectedCategory!.categoryId,
        'tags': _tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
              SnackBar(content: Text('localNewsEdit.alerts.success'.tr())));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
                content: Text('localNewsEdit.alerts.failure'
                    .tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ✅ 커스텀 태그 위젯을 빌드하는 함수
  Widget _buildCustomChipsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 칩들을 보여주는 부분
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            );
          }).toList(),
        ),
        // 새 태그를 입력하는 텍스트 필드
        TextField(
          controller: _tagInputController,
          decoration: InputDecoration(
            labelText: 'localNewsEdit.form.tagInputLabel'.tr(),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            // 스페이스바를 누르면 태그 추가
            if (value.endsWith(' ') && value.trim().isNotEmpty) {
              final newTag = value.trim();
              if (!_tags.contains(newTag)) {
                setState(() {
                  _tags.add(newTag);
                });
              }
              _tagInputController.clear();
            }
          },
          onSubmitted: (value) {
            // 키보드에서 완료(엔터)를 누르면 태그 추가
            final newTag = value.trim();
            if (newTag.isNotEmpty && !_tags.contains(newTag)) {
              setState(() {
                _tags.add(newTag);
              });
            }
            _tagInputController.clear();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('localNewsEdit.appBarTitle'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<PostCategoryModel>(
              value: _selectedCategory,
              decoration: InputDecoration(
                  labelText: 'localNewsCreate.form.categoryLabel'.tr(),
                  border: const OutlineInputBorder()),
              items: AppCategories.postCategories.map((category) {
                return DropdownMenuItem<PostCategoryModel>(
                  value: category,
                  child: Row(children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(category.nameKey.tr()),
                  ]),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'localNewsCreate.form.titleLabel'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                    labelText: 'localNewsCreate.form.contentLabel'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            
            // ✅ 직접 만든 커스텀 태그 입력 위젯을 사용합니다.
            _buildCustomChipsInput(),

            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSubmitting ? null : _updatePost,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('localNewsEdit.buttons.submit'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final existingImageCount = _existingImageUrls.length;
    final newImageCount = _newSelectedImages.length;
    final totalImageCount = existingImageCount + newImageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.camera_alt),
          label: Text('localNewsCreate.buttons.addImage'.tr()),
        ),
        const SizedBox(height: 8),
        if (totalImageCount > 0)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: totalImageCount,
            itemBuilder: (context, index) {
              Widget imageWidget;
              bool isExisting;
              int imageIndex;

              if (index < existingImageCount) {
                isExisting = true;
                imageIndex = index;
                imageWidget = Image.network(_existingImageUrls[index], fit: BoxFit.cover);
              } else {
                isExisting = false;
                imageIndex = index - existingImageCount;
                imageWidget =
                    Image.file(File(_newSelectedImages[imageIndex].path), fit: BoxFit.cover);
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageWidget,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => isExisting
                          ? _removeExistingImage(imageIndex)
                          : _removeNewImage(imageIndex),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
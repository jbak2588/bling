// lib/features/local_news/views/edit_local_news_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ 새로 만든 공용 위젯을 import 합니다.
import '../../shared/widgets/custom_tag_input_field.dart';

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
  
  // ❌ 공용 위젯으로 대체되었으므로 기존 태그 컨트롤러는 제거합니다.
  // final _tagInputController = TextEditingController(); 
  
  // ✅ 태그 목록 상태는 그대로 유지합니다. 공용 위젯이 이 상태를 업데이트합니다.
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
    // ❌ 더 이상 사용하지 않으므로 dispose 호출도 제거합니다.
    // _tagInputController.dispose(); 
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
        'tags': _tags, // ✅ _tags 상태는 그대로 사용됩니다.
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다')));   // TODO : 다국어 작업
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('수정 실패: $e')));   // TODO : 다국어 작업
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ❌ 기존 커스텀 태그 위젯 빌드 함수는 완전히 제거합니다.
  // Widget _buildCustomChipsInput() { ... }

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
              initialValue: _selectedCategory,
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
            
            // ✅ 교체된 공용 커스텀 태그 위젯을 사용합니다.
            CustomTagInputField(
              initialTags: _tags, // 초기 태그 목록을 전달합니다.
              hintText: 'localNewsCreate.form.tagsHint'.tr(), // 다국어 힌트 텍스트
              onTagsChanged: (tags) {
                // 태그가 변경될 때마다 화면의 상태(_tags)를 업데이트합니다.
                setState(() {
                  _tags = tags;
                });
              },
            ),

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
    // ... (이 부분은 기존 코드와 동일하여 생략하지 않고 그대로 둡니다)
    final existingImageCount = _existingImageUrls.length;
    final newImageCount = _newSelectedImages.length;
    final totalImageCount = existingImageCount + newImageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: totalImageCount >= 10 ? null : _pickImages,
          icon: const Icon(Icons.camera_alt),
          label: Text('${'localNewsCreate.buttons.addImage'.tr()} ($totalImageCount/10)'),
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
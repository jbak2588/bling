// lib/features/post/screens/edit_post_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_category_model.dart';
import '../../../core/models/post_model.dart';



class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

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

    // Convert List<String> tags to a comma-separated String for the controller
    // ignore: unnecessary_type_check
    _tagsController.text = (widget.post.tags is List)
        ? widget.post.tags.join(', ')
        : '';

    // Handle mediaUrl being either a List or a single String
    if (widget.post.mediaUrl != null) {
      if (widget.post.mediaUrl is List) {
        _existingImageUrls.addAll(
          List<String>.from(widget.post.mediaUrl as List),
        );
      } else if (widget.post.mediaUrl is String) {
        _existingImageUrls.add(widget.post.mediaUrl as String);
      }
    }

    _selectedCategory = AppCategories.postCategories.firstWhere(
      (c) => c.categoryId == widget.post.category,
      orElse: () => AppCategories.postCategories.first,
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('createPost.alerts.contentRequired'.tr())));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('createPost.alerts.categoryRequired'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newImageUrls = await _uploadImages();
      // 이제 mediaUrl은 항상 List<String> 타입으로 저장됩니다.
      final finalImageUrls = [..._existingImageUrls, ...newImageUrls];
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final updatedData = {
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        'mediaUrl': finalImageUrls,
        'mediaType': finalImageUrls.isNotEmpty ? 'image' : null,
        'category': _selectedCategory!.categoryId,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('게시글이 수정되었습니다')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('수정 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 코드는 이전과 동일합니다.
    return Scaffold(
       appBar: AppBar(title: Text('editPost.appBarTitle'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<PostCategoryModel>(
              value: _selectedCategory,
               decoration: InputDecoration(
                  labelText: 'createPost.form.categoryLabel'.tr(),
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
                decoration: const InputDecoration(
                    labelText: '제목', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                    labelText: '내용', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                    labelText: '태그 (쉼표로 구분)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSubmitting ? null : _updatePost,
              // ✅ [다국어 수정] 수정하기 버튼
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('editPost.buttons.submit'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final allImages = <Widget>[
      ..._existingImageUrls.asMap().entries.map((entry) =>
          _buildImageThumbnail(entry.key, entry.value, isExisting: true)),
      ..._newSelectedImages.asMap().entries.map((entry) =>
          _buildImageThumbnail(entry.key, entry.value, isExisting: false)),
    ];

        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.camera_alt),
            label: Text('createPost.buttons.addImage'.tr())),
        const SizedBox(height: 8),
        if (allImages.isNotEmpty)
          SizedBox(
              height: 100,
              child: ListView(
                  scrollDirection: Axis.horizontal, children: allImages)),
      ],
    );
  }

  Widget _buildImageThumbnail(int index, dynamic imageData,
      {required bool isExisting}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isExisting
                ? Image.network(imageData,
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image.file(File(imageData.path),
                    width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => isExisting
                  ? _removeExistingImage(index)
                  : _removeNewImage(index),
              child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white, size: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

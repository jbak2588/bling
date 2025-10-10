// lib/features/local_news/screens/create_local_news_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ easy_localization import

// ✅ 공용 태그 위젯 import
import '../../shared/widgets/custom_tag_input_field.dart';

import '../../../core/constants/app_categories.dart';
import '../models/post_category_model.dart';
import '../../../core/models/user_model.dart';

class CreateLocalNewsScreen extends StatefulWidget {
  const CreateLocalNewsScreen({super.key});

  @override
  State<CreateLocalNewsScreen> createState() => _CreateLocalNewsScreenState();
}

class _CreateLocalNewsScreenState extends State<CreateLocalNewsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  // final _tagsController = TextEditingController();
// ✅ 태그 목록을 관리할 상태 변수를 추가합니다.
  List<String> _tags = [];

  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();
  PostCategoryModel? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (AppCategories.postCategories.isNotEmpty) {
      _selectedCategory = AppCategories.postCategories.first;
    }
  }

  // ✅ dispose도 잊지 않고 정리합니다.
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedImages =
        await _picker.pickMultiImage(imageQuality: 70, limit: 10);
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedImages.take(10 - _selectedImages.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];
    for (var image in _selectedImages) {
      final ref = FirebaseStorage.instance.ref(
          'post_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      final uploadTask = await ref.putFile(File(image.path));
      downloadUrls.add(await uploadTask.ref.getDownloadURL());
    }
    return downloadUrls;
  }

  Future<void> _submitPost() async {
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('localNewsCreate.alerts.loginRequired'.tr());
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('localNewsCreate.alerts.userNotFound'.tr());
      }
      final userModel = UserModel.fromFirestore(userDoc);

      final imageUrls = await _uploadImages();
      // final tags = _tagsController.text
      //     .split(',')
      //     .map((tag) => tag.trim())
      //     .where((tag) => tag.isNotEmpty)
      //     .toList();

      final postData = {
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        'mediaUrl': imageUrls,
        'mediaType': imageUrls.isNotEmpty ? 'image' : null,
        'category': _selectedCategory!.categoryId,
        'tags': _tags, // ✅ 공용 위젯과 연결된 _tags 상태 사용
        'locationName': userModel.locationName,
        'locationParts': userModel.locationParts,
        'geoPoint': userModel.geoPoint,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'viewsCount': 0,
        'thanksCount': 0,
      };

      // 1. 새 게시물 저장 (DocumentReference로 ID 생성)
      final newPostRef =
          await FirebaseFirestore.instance.collection('posts').add(postData);
      final newPostId = newPostRef.id;

      // 2. ✅ [핵심 추가] 사용자의 postIds 배열에 새 게시물 ID 추가
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'postIds': FieldValue.arrayUnion([newPostId]),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('localNewsCreate.alerts.success'.tr())));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('localNewsCreate.alerts.failure'
                .tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('localNewsCreate.appBarTitle'.tr())),
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
                    // ✅ [다국어 수정] 카테고리 이름을 nameKey.tr()로 가져옵니다.
                    Text(category.nameKey.tr()),
                  ]),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                // ✅ [다국어 수정] 카테고리 설명을 descriptionKey.tr()로 가져옵니다.
                child: Text(
                  _selectedCategory!.descriptionKey.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
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
            CustomTagInputField(
              hintText: 'localNewsCreate.form.tagsHint'.tr(),
              onTagsChanged: (tags) {
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
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('localNewsCreate.buttons.submit'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.camera_alt),
            label: Text('localNewsCreate.buttons.addImage'.tr())),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_selectedImages[index].path),
                            width: 100, height: 100, fit: BoxFit.cover)),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                color: Colors.white, size: 16)),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
      ],
    );
  }
}

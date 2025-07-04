// lib/features/post/screens/create_post_screen.dart
// Bling App v0.4
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// [수정] 새로운 카테고리 시스템을 import 합니다.
import '../../../core/constants/app_categories.dart';
import '../../../core/models/post_category_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();

  // [수정] PostCategoryModel을 사용하여 선택된 카테고리를 관리합니다.
  PostCategoryModel? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // [수정] 앱이 시작될 때 첫 번째 카테고리를 기본값으로 설정합니다.
    if (AppCategories.postCategories.isNotEmpty) {
      _selectedCategory = AppCategories.postCategories.first;
    }
  }

  // ... (이미지 관련 함수 _pickImages, _removeImage, _uploadImages는 이전과 동일)
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('내용을 입력해주세요.')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("로그인이 필요합니다.");

      final imageUrls = await _uploadImages();
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final postData = {
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        'mediaUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        'mediaType': imageUrls.isNotEmpty ? 'image' : null,
        // [수정] 이제 이름이 아닌 categoryId를 저장합니다.
        'category': _selectedCategory!.categoryId,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'viewsCount': 0,
      };

      await FirebaseFirestore.instance.collection('posts').add(postData);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다')));
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('게시글 업로드 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 게시물 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // [수정] 카테고리 선택 메뉴에 이모지 추가
            DropdownButtonFormField<PostCategoryModel>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              // 각 아이템에 이모지와 텍스트를 함께 보여줍니다.
              items: AppCategories.postCategories.map((category) {
                return DropdownMenuItem<PostCategoryModel>(
                  value: category,
                  child: Row(
                    children: [
                      Text(category.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            // [추가] 선택된 카테고리의 설명을 힌트로 보여줍니다.
            if (_selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  _selectedCategory!.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
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
                    labelText: '내용을 입력하세요', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                    labelText: '태그 (쉼표로 구분)',
                    hintText: '예: 강아지, 무료나눔',
                    border: OutlineInputBorder())),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    // ... (이전과 동일)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.camera_alt),
          label: const Text('이미지 추가'),
        ),
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
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

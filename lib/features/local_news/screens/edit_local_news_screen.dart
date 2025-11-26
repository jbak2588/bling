// lib/features/local_news/views/edit_local_news_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ 새로 만든 공용 위젯을 import 합니다.
import 'package:bling_app/core/models/user_model.dart'; // ✅ UserModel import
import '../../shared/widgets/custom_tag_input_field.dart';

import '../../../core/constants/app_categories.dart';
import '../models/post_category_model.dart';
import '../models/post_model.dart';
// ✅ 태그 사전 + 추천 로직
import '../../../core/constants/app_tags.dart';
import '../utils/tag_recommender.dart';
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]

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
  // ✅ 추천 태그 상태
  List<String> _recommended = [];
  TagRecommenderController? _reco;

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
    // ✅ [롤백] restore category usage: initialize selected category from post.category
    final initialCategoryId = widget.post.category.isNotEmpty
        ? widget.post.category
        : AppCategories.postCategories.first.categoryId;
    _selectedCategory = AppCategories.postCategories.firstWhere(
      (c) => c.categoryId == initialCategoryId,
      orElse: () => AppCategories.postCategories.first,
    );

    // ✅ (선택) 기존 포스트의 태그를 초기 세팅했다면 그대로 두고, 추천 컨트롤러만 연결합니다.
    _reco = TagRecommenderController(
      titleController: _titleController,
      contentController: _contentController,
      excludeProvider: () => _tags.toSet(),
      onRecommend: (tags) {
        if (!mounted) return;
        setState(() => _recommended = tags);
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // ❌ 더 이상 사용하지 않으므로 dispose 호출도 제거합니다.
    // _tagInputController.dispose();
    _reco?.dispose();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final userId = user.uid;
    final postId = widget.post.id;

    List<String> downloadUrls = [];
    for (var image in _newSelectedImages) {
      final ref = FirebaseStorage.instance.ref(
          'post_images/$userId/$postId/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
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
      // ✅ [Fix] 사용자 최신 정보(위치) 가져오기 (데이터 보정용)
      final user = FirebaseAuth.instance.currentUser;
      UserModel? userModel;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) userModel = UserModel.fromFirestore(userDoc);
      }

      final newImageUrls = await _uploadImages();
      final finalImageUrls = [..._existingImageUrls, ...newImageUrls];

      // ✅ 태그 기본값 정책 정합: 비어있으면 'daily_life'로 저장

      final List<String> tagsToSave =
          _tags.isEmpty ? ['daily_life'] : List.of(_tags);

      // [추가] 검색 키워드 갱신
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: tagsToSave,
        description: _contentController.text,
      );

      final updatedData = {
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        'mediaUrl': finalImageUrls,
        'mediaType': finalImageUrls.isNotEmpty ? 'image' : null,
        'category': _selectedCategory!.categoryId,
        'tags': tagsToSave, // ✅ 비어있으면 daily_life 기본 태그 저장
        'searchIndex': searchKeywords, // [추가]
        'updatedAt': FieldValue.serverTimestamp(),
        // ✅ [Fix] 위치 정보 업데이트 (기존 데이터 없으면 유저 정보로 채움)
        'locationName': userModel?.locationName ?? widget.post.locationName,
        'locationParts': userModel?.locationParts ?? widget.post.locationParts,
        'geoPoint': userModel?.geoPoint ?? widget.post.geoPoint,
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('localNewsEdit.alerts.success'.tr())),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'localNewsEdit.alerts.failure'
                  .tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
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
      appBar: AppBar(
        title: Text('localNewsEdit.appBarTitle'.tr()),
        actions: [
          IconButton(
            tooltip: 'localNewsEdit.buttons.submit'.tr(),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check),
            onPressed: _isSubmitting ? null : _updatePost,
          ),
        ],
      ),
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
            // =========================
            // ✅ 실시간 추천 태그 블록 (선택된 태그 제외 후 비어있으면 숨김)
            // =========================
            for (final _ in [0])
              ...(() {
                final visibleRecs =
                    _recommended.where((id) => !_tags.contains(id)).toList();
                if (visibleRecs.isEmpty) return <Widget>[];
                return [
                  Text('localNewsCreate.form.recommendedTags'.tr(),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final id in visibleRecs)
                        ChoiceChip(
                          label: Text(
                            () {
                              final tag = AppTags.localNewsTags.firstWhere(
                                (t) => t.tagId == id,
                                orElse: () => const TagInfo(
                                    tagId: '', nameKey: '', descriptionKey: ''),
                              );
                              final name = (tag.nameKey.isNotEmpty)
                                  ? formatTagLabel(tag.tagId)
                                  : id;
                              return '${tag.emoji ?? ''} $name'.trim();
                            }(),
                          ),
                          selected: _tags.contains(id),
                          onSelected: (_) {
                            setState(() {
                              if (_tags.contains(id)) {
                                _tags.remove(id);
                              } else if (_tags.length < 3) {
                                _tags.add(id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('태그는 최대 3개까지 선택할 수 있어요.')),
                                );
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ];
              }()),

            // ✅ 교체된 공용 커스텀 태그 위젯을 사용합니다.
            CustomTagInputField(
              initialTags: _tags, // 초기 태그 목록을 전달합니다.
              hintText: 'tag_input.help'.tr(), // 다국어 힌트 텍스트
              onTagsChanged: (tags) {
                // 태그가 변경될 때마다 화면의 상태(_tags)를 업데이트합니다.
                setState(() {
                  _tags = tags;
                });
              },
              titleController: _titleController,
              autoCreateTitleTag: true,
              // [수정] AppTags.newsTags -> localNewsTags 매핑 + _recommended 결합
              suggestedTags: {
                ..._recommended,
                ...AppTags.localNewsTags.map((e) => e.tagId),
              }.toList(),
              maxTags: 3,
            ),

            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // ✅ 하단 고정 저장 바: SafeArea + Material(elevation)로 네비게이션바 위에 분리감 제공
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _updatePost,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('localNewsEdit.buttons.submit'.tr()),
              ),
            ),
          ),
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
          label: Text(
              '${'localNewsCreate.buttons.addImage'.tr()} ($totalImageCount/10)'),
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
                imageWidget =
                    Image.network(_existingImageUrls[index], fit: BoxFit.cover);
              } else {
                isExisting = false;
                imageIndex = index - existingImageCount;
                imageWidget = Image.file(
                    File(_newSelectedImages[imageIndex].path),
                    fit: BoxFit.cover);
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

// lib/features/local_news/screens/create_local_news_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_categories.dart';
import '../../shared/widgets/custom_tag_input_field.dart';
import '../../local_news/utils/tag_recommender.dart';
import '../../../core/utils/popups/snackbars.dart';
import '../data/local_news_repository.dart';
import '../../../core/models/user_model.dart';
// note: PostModel conversion is handled in repository/json path; no direct PostModel use here

class CreateLocalNewsScreen extends StatefulWidget {
  final UserModel user;
  const CreateLocalNewsScreen({super.key, required this.user});

  @override
  State<CreateLocalNewsScreen> createState() => _CreateLocalNewsScreenState();
}

class _CreateLocalNewsScreenState extends State<CreateLocalNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  List<String> _tags = [];
  List<String> _recommended = [];

  // categories use AppCategories.postCategories; each item has nameKey, categoryId, emoji
  var _selectedCategoryIndex = 0;

  DateTime? _eventDate;
  final _eventAddressController = TextEditingController();
  bool _eventExpanded = false;

  bool _isSaving = false;
  Timer? _debounce;

  final LocalNewsRepository _repository = LocalNewsRepository();
  UserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChangedForRecommend);
    _bodyController.addListener(_onTextChangedForRecommend);
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => _currentUserModel = UserModel.fromFirestore(doc));
      }
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _eventAddressController.dispose();
    super.dispose();
  }

  void _onTextChangedForRecommend() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final recs = recommendTagsFromText(
          title: _titleController.text,
          content: _bodyController.text,
        );
        if (mounted) setState(() => _recommended = recs);
      } catch (_) {
        // ignore
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked.take(5 - _images.length));
        });
      }
    } catch (e) {
      BArtSnackBar.showErrorSnackBar(
          title: '', message: 'localNewsCreate.imagePickFail'.tr());
    }
  }

  void _removeImageAt(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate ?? now),
    );
    if (time == null) return;

    setState(() {
      _eventDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (AppCategories.postCategories.isEmpty) {
      BArtSnackBar.showErrorSnackBar(
          title: '',
          message: 'localNewsCreate.validation.categoryRequired'.tr());
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentAuthUser = FirebaseAuth.instance.currentUser;
      if (currentAuthUser == null) throw Exception('User not authenticated');

      // upload images (keep using repository helper)
      List<File> files = _images.map((x) => File(x.path)).toList();
      final uploadedUrls =
          await _repository.uploadImages(files, currentAuthUser.uid);

      final tagsToSave = _tags.isEmpty ? ['daily_life'] : List.of(_tags);

      // Build map and write directly to Firestore so we can use server timestamps
      final newPostRef = FirebaseFirestore.instance.collection('posts').doc();
      final postData = {
        'userId': currentAuthUser.uid,
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category':
            AppCategories.postCategories[_selectedCategoryIndex].categoryId,
        'tags': tagsToSave,
        'mediaUrl': uploadedUrls.isNotEmpty ? uploadedUrls : null,
        'mediaType': uploadedUrls.isNotEmpty ? 'image' : null,
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
        // Use fetched user profile when available
        'locationName': _currentUserModel?.locationName,
        'locationParts': _currentUserModel?.locationParts,
        'geoPoint': _currentUserModel?.geoPoint,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'viewsCount': 0,
        'thanksCount': 0,
        if (_eventDate != null) 'eventDate': Timestamp.fromDate(_eventDate!),
        if (_eventAddressController.text.trim().isNotEmpty)
          'eventAddress': _eventAddressController.text.trim(),
      };

      await newPostRef.set(postData);

      // 2. ✅ [추가] 사용자의 postIds 배열에 새 게시글 ID 추가 (제품과 동일한 패턴)
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentAuthUser.uid)
            .update({
          'postIds': FieldValue.arrayUnion([newPostRef.id]),
        });
      } catch (e) {
        // users 문서가 없거나 update 권한이 없을 경우 merge로 안전하게 생성/병합 시도
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentAuthUser.uid)
              .set({
            'postIds': [newPostRef.id]
          }, SetOptions(merge: true));
        } catch (_) {
          // 실패해도 게시물 생성은 성공 상태로 유지; 로그는 필요시 추가
        }
      }

      if (!mounted) return;
      BArtSnackBar.showSuccessSnackBar(
          title: '', message: 'localNewsCreate.success'.tr());
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(
            title: '',
            message:
                'localNewsCreate.fail'.tr(namedArgs: {'error': e.toString()}));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImageScroller() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _images.length >= 5 ? null : _pickImages,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.add_a_photo_outlined,
                    color: Colors.grey.shade700),
              ),
            );
          }
          final xfile = _images[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(xfile.path),
                    width: 96, height: 96, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => _removeImageAt(index),
                  child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 16)),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('localNewsCreate.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 카테고리 선택
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryIndex,
                decoration: InputDecoration(
                  labelText: 'localNewsCreate.form.categoryLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: List.generate(AppCategories.postCategories.length, (i) {
                  final c = AppCategories.postCategories[i];
                  return DropdownMenuItem<int>(
                    value: i,
                    child: Row(children: [
                      Text(c.emoji),
                      const SizedBox(width: 8),
                      Text(c.nameKey.tr())
                    ]),
                  );
                }),
                onChanged: (v) =>
                    setState(() => _selectedCategoryIndex = v ?? 0),
                validator: (v) => v == null
                    ? 'localNewsCreate.validation.categoryRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 2. 제목
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'localNewsCreate.labels.title'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'localNewsCreate.validation.titleRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. 본문
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: 'localNewsCreate.labels.body'.tr(),
                  hintText: 'localNewsCreate.hints.body'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'localNewsCreate.validation.bodyRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 4. 사진 등록
              Text('localNewsCreate.form.photoSectionTitle'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildImageScroller(),
              const SizedBox(height: 16),

              // 5. 태그 등록
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              CustomTagInputField(
                initialTags: _tags,
                hintText: 'tag_input.addHint'.tr(),
                onTagsChanged: (tags) => setState(() => _tags = tags),
                maxTags: 5,
              ),
              const SizedBox(height: 8),

              // 추천 태그
              if (_recommended.isNotEmpty) ...[
                Text('localNewsCreate.form.recommendedTags'.tr(),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _recommended.map((t) {
                    final already = _tags.contains(t);
                    return ChoiceChip(
                      label: Text(t),
                      selected: already,
                      onSelected: (_) {
                        setState(() {
                          if (!already) _tags.add(t);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 6. 행사 정보 (ExpansionTile)
              ExpansionTile(
                initiallyExpanded: _eventExpanded,
                onExpansionChanged: (v) => setState(() => _eventExpanded = v),
                title: Text('localNewsCreate.labels.eventInfo'.tr()),
                children: [
                  ListTile(
                    title: Text(_eventDate == null
                        ? 'localNewsCreate.hints.eventDate'.tr()
                        : DateFormat.yMMMd().add_jm().format(_eventDate!)),
                    trailing: TextButton(
                        onPressed: _pickEventDate,
                        child: Text('common.select'.tr())),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: TextFormField(
                      controller: _eventAddressController,
                      decoration: InputDecoration(
                        labelText: 'localNewsCreate.labels.eventAddress'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('localNewsCreate.buttons.submit'.tr()),
          ),
        ),
      ),
    );
  }
}

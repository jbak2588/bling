// lib/features/local_news/screens/edit_local_news_screen.dart
import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_categories.dart';
import '../../shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import '../../local_news/utils/tag_recommender.dart';
import '../../../core/utils/popups/snackbars.dart';
import '../data/local_news_repository.dart';
import '../../../core/models/bling_location.dart';
import '../../shared/widgets/address_map_picker.dart';

class EditLocalNewsScreen extends StatefulWidget {
  final PostModel post;
  const EditLocalNewsScreen({super.key, required this.post});

  @override
  State<EditLocalNewsScreen> createState() => _EditLocalNewsScreenState();
}

class _EditLocalNewsScreenState extends State<EditLocalNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  // Images: existing URLs, newly added files, and deleted existing URLs tracker
  final List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  final List<String> _deletedImageUrls = [];
  final ImagePicker _picker = ImagePicker();

  List<String> _tags = [];
  List<String> _recommended = [];

  int _selectedCategoryIndex = 0;

  DateTime? _eventDate;
  BlingLocation? _eventLocation;
  // [UX] 생성/수정 화면 모두 행사 정보 섹션을 기본으로 펼쳐 둔다.
  bool _eventExpanded = true;
  // [UX] 지도/행사 정보는 항상 펼쳐두되,
  // 실제 지도 위젯 생성은 첫 프레임 이후로 지연합니다.
  bool _showEventLocationPicker = false;

  bool _isLoading = false;
  Timer? _debounce;

  final LocalNewsRepository _repository = LocalNewsRepository();

  @override
  void initState() {
    super.initState();
    // initialize fields from widget.post
    _titleController.text = widget.post.title ?? '';
    _bodyController.text = widget.post.body;
    _tags = List<String>.from(widget.post.tags);

    if (widget.post.mediaUrl != null) {
      _existingImageUrls.addAll(widget.post.mediaUrl!);
    }

    // init category index from post.category
    final idx = AppCategories.postCategories
        .indexWhere((c) => c.categoryId == widget.post.category);
    _selectedCategoryIndex = idx >= 0 ? idx : 0;

    _eventDate = widget.post.eventDate;
    _eventLocation = widget.post.eventLocation;
    // [UX] 행사 정보 섹션은 항상 펼쳐두고,
    // 지도 위젯 생성만 첫 프레임 이후로 지연합니다.
    _eventExpanded = true;

    // 첫 프레임 렌더가 끝난 후에만 실제 지도 위젯을 생성해서
    // 초기 진입 시 프레임 드랍을 완화합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _showEventLocationPicker = true;
      });
    });

    _titleController.addListener(_onTextChangedForRecommend);
    _bodyController.addListener(_onTextChangedForRecommend);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onTextChangedForRecommend() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      try {
        final recs = recommendTagsFromText(
          title: _titleController.text,
          content: _bodyController.text,
        );
        if (mounted) setState(() => _recommended = recs);
      } catch (_) {}
    });
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isNotEmpty) {
        setState(() {
          final available = 5 - (_existingImageUrls.length + _newImages.length);
          if (available > 0) _newImages.addAll(picked.take(available));
        });
      }
    } catch (e) {
      BArtSnackBar.showErrorSnackBar(
          title: '', message: 'localNewsCreate.imagePickFail'.tr());
    }
  }

  void _removeExistingImageAt(int index) {
    setState(() {
      final url = _existingImageUrls.removeAt(index);
      _deletedImageUrls.add(url);
    });
  }

  void _removeNewImageAt(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 1) upload new images if any
      List<String> uploadedUrls = [];
      if (_newImages.isNotEmpty) {
        final files = _newImages.map((x) => File(x.path)).toList();
        uploadedUrls = await _repository.uploadImages(files, user.uid);
      }

      // 2) final images = existing + uploaded
      final finalImageList = [..._existingImageUrls, ...uploadedUrls];

      // 3) prepare tags
      final tagsToSave = _tags.isEmpty ? ['daily_life'] : List.of(_tags);

      // 4) prepare update map (repository will set updatedAt)
      final Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category':
            AppCategories.postCategories[_selectedCategoryIndex].categoryId,
        'tags': tagsToSave,
        'mediaUrl': finalImageList,
        'mediaType': finalImageList.isNotEmpty ? 'image' : null,
      };

      if (_eventDate != null) {
        data['eventDate'] = Timestamp.fromDate(_eventDate!);
      }

      // Persist structured eventLocation when available; keep legacy
      // `eventAddress` for backward compatibility.
      if (_eventLocation != null) {
        data['eventLocation'] = _eventLocation!.toJson();
        data['eventAddress'] =
            _eventLocation!.shortLabel ?? _eventLocation!.mainAddress;
      } else if (widget.post.eventAddress != null &&
          widget.post.eventAddress!.trim().isNotEmpty) {
        data['eventAddress'] = widget.post.eventAddress!.trim();
      }

      await _repository.updatePost(widget.post.id, data);

      // ✅ 편집 저장 후: 소유자 users.{uid}.postIds에 해당 postId가 없으면 추가
      try {
        final ownerRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.post.userId);
        final ownerSnap = await ownerRef.get();
        final ownerData = ownerSnap.exists ? ownerSnap.data() : null;
        final List<dynamic> postIdsRaw =
            ownerData != null && ownerData['postIds'] != null
                ? List<dynamic>.from(ownerData['postIds'])
                : [];
        final contains = postIdsRaw.contains(widget.post.id);
        if (!contains) {
          await ownerRef.update({
            'postIds': FieldValue.arrayUnion([widget.post.id])
          });
        }
      } catch (e) {
        // 실패해도 편집 동작에는 영향 없음. 필요시 로깅 추가 가능.
      }

      if (!mounted) return;
      BArtSnackBar.showSuccessSnackBar(
          title: '', message: 'localNewsEdit.success'.tr());
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(
            title: '',
            message:
                'localNewsEdit.fail'.tr(namedArgs: {'error': e.toString()}));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImageScroller() {
    final total = _existingImageUrls.length + _newImages.length;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          if (index == total) {
            return GestureDetector(
              onTap: (_existingImageUrls.length + _newImages.length) >= 5
                  ? null
                  : _pickImages,
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

          Widget img;
          bool isExisting = index < _existingImageUrls.length;
          int imgIndex = isExisting ? index : index - _existingImageUrls.length;

          if (isExisting) {
            img = Image.network(_existingImageUrls[imgIndex],
                width: 96, height: 96, fit: BoxFit.cover);
          } else {
            img = Image.file(File(_newImages[imgIndex].path),
                width: 96, height: 96, fit: BoxFit.cover);
          }

          return Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: img),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    if (isExisting) {
                      _removeExistingImageAt(imgIndex);
                    } else {
                      _removeNewImageAt(imgIndex);
                    }
                  },
                  child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );
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

    setState(() => _eventDate =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('localNewsEdit.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
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
              // 1. category
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryIndex,
                decoration: InputDecoration(
                    labelText: 'localNewsCreate.form.categoryLabel'.tr(),
                    border: const OutlineInputBorder()),
                items: List.generate(AppCategories.postCategories.length, (i) {
                  final c = AppCategories.postCategories[i];
                  return DropdownMenuItem<int>(
                      value: i,
                      child: Row(children: [
                        Text(c.emoji),
                        const SizedBox(width: 8),
                        Text(c.nameKey.tr())
                      ]));
                }),
                onChanged: (v) =>
                    setState(() => _selectedCategoryIndex = v ?? 0),
                validator: (v) => v == null
                    ? 'localNewsCreate.validation.categoryRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 2. title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'localNewsCreate.labels.title'.tr(),
                    border: const OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'localNewsCreate.validation.titleRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. body
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                    labelText: 'localNewsCreate.labels.body'.tr(),
                    hintText: 'localNewsCreate.hints.body'.tr(),
                    border: const OutlineInputBorder()),
                maxLines: 10,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'localNewsCreate.validation.bodyRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 4. images
              Text('localNewsCreate.form.photoSectionTitle'.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildImageScroller(),
              const SizedBox(height: 16),

              // 5. tags
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              CustomTagInputField(
                  initialTags: _tags,
                  hintText: 'tag_input.addHint'.tr(),
                  onTagsChanged: (tags) => setState(() => _tags = tags),
                  maxTags: 5),
              const SizedBox(height: 8),
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
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (!already) _tags.add(t);
                          } else {
                            _tags.remove(t);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // 6. event info (optional, always expanded by default)
              ExpansionTile(
                initiallyExpanded: _eventExpanded,
                onExpansionChanged: (v) => setState(() => _eventExpanded = v),
                // 생성/수정 모두 동일하게 “행사 정보 (옵션)”으로 표시
                title: Text(
                  '${'localNewsCreate.labels.eventInfo'.tr()} ${'common.optionalSuffix'.tr()}',
                ),
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
                    child: _showEventLocationPicker
                        ? AddressMapPicker(
                            initialValue: _eventLocation,
                            // 편집 시에는 기존 이벤트 위치 또는 글의 geoPoint를 활용해서
                            // AddressMapPicker가 불필요한 현재 위치 조회를 하지 않도록 함.
                            userGeoPoint: _eventLocation?.geoPoint ??
                                widget.post.eventLocation?.geoPoint ??
                                widget.post.geoPoint,
                            labelText:
                                'localNewsCreate.labels.eventAddress'.tr(),
                            hintText: 'localNewsCreate.hints.eventAddress'.tr(),
                            onChanged: (loc) =>
                                setState(() => _eventLocation = loc),
                          )
                        : const SizedBox(
                            height: 180,
                            child: Center(
                              child: CircularProgressIndicator(),
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
            onPressed: _isLoading ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isLoading
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('localNewsEdit.buttons.save'.tr()),
          ),
        ),
      ),
    );
  }
}

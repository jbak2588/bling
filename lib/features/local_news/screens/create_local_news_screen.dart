// lib/features/local_news/screens/create_local_news_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart'; // 이미지 ID 생성을 위해 추가
// ✅ 공용 텍스트 입력 기반 태그 위젯
import '../../shared/widgets/custom_tag_input_field.dart';

// ❌ [태그 시스템] 기존 카테고리 import 제거
// import '../../../core/constants/app_categories.dart';
// import '../models/post_category_model.dart';

// ✅ [태그 시스템] 태그 사전 + 추천 로직
import '../../../core/constants/app_tags.dart';
import '../utils/tag_recommender.dart';

// ❌ [태그 시스템] 기존 자유 태그 입력 필드 import 제거
// import '../../shared/widgets/custom_tag_input_field.dart';

import '../../../core/models/user_model.dart';
// import '../models/post_model.dart'; // PostModel은 그대로 사용 (내부 필드 변경됨)

class CreateLocalNewsScreen extends StatefulWidget {
  const CreateLocalNewsScreen({super.key});

  @override
  State<CreateLocalNewsScreen> createState() => _CreateLocalNewsScreenState();
}

class _CreateLocalNewsScreenState extends State<CreateLocalNewsScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼 유효성 검사를 위한 키
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // ✅ [태그 시스템] 텍스트 입력 기반 태그 목록
  final List<String> _tags = []; // 예: ['power_outage', 'question']
  // ✅ 추천 태그 상태 및 컨트롤러
  List<String> _recommended = [];
  TagRecommenderController? _reco;

  // ❌ [태그 시스템] _selectedCategory 상태 변수 제거
  // PostCategoryModel? _selectedCategory;

  // ✅ [태그 시스템] 가이드형 필드용 컨트롤러 및 상태 변수 추가
  final _eventLocationController = TextEditingController();
  bool _showGuidedFields = false; // 가이드형 필드 표시 여부

  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();
  bool _isSaving = false;
  UserModel? _currentUserModel; // 현재 사용자 정보 (위치 등)

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    // ✅ 제목/본문 실시간 추천 연결 (디바운스 300ms)
    _reco = TagRecommenderController(
      titleController: _titleController,
      contentController: _contentController,
      // 이미 선택된 태그는 추천에서 제외
      excludeProvider: () => _tags.toSet(),
      onRecommend: (tags) {
        if (!mounted) return;
        setState(() {
          _recommended = tags;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _eventLocationController.dispose(); // ✅ 가이드형 필드 컨트롤러 해제
    _reco?.dispose();
    super.dispose();
  }

  // 현재 사용자 정보 가져오기 (위치 정보 사용)
  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _currentUserModel = UserModel.fromFirestore(doc);
        });
      }
    }
  }

  // 이미지 업로드 로직 (Firestore Storage)
  Future<List<String>> _uploadImages(List<XFile> images, String postId) async {
    final storageRef = FirebaseStorage.instance.ref();
    List<String> downloadUrls = [];
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (var imageFile in images) {
      final fileId = const Uuid().v4();
      // ✅ 규칙 준수: post_images/{userId}/{postId}/...
      final imageRef =
          storageRef.child('post_images/$userId/$postId/$fileId.jpg');
      try {
        final uploadTask = await imageRef.putFile(File(imageFile.path));
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Image upload error: $e');
        // 에러 발생 시 사용자에게 알림 (옵션)
      }
    }
    return downloadUrls;
  }

  // 게시글 저장 로직
  Future<void> _savePost() async {
    // 1. 폼 유효성 검사 (제목, 본문)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ✅ [태그 시스템] 2. 태그 선택 유효성 검사 → 선택은 선택사항, 비어 있으면 'etc'(일상/기타)로 저장
    final List<String> tagsToSave =
        _tags.isEmpty ? ['daily_life'] : List.of(_tags);

    if (_currentUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('main.errors.userNotFound'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final newPostRef = FirebaseFirestore.instance.collection('posts').doc();
      final postId = newPostRef.id;

      // 이미지 업로드
      final imageUrls = await _uploadImages(_selectedImages, postId);

      // ✅ [태그 시스템] 가이드형 필드 데이터 준비
      final eventLocation =
          _showGuidedFields ? _eventLocationController.text.trim() : null;
      // TODO: eventTime (Timestamp)은 별도 Date/Time Picker UI 구현 필요
      final Timestamp? eventTime = null; // 임시로 null 처리

      // PostModel 데이터 생성 (Map)
      final postData = {
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'body': _contentController.text.trim(),
        // ❌ [태그 시스템] category 제거
        // 'category': _selectedCategory!.categoryId,
        // ✅ [태그 시스템] tags (Tag ID 리스트) 저장 - 비었으면 'etc' 기본값
        'tags': tagsToSave,
        'mediaUrl': imageUrls,
        'mediaType': imageUrls.isNotEmpty ? 'image' : null,
        // 사용자 위치 정보 사용
        'locationName': _currentUserModel!.locationName,
        'locationParts': _currentUserModel!.locationParts,
        'geoPoint': _currentUserModel!.geoPoint,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'viewsCount': 0,
        'thanksCount': 0,
        // ✅ [태그 시스템] 가이드형 필드 저장 (null이 아닐 경우)
        if (eventLocation != null && eventLocation.isNotEmpty)
          'eventLocation': eventLocation,
        if (eventTime != null) 'eventTime': eventTime,
      };

      // Firestore에 문서 생성
      await newPostRef.set(postData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('localNewsCreate.success'.tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Post save error: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'localNewsCreate.fail'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('localNewsCreate.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _savePost,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- ❌ [태그 시스템] 기존 카테고리 드롭다운 제거 ---
                  // DropdownButtonFormField<PostCategoryModel>( ... )

                  // --- ✅ [태그 시스템] 태그 선택/가이드형 필드 UI는 아래로 이동 ---

                  // --- 기존 제목/본문 입력 ---
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'localNewsCreate.labels.title'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    // ✅ [UI 개선] 제목 필수 입력
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'localNewsCreate.validation.titleRequired'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'localNewsCreate.labels.body'.tr(),
                      hintText: 'localNewsCreate.hints.body'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'localNewsCreate.validation.bodyRequired'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // =========================
                  // ✅ 텍스트 입력 기반 태그 캡처
                  // =========================
                  Text(
                    'localNewsCreate.labels.tags'.tr(), // '태그'
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  CustomTagInputField(
                    hintText: 'localNewsCreate.form.tagsHint'.tr(),
                    initialTags: _tags,
                    onTagsChanged: (tags) {
                      setState(() {
                        _tags
                          ..clear()
                          ..addAll(tags);
                        _updateGuidedFieldsVisibility();
                      });
                    },
                    titleController: _titleController, // 제목으로부터 제안
                    autoCreateTitleTag: true,
                    allowEmptyTags: true, // 사용자가 원치 않으면 비워둘 수 있음
                    suggestedTags: _recommended,
                    whitelist:
                        AppTags.localNewsTags.map((t) => t.tagId).toSet(),
                    maxTags: 3,
                  ),

                  // --- 기존 이미지 첨부 ---
                  _buildImagePicker(),

                  // --- ✅ [태그 시스템] 가이드형 필드 UI (조건부 표시) ---
                  if (_showGuidedFields) _buildGuidedFields(),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // ✅ [태그 시스템] 가이드형 필드 표시 여부 업데이트 함수
  void _updateGuidedFieldsVisibility() {
    // 선택된 태그 ID 목록(_tags)을 기반으로
    // AppTags.localNewsTags에서 해당 TagInfo를 찾음
    final selectedTagsInfo =
        AppTags.localNewsTags.where((tag) => _tags.contains(tag.tagId));

    // 선택된 태그 중 하나라도 guidedFields를 가지고 있는지 확인
    final bool shouldShow = selectedTagsInfo
        .any((tag) => tag.guidedFields != null && tag.guidedFields!.isNotEmpty);

    setState(() {
      _showGuidedFields = shouldShow;
      // 가이드형 필드가 숨겨질 때 컨트롤러 텍스트 초기화 (선택 사항)
      if (!shouldShow) {
        _eventLocationController.clear();
        // _eventTimeController.clear(); // TODO
      }
    });
  }

  // ✅ [태그 시스템] 가이드형 필드 UI 위젯
  Widget _buildGuidedFields() {
    // TODO: 선택된 태그에 따라 필요한 필드만 동적으로 생성 (현재는 eventLocation만 예시로 구현)
    // 예: tag.guidedFields.contains('eventLocation')

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 24),
        Text(
          'localNewsCreate.labels.guidedTitle'.tr(), // '추가 정보 (선택)' (다국어 키)
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _eventLocationController,
          decoration: InputDecoration(
            labelText: 'localNewsCreate.labels.eventLocation'
                .tr(), // '이벤트/발생 장소' (다국어 키)
            hintText: 'localNewsCreate.hints.eventLocation'
                .tr(), // '예: Jl. Sudirman 123' (다국어 키)
            border: const OutlineInputBorder(),
          ),
        ),
        // TODO: eventTime을 위한 Date/Time Picker 필드 추가
        // TextFormField( ... controller: _eventTimeController ... )
        const SizedBox(height: 16),
      ],
    );
  }

  // --- 기존 이미지 피커 로직 (_pickImages, _removeImage) ---
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      // 최대 5장 제한
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('localNewsCreate.validation.imageMaxLimit'
                .tr())), // 다국어 키 추가 필요
      );
      return;
    }
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          if (_selectedImages.length > 5) {
            _selectedImages.removeRange(5, _selectedImages.length); // 5장 초과분 제거
          }
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
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

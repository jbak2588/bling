/// ============================================================================
/// Bling DocHeader
/// Module        : Jobs
/// File          : lib/features/jobs/screens/create_quick_gig_screen.dart
/// Purpose       : '단순/일회성 도움' (quick_gig) 전용 간편 등록 폼.
///
/// 2025-10-31 (작업 34, 35):
///   - '하이브리드 기획안' 5단계: 'quick_gig' 전용 폼으로 신규 생성.
///   - 'AppJobCategories.getCategoriesByType(JobType.quickGig)'를 호출하여
///     '오토바이 배송', '짐 옮기기' 등 'quick_gig' 카테고리만 표시.
///   - '근무 기간/시간' 필드를 제거하고 '총 보수(Total Pay)'만 입력받도록 UI 간소화.
///   - 저장 시 'jobType: "quick_gig"', 'salaryType: "total"' 자동 설정.
///   - (작업 35) 'ImageUploadHelper' 의존성 제거 및 'create_job_screen'의
///     이미지 업로드 로직을 이식하여 컴파일 에러 수정.
/// ============================================================================
library;
// (파일 내용...)

// lib/features/jobs/screens/create_quick_gig_screen.dart
// lib/features/jobs/screens/create_quick_gig_screen.dart

import 'dart:io';

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constants/job_categories.dart';
import 'package:bling_app/core/utils/search_helper.dart';

// ✅ [추가] 공용 태그 위젯 import
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateQuickGigScreen extends StatefulWidget {
  final UserModel userModel;
  final JobModel? jobToEdit;

  const CreateQuickGigScreen(
      {super.key, required this.userModel, this.jobToEdit});

  @override
  State<CreateQuickGigScreen> createState() => _CreateQuickGigScreenState();
}

class _CreateQuickGigScreenState extends State<CreateQuickGigScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryAmountController;
  late TextEditingController _locationController;

  List<JobCategory> _categories = [];
  JobCategory? _selectedCategory;

  bool _isSalaryNegotiable = false;

  final List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];

  // ✅ [추가] 태그 목록 상태 변수
  List<String> _tags = [];

  bool _isSaving = false;

  final JobRepository _jobRepository = JobRepository();
  final ImagePicker _picker = ImagePicker();

  bool get _isEditMode => widget.jobToEdit != null;

  @override
  void initState() {
    super.initState();
    _categories = AppJobCategories.getCategoriesByType(JobType.quickGig);

    if (_isEditMode) {
      final job = widget.jobToEdit!;
      _titleController = TextEditingController(text: job.title);
      _descriptionController = TextEditingController(text: job.description);
      _salaryAmountController =
          TextEditingController(text: job.salaryAmount?.toString() ?? '');
      _locationController = TextEditingController(text: job.locationName ?? '');
      _isSalaryNegotiable = job.isSalaryNegotiable;

      try {
        _selectedCategory = _categories.firstWhere((c) => c.id == job.category);
      } catch (_) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      }

      if (job.imageUrls != null) {
        _existingImageUrls = List.from(job.imageUrls!);
      }

      // ✅ [추가] 수정 시 기존 태그 불러오기
      try {
        _tags = List<String>.from(job.tags);
      } catch (_) {
        _tags = [];
      }
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _salaryAmountController = TextEditingController();
      _locationController =
          TextEditingController(text: widget.userModel.locationName ?? '');
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryAmountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final currentCount = _existingImageUrls.length + _newImages.length;
    if (currentCount >= 10) return;

    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.take(10 - currentCount));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  Future<List<String>> _uploadNewImages(String uid) async {
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (XFile imageFile in _newImages) {
      try {
        final fileId = const Uuid().v4();
        final imageRef = storageRef.child('job_images/$uid/image_$fileId.jpg');

        final uploadTask = await imageRef.putFile(File(imageFile.path));
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Image upload error: $e');
      }
    }
    return downloadUrls;
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('jobs.form.validationError'.tr())),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final userModel = widget.userModel;

      List<String> finalImageUrls = List.from(_existingImageUrls);
      final newUrls = await _uploadNewImages(userModel.uid);
      finalImageUrls.addAll(newUrls);

      // ✅ [추가] 검색어 생성 시 태그 포함
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags, // 태그 전달
      );

      final jobData = JobModel(
        id: _isEditMode ? widget.jobToEdit!.id : '',
        userId: userModel.uid,
        jobType: JobType.quickGig.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!.id,
        salaryType: 'total',
        salaryAmount: (double.tryParse(_salaryAmountController.text)?.toInt()),
        isSalaryNegotiable: _isSalaryNegotiable,
        workPeriod: 'one_time',
        workHours: null,
        imageUrls: finalImageUrls,
        locationName: _locationController.text.trim(),
        locationParts: _isEditMode
            ? widget.jobToEdit!.locationParts
            : userModel.locationParts,
        geoPoint: _isEditMode ? widget.jobToEdit!.geoPoint : userModel.geoPoint,
        createdAt: _isEditMode ? widget.jobToEdit!.createdAt : Timestamp.now(),
        trustLevelRequired:
            _isEditMode ? widget.jobToEdit!.trustLevelRequired : 'normal',

        // ✅ [추가] 태그 및 검색 인덱스 저장
        tags: _tags,
        searchIndex: searchKeywords,

        viewsCount: _isEditMode ? widget.jobToEdit!.viewsCount : 0,
        likesCount: _isEditMode ? widget.jobToEdit!.likesCount : 0,
      );

      if (_isEditMode) {
        await _jobRepository.updateJob(jobData);
      } else {
        await _jobRepository.createJob(jobData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode
                  ? 'jobs.form.updateSuccess'.tr()
                  : 'jobs.form.saveSuccess'.tr())),
        );
        Navigator.of(context).pop();
        if (!_isEditMode) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('jobs.form.saveError'
                  .tr(namedArgs: {'error': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'jobs.form.editTitle'.tr()
            : 'jobs.form.titleQuickGig'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveJob,
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                _buildTitleInput(),
                const SizedBox(height: 16),
                _buildTotalPayInput(),
                const SizedBox(height: 16),
                _buildLocationInput(),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildDescriptionInput(),

                // ✅ [추가] 태그 입력 위젯
                const SizedBox(height: 24),
                CustomTagInputField(
                  initialTags: _tags,
                  hintText: 'marketplace.registration.tagsHint'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),
                // 태그 입력 필드 하단 여백 확보
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // --- 위젯 빌더 함수들 (기존과 동일하므로 생략하지 않고 문맥상 필요한 부분만 포함) ---

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<JobCategory>(
      initialValue: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem<JobCategory>(
          value: category,
          child: Row(
            children: [
              Text(category.icon),
              const SizedBox(width: 8),
              Text(category.nameKey.tr()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
      decoration: InputDecoration(
        labelText: 'jobs.form.categoryLabel'.tr(),
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null ? 'jobs.form.categoryValidator'.tr() : null,
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'jobs.form.titleLabel'.tr(),
        hintText: 'jobs.form.titleHintQuickGig'.tr(),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'jobs.form.titleValidator'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildTotalPayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _salaryAmountController,
          decoration: InputDecoration(
            labelText: 'jobs.form.totalPayLabel'.tr(),
            hintText: 'jobs.form.totalPayHint'.tr(),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty ||
                (double.tryParse(value) ?? 0) <= 0) {
              return 'jobs.form.totalPayValidator'.tr();
            }
            return null;
          },
        ),
        CheckboxListTile(
          title: Text('jobs.form.negotiable'.tr()),
          value: _isSalaryNegotiable,
          onChanged: (value) {
            setState(() {
              _isSalaryNegotiable = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildLocationInput() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'jobs.form.locationLabel'.tr(),
        hintText: 'jobs.form.locationHint'.tr(),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'jobs.form.locationValidator'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'jobs.form.descriptionLabel'.tr(),
        hintText: 'jobs.form.descriptionHintQuickGig'.tr(),
        border: const OutlineInputBorder(),
      ),
      maxLines: 8,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'jobs.form.descriptionValidator'.tr();
        }
        return null;
      },
    );
  }

  // _buildImagePicker()는 기존 코드와 동일
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('jobs.form.imageLabel'.tr(),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._existingImageUrls.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(entry.value,
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(entry.key),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ..._newImages.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(entry.value.path),
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeNewImage(entry.key),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if ((_existingImageUrls.length + _newImages.length) < 10)
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400)),
                    child: Icon(Icons.add_a_photo_outlined,
                        color: Colors.grey.shade600),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}

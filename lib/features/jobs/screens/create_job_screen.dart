// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 생성, 이미지 업로드, 급여/근무기간/카테고리 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 게시글 생성, 이미지 업로드, 급여/근무기간/카테고리 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(게시글 부스트, 조회수, 지원수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// lib/features/jobs/screens/create_job_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 구인/구직 게시글 생성, 이미지 업로드, 급여/근무기간/카테고리 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 게시글 생성, 이미지 업로드, 급여/근무기간/카테고리 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(게시글 부스트, 조회수, 지원수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
/// 2025-10-31 (작업 33):
///   - '하이브리드 기획안' 4단계: '정규직/파트타임' (regular) 전용 폼으로 수정.
///   - 'jobType' 파라미터를 생성자(constructor)로 받음.
///   - 카테고리 드롭다운이 'AppJobCategories.getCategoriesByType(JobType.regular)'를
///     호출하여 'regular' 카테고리만 표시하도록 수정.
///   - 저장 시 'jobType: "regular"' 필드 포함.
/// ============================================================================
library;
// (파일 내용...)
// lib/features/jobs/screens/create_job_screen.dart

import 'dart:io';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/job_categories.dart';
import 'package:bling_app/core/utils/search_helper.dart';

// ✅ [추가] 공용 태그 위젯 import
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateJobScreen extends StatefulWidget {
  final UserModel userModel;
  final JobType jobType;
  final JobModel? jobToEdit;

  final String? initialCompanyName;
  final String? initialLocation;
  final GeoPoint? initialGeoPoint;
  final Map<String, dynamic>? initialLocationParts;

  const CreateJobScreen({
    super.key,
    required this.userModel,
    this.jobType = JobType.regular,
    this.jobToEdit,
    this.initialCompanyName,
    this.initialLocation,
    this.initialGeoPoint,
    this.initialLocationParts,
  });

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _workHoursController;
  late TextEditingController _salaryAmountController;

  String? _selectedWorkPeriod;
  String? _selectedSalaryType;
  bool _isSalaryNegotiable = false;

  bool _isSaving = false;
  List<JobCategory> _categories = [];
  JobCategory? _selectedCategory;

  final List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];

  // ✅ [추가] 태그 목록 상태 변수
  List<String> _tags = [];

  final ImagePicker _picker = ImagePicker();
  final JobRepository _repository = JobRepository();

  bool get _isEditMode => widget.jobToEdit != null;

  @override
  void initState() {
    super.initState();
    _categories = AppJobCategories.getCategoriesByType(widget.jobType);

    if (_isEditMode) {
      final job = widget.jobToEdit!;
      _titleController = TextEditingController(text: job.title);
      _descriptionController = TextEditingController(text: job.description);
      _workHoursController = TextEditingController(text: job.workHours);
      _salaryAmountController =
          TextEditingController(text: job.salaryAmount?.toString() ?? '');
      _selectedWorkPeriod = job.workPeriod;
      _selectedSalaryType = job.salaryType;
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
      _titleController = TextEditingController(
          text: (widget.initialCompanyName != null &&
                  widget.initialCompanyName!.trim().isNotEmpty)
              ? widget.initialCompanyName!.trim()
              : '');
      _descriptionController = TextEditingController();
      _workHoursController = TextEditingController();
      _salaryAmountController = TextEditingController();
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _workHoursController.dispose();
    _salaryAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final currentCount = _existingImageUrls.length + _newImages.length;
    if (currentCount >= 5) return;

    final pickedFiles =
        await _picker.pickMultiImage(imageQuality: 70, limit: 5 - currentCount);

    if (pickedFiles.isNotEmpty) {
      setState(() => _newImages.addAll(pickedFiles));
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    // Fetch freshest user profile to prefer its location fields for new posts
    UserModel? freshUserModel;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        try {
          freshUserModel = UserModel.fromFirestore(userDoc);
        } catch (_) {
          freshUserModel = null;
        }
      }
    } catch (_) {
      freshUserModel = null;
    }

    try {
      List<String> finalImageUrls = List.from(_existingImageUrls);

      if (_newImages.isNotEmpty) {
        for (var imageFile in _newImages) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('job_images/${user.uid}/$fileName');
          await ref.putFile(File(imageFile.path));
          finalImageUrls.add(await ref.getDownloadURL());
        }
      }

      // ✅ [추가] 검색 키워드 생성 시 태그 포함
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags, // 태그 전달
      );

      final jobData = JobModel(
        id: _isEditMode ? widget.jobToEdit!.id : '',
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!.id,
        // For edit mode keep existing stored values. For new posts prefer freshly-read user profile, fallback to initial/widget values.
        locationName: _isEditMode
            ? widget.jobToEdit!.locationName
            : (freshUserModel?.locationName ??
                widget.initialLocation ??
                widget.userModel.locationName),
        locationParts: _isEditMode
            ? widget.jobToEdit!.locationParts
            : (freshUserModel?.locationParts ??
                widget.initialLocationParts ??
                widget.userModel.locationParts),
        geoPoint: _isEditMode
            ? widget.jobToEdit!.geoPoint
            : (freshUserModel?.geoPoint ??
                widget.initialGeoPoint ??
                widget.userModel.geoPoint),

        createdAt: _isEditMode ? widget.jobToEdit!.createdAt : Timestamp.now(),
        salaryType: _selectedSalaryType,
        salaryAmount: int.tryParse(_salaryAmountController.text),
        isSalaryNegotiable: _isSalaryNegotiable,
        workPeriod: _selectedWorkPeriod,
        workHours: _workHoursController.text.trim(),
        imageUrls: finalImageUrls,
        jobType: widget.jobType.name,

        // ✅ [추가] 태그 및 검색 인덱스 저장
        tags: _tags,
        searchIndex: searchKeywords,

        viewsCount: _isEditMode ? widget.jobToEdit!.viewsCount : 0,
        likesCount: _isEditMode ? widget.jobToEdit!.likesCount : 0,
        trustLevelRequired:
            _isEditMode ? widget.jobToEdit!.trustLevelRequired : 'normal',
      );

      if (_isEditMode) {
        await _repository.updateJob(jobData);
      } else {
        await _repository.createJob(jobData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'jobs.form.updateSuccess'.tr()
                : 'jobs.form.submitSuccess'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('jobs.form.submitFail'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'jobs.form.editTitle'.tr()
            : 'jobs.form.titleRegular'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _submitJob,
              child: Text(_isEditMode
                  ? 'jobs.form.update'.tr()
                  : 'jobs.form.submit'.tr()),
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
                DropdownButtonFormField<JobCategory>(
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'jobs.form.categoryValidator'.tr() : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.titleLabel'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'jobs.form.titleValidator'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Text('jobs.form.salaryInfoTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _selectedSalaryType,
                  hint: Text('jobs.form.salaryTypeHint'.tr()),
                  items: ['hourly', 'daily', 'monthly', 'per_case']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text('jobs.salaryTypes.$value'.tr()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSalaryType = val),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _salaryAmountController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.salaryAmountLabel'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                CheckboxListTile(
                  title: Text('jobs.form.salaryNegotiable'.tr()),
                  value: _isSalaryNegotiable,
                  onChanged: (val) =>
                      setState(() => _isSalaryNegotiable = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                Text('jobs.form.workInfoTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('jobs.form.workPeriodTitle'.tr(),
                    style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8.0,
                  children:
                      ['short_term', 'mid_term', 'long_term'].map((period) {
                    return ChoiceChip(
                      label: Text('jobs.workPeriods.$period'.tr()),
                      selected: _selectedWorkPeriod == period,
                      onSelected: (selected) {
                        setState(() {
                          _selectedWorkPeriod = selected ? period : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _workHoursController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.workHoursLabel'.tr(),
                    hintText: 'jobs.form.workHoursHint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                Text('jobs.form.imageSectionTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._existingImageUrls.asMap().entries.map((entry) {
                        final index = entry.key;
                        final url = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(url,
                                    width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(index),
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
                        final index = entry.key;
                        final xfile = entry.value;
                        return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(File(xfile.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeNewImage(index),
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
                            ));
                      }),
                      if ((_existingImageUrls.length + _newImages.length) < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey.shade400)),
                            child: Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.descriptionLabel'.tr(),
                    hintText: 'jobs.form.descriptionHint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'jobs.form.descriptionValidator'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ✅ [추가] 태그 입력 위젯 (ProductRegistrationScreen과 동일한 위치 배치)
                CustomTagInputField(
                  initialTags: _tags, // 수정 시 기존 태그 전달
                  hintText: 'tag_input.help'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),

                // 태그 입력 필드 밑 여백 확보
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
}

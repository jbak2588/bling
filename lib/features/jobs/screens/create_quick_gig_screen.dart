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
// (신규 파일)

import 'dart:io';

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/data/job_repository.dart';
import 'package:bling_app/features/jobs/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// ✅ [작업 35] 1. 'uuid' import (이미지 파일명 생성용)
import 'package:uuid/uuid.dart';
// ✅ [작업 35] 2. Firebase Storage import (직접 업로드용)
import 'package:firebase_storage/firebase_storage.dart';

// ✅ [작업 31] 1. 중앙 카테고리 및 JobType import
import '../constants/job_categories.dart';

/// '단순/일회성 도움' (quick_gig) 전용 등록 폼
class CreateQuickGigScreen extends StatefulWidget {
  final UserModel userModel;

  const CreateQuickGigScreen({super.key, required this.userModel});

  @override
  State<CreateQuickGigScreen> createState() => _CreateQuickGigScreenState();
}

class _CreateQuickGigScreenState extends State<CreateQuickGigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryAmountController = TextEditingController();
  final _locationController = TextEditingController();

  // ✅ 'quick_gig' 타입의 카테고리만 로드
  List<JobCategory> _categories = [];
  JobCategory? _selectedCategory;

  bool _isSalaryNegotiable = false;
  final List<XFile> _selectedImages = [];
  bool _isSaving = false;

  final JobRepository _jobRepository = JobRepository();
  final ImagePicker _picker = ImagePicker(); // ✅ ImagePicker 직접 사용

  @override
  void initState() {
    super.initState();
    // ✅ 'quick_gig' 타입의 카테고리만 로드
    _categories = AppJobCategories.getCategoriesByType(JobType.quickGig);
    _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    // 위치 컨트롤러 초기화
    _locationController.text = widget.userModel.locationName ?? '';
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
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages
            .addAll(pickedFiles.take(10 - _selectedImages.length)); // 최대 10장
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(String docId) async {
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (XFile imageFile in _selectedImages) {
      try {
        final fileId = const Uuid().v4();
        final imageRef =
            storageRef.child('job_images/$docId/image_$fileId.jpg');

        final uploadTask = await imageRef.putFile(File(imageFile.path));
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Image upload error: $e');
        // Handle error (e.g., show snackbar)
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
      final newJobRef = FirebaseFirestore.instance.collection('jobs').doc();
      final imageUrls = await _uploadImages(newJobRef.id);

      final newJob = JobModel(
        id: newJobRef.id,
        userId: userModel.uid,
        // ✅ [작업 31] 1. 'quick_gig' 타입으로 자동 설정
        jobType: JobType.quickGig.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!.id,
        // ✅ [작업 31] 2. 'total' (총 보수) 타입으로 자동 설정
        salaryType: 'total',
        // ✅ [작업 35] 8. (num vs int?) 에러 수정: double 값을 int로 변환
        salaryAmount: (double.tryParse(_salaryAmountController.text)?.toInt()),
        isSalaryNegotiable: _isSalaryNegotiable,
        // ✅ [작업 31] 3. 'one_time' (일회성)으로 자동 설정
        workPeriod: 'one_time',
        workHours: null, // 단순 일자리는 근무 시간이 필요 없음
        imageUrls: imageUrls,
        locationName: _locationController.text.trim(),
        locationParts: userModel.locationParts,
        geoPoint: userModel.geoPoint,
        createdAt: Timestamp.now(),
        trustLevelRequired: 'normal',
      );

      await _jobRepository.createJob(newJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('jobs.form.saveSuccess'.tr())),
        );
        // 유형 선택 화면까지 2번 pop
        Navigator.of(context).pop();
        Navigator.of(context).pop();
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
        title: Text('jobs.form.titleQuickGig'.tr()), // '단순 일자리 등록'
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
                // ✅ [작업 31] 4. 간소화된 '총 보수' 입력 필드
                _buildTotalPayInput(),
                const SizedBox(height: 16),
                _buildLocationInput(),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildDescriptionInput(),
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

  // --- 위젯 빌더 함수들 ---

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
        hintText: 'jobs.form.titleHintQuickGig'.tr(), // '예: 오토바이로 서류 배송'
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

  /// ✅ [작업 31] 5. '총 보수' 전용 입력 필드 (단순화)
  Widget _buildTotalPayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _salaryAmountController,
          decoration: InputDecoration(
            labelText: 'jobs.form.totalPayLabel'.tr(), // '총 보수 (IDR)'
            hintText: 'jobs.form.totalPayHint'.tr(), // '제시할 금액'
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty ||
                (double.tryParse(value) ?? 0) <= 0) {
              return 'jobs.form.totalPayValidator'.tr(); // '금액을 입력하세요'
            }
            return null;
          },
        ),
        CheckboxListTile(
          title: Text('jobs.form.negotiable'.tr()), // '금액 협의 가능'
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
        hintText: 'jobs.form.descriptionHintQuickGig'
            .tr(), // '상세한 업무 내용 (출발지, 도착지 등)'
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('jobs.form.imageLabel'.tr(),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 100, // 고정 높이
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1, // +1 for the 'Add' button
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                // 'Add' button
                return _selectedImages.length < 10
                    ? InkWell(
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
                    : const SizedBox(); // 10장 꽉 차면 'Add' 버튼 숨김
              }
              // Image tile
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_selectedImages[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateJobScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateJobScreen({super.key, required this.userModel});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workHoursController = TextEditingController();
  String? _selectedWorkPeriod;

  // ✅ 태그 상태 변수 추가
  List<String> _tags = [];

  final _salaryAmountController = TextEditingController();
  String? _selectedSalaryType;
  bool _isSalaryNegotiable = false;

  bool _isSaving = false;
  String? _selectedCategory;

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  final JobRepository _repository = JobRepository();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryAmountController.dispose(); // [추가]
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return; // 최대 5장 제한
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 5 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // [수정] 이미지 업로드 로직 추가
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('job_images/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newJob = JobModel(
        id: '',
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        locationName: widget.userModel.locationName,
        locationParts: widget.userModel.locationParts,
        geoPoint: widget.userModel.geoPoint,
        createdAt: Timestamp.now(),
        salaryType: _selectedSalaryType,
        salaryAmount: int.tryParse(_salaryAmountController.text),
        isSalaryNegotiable: _isSalaryNegotiable,
        workPeriod: _selectedWorkPeriod,
        workHours: _workHoursController.text.trim(),
        imageUrls: imageUrls, // [수정] 업로드된 이미지 URL 목록 전달
        tags: _tags, // ✅ 저장 시 태그 목록을 전달합니다.
      );
      await _repository.createJob(newJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('jobs.form.submitSuccess'.tr()),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('jobs.form.submitFail'.tr(args: [e.toString()])),
              backgroundColor: Colors.red),
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
        title: Text('jobs.form.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _submitJob,
              child: Text('jobs.form.submit'.tr()),
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
                // --- 직종 선택 ---
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text('jobs.form.categorySelectHint'.tr()),
                  items: [
                    'restaurant',
                    'cafe',
                    'retail',
                    'delivery',
                    'etc'
                  ] // 예시 카테고리
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('jobs.categories.$value'.tr()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null ? 'jobs.form.categoryValidator'.tr() : null,
                ),
                const SizedBox(height: 16),

                // --- 제목 입력 ---
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.titleLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'jobs.form.titleValidator'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // V V V --- [수정] 급여 정보 입력 UI --- V V V
                Text('jobs.form.salaryInfoTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                // 급여 종류 선택
                DropdownButtonFormField<String>(
                  value: _selectedSalaryType,
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
                // 급여액 입력
                TextFormField(
                  controller: _salaryAmountController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.salaryAmountLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // 급여 협의 가능
                CheckboxListTile(
                  title: Text('jobs.form.salaryNegotiable'.tr()),
                  value: _isSalaryNegotiable,
                  onChanged: (val) =>
                      setState(() => _isSalaryNegotiable = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // V V V --- [추가] 근무 조건 입력 UI --- V V V
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
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // V V V --- [추가] 이미지 첨부 UI --- V V V
                Text('jobs.form.imageSectionTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.map((xfile) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(File(xfile.path),
                                  width: 100, height: 100, fit: BoxFit.cover),
                            ),
                          )),
                      if (_images.length < 5)
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

                // --- 상세 설명 ---
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'jobs.form.descriptionLabel'.tr(),
                    hintText: 'jobs.form.descriptionHint'.tr(),
                    border: OutlineInputBorder(),
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

                // ✅ 공용 태그 입력 위젯을 추가합니다.
                Text('jobs.form.tagsTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                CustomTagInputField(
                  hintText: 'jobs.form.tagsHint'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),
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

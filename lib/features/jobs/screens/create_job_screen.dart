// lib/features/jobs/screens/create_job_screen.dart
import 'dart:io';
import 'package:bling_app/core/models/job_model.dart';
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
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 70, limit: 5 - _images.length);
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
        final ref = FirebaseStorage.instance.ref().child('job_images/${user.uid}/$fileName');
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
      );
      await _repository.createJob(newJob);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('구인글이 등록되었습니다.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('구인글 등록에 실패했습니다: $e'), backgroundColor: Colors.red),
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
        title: Text('새 구인글 등록'), // TODO: 다국어
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _submitJob,
              child: Text('등록'), // TODO: 다국어
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
                  hint: Text('직종을 선택하세요'), // TODO: 다국어
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
                      child: Text(
                          'jobs.categories.$value'.tr()), // TODO: 다국어 키 정의 필요
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
                      value == null ? '직종을 선택해주세요.' : null, // TODO: 다국어
                ),
                const SizedBox(height: 16),

                // --- 제목 입력 ---
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '제목', // TODO: 다국어
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요.'; // TODO: 다국어
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // V V V --- [수정] 급여 정보 입력 UI --- V V V
                Text('급여 정보',
                    style:
                        Theme.of(context).textTheme.titleMedium), // TODO: 다국어
                const SizedBox(height: 12),
                // 급여 종류 선택
                DropdownButtonFormField<String>(
                  value: _selectedSalaryType,
                  hint: Text('종류'), // TODO: 다국어
                  items: ['hourly', 'daily', 'monthly', 'per_case']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                                'jobs.salaryTypes.$value'.tr()), // TODO: 다국어
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
                    labelText: '금액 (IDR)', // TODO: 다국어
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // 급여 협의 가능
                CheckboxListTile(
                  title: Text('급여 협의 가능'), // TODO: 다국어
                  value: _isSalaryNegotiable,
                  onChanged: (val) =>
                      setState(() => _isSalaryNegotiable = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // V V V --- [추가] 근무 조건 입력 UI --- V V V
                Text('근무 조건',
                    style:
                        Theme.of(context).textTheme.titleMedium), // TODO: 다국어
                const SizedBox(height: 12),
                Text('근무 기간',
                    style: Theme.of(context).textTheme.titleSmall), // TODO: 다국어
                Wrap(
                  spacing: 8.0,
                  children:
                      ['short_term', 'mid_term', 'long_term'].map((period) {
                    return ChoiceChip(
                      label: Text('jobs.workPeriods.$period'.tr()), // TODO: 다국어
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
                    labelText: '근무 요일/시간', // TODO: 다국어
                    hintText: '예: 월-금, 09:00-18:00', // TODO: 다국어
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                    // V V V --- [추가] 이미지 첨부 UI --- V V V
                Text('사진 첨부 (선택, 최대 5장)', style: Theme.of(context).textTheme.titleMedium), // TODO: 다국어
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
                          child: Image.file(File(xfile.path), width: 100, height: 100, fit: BoxFit.cover),
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
                              border: Border.all(color: Colors.grey.shade400)
                            ),
                            child: Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600),
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
                    labelText: '상세 설명', // TODO: 다국어
                    hintText:
                        '예) 주 3회, 오후 5시-10시 파트타임 구합니다. 시급은 협의 가능합니다.', // TODO: 다국어
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '상세 설명을 입력해주세요.'; // TODO: 다국어
                    }
                    return null;
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

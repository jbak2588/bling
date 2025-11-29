import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart';
import 'package:bling_app/features/jobs/constants/job_categories.dart';
import 'package:bling_app/core/utils/popups/snackbars.dart';

class EditTalentScreen extends StatefulWidget {
  final TalentModel talent;

  const EditTalentScreen({super.key, required this.talent});

  @override
  State<EditTalentScreen> createState() => _EditTalentScreenState();
}

class _EditTalentScreenState extends State<EditTalentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = TalentRepository();
  final _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  bool _isLoading = false;
  String? _selectedCategory;
  String _selectedPriceUnit = 'project';

  // 이미지 관리: 기존 URL과 새 파일(XFile) 분리 관리
  List<String> _existingImageUrls = [];
  final List<XFile> _newImages = [];
  final List<String> _deletedImageUrls = []; // 삭제된 기존 이미지 추적 (필요 시 스토리지 삭제용)

  @override
  void initState() {
    super.initState();
    final t = widget.talent;
    _titleController = TextEditingController(text: t.title);
    _descController = TextEditingController(text: t.description);
    _priceController = TextEditingController(text: t.price.toString());
    _selectedCategory = t.category;
    _selectedPriceUnit = t.priceUnit;
    _existingImageUrls = List.from(t.portfolioUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    int currentTotal = _existingImageUrls.length + _newImages.length;
    if (currentTotal >= 10) {
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.maxImages'.tr());
      return;
    }

    final List<XFile> images =
        await _picker.pickMultiImage(limit: 10 - currentTotal);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      final url = _existingImageUrls.removeAt(index);
      _deletedImageUrls.add(url);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _updateTalent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.categoryRequired'.tr());
      return;
    }
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.portfolioRequired'.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('user.notLoggedIn'.tr());

      // 1. 새 이미지 업로드
      List<String> finalImageUrls = List.from(_existingImageUrls);
      for (var img in _newImages) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('talents/${user.uid}/${const Uuid().v4()}.jpg');
        await ref.putFile(File(img.path));
        final url = await ref.getDownloadURL();
        finalImageUrls.add(url);
      }

      // 2. 업데이트 데이터 구성
      final updateData = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'price': int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        'priceUnit': _selectedPriceUnit,
        'portfolioUrls': finalImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 3. 저장
      await _repo.updateTalent(widget.talent.id, updateData);

      if (mounted) {
        Navigator.pop(context, true); // true: 수정됨 신호
        BArtSnackBar.showSuccessSnackBar(
            title: 'common.success'.tr(), message: 'common.saved'.tr());
      }
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(
            title: 'common.error'.tr(), message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final talentCategories = AppJobCategories.allCategories
        .where((c) => c.jobType == JobType.talent)
        .toList();

    final Map<String, String> priceUnits = {
      'project': 'jobs.talent.create.priceUnits.project'.tr(),
      'hourly': 'jobs.talent.create.priceUnits.hourly'.tr(),
      'negotiable': 'jobs.talent.create.priceUnits.negotiable'.tr(),
    };

    return Scaffold(
      appBar: AppBar(title: Text('localNewsEdit.title'.tr())), // 또는 "재능 수정"
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 카테고리
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'jobs.talent.create.labels.category'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: talentCategories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nameKey.tr()),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),

              // 2. 제목
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'jobs.talent.create.labels.title'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? 'jobs.talent.create.errors.titleRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. 가격 설정
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'jobs.talent.create.labels.price'.tr(),
                        prefixText: 'Rp ',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty
                          ? 'jobs.talent.create.errors.priceRequired'.tr()
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _selectedPriceUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: priceUnits.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPriceUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. 상세 설명
              TextFormField(
                controller: _descController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'jobs.talent.create.labels.description'.tr(),
                  hintText: 'jobs.talent.create.labels.descriptionHint'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? 'jobs.talent.create.errors.descriptionRequired'.tr()
                    : null,
              ),
              const SizedBox(height: 16),

              // 5. 포트폴리오 이미지
              Text(
                  '${'jobs.talent.create.labels.portfolio'.tr()} (${_existingImageUrls.length + _newImages.length}/10)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // 이미지 추가 버튼
                    if ((_existingImageUrls.length + _newImages.length) < 10)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                    // 기존 이미지 표시
                    ..._existingImageUrls.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                    // 새 이미지 표시
                    ..._newImages.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. 위치 정보 (표시만)
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.grey),
                title: Text('jobs.talent.create.labels.location'.tr()),
                subtitle: Text(widget.talent.locationName ??
                    'location.unknown'.tr()), // 기존 값 사용
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateTalent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white))
                : Text('localNewsEdit.buttons.save'.tr(), // "수정 완료" 키 사용
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

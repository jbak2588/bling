import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

// Models
import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/jobs/constants/job_categories.dart'; // JobCategory, JobType

// Repository
import 'package:bling_app/features/jobs/data/talent_repository.dart';

// Utils & Widgets
import 'package:bling_app/core/utils/popups/snackbars.dart';

class CreateTalentScreen extends StatefulWidget {
  final UserModel user; // 유저 정보 필수 (위치 상속용)

  const CreateTalentScreen({super.key, required this.user});

  @override
  State<CreateTalentScreen> createState() => _CreateTalentScreenState();
}

class _CreateTalentScreenState extends State<CreateTalentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = TalentRepository();
  final _picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _selectedCategory;
  String _selectedPriceUnit = 'project'; // 기본값: 건당
  final List<XFile> _portfolioImages = [];

  // [수정] _priceUnits는 build 메서드 내에서 tr()로 생성하도록 변경 (여기서는 제거)

  Future<void> _pickImages() async {
    if (_portfolioImages.length >= 10) {
      // [수정] 다국어 키 적용
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.maxImages'.tr());
      return;
    }
    final List<XFile> images =
        await _picker.pickMultiImage(limit: 10 - _portfolioImages.length);
    if (images.isNotEmpty) {
      setState(() => _portfolioImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _portfolioImages.removeAt(index));
  }

  Future<void> _submitTalent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.categoryRequired'.tr());
      return;
    }
    if (_portfolioImages.isEmpty) {
      BArtSnackBar.showErrorSnackBar(
          title: 'common.notice'.tr(),
          message: 'jobs.talent.create.errors.portfolioRequired'.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다.');

      // 1. 이미지 업로드
      List<String> imageUrls = [];
      for (var img in _portfolioImages) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('talents/${user.uid}/${const Uuid().v4()}.jpg');
        await ref.putFile(File(img.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // 2. 모델 생성
      final newTalent = TalentModel(
        id: '', // Firestore 자동 ID 예정
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory!,
        price: int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        priceUnit: _selectedPriceUnit,
        portfolioUrls: imageUrls,

        // 위치 정보 상속
        locationName: widget.user.locationName ?? 'Unknown',
        locationParts: widget.user.locationParts,
        geoPoint: widget.user.geoPoint,

        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      // 3. 저장
      await _repo.createTalent(newTalent);

      if (mounted) {
        Navigator.pop(context);
        BArtSnackBar.showSuccessSnackBar(
            title: 'jobs.talent.success'.tr(),
            message: 'jobs.talent.create.success'.tr());
      }
    } catch (e) {
      if (mounted) {
        // [수정] 에러 메시지 명확화
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

    // [추가] 가격 단위 다국어 맵 생성
    final Map<String, String> priceUnits = {
      'project': 'jobs.talent.create.priceUnits.project'.tr(),
      'hourly': 'jobs.talent.create.priceUnits.hourly'.tr(),
      'negotiable': 'jobs.talent.create.priceUnits.negotiable'.tr(),
    };

    return Scaffold(
      appBar: AppBar(title: Text('jobs.talent.create.title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 카테고리
              DropdownButtonFormField<String>(
                isExpanded: true,
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
                      isExpanded: true,
                      // ignore: deprecated_member_use
                      value: _selectedPriceUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: priceUnits.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value,
                                    overflow: TextOverflow.ellipsis),
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
                  '${'jobs.talent.create.labels.portfolio'.tr()} (${_portfolioImages.length}/10)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _portfolioImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(Icons.add_a_photo, color: Colors.grey),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_portfolioImages[index - 1].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeImage(index - 1),
                            child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 12, color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 6. 위치 정보 (Read Only)
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.grey),
                title: Text('jobs.talent.create.labels.location'.tr()),
                subtitle:
                    Text(widget.user.locationName ?? 'location.unknown'.tr()),
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
            onPressed: _isLoading ? null : _submitTalent,
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
                : Text('jobs.talent.create.submit'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

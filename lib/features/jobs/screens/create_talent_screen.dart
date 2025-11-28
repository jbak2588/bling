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

  // 가격 단위 옵션 (다국어 키 필요)
  final Map<String, String> _priceUnits = {
    'project': '건당', // jobs.price_unit.project
    'hourly': '시간당', // jobs.price_unit.hourly
    'negotiable': '협의', // jobs.price_unit.negotiable
  };

  Future<void> _pickImages() async {
    if (_portfolioImages.length >= 10) {
      BArtSnackBar.showErrorSnackBar(
          title: '알림', message: '최대 10장까지 업로드 가능합니다.');
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
      BArtSnackBar.showErrorSnackBar(title: '알림', message: '카테고리를 선택해주세요.');
      return;
    }
    if (_portfolioImages.isEmpty) {
      BArtSnackBar.showErrorSnackBar(
          title: '알림', message: '포트폴리오 사진을 최소 1장 등록해주세요.');
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
            title: '완료', message: '재능이 성공적으로 등록되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(title: '오류', message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Talent 카테고리 필터링 (AppJobCategories 구현에 따라 조정 필요)
    final talentCategories = AppJobCategories.allCategories
        .where((c) => c.jobType == JobType.talent)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('재능 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 카테고리
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: talentCategories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nameKey.tr()), // 다국어 적용
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),

              // 2. 제목
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목 (예: 꼼꼼한 입주청소 해드립니다)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? '제목을 입력해주세요.' : null,
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
                      decoration: const InputDecoration(
                        labelText: '가격',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? '가격을 입력해주세요.' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPriceUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: _priceUnits.entries
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
                decoration: const InputDecoration(
                  labelText: '상세 설명',
                  hintText: '경력, 작업 방식, 가능 시간 등을 자세히 적어주세요.',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? '내용을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              // 5. 포트폴리오 이미지
              Text('포트폴리오 (${_portfolioImages.length}/10)',
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
                title: const Text('활동 지역'),
                subtitle: Text(widget.user.locationName ?? '위치 정보 없음'),
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
                : const Text('재능 등록하기',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

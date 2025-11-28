import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart';
// removed unused import: job_categories
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

  List<String> _existingImages = [];
  final List<XFile> _newImages = [];

  final Map<String, String> _priceUnits = {
    'project': '건당',
    'hourly': '시간당',
    'negotiable': '협의',
  };

  @override
  void initState() {
    super.initState();
    final t = widget.talent;
    _titleController = TextEditingController(text: t.title);
    _descController = TextEditingController(text: t.description);
    _priceController = TextEditingController(text: t.price.toString());
    _selectedCategory = t.category;
    _selectedPriceUnit = t.priceUnit;
    _existingImages = List.from(t.portfolioUrls);
  }

  Future<void> _pickImages() async {
    int currentTotal = _existingImages.length + _newImages.length;
    if (currentTotal >= 10) return;

    final List<XFile> images =
        await _picker.pickMultiImage(limit: 10 - currentTotal);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  Future<void> _updateTalent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 필요');

      // 1. 새 이미지 업로드
      List<String> finalImageUrls = List.from(_existingImages);
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
        Navigator.pop(context, true); // true: 갱신 신호
        BArtSnackBar.showSuccessSnackBar(title: '완료', message: '수정되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        BArtSnackBar.showErrorSnackBar(title: '오류', message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... UI 구조는 CreateTalentScreen과 유사하며 초기값만 바인딩 ...
    // (지면 관계상 핵심 위젯만 보여드리고 나머지는 Create와 동일합니다)
    return Scaffold(
      appBar: AppBar(title: const Text('재능 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ... 기존 입력 필드들 ...
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              const SizedBox(height: 16),

              // 가격 입력 및 단위 선택
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '가격'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPriceUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
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

              // ... 이미지 관리 섹션 (기존 삭제 + 새거 추가) ...
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                            width: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.add))),
                    ..._existingImages.map((url) => Stack(children: [
                          Image.network(url,
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                              right: 0,
                              child: GestureDetector(
                                  onTap: () => setState(
                                      () => _existingImages.remove(url)),
                                  child: const Icon(Icons.cancel,
                                      color: Colors.red))),
                        ])),
                    ..._newImages.map((file) => Stack(children: [
                          Image.file(File(file.path),
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                              right: 0,
                              child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _newImages.remove(file)),
                                  child: const Icon(Icons.cancel,
                                      color: Colors.red))),
                        ])),
                  ],
                ),
              ),
              // ...
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
              onPressed: _isLoading ? null : _updateTalent,
              child: const Text('수정 완료')),
        ),
      ),
    );
  }
}

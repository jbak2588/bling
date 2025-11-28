// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 등록, 이미지 업로드, 위치/현상금 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 분실/습득물 등록, 이미지 업로드, 위치/현상금 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(현상금 부스트, 조회수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// lib/features/lost_and_found/screens/create_lost_item_screen.dart

import 'dart:io';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력 포맷팅
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
// search index generation removed to reduce background processing

class CreateLostItemScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateLostItemScreen({super.key, required this.userModel});

  @override
  State<CreateLostItemScreen> createState() => _CreateLostItemScreenState();
}

class _CreateLostItemScreenState extends State<CreateLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemDescriptionController = TextEditingController();
  final _locationDescriptionController = TextEditingController();
  List<String> _tags = []; // ✅ 태그 상태 변수 추가

  String _type = 'lost';
  final List<XFile> _images = [];
  bool _isSaving = false;

  // ✅ 현상금(Bounty) 상태
  bool _isHunted = false;
  final _bountyAmountController = TextEditingController();

  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _itemDescriptionController.dispose();
    _locationDescriptionController.dispose();
    _bountyAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 5 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('lostAndFound.form.imageRequired'.tr())));

      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // ✅ [Fix] 사용자 최신 정보(위치) 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) throw Exception('User profile not found');
      final userModel = UserModel.fromFirestore(userDoc);
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('lost_and_found/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newItem = LostItemModel(
        id: '',
        userId: user.uid,
        type: _type,
        itemDescription: _itemDescriptionController.text.trim(),
        locationDescription: _locationDescriptionController.text.trim(),
        locationParts: userModel.locationParts, // ✅ 저장
        geoPoint: userModel.geoPoint, // ✅ 저장
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
        tags: _tags, // ✅ 저장 시 태그 목록을 전달
        // ✅ 현상금 정보 저장
        isHunted: _isHunted,
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
        bountyAmount:
            _isHunted ? num.tryParse(_bountyAmountController.text) : null,
      );

      // [수정] 주석을 해제하여 DB 저장 기능을 활성화합니다.
      await _repository.createItem(newItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('lostAndFound.form.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('lostAndFound.form.fail'
                .tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lostAndFound.form.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _submitItem,
            icon: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : const Icon(Icons.save),
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
                SegmentedButton<String>(
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(
                        value: 'lost',
                        label: Text('lostAndFound.form.type.lost'.tr())),
                    ButtonSegment<String>(
                        value: 'found',
                        label: Text('lostAndFound.form.type.found'.tr())),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) =>
                      setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 24),

                // V V V --- [복원] 이미지 선택 및 취소 기능이 포함된 UI --- V V V
                Text('lostAndFound.form.photoSectionTitle'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final xfile = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(xfile.path),
                                    width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_images.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                // ^ ^ ^ --- 여기까지 복원 --- ^ ^ ^
                const SizedBox(height: 24),

                TextFormField(
                  controller: _itemDescriptionController,
                  decoration: InputDecoration(
                      labelText: 'lostAndFound.form.itemLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'lostAndFound.form.itemError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                // ✅ 현상금(Bounty) 섹션
                _buildBountySection(),

                TextFormField(
                  controller: _locationDescriptionController,
                  decoration: InputDecoration(
                      labelText: 'lostAndFound.form.locationLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'lostAndFound.form.locationError'.tr()
                      : null,
                ),
                const SizedBox(height: 24),

                // ✅ 태그 입력 필드를 추가합니다.
                CustomTagInputField(
                  hintText: 'tag_input.addHint'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),
                const SizedBox(height: 72),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _submitItem,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('lostAndFound.form.submit'.tr()),
          ),
        ),
      ),
    );
  }

  // ✅ 현상금(Bounty) 입력 UI 위젯
  Widget _buildBountySection() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('lostAndFound.form.bountyTitle'.tr()),
          subtitle: Text('lostAndFound.form.bountyDesc'.tr()),
          value: _isHunted,
          onChanged: (bool value) {
            setState(() {
              _isHunted = value;
            });
          },
        ),
        if (_isHunted)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextFormField(
              controller: _bountyAmountController,
              decoration: InputDecoration(
                labelText: 'lostAndFound.form.bountyAmount'.tr(),
                hintText: '50000',
                prefixText: 'Rp ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_isHunted && (value == null || value.trim().isEmpty)) {
                  return 'lostAndFound.form.bountyAmountError'.tr();
                }
                return null;
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

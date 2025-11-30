// ===================== DocHeader =====================
// [기획 요약]
// - 분실/습득물 정보 수정, 이미지 업로드, 위치/현상금 등 다양한 필드 편집 지원.
//
// [실제 구현 비교]
// - 분실/습득물 정보 수정, 이미지 업로드, 위치/현상금 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(현상금 부스트, 조회수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// lib/features/lost_and_found/screens/edit_lost_item_screen.dart

import 'dart:io';
import 'package:bling_app/features/lost_and_found/models/lost_item_model.dart';
import 'package:bling_app/features/lost_and_found/data/lost_and_found_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/core/models/user_model.dart'; // ✅ Import 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // 숫자 입력 포맷팅
// search index generation removed to reduce background processing
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class EditLostItemScreen extends StatefulWidget {
  final LostItemModel item;
  const EditLostItemScreen({super.key, required this.item});

  @override
  State<EditLostItemScreen> createState() => _EditLostItemScreenState();
}

class _EditLostItemScreenState extends State<EditLostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemDescriptionController;
  late final TextEditingController _locationDescriptionController;

  late String _type;
  final List<dynamic> _images = [];
  List<String> _tags = []; // 태그 상태 변수 추가
  bool _isSaving = false;

  // ✅ 현상금(Bounty)
  bool _isHunted = false;
  final TextEditingController _bountyAmountController = TextEditingController();

  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _itemDescriptionController =
        TextEditingController(text: widget.item.itemDescription);
    _locationDescriptionController =
        TextEditingController(text: widget.item.locationDescription);
    _type = widget.item.type;
    _images.addAll(widget.item.imageUrls);

    // 기존 태그 로드
    _tags = widget.item.tags;

    // ✅ 기존 현상금 정보 로드
    _isHunted = widget.item.isHunted;
    final amount = widget.item.bountyAmount;
    _bountyAmountController.text = amount == null
        ? ''
        : (amount is int ? amount.toString() : amount.toStringAsFixed(0));
  }

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

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('lostAndFound.form.imageRequired'.tr())));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ [Fix] 사용자 최신 정보(위치) 가져오기 (데이터 보정용)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userModel =
          (userDoc.exists) ? UserModel.fromFirestore(userDoc) : null;
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          final fileName = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('lost_and_found/${widget.item.userId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      final updatedItem = LostItemModel(
        id: widget.item.id,
        userId: widget.item.userId,
        type: _type,
        itemDescription: _itemDescriptionController.text.trim(),
        locationDescription: _locationDescriptionController.text.trim(),
        imageUrls: imageUrls,
        createdAt: widget.item.createdAt,
        geoPoint: userModel?.geoPoint ?? widget.item.geoPoint,
        locationParts: userModel?.locationParts ?? widget.item.locationParts,
        // ✅ 현상금 정보 저장
        isHunted: _isHunted,
        tags: _tags,
        // 'searchIndex' intentionally omitted — client-side token generation disabled; use server-side/background indexing.
        bountyAmount:
            _isHunted ? num.tryParse(_bountyAmountController.text) : null,
      );

      await _repository.updateItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('lostAndFound.edit.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('lostAndFound.edit.fail'
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
        title: Text('lostAndFound.edit.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _updateItem,
            icon: const Icon(Icons.save),
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

                // ✅ 현상금(Bounty) 섹션 UI
                _buildBountySection(),
                // V V V --- [복원] 누락되었던 이미지 선택/수정 UI --- V V V
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        ImageProvider imageProvider;
                        if (image is XFile) {
                          imageProvider = FileImage(File(image.path));
                        } else {
                          imageProvider = NetworkImage(image as String);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image(
                                    image: imageProvider,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
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
                                          color: Colors.white, size: 16)),
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
                                borderRadius: BorderRadius.circular(8)),
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
                TextFormField(
                  controller: _locationDescriptionController,
                  decoration: InputDecoration(
                      labelText: 'lostAndFound.form.locationLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'lostAndFound.form.locationError'.tr()
                      : null,
                ),
                const SizedBox(height: 16),

                // ✅ 태그 입력 필드
                CustomTagInputField(
                  hintText: 'tag_input.addHint'.tr(),
                  initialTags: _tags,
                  onTagsChanged: (tags) => setState(() => _tags = tags),
                ),
                const SizedBox(height: 88),
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
            onPressed: _isSaving ? null : _updateItem,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : Text('common.save'.tr()),
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(), // ✅ 하단 클래스 추가
              ],
              validator: (value) {
                if (!_isHunted) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'lostAndFound.form.bountyAmountError'.tr();
                }
                final int amount = int.tryParse(value.replaceAll(',', '')) ?? 0;
                if (amount < 10000) return '최소 10,000 Rp 이상 설정해주세요.';
                if (amount > 100000000) return '금액이 너무 큽니다.';
                return null;
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ✅ [작업 6] 숫자 입력 시 자동으로 3자리 콤마를 찍어주는 포맷터
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final plain = newValue.text.replaceAll(',', '');
    if (plain.isEmpty) return newValue.copyWith(text: '');
    int value = int.tryParse(plain) ?? 0;
    final formatter = NumberFormat('#,###');
    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

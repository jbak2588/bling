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
import 'package:bling_app/i18n/strings.g.dart';
import 'package:flutter/services.dart'; // 숫자 입력 포맷팅
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]
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
          SnackBar(content: Text(t.lostAndFound.form.imageRequired)));
      return;
    }

    setState(() => _isSaving = true);

    try {
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

      // [추가] 검색 키워드 생성
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _itemDescriptionController.text, // 물품명/설명을 제목으로 사용
        tags: _tags,
        description: _locationDescriptionController.text,
      );

      final updatedItem = LostItemModel(
        id: widget.item.id,
        userId: widget.item.userId,
        type: _type,
        itemDescription: _itemDescriptionController.text.trim(),
        locationDescription: _locationDescriptionController.text.trim(),
        imageUrls: imageUrls,
        createdAt: widget.item.createdAt,
        geoPoint: widget.item.geoPoint,
        // ✅ 현상금 정보 저장
        isHunted: _isHunted,
        tags: _tags,
        searchIndex: searchKeywords, // [추가]
        bountyAmount:
            _isHunted ? num.tryParse(_bountyAmountController.text) : null,
      );

      await _repository.updateItem(updatedItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.lostAndFound.edit.success),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                t.lostAndFound.edit.fail.replaceAll('{error}', e.toString())),
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
        title: Text(t.lostAndFound.edit.title),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _updateItem, child: Text(t.lostAndFound.edit.save)),
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
                        label: Text(t.lostAndFound.form.type.lost)),
                    ButtonSegment<String>(
                        value: 'found',
                        label: Text(t.lostAndFound.form.type.found)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) =>
                      setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 24),

                // ✅ 현상금(Bounty) 섹션 UI
                _buildBountySection(),

                // 이미지 썸네일 리스트
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
                const SizedBox(height: 24),

                TextFormField(
                  controller: _itemDescriptionController,
                  decoration: InputDecoration(
                      labelText: t.lostAndFound.form.itemLabel,
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? t.lostAndFound.form.itemError
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationDescriptionController,
                  decoration: InputDecoration(
                      labelText: t.lostAndFound.form.locationLabel,
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? t.lostAndFound.form.locationError
                      : null,
                ),
                const SizedBox(height: 16),

                // ✅ 태그 입력 필드
                CustomTagInputField(
                  hintText: t.shared.tagInput.defaultHint,
                  initialTags: _tags,
                  onTagsChanged: (tags) => setState(() => _tags = tags),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // ✅ 현상금(Bounty) 입력 UI 위젯
  Widget _buildBountySection() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(t.lostAndFound.form.bountyTitle),
          subtitle: Text(t.lostAndFound.form.bountyDesc),
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
                labelText: t.lostAndFound.form.bountyAmount,
                hintText: '50000',
                prefixText: 'Rp ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_isHunted && (value == null || value.trim().isEmpty)) {
                  return t.lostAndFound.form.bountyAmountError;
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

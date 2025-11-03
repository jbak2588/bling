// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 등록, 이미지 업로드, 가격/편의시설 등 다양한 필드 입력 지원.
//
// [실제 구현 비교]
// - 매물 등록, 이미지 업로드, 가격/편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(매물 부스트, 조회수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 1, 4).
// 2. [Gap 1] UI 추가: 'area'(면적), 'roomCount'(방 수), 'bathroomCount'(욕실 수), 'moveInDate'(입주 가능일) 입력 필드 추가.
// 3. [Gap 4] UI 추가: 'listingType'(임대/매매), 'publisherType'(직거래/중개인) 선택 Dropdown 추가.
// =====================================================
// lib/features/real_estate/screens/create_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
// [추가] DateFormat 사용

import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateRoomListingScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateRoomListingScreen({super.key, required this.userModel});

  @override
  State<CreateRoomListingScreen> createState() =>
      _CreateRoomListingScreenState();
}

class _CreateRoomListingScreenState extends State<CreateRoomListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _type = 'kos'; // 'kos', 'kontrakan', 'sewa'
  String _priceUnit = 'monthly'; // 'monthly', 'yearly'
  final List<XFile> _images = [];
  final Set<String> _amenities = {};
  bool _isSaving = false;
  List<String> _tags = []; // ✅ 태그 상태 변수 추가

  // [추가] Phase 1 신규 메타 필드 상태
  String _selectedListingType = 'rent'; // 'rent', 'sale'
  String _selectedPublisherType = 'individual'; // 'individual', 'agent'
  final _areaController = TextEditingController(); // 면적
  final _roomCountController = TextEditingController(text: '1'); // 방 수
  final _bathroomCountController = TextEditingController(text: '1'); // 욕실 수
  DateTime? _selectedMoveInDate; // 입주 가능일

  final RoomRepository _repository = RoomRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _roomCountController.dispose();
    _bathroomCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('realEstate.form.imageRequired'.tr())));
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var imageFile in _images) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('room_listings/${user.uid}/$fileName');
        await ref.putFile(File(imageFile.path));
        imageUrls.add(await ref.getDownloadURL());
      }

      final newListing = RoomListingModel(
        id: '',
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        locationName: widget.userModel.locationName,
        locationParts: widget.userModel.locationParts,
        geoPoint: widget.userModel.geoPoint,
        price: int.tryParse(_priceController.text) ?? 0,
        priceUnit: _priceUnit,
        imageUrls: imageUrls,
        amenities: _amenities.toList(),
        createdAt: Timestamp.now(),
        tags: _tags, // ✅ 태그 저장
        // [추가] Gap 1, 4 필드 저장
        listingType: _selectedListingType,
        publisherType: _selectedPublisherType,
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        roomCount: int.tryParse(_roomCountController.text.trim()) ?? 1,
        bathroomCount: int.tryParse(_bathroomCountController.text.trim()) ?? 1,
        moveInDate: _selectedMoveInDate != null
            ? Timestamp.fromDate(_selectedMoveInDate!)
            : null,
      );

      await _repository.createRoomListing(newListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('realEstate.form.success'.tr()),
            backgroundColor: Colors.green));
        // V V V --- [수정] 등록 성공 신호(true)와 함께 화면을 닫습니다 --- V V V
        Navigator.of(context).pop(true);
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'realEstate.form.fail'.tr(namedArgs: {'error': e.toString()})),
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
        title: Text('realEstate.form.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _submitListing,
                child: Text('realEstate.form.submit'.tr())),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- 사진 등록 ---
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(File(image.path),
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
                      if (_images.length < 10)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined,
                                color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- 매물 종류 (직방 스타일 카테고리) ---
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: 'realEstate.form.typeLabel'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  // 'kos', 'apartment', 'kontrakan', 'ruko', 'kantor', 'etc'
                  items: const [
                    'kos',
                    'apartment',
                    'kontrakan',
                    'ruko',
                    'kantor',
                    'etc'
                  ].map<DropdownMenuItem<String>>((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('realEstate.form.roomTypes.$type'.tr()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 16),
                // --- 가격 정보 ---
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                            labelText: 'realEstate.form.priceLabel'.tr(),
                            border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'realEstate.form.priceRequired'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _priceUnit,
                      items: [
                        DropdownMenuItem(
                            value: 'monthly',
                            child:
                                Text('realEstate.form.priceUnit.monthly'.tr())),
                        DropdownMenuItem(
                            value: 'yearly',
                            child:
                                Text('realEstate.form.priceUnit.yearly'.tr())),
                      ],
                      onChanged: (val) => setState(() => _priceUnit = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // --- 제목 및 설명 ---
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'realEstate.form.titleLabel'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'realEstate.form.titleRequired'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'realEstate.form.descriptionLabel'.tr(),
                      border: const OutlineInputBorder()),
                  maxLines: 3,
                ),

                // [추가] 거래 유형 (임대/매매), 게시자 유형 (직거래/중개인)
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedListingType,
                        decoration: InputDecoration(
                            labelText: 'realEstate.form.listingType'.tr(),
                            border: const OutlineInputBorder()),
                        items: ['rent', 'sale'].map((type) {
                          return DropdownMenuItem(
                              value: type,
                              child: Text(
                                  'realEstate.form.listingTypes.$type'.tr()));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedListingType = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPublisherType,
                        decoration: InputDecoration(
                            labelText: 'realEstate.form.publisherType'.tr(),
                            border: const OutlineInputBorder()),
                        items: ['individual', 'agent'].map((type) {
                          return DropdownMenuItem(
                              value: type,
                              child: Text(
                                  'realEstate.form.publisherTypes.$type'.tr()));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedPublisherType = value!),
                      ),
                    ),
                  ],
                ),

                // [추가] 면적, 방 수, 욕실 수
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'realEstate.form.area'.tr(), // 면적 (m²)
                    hintText: 'realEstate.form.areaHint'.tr(), // 예: 33
                    border: const OutlineInputBorder(),
                    suffixText: 'm²',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _roomCountController,
                        decoration: InputDecoration(
                          labelText: 'realEstate.form.rooms'.tr(), // 방 수
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomCountController,
                        decoration: InputDecoration(
                          labelText: 'realEstate.form.bathrooms'.tr(), // 욕실 수
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // [추가] 입주 가능일
                const SizedBox(height: 16),
                Text('realEstate.form.moveInDate'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _selectedMoveInDate == null
                        ? 'realEstate.form.selectDate'.tr()
                        : DateFormat('yyyy-MM-dd').format(_selectedMoveInDate!),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedMoveInDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedMoveInDate = pickedDate);
                    }
                  },
                ),
                if (_selectedMoveInDate != null)
                  TextButton(
                    child: Text('realEstate.form.clearDate'.tr()),
                    onPressed: () => setState(() => _selectedMoveInDate = null),
                  ),
                const SizedBox(height: 24),
                // --- 편의시설 ---
                Text('realEstate.form.amenities'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8.0,
                  children: ['wifi', 'ac', 'parking', 'kitchen'].map((amenity) {
                    return FilterChip(
                      label: Text('realEstate.form.amenity.$amenity'.tr()),
                      selected: _amenities.contains(amenity),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _amenities.add(amenity);
                          } else {
                            _amenities.remove(amenity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
// ✅ 편의시설 다음에 태그 입력 필드를 추가합니다.
                const SizedBox(height: 24),
                Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                CustomTagInputField(
                  hintText: 'e.g. furnished, near_station, quiet',
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
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

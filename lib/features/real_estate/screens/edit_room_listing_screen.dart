// ===================== DocHeader =====================
// [기획 요약]
// - 부동산(월세/하숙) 매물 정보 수정, 이미지 업로드, 가격/편의시설 등 다양한 필드 편집 지원.
//
// [실제 구현 비교]
// - 매물 정보 수정, 이미지 업로드, 가격/편의시설 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 입력값 유효성 검사 및 저장 로직 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(매물 부스트, 조회수 등).
// - 필수 입력값, 에러 메시지, UX 강화. 신고/차단/신뢰 등급 UI 노출 및 기능 강화.
// =====================================================
// [작업 이력 (2025-11-02)]
// 1. (Task 23) '직방' 모델 도입 (Gap 1, 4).
// 2. [Gap 1, 4] UI 추가: 'area', 'roomCount', 'bathroomCount', 'moveInDate', 'listingType', 'publisherType' 필드를 로드하고 수정할 수 있도록 UI 추가.
// =====================================================
// lib/features/real_estate/screens/edit_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] Timestamp 클래스

class EditRoomListingScreen extends StatefulWidget {
  final RoomListingModel room;
  const EditRoomListingScreen({super.key, required this.room});

  @override
  State<EditRoomListingScreen> createState() => _EditRoomListingScreenState();
}

class _EditRoomListingScreenState extends State<EditRoomListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  late String _type;
  late String _priceUnit;
  final List<dynamic> _images = []; // 기존 URL(String)과 새로운 파일(XFile)을 모두 담음
  late Set<String> _amenities;
  bool _isSaving = false;

  // [추가] 새 필드: 매물 유형, 게시자 유형, 면적, 방 수, 욕실 수, 입주 가능일
  late String _selectedListingType;
  late String _selectedPublisherType;
  late final TextEditingController _areaController; // 면적
  late final TextEditingController _roomCountController; // 방 수
  late final TextEditingController _bathroomCountController; // 욕실 수
  DateTime? _selectedMoveInDate; // 입주 가능일

  // [추가] Task 40: 카테고리별 상세 필드
  String?
      _selectedFurnishedStatus; // 'furnished', 'semi_furnished', 'unfurnished'
  String? _selectedRentPeriod; // 'daily', 'monthly', 'yearly'
  late final TextEditingController _maintenanceFeeController; // 관리비
  late final TextEditingController _depositController; // 보증금
  late final TextEditingController _floorInfoController; // 층수 정보

  final RoomRepository _repository = RoomRepository();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.room.title);
    _descriptionController =
        TextEditingController(text: widget.room.description);
    _priceController =
        TextEditingController(text: widget.room.price.toString());
    _type = widget.room.type;
    _priceUnit = widget.room.priceUnit;
    _images.addAll(widget.room.imageUrls);
    _amenities = Set<String>.from(widget.room.amenities);

    // [추가] 새 필드 초기화
    _selectedListingType = widget.room.listingType;
    _selectedPublisherType = widget.room.publisherType;
    _areaController = TextEditingController(text: widget.room.area.toString());
    _roomCountController =
        TextEditingController(text: widget.room.roomCount.toString());
    _bathroomCountController =
        TextEditingController(text: widget.room.bathroomCount.toString());
    _selectedMoveInDate = widget.room.moveInDate?.toDate();

    // [추가] Task 40: 카테고리별 필드 로드
    _selectedFurnishedStatus = widget.room.furnishedStatus;
    _selectedRentPeriod = widget.room.rentPeriod;
    _maintenanceFeeController = TextEditingController(
        text: widget.room.maintenanceFee?.toString() ?? '');
    _depositController =
        TextEditingController(text: widget.room.deposit?.toString() ?? '');
    _floorInfoController =
        TextEditingController(text: widget.room.floorInfo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    // [추가] 새 필드에 대한 컨트롤러 해제
    _areaController.dispose();
    _roomCountController.dispose();
    _bathroomCountController.dispose();
    // [추가] Task 40
    _maintenanceFeeController.dispose();
    _depositController.dispose();
    _floorInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 10) return;
    final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70, limit: 10 - _images.length);
    if (pickedFiles.isNotEmpty && mounted) {
      setState(() => _images.addAll(pickedFiles));
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      setState(() => _images.removeAt(index));
    }
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate() || _isSaving || _images.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      List<String> imageUrls = [];
      for (var image in _images) {
        if (image is XFile) {
          final fileName = Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('room_listings/${widget.room.userId}/$fileName');
          await ref.putFile(File(image.path));
          imageUrls.add(await ref.getDownloadURL());
        } else if (image is String) {
          imageUrls.add(image);
        }
      }

      // V V V --- [핵심 수정] RoomListingModel에 실제로 존재하는 필드만 사용하여 객체를 생성합니다 --- V V V
      final updatedListing = RoomListingModel(
        id: widget.room.id,
        userId: widget.room.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        price: int.tryParse(_priceController.text) ?? 0,
        priceUnit: _priceUnit,
        imageUrls: imageUrls,
        amenities: _amenities.toList(),
        listingType: _selectedListingType,
        publisherType: _selectedPublisherType,
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        roomCount: int.tryParse(_roomCountController.text.trim()) ?? 1,
        bathroomCount: int.tryParse(_bathroomCountController.text.trim()) ?? 1,
        moveInDate: _selectedMoveInDate != null
            ? Timestamp.fromDate(_selectedMoveInDate!)
            : null,
        // [추가] Task 40: 카테고리별 필드 저장
        furnishedStatus: _selectedFurnishedStatus,
        rentPeriod: _selectedRentPeriod,
        maintenanceFee: int.tryParse(_maintenanceFeeController.text.trim()),
        deposit: int.tryParse(_depositController.text.trim()),
        floorInfo: _floorInfoController.text.trim(),
        // --- 기존 정보 보존 ---
        locationName: widget.room.locationName,
        locationParts: widget.room.locationParts,
        geoPoint: widget.room.geoPoint,
        createdAt: widget.room.createdAt,
        isAvailable: widget.room.isAvailable,
      );
      // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

      await _repository.updateRoomListing(updatedListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('realEstate.edit.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'realEstate.edit.fail'.tr(namedArgs: {'error': e.toString()})),
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
        title: Text('realEstate.edit.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _updateListing,
                child: Text('realEstate.edit.save'.tr()))
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
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
                      if (_images.length < 10)
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
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'kos',
                        label: Text('realEstate.form.type.kos'.tr())),
                    ButtonSegment(
                        value: 'kontrakan',
                        label: Text('realEstate.form.type.kontrakan'.tr())),
                    ButtonSegment(
                        value: 'sewa',
                        label: Text('realEstate.form.type.sewa'.tr())),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) =>
                      setState(() => _type = newSelection.first),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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

                // [추가] Gap 4: 거래 유형, 게시자 유형
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

                // [추가] Gap 1: 면적, 방 수, 욕실 수
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: 'realEstate.form.area'.tr(), // 면적 (m²)
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

                // [추가] Gap 1: 입주 가능일
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
                          DateTime.now().subtract(const Duration(days: 365)),
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

                // [추가] Task 40: 카테고리별 동적 입력 필드
                // --- 1. 주거용 필드 (Kos, Apartment, Kontrakan, House) ---
                if (['kos', 'apartment', 'kontrakan', 'house']
                    .contains(_type)) ...[
                  const SizedBox(height: 16),
                  // 가구 상태
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFurnishedStatus,
                    decoration: InputDecoration(
                      labelText: 'realEstate.filter.furnishedStatus'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text('realEstate.filter.selectFurnished'.tr()),
                    items: ['furnished', 'semi_furnished', 'unfurnished']
                        .map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                            'realEstate.filter.furnishedTypes.$status'.tr()),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedFurnishedStatus = value),
                  ),
                  const SizedBox(height: 16),
                  // 임대 기간 (Kos/Kontrakan 에만)
                  if (['kos', 'kontrakan'].contains(_type))
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRentPeriod,
                      decoration: InputDecoration(
                        labelText: 'realEstate.filter.rentPeriod'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      hint: Text('realEstate.filter.selectRentPeriod'.tr()),
                      items: ['daily', 'monthly', 'yearly'].map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(
                              'realEstate.filter.rentPeriods.$period'.tr()),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRentPeriod = value),
                    ),
                  const SizedBox(height: 16),
                  // 월 관리비
                  TextFormField(
                    controller: _maintenanceFeeController,
                    decoration: InputDecoration(
                      labelText: 'realEstate.form.maintenanceFee'.tr(),
                      hintText: 'realEstate.form.maintenanceFeeHint'.tr(),
                      border: const OutlineInputBorder(),
                      suffixText: 'Rp',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],

                // --- 2. 상업용 필드 (Ruko, Kantor) ---
                if (['ruko', 'kantor'].contains(_type)) ...[
                  const SizedBox(height: 16),
                  // 보증금 (Deposit)
                  TextFormField(
                    controller: _depositController,
                    decoration: InputDecoration(
                      labelText: 'realEstate.form.deposit'.tr(),
                      hintText: 'realEstate.form.depositHint'.tr(),
                      border: const OutlineInputBorder(),
                      suffixText: 'Rp',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // 층수 정보
                  TextFormField(
                    controller: _floorInfoController,
                    decoration: InputDecoration(
                      labelText: 'realEstate.form.floorInfo'.tr(),
                      hintText: 'realEstate.form.floorInfoHint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

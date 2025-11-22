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
// - V2.0: 부동산 매물 수정 화면.
// - 'roomType'에 따라 동적으로 상세 필드(예: 'Kos' 전용)를 로드하고 수정.
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 7) 기존 'amenities' 로직 제거. `_buildDynamicFacilityInputs`를 추가하여
//    'roomType'에 맞는 시설(예: `kosRoomFacilities`)을 동적으로 표시.
// 2. (Task 13) `initState`: `RoomListingModel`에서 신규 상세 필드
//    (예: `furnishedStatus`, `kosBathroomType`)를 로드하도록 수정.
// 3. (Task 13) `_buildDynamicDetailInputs` 등 헬퍼를 추가하여 신규 필드 수정 UI 구현.
// 4. (Task 13) `_saveForm`: 수정된 모든 신규 필드를 `RoomListingModel`에 저장하도록 로직 수정.
// =====================================================
// lib/features/real_estate/screens/edit_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/features/real_estate/constants/real_estate_facilities.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] Timestamp 클래스
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

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
  // [수정] 'amenities'를 타입별 Set으로 분리
  late Set<String> _kosRoomFacilities;
  late Set<String> _kosPublicFacilities;
  late Set<String> _apartmentFacilities;
  late Set<String> _houseFacilities;
  late Set<String> _commercialFacilities;
  bool _isSaving = false;
  List<String> _tags = [];

  // [추가] 새 필드: 매물 유형, 게시자 유형, 면적, 방 수, 욕실 수, 입주 가능일
  late String _selectedListingType;
  late String _selectedPublisherType;
  late final TextEditingController _areaController; // 면적
  late final TextEditingController _landAreaController; // 토지 면적

  // [신규] '작업 13': 상세 필드 상태
  String? _furnishedStatus;
  String? _propertyCondition;
  String? _kosBathroomType;
  bool? _isElectricityIncluded;
  int? _maxOccupants;
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
    _tags = List<String>.from(widget.room.tags);
    // [수정] 'amenities' 대신 타입별 시설 로드
    _kosRoomFacilities = Set<String>.from(widget.room.kosRoomFacilities);
    _kosPublicFacilities = Set<String>.from(widget.room.kosPublicFacilities);
    _apartmentFacilities = Set<String>.from(widget.room.apartmentFacilities);
    _houseFacilities = Set<String>.from(widget.room.houseFacilities);
    _commercialFacilities = Set<String>.from(widget.room.commercialFacilities);

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
    _landAreaController = TextEditingController(
        text: widget.room.landArea != null
            ? widget.room.landArea!.toStringAsFixed(0)
            : '');

    // [신규] '작업 13': 상세 필드 로드
    _furnishedStatus = widget.room.furnishedStatus;
    _propertyCondition = widget.room.propertyCondition;
    _kosBathroomType = widget.room.kosBathroomType;
    _isElectricityIncluded = widget.room.isElectricityIncluded;
    _maxOccupants = widget.room.maxOccupants;
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
    _landAreaController.dispose();
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
      // [추가] 검색 키워드
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags,
        description: _descriptionController.text,
      );

      final updatedListing = RoomListingModel(
        id: widget.room.id,
        userId: widget.room.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type,
        price: int.tryParse(_priceController.text) ?? 0,
        // [수정] '작업 27': 'sale'일 경우 'priceUnit'을 기본값('monthly')으로 강제
        priceUnit: _selectedListingType == 'rent' ? _priceUnit : 'monthly',
        imageUrls: imageUrls,
        // [수정] 'amenities' 대신 타입별 시설 저장
        kosRoomFacilities: _kosRoomFacilities.toList(),
        kosPublicFacilities: _kosPublicFacilities.toList(),
        apartmentFacilities: _apartmentFacilities.toList(),
        houseFacilities: _houseFacilities.toList(),
        commercialFacilities: _commercialFacilities.toList(),
        listingType: _selectedListingType,
        publisherType: _selectedPublisherType,
        area: double.tryParse(_areaController.text.trim()) ?? 0.0,
        landArea: double.tryParse(_landAreaController.text.trim()),
        roomCount: int.tryParse(_roomCountController.text.trim()) ?? 1,
        bathroomCount: int.tryParse(_bathroomCountController.text.trim()) ?? 1,
        moveInDate: _selectedMoveInDate != null
            ? Timestamp.fromDate(_selectedMoveInDate!)
            : null,
        // [추가] Task 40: 카테고리별 필드 저장
        furnishedStatus: _furnishedStatus,
        propertyCondition: _propertyCondition,
        rentPeriod: _selectedRentPeriod,
        maintenanceFee: int.tryParse(_maintenanceFeeController.text.trim()),
        deposit: int.tryParse(_depositController.text.trim()),
        floorInfo: _floorInfoController.text.trim(),
        // [신규] '작업 13': Kos 전용 필드 저장
        kosBathroomType: _kosBathroomType,
        isElectricityIncluded: _isElectricityIncluded,
        maxOccupants: _maxOccupants,
        // tags and searchIndex
        tags: _tags,
        searchIndex: searchKeywords,
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
                child: Text('realEstate.edit.save'.tr(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)))
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
                // [수정] '작업 27': 'listingType'을 'roomType' 앞으로 이동
                Text('realEstate.form.listingType'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                _buildDropdown<String?>(
                  value: _selectedListingType,
                  hint: 'realEstate.form.listingTypeHint'.tr(),
                  items: const ['rent', 'sale'],
                  itemBuilder: (type) => DropdownMenuItem(
                    value: type,
                    child: Text('realEstate.form.listingTypes.$type'.tr()),
                  ),
                  onChanged: (val) {
                    // [수정] '작업 27': 수정 시에도 listingType 변경 허용 (UX 일관성)
                    setState(() {
                      _selectedListingType = val ?? 'rent';
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                    // [수정] '작업 27': 'listingType'이 'rent'일 때만 가격 단위 표시
                    if (_selectedListingType == 'rent') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _priceUnit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const ['monthly', 'yearly']
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                        'realEstate.form.priceUnit.$value'
                                            .tr()),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _priceUnit = newValue ?? 'monthly';
                            });
                          },
                        ),
                      ),
                    ],
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
                // [신규] 타입별 시설 입력 UI
                _buildDynamicFacilityInputs(),

                const SizedBox(height: 24),

                // [신규] '작업 13': 가구 상태 (모든 타입 공통)
                _buildFurnishedStatusInput(),

                // [신규] '작업 13': 매물 상태 (모든 타입 공통)
                _buildPropertyConditionInput(),

                const SizedBox(height: 16),

                // [신규] 타입별 상세 입력 UI (토지 면적 등)
                _buildDynamicDetailInputs(),

                const SizedBox(height: 24),
                Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                CustomTagInputField(
                  hintText: 'e.g. furnished, near_station, quiet',
                  initialTags: _tags,
                  titleController: _titleController,
                  onTagsChanged: (tags) {
                    setState(() => _tags = tags);
                  },
                ),

                // [수정] 게시자 유형 (listingType은 위로 이동)
                const SizedBox(height: 16),
                Text('realEstate.form.publisherType'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
                _buildDropdown<String?>(
                  value: _selectedPublisherType,
                  hint: 'realEstate.form.publisherType'.tr(),
                  items: const ['individual', 'agent'],
                  itemBuilder: (type) => DropdownMenuItem(
                    value: type,
                    child: Text('realEstate.form.publisherTypes.$type'.tr()),
                  ),
                  onChanged: (value) => setState(
                      () => _selectedPublisherType = value ?? 'individual'),
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

                const SizedBox(height: 24),
                // Bottom primary action consistent with AppBar
                ElevatedButton(
                  onPressed: _isSaving ? null : _updateListing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text('realEstate.edit.save'.tr()),
                ),

                // 상업용 상세 입력은 _buildDynamicDetailInputs()에서 처리합니다.
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

  // --- 동적 시설 UI ---
  Widget _buildDynamicFacilityInputs() {
    switch (_type) {
      case 'kos':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('realEstate.filter.kos.roomFacilities'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(
                RealEstateFacilities.kosRoomFacilities, _kosRoomFacilities),
            const SizedBox(height: 24),
            Text('realEstate.filter.kos.publicFacilities'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(
                RealEstateFacilities.kosPublicFacilities, _kosPublicFacilities),
          ],
        );
      case 'apartment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('realEstate.filter.apartment.facilities'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(
                RealEstateFacilities.apartmentFacilities, _apartmentFacilities),
          ],
        );
      case 'house':
      case 'kontrakan':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('realEstate.filter.house.facilities'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(
                RealEstateFacilities.houseFacilities, _houseFacilities),
          ],
        );
      case 'ruko':
      case 'kantor':
      case 'gudang':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // i18n key may be missing; fallback to key string
            Text('realEstate.filter.commercial.facilities'.tr(),
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(RealEstateFacilities.commercialFacilities,
                _commercialFacilities),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --- 동적 상세 UI (Kos 전용 필드 + 토지면적 + 상업용 보증금/층수) ---
  Widget _buildDynamicDetailInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 'Kos' 전용 필드 ---
        if (_type == 'kos') ...[
          Text('realEstate.filter.kos.bathroomType'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          _buildDropdown<String?>(
            value: _kosBathroomType,
            hint: 'realEstate.filter.kos.bathroomType'.tr(),
            items: const ['in_room', 'out_room'],
            itemBuilder: (type) => DropdownMenuItem(
              value: type,
              child: Text('realEstate.filter.kos.bathroomTypes.${type ?? ''}')
                  .tr(),
            ),
            onChanged: (val) => setState(() => _kosBathroomType = val),
          ),
          const SizedBox(height: 16),
          Text('realEstate.filter.kos.maxOccupants'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          _buildDropdown<int?>(
            value: _maxOccupants,
            hint: 'realEstate.filter.kos.maxOccupants'.tr(),
            items: const [1, 2, 3],
            itemBuilder: (val) => DropdownMenuItem(
              value: val,
              child: Text(val == 3 ? '3+' : '$val'),
            ),
            onChanged: (val) => setState(() => _maxOccupants = val),
          ),
          SwitchListTile(
            title: Text('realEstate.filter.kos.electricityIncluded'.tr()),
            value: _isElectricityIncluded ?? false,
            onChanged: (value) =>
                setState(() => _isElectricityIncluded = value),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 24),
        ],

        // --- 'Kos'가 아닐 경우: 토지 면적 ---
        if (_type != 'kos') ...[
          TextFormField(
            controller: _landAreaController,
            decoration: InputDecoration(
              labelText: 'realEstate.form.landArea'.tr(),
              hintText: '0',
              border: const OutlineInputBorder(),
              suffixText: 'm²',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
        ],

        // --- 상업용: 보증금, 층수 ---
        if (['ruko', 'kantor', 'gudang'].contains(_type)) ...[
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
          TextFormField(
            controller: _floorInfoController,
            decoration: InputDecoration(
              labelText: 'realEstate.form.floorInfo'.tr(),
              hintText: 'realEstate.form.floorInfoHint'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
        ]
      ],
    );
  }

  /// [신규] '작업 13': 가구 상태 입력
  Widget _buildFurnishedStatusInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.furnishedStatus'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildDropdown<String?>(
          value: _furnishedStatus,
          hint: 'realEstate.filter.furnishedHint'.tr(),
          items: const ['furnished', 'semi_furnished', 'unfurnished'],
          itemBuilder: (status) => DropdownMenuItem(
            value: status,
            child:
                Text('realEstate.filter.furnishedTypes.${status ?? ''}').tr(),
          ),
          onChanged: (val) => setState(() => _furnishedStatus = val),
        ),
      ],
    );
  }

  /// [신규] '작업 13': 매물 상태 입력
  Widget _buildPropertyConditionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('realEstate.filter.propertyCondition'.tr(),
            style: Theme.of(context).textTheme.titleMedium),
        _buildDropdown<String?>(
          value: _propertyCondition,
          hint: 'realEstate.filter.propertyCondition'.tr(),
          items: const ['new', 'used'],
          itemBuilder: (status) => DropdownMenuItem(
            value: status,
            child: Text('realEstate.filter.propertyConditions.${status ?? ''}')
                .tr(),
          ),
          onChanged: (val) => setState(() => _propertyCondition = val),
        ),
      ],
    );
  }

  /// [신규] '작업 13': 공용 드롭다운 위젯
  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<T> items,
    required DropdownMenuItem<T> Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      hint: Text(hint),
      isExpanded: true,
      items: items.map<DropdownMenuItem<T>>(itemBuilder).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFacilityChips(List<String> keys, Set<String> selected) {
    return Wrap(
      spacing: 8.0,
      children: keys.map((key) {
        return FilterChip(
          label: Text('realEstate.filter.amenities.$key'.tr()),
          selected: selected.contains(key),
          onSelected: (isSel) {
            setState(() {
              if (isSel) {
                selected.add(key);
              } else {
                selected.remove(key);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

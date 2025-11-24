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
// [기획 요약]
// - V2.0: 부동산 매물 등록 화면.
// - 'roomType'에 따라 동적으로 상세 입력 필드(예: 'Kos' 전용)를 제공.
//
// [V2.0 작업 이력 (2025-11-05)]
// 1. (Task 7) 기존 'amenities' 칩 UI를 제거. `_buildDynamicFacilityInputs` 헬퍼를 추가하여
//    'roomType'에 맞는 시설(예: `kosRoomFacilities`) 입력 UI를 동적으로 빌드.
// 2. (Task 13) `_buildDynamicDetailInputs`, `_buildFurnishedStatusInput` 등 헬퍼를 추가하여
//    '가구 상태', '매물 상태', 'Kos' 전용 상세 필드(욕실 타입, 전기세) 입력 UI(Dropdown, Switch) 구현.
// 3. (Task 13) `_saveForm`: `RoomListingModel`의 모든 신규 필드
//    (예: `kosBathroomType`, `propertyCondition`, `landArea`)에 입력값을 저장하도록 로직 수정.
// =====================================================
// lib/features/real_estate/screens/create_room_listing_screen.dart

import 'dart:io';
import 'package:bling_app/features/real_estate/constants/real_estate_facilities.dart';
import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/real_estate/data/room_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
// ignore: unused_import
import 'package:bling_app/i18n/strings.g.dart';
// compat shim removed; using Slang `t` accessors

import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/core/utils/search_helper.dart'; // [추가]

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
  // [수정] 'amenities'를 타입별 Set으로 분리
  final Set<String> _kosRoomFacilities = <String>{};
  final Set<String> _kosPublicFacilities = <String>{};
  final Set<String> _apartmentFacilities = <String>{};
  final Set<String> _houseFacilities = <String>{};
  final Set<String> _commercialFacilities = <String>{};
  bool _isSaving = false;
  List<String> _tags = []; // ✅ 태그 상태 변수 추가

  // [신규] '작업 13': 상세 필드 상태
  String? _furnishedStatus;
  String? _propertyCondition;
  String? _kosBathroomType;
  bool? _isElectricityIncluded;
  int? _maxOccupants;

  // [추가] Task 38, 40: 카테고리별 상세 필드
  // 주거용 (Kos, Apartment, Kontrakan)
  String?
      _selectedFurnishedStatus; // 'furnished', 'semi_furnished', 'unfurnished'
  String? _selectedRentPeriod; // 'daily', 'monthly', 'yearly'
  final _maintenanceFeeController = TextEditingController(); // 관리비
  // 상업용 (Ruko, Kantor)
  final _depositController = TextEditingController(); // 보증금
  final _floorInfoController = TextEditingController(); // 층수

  // [추가] Phase 1 신규 메타 필드 상태
  String _selectedListingType = 'rent'; // 'rent', 'sale'
  String _selectedPublisherType = 'individual'; // 'individual', 'agent'
  final _areaController = TextEditingController(); // 면적
  final _landAreaController = TextEditingController(text: '0'); // 토지 면적
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
    _landAreaController.dispose();
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
          SnackBar(content: Text(t.realEstate.form.imageRequired)));
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

      // [추가] 검색 키워드
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _tags,
        description: _descriptionController.text,
      );

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
        // [수정] '작업 27': 'sale'일 경우 'priceUnit'을 기본값('monthly')으로 강제
        priceUnit: _selectedListingType == 'rent' ? _priceUnit : 'monthly',
        imageUrls: imageUrls,
        // [수정] 'amenities' 대신 타입별 시설 저장
        kosRoomFacilities: _kosRoomFacilities.toList(),
        kosPublicFacilities: _kosPublicFacilities.toList(),
        apartmentFacilities: _apartmentFacilities.toList(),
        houseFacilities: _houseFacilities.toList(),
        commercialFacilities: _commercialFacilities.toList(),
        createdAt: Timestamp.now(),
        tags: _tags, // ✅ 태그 저장
        searchIndex: searchKeywords, // [추가]
        // [추가] Gap 1, 4 필드 저장
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
        furnishedStatus:
            _furnishedStatus ?? _selectedFurnishedStatus, // [수정] '작업 13'
        propertyCondition: _propertyCondition, // [수정] '작업 13'
        rentPeriod: _selectedRentPeriod,
        maintenanceFee: int.tryParse(_maintenanceFeeController.text.trim()),
        deposit: int.tryParse(_depositController.text.trim()),
        floorInfo: _floorInfoController.text.trim(),
        // [신규] '작업 13': Kos 전용 필드 저장
        kosBathroomType: _kosBathroomType,
        isElectricityIncluded: _isElectricityIncluded,
        maxOccupants: _maxOccupants,
      );

      await _repository.createRoomListing(newListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.realEstate.form.success),
            backgroundColor: Colors.green));
        // V V V --- [수정] 등록 성공 신호(true)와 함께 화면을 닫습니다 --- V V V
        Navigator.of(context).pop(true);
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                t.realEstate.form.fail.replaceAll('{error}', e.toString())),
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
        title: Text(t.realEstate.form.title),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _submitListing,
                child: Text(t.realEstate.form.submit,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold))),
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
                // Bottom primary action consistent with appBar
                ElevatedButton(
                  onPressed: _isSaving ? null : _submitListing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text(t.realEstate.form.submit),
                ),
                // [수정] '작업 27': 'listingType'을 'roomType' 앞으로 이동
                Text(t.realEstate.form.listingType,
                    style: Theme.of(context).textTheme.titleMedium),
                _buildDropdown<String?>(
                  value: _selectedListingType,
                  hint: t.realEstate.form.listingTypeHint,
                  items: const ['rent', 'sale'],
                  itemBuilder: (type) => DropdownMenuItem(
                    value: type,
                    child: Text(t['realEstate.form.listingTypes.$type'] ?? ''),
                  ),
                  onChanged: (val) {
                    setState(() => _selectedListingType = val ?? 'rent');
                  },
                ),
                const SizedBox(height: 16),

                // --- 매물 종류 (직방 스타일 카테고리) ---
                // [수정] '직방' 모델 카테고리 적용: kos/apartment/kontrakan/ruko/kantor/etc
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: t.realEstate.form.typeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  // 'kos', 'apartment', 'kontrakan', 'house', 'gudang', 'ruko', 'kantor', 'etc'
                  items: const [
                    'kos',
                    'apartment',
                    'kontrakan',
                    'house',
                    'gudang', // [추가] '작업 5'
                    'ruko',
                    'kantor',
                    'etc'
                  ].map<DropdownMenuItem<String>>((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(t['realEstate.form.roomTypes.$type'] ?? ''),
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
                            labelText: t.realEstate.form.priceLabel,
                            border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty)
                            ? t.realEstate.form.priceRequired
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
                                        t['realEstate.form.priceUnit.$value'] ?? ''),
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
                // --- 제목 및 설명 ---
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: t.realEstate.form.titleLabel,
                      border: const OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty)
                      ? t.realEstate.form.titleRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: t.realEstate.form.descriptionLabel,
                      border: const OutlineInputBorder()),
                  maxLines: 3,
                ),

                // [수정] 게시자 유형 (listingType은 위로 이동)
                const SizedBox(height: 16),
                Text(t.realEstate.form.publisherType,
                    style: Theme.of(context).textTheme.titleMedium),
                _buildDropdown<String?>(
                  value: _selectedPublisherType,
                  hint: t.realEstate.form.publisherType,
                  items: const ['individual', 'agent'],
                  itemBuilder: (type) => DropdownMenuItem(
                    value: type,
                    child: Text(t['realEstate.form.publisherTypes.$type'] ?? ''),
                  ),
                  onChanged: (value) => setState(
                      () => _selectedPublisherType = value ?? 'individual'),
                ),

                // [추가] 면적, 방 수, 욕실 수
                const SizedBox(height: 24),
                Text(
                  t.realEstate.form.details, // "매물 상세 정보"
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: t.realEstate.form.area, // 면적 (m²)
                    hintText: t.realEstate.form.areaHint, // 예: 33
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
                          labelText: t.realEstate.form.rooms, // 방 수
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
                          labelText: t.realEstate.form.bathrooms, // 욕실 수
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
                      labelText:
                          t.realEstate.filter.furnishedStatus, // "가구 상태"
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text(
                        t.realEstate.filter.selectFurnished), // "가구 상태 선택"
                    items: ['furnished', 'semi_furnished', 'unfurnished']
                        .map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child:
                            Text(t['realEstate.filter.furnishedTypes.$status'] ?? ''),
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
                        labelText: t.realEstate.filter.rentPeriod, // "임대 기간"
                        border: const OutlineInputBorder(),
                      ),
                      hint: Text(t[
                          'realEstate.filter.selectRentPeriod']), // "임대 기간 선택"
                      items: ['daily', 'monthly', 'yearly'].map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child:
                              Text(t['realEstate.filter.rentPeriods.$period'] ?? ''),
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
                      labelText: t.realEstate.form.maintenanceFee, // "월 관리비"
                      hintText: t[
                          'realEstate.form.maintenanceFeeHint'], // "관리비 (월, Rp)"
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
                      labelText: t.realEstate.form.deposit, // "보증금"
                      hintText: t.realEstate.form.depositHint, // "보증금 (Rp)"
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
                      labelText: t.realEstate.form.floorInfo, // "층수"
                      hintText: t[
                          'realEstate.form.floorInfoHint'], // "예: 1층 / 총 5층 중 3층"
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],

                // [추가] 입주 가능일
                const SizedBox(height: 16),
                Text(t.realEstate.form.moveInDate,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _selectedMoveInDate == null
                        ? t.realEstate.form.selectDate
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
                    child: Text(t.realEstate.form.clearDate),
                    onPressed: () => setState(() => _selectedMoveInDate = null),
                  ),
                // [신규] '작업 7': 'roomType'에 따라 동적으로 시설 입력 UI 표시
                // _type이 변경될 때마다 이 부분이 다시 빌드됩니다.
                _buildDynamicFacilityInputs(),

                const SizedBox(height: 24),

                // [신규] '작업 13': 가구 상태 (모든 타입 공통)
                _buildFurnishedStatusInput(),

                // [신규] '작업 13': 매물 상태 (모든 타입 공통)
                _buildPropertyConditionInput(),

                const SizedBox(height: 16),

                // [신규] '작업 7': 'roomType'에 따라 동적 상세 필드 UI 표시
                _buildDynamicDetailInputs(),
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

  /// [신규] '작업 7': 'roomType'에 따라 동적인 시설(Facility) 입력 UI를 빌드
  Widget _buildDynamicFacilityInputs() {
    switch (_type) {
      case 'kos':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(t.realEstate.filter.kos.roomFacilities,
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(
                RealEstateFacilities.kosRoomFacilities, _kosRoomFacilities),
            const SizedBox(height: 24),
            Text(t.realEstate.filter.kos.publicFacilities,
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
            Text(t.realEstate.filter.apartment.facilities,
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
            Text(t.realEstate.filter.house.facilities,
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
            Text(t.realEstate.filter.commercial.facilities,
                style: Theme.of(context).textTheme.titleMedium),
            _buildFacilityChips(RealEstateFacilities.commercialFacilities,
                _commercialFacilities),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// [신규] '작업 7': 'roomType'에 따라 토지 면적, 보증금 등 동적 필드 UI 빌드
  Widget _buildDynamicDetailInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 'Kos' 전용 필드 ---
        if (_type == 'kos') ...[
          Text(t.realEstate.filter.kos.bathroomType,
              style: Theme.of(context).textTheme.titleMedium),
          _buildDropdown<String?>(
            value: _kosBathroomType,
            hint: t.realEstate.filter.kos.hintBathroomType,
            items: const ['in_room', 'out_room'],
            itemBuilder: (type) => DropdownMenuItem(
              value: type,
              child:
                  Text(t['realEstate.filter.kos.bathroomTypes.${type ?? ''}']),
            ),
            onChanged: (val) => setState(() => _kosBathroomType = val),
          ),
          const SizedBox(height: 16),
          Text(t.realEstate.filter.kos.maxOccupants,
              style: Theme.of(context).textTheme.titleMedium),
          _buildDropdown<int?>(
            value: _maxOccupants,
            hint: t.realEstate.filter.kos.hintMaxOccupants,
            items: const [1, 2, 3], // 1, 2, 3+
            itemBuilder: (val) => DropdownMenuItem(
              value: val,
              child: Text(val == 3 ? '3+' : '$val'),
            ),
            onChanged: (val) => setState(() => _maxOccupants = val),
          ),
          SwitchListTile(
            title: Text(t.realEstate.filter.kos.electricityIncluded),
            value: _isElectricityIncluded ?? false,
            onChanged: (value) =>
                setState(() => _isElectricityIncluded = value),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 24),
        ],

        // --- 'Kos'가 아닌 경우: 토지 면적 입력 ---
        if (_type != 'kos') ...[
          TextFormField(
            controller: _landAreaController,
            decoration: InputDecoration(
              labelText: t.realEstate.form.landArea,
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
              labelText: t.realEstate.form.deposit,
              hintText: t.realEstate.form.depositHint, // "보증금 (Rp)"
              border: const OutlineInputBorder(),
              suffixText: 'Rp',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _floorInfoController,
            decoration: InputDecoration(
              labelText: t.realEstate.form.floorInfo,
              hintText: t.realEstate.form.floorInfoHint,
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
        Text(t.realEstate.filter.furnishedStatus,
            style: Theme.of(context).textTheme.titleMedium),
        _buildDropdown<String?>(
          value: _furnishedStatus,
          hint: t.realEstate.filter.furnishedHint,
          items: const ['furnished', 'semi_furnished', 'unfurnished'],
          itemBuilder: (status) => DropdownMenuItem(
            value: status,
            child: Text(t['realEstate.filter.furnishedTypes.${status ?? ''}']),
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
        Text(t.realEstate.filter.propertyCondition,
            style: Theme.of(context).textTheme.titleMedium),
        _buildDropdown<String?>(
          value: _propertyCondition,
          hint: t.realEstate.filter.propertyCondition,
          items: const ['new', 'used'],
          itemBuilder: (status) => DropdownMenuItem(
            value: status,
            child:
                Text(t['realEstate.filter.propertyConditions.${status ?? ''}']),
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

  /// [신규] '작업 7': 시설(Facility) 칩 목록을 생성하는 헬퍼 위젯
  Widget _buildFacilityChips(
      List<String> facilityKeys, Set<String> selectedSet) {
    return Wrap(
      spacing: 8.0,
      children: facilityKeys.map((key) {
        return FilterChip(
          label: Text(t['realEstate.filter.amenities.$key'] ?? ''),
          selected: selectedSet.contains(key),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedSet.add(key);
              } else {
                selectedSet.remove(key);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

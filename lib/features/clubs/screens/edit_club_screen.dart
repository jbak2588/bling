// lib/features/clubs/screens/edit_club_screen.dart
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// - (Task 9) 기획서 검토 완료.
// - '모임 제안' V2.0 로직 개편으로 인해 이 파일은 현재 직접 수정 사항 없음.
// - (참고) 이 화면은 '모임 제안' 단계가 아닌, 생성된 '정식 클럽'의 정보 수정용임.
// =====================================================

import 'dart:io';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

// ✅ 1. GeoPoint 클래스 사용을 위해 cloud_firestore를 import 합니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/utils/search_helper.dart';
// ✅ 공용 태그 입력 위젯을 import 합니다.
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
// ✅ 위치 설정을 위해 LocationFilterScreen을 import 합니다.
import 'package:bling_app/features/location/screens/location_filter_screen.dart';

class EditClubScreen extends StatefulWidget {
  final ClubModel club;
  const EditClubScreen({super.key, required this.club});

  @override
  State<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // late List<String> _selectedInterests;
  late List<String> _interestTags;
  late bool _isPrivate;
  bool _isSaving = false;

  XFile? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  final ClubRepository _repository = ClubRepository();
// ✅ 위치 정보를 관리할 상태 변수들을 추가합니다.
  late String _locationName;
  late Map<String, dynamic>? _locationParts;
  late GeoPoint? _geoPoint;

  // final Map<String, List<String>> _interestCategories = {
  //   'category_creative': [
  //     'drawing',
  //     'instrument',
  //     'photography',
  //     'writing',
  //     'crafting',
  //     'gardening'
  //   ],
  //   'category_sports': [
  //     'soccer',
  //     'hiking',
  //     'camping',
  //     'running',
  //     'biking',
  //     'golf',
  //     'workout'
  //   ],
  //   'category_food_drink': [
  //     'foodie',
  //     'cooking',
  //     'baking',
  //     'coffee',
  //     'wine',
  //     'tea'
  //   ],
  //   'category_entertainment': ['movies', 'music', 'concerts', 'gaming'],
  //   'category_growth': ['reading', 'investing', 'language', 'coding'],
  //   'category_lifestyle': ['travel', 'pets', 'volunteering', 'minimalism'],
  // };

  @override
  void initState() {
    super.initState();
    // 기존 동호회 정보로 UI 상태를 초기화합니다.
    _titleController = TextEditingController(text: widget.club.title);
    _descriptionController =
        TextEditingController(text: widget.club.description);
    // _selectedInterests = List<String>.from(widget.club.interestTags);
    // ✅ interestTags를 사용하도록 초기화
    _interestTags = List<String>.from(widget.club.interestTags);
    _isPrivate = widget.club.isPrivate;
    _existingImageUrl = widget.club.imageUrl;

    // ✅ 기존 클럽의 위치 정보로 상태를 초기화합니다.
    _locationName = widget.club.location;
    _locationParts = widget.club.locationParts;
    _geoPoint = widget.club.geoPoint;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _existingImageUrl = null; // 새 이미지를 선택하면 기존 이미지는 무시
      });
    }
  }

  // ✅ 위치를 새로 선택하는 함수를 추가합니다.
  Future<void> _selectLocation() async {
    // [작업 8] LocationFilterScreen 사용 (0번 탭: 행정구역)
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const LocationFilterScreen(initialTabIndex: 0)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // 주소 문자열 생성
        final kKel = result['kel'] != null ? "Kel. ${result['kel']}" : "";
        final kKec = result['kec'] != null ? "Kec. ${result['kec']}" : "";
        final kKab = result['kab'] ?? "";

        _locationName =
            [kKel, kKec, kKab].where((s) => s.toString().isNotEmpty).join(', ');
        _locationParts = result;
        _geoPoint = null; // 좌표 정보 없음
      });
    }
  }

  Future<void> _updateClub() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    // if (_selectedInterests.isEmpty) {
    // ✅ _interestTags로 유효성 검사
    if (_interestTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('clubs.createClub.selectAtLeastOneInterest'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _existingImageUrl;
      // 새 이미지가 선택되었으면 Storage에 업로드
      if (_selectedImage != null) {
        final fileName = const Uuid().v4();
        final ref =
            FirebaseStorage.instance.ref().child('club_images/$fileName');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      // ClubModel 객체를 업데이트된 정보로 새로 만듭니다.
      // [추가] 검색 키워드 생성
      final searchKeywords = SearchHelper.generateSearchIndex(
        title: _titleController.text,
        tags: _interestTags,
        description: _descriptionController.text,
      );

      final updatedClub = ClubModel(
        id: widget.club.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        interestTags: _interestTags,
        isPrivate: _isPrivate,
        ownerId: widget.club.ownerId,
        // 새로 선택된 위치 정보로 업데이트
        location: _locationName,
        locationParts: _locationParts,
        geoPoint: _geoPoint,
        // 수정되지 않는 나머지 필드들은 기존 값을 그대로 사용
        mainCategory: _interestTags.isNotEmpty
            ? _interestTags.first
            : widget.club.mainCategory,
        membersCount: widget.club.membersCount,
        createdAt: widget.club.createdAt,
        kickedMembers: widget.club.kickedMembers,
        pendingMembers: widget.club.pendingMembers,
        searchIndex: searchKeywords,
      );

      await _repository.updateClub(updatedClub);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('clubs.editClub.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'clubs.editClub.fail'.tr(namedArgs: {'error': e.toString()})),
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
        title: Text('clubs.editClub.title'.tr()),
        actions: [
          if (!_isSaving)
            TextButton(
                onPressed: _updateClub, child: Text('clubs.editClub.save'.tr()))
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 대표 이미지 선택 UI
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : (_existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty
                                ? NetworkImage(_existingImageUrl!)
                                : null) as ImageProvider?,
                        child: (_selectedImage == null &&
                                _existingImageUrl == null)
                            ? Icon(Icons.groups,
                                size: 40, color: Colors.grey[600])
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'clubs.createClub.nameLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'clubs.createClub.nameError'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'clubs.createClub.descriptionLabel'.tr(),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'clubs.createClub.descriptionError'.tr();
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                // ✅ 위치 선택 UI를 추가합니다.
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text('clubs.createClub.locationLabel'.tr()),
                  subtitle: Text(_locationName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectLocation,
                ),
                const SizedBox(height: 24),

                Text(
                  "interests.title".tr(), /* ... */
                ),
                const SizedBox(height: 8),
                CustomTagInputField(
                  initialTags: _interestTags,
                  hintText: 'tag_input.help'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _interestTags = tags;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text('clubs.createClub.privateClub'.tr()),
                  subtitle: Text('clubs.createClub.privateDescription'.tr()),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

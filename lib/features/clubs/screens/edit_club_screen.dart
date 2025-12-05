// lib/features/clubs/screens/edit_club_screen.dart
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// - (Task 9) 기획서 검토 완료.
// - '모임 제안' V2.0 로직 개편으로 인해 이 파일은 현재 직접 수정 사항 없음.
// - (참고) 이 화면은 '모임 제안' 단계가 아닌, 생성된 '정식 클럽'의 정보 수정용임.
// =====================================================
// lib/features/clubs/screens/edit_club_screen.dart
// lib/features/clubs/screens/edit_club_screen.dart
// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// - (Task 9) 기획서 검토 완료.
// - '모임 제안' V2.0 로직 개편으로 인해 이 파일은 현재 직접 수정 사항 없음.
// - (참고) 이 화면은 '모임 제안' 단계가 아닌, 생성된 '정식 클럽'의 정보 수정용임.
// [작업 이력 (2025-12-05)]
// - (Task 12) initState 초기화 로직 버그 수정 (Null check operator crash 해결)
// - (Task 14) 개선 사항 적용: 스토리지 고아 이미지 삭제 로직 및 키보드 UX 개선
// =====================================================
// lib/features/clubs/screens/edit_club_screen.dart

import 'dart:io';
import 'package:bling_app/features/clubs/models/club_model.dart';
import 'package:bling_app/features/clubs/models/club_proposal_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';

class EditClubScreen extends StatefulWidget {
  final ClubModel? club;
  final ClubProposalModel? proposal;

  const EditClubScreen({
    super.key,
    this.club,
    this.proposal,
  }) : assert(club != null || proposal != null,
            'Either club or proposal must be provided');

  @override
  State<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _mainCategory;
  final List<String> _categories = [
    'sports',
    'hobbies',
    'social',
    'study',
    'reading',
    'culture',
    'travel',
    'volunteer',
    'pets',
    'food',
    'etc'
  ];

  late List<String> _interestTags;
  late bool _isPrivate;
  double _targetMemberCount = 5.0;

  bool _isSaving = false;

  XFile? _selectedImage;
  String? _existingImageUrl;
  String? _originalImageUrl; // [추가] 삭제 대상 확인을 위한 원본 URL 보관
  final ImagePicker _picker = ImagePicker();

  final ClubRepository _repository = ClubRepository();
  late String _locationName;
  late Map<String, dynamic>? _locationParts;
  late GeoPoint? _geoPoint;

  bool get _isProposal => widget.proposal != null;

  @override
  void initState() {
    super.initState();
    // [수정] Task 12: 데이터 원천을 명확히 분리하여 Null Check Error 방지

    String title;
    String description;
    List<String> tags;
    String? imageUrl;
    String location;
    Map<String, dynamic>? locParts;
    GeoPoint? geo;
    String category;

    if (_isProposal) {
      // 제안(Proposal) 수정 시
      final p = widget.proposal!;
      title = p.title;
      description = p.description;
      tags = p.interestTags;
      imageUrl = p.imageUrl;
      location = p.location;
      locParts = p.locationParts;
      geo = p.geoPoint;
      category = p.mainCategory;

      _targetMemberCount = p.targetMemberCount.toDouble();
      _isPrivate = p.isPrivate;
    } else {
      // 정식 모임(Club) 수정 시
      final c = widget.club!;
      title = c.title;
      description = c.description;
      tags = c.interestTags;
      imageUrl = c.imageUrl;
      location = c.location;
      locParts = c.locationParts;
      geo = c.geoPoint;
      category = c.mainCategory;

      _isPrivate = c.isPrivate;
    }

    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);
    _interestTags = List<String>.from(tags);
    _existingImageUrl = imageUrl;
    _originalImageUrl = imageUrl; // [추가] 초기 이미지 URL 백업
    _locationName = location;
    _locationParts = locParts;
    _geoPoint = geo;
    _mainCategory = category;
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
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const LocationFilterScreen(initialTabIndex: 0)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final kKel = result['kel'] != null ? "Kel. ${result['kel']}" : "";
        final kKec = result['kec'] != null ? "Kec. ${result['kec']}" : "";
        final kKab = result['kab'] ?? "";

        _locationName =
            [kKel, kKec, kKab].where((s) => s.toString().isNotEmpty).join(', ');
        _locationParts = result;
        _geoPoint = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

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
      if (_selectedImage != null) {
        final fileName = const Uuid().v4();
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final storageUserId =
            currentUid ?? widget.club?.ownerId ?? widget.proposal?.ownerId;
        if (storageUserId == null) {
          throw Exception('No authenticated user or owner id for storage path');
        }
        final ref = FirebaseStorage.instance
            .ref()
            .child('club_images/$storageUserId/$fileName');
        await ref.putFile(File(_selectedImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      if (_isProposal) {
        // 제안 업데이트
        final updatedProposal = ClubProposalModel(
          id: widget.proposal!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          ownerId: widget.proposal!.ownerId,
          location: _locationName,
          locationParts: _locationParts,
          geoPoint: _geoPoint,
          mainCategory: _mainCategory,
          interestTags: _interestTags,
          imageUrl: imageUrl ?? '',
          createdAt: widget.proposal!.createdAt,
          isPrivate: _isPrivate,
          targetMemberCount: _targetMemberCount.toInt(),
          currentMemberCount: widget.proposal!.currentMemberCount,
          memberIds: widget.proposal!.memberIds,
        );
        await _repository.updateClubProposal(updatedProposal);
      } else {
        // 정식 모임 업데이트
        final updatedClub = ClubModel(
          id: widget.club!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
          interestTags: _interestTags,
          isPrivate: _isPrivate,
          ownerId: widget.club!.ownerId,
          location: _locationName,
          locationParts: _locationParts,
          geoPoint: _geoPoint,
          mainCategory: _mainCategory,
          membersCount: widget.club!.membersCount,
          createdAt: widget.club!.createdAt,
          kickedMembers: widget.club!.kickedMembers,
          pendingMembers: widget.club!.pendingMembers,
          isSponsored: widget.club!.isSponsored,
          adExpiryDate: widget.club!.adExpiryDate,
        );
        await _repository.updateClub(updatedClub);
      }

      // [추가] 새 이미지가 업로드되었다면, 기존 이미지 삭제 (스토리지 최적화)
      if (_selectedImage != null &&
          _originalImageUrl != null &&
          _originalImageUrl!.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .refFromURL(_originalImageUrl!)
              .delete();
        } catch (_) {
          // 삭제 실패 시 흐름을 막지 않음 (로그만 남기거나 무시)
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('clubs.editClub.success'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
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
        title: Text(_isProposal
            ? 'clubs.proposal.editTitle'.tr()
            : 'clubs.editClub.title'.tr()),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _submit,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // [추가] 빈 곳 터치 시 키보드 숨김
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- 이미지 선택 ---
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
                      border: const OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
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

                  // 카테고리 선택
                  DropdownButtonFormField<String>(
                    initialValue: _categories.contains(_mainCategory)
                        ? _mainCategory
                        : null,
                    decoration: InputDecoration(
                      labelText: 'clubs.createClub.categoryLabel'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('clubs.categories.$cat'.tr()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _mainCategory = val);
                    },
                  ),

                  const SizedBox(height: 24),

                  Text("interests.title".tr()),
                  const SizedBox(height: 8),
                  CustomTagInputField(
                    initialTags: _interestTags,
                    hintText: 'tag_input.addHint'.tr(),
                    onTagsChanged: (tags) {
                      setState(() {
                        _interestTags = tags;
                      });
                    },
                  ),

                  // V V V --- [분기] 제안일 경우 '목표 인원', 정식 모임일 경우 '비공개 설정' --- V V V
                  if (_isProposal) ...[
                    const SizedBox(height: 24),
                    Text(
                      'clubs.proposal.targetMembers'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _targetMemberCount,
                            min: 3,
                            max: 50,
                            divisions: 47,
                            label: _targetMemberCount.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _targetMemberCount = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          '${_targetMemberCount.toInt()}명',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('clubs.createClub.privateClub'.tr()),
                      subtitle:
                          Text('clubs.createClub.privateDescription'.tr()),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text('clubs.createClub.privateClub'.tr()),
                      subtitle:
                          Text('clubs.createClub.privateDescription'.tr()),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 88),
                ],
              ),
            ),
            if (_isSaving)
              Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FilledButton(
            onPressed: _isSaving ? null : _submit,
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
}

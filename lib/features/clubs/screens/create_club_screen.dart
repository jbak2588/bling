// ===================== DocHeader =====================
// [작업 이력 (2025-11-02)]
// 1. (Task 9-2) 기획서 6.1 '모임 제안' V2.0 로직 적용.
// 2. '클럽 즉시 생성'에서 '모임 제안하기' 화면으로 변경.
// 3. 'ClubModel' 대신 'ClubProposalModel'을 생성하도록 수정.
// 4. 'repository.createClubProposal'을 호출하도록 변경.
// 5. (Task 11) [UI 추가] '목표 인원' (targetMemberCount)을 설정하는 'Slider' 위젯 추가.
// =====================================================
// lib/features/clubs/screens/create_club_screen.dart

import 'dart:io'; // [추가] File 클래스 사용
import 'package:bling_app/features/clubs/models/club_proposal_model.dart'; // [수정] ClubModel -> ClubProposalModel
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // [추가] Firebase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // [추가] image_picker
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart'; // [추가] 고유 파일명 생성
import 'package:easy_localization/easy_localization.dart';

// ✅ 공용 태그 입력 위젯을 import 합니다.
import 'package:bling_app/features/shared/widgets/custom_tag_input_field.dart';

class CreateClubScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateClubScreen({super.key, required this.userModel});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TextEditingController _targetCountController =
      TextEditingController(text: '5');

  // final List<String> _selectedInterests = [];

  // ✅ 새로운 태그 상태 변수를 추가합니다.
  // ignore: unused_field, prefer_final_fields
  String _locationName = '';
  // ignore: unused_field
  GeoPoint? _geoPoint;

  // ignore: prefer_final_fields
  String _mainCategory = 'sports'; // [추가]
  List<String> _interestTags = []; // [추가]

  // [추가] 목표 인원 설정
  // ignore: prefer_final_fields
  double _targetMemberCount = 5.0; // Slider의 기본값

  bool _isPrivate = false; // [수정] 비공개 여부 (제안에서는 제거해도 무방하나 유지)
  bool _isSaving = false;
  Map<String, String?>? _selectedLocationParts;

  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final ClubRepository _repository = ClubRepository();

  // [수정] find_friend와 동일한 전체 관심사 목록을 사용합니다.
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _targetCountController.text = _targetMemberCount.toInt().toString();
  }

  // [추가] 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<Map<String, String?>>(
        MaterialPageRoute(builder: (_) => const LocationFilterScreen()));
    if (result != null) {
      setState(() => _selectedLocationParts = result);
    }
  }

  // [수정] 동호회 생성 로직 구현

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }
    // if (_selectedInterests.isEmpty) {

    // ✅ 태그(관심사)를 1개 이상 입력했는지 검사합니다.
    if (_interestTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('clubs.createClub.selectAtLeastOneInterest'.tr())),
      );
      return;
    }
    if (_selectedLocationParts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select location')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? imageUrl;
      // [수정] 이미지가 선택되었으면 Storage에 업로드
      if (_image != null) {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('club_images/${widget.userModel.uid}/$fileName');
        await ref.putFile(File(_image!.path));
        imageUrl = await ref.getDownloadURL();
      }

      final parts = widget.userModel.locationParts;

      // [수정] ClubModel 대신 ClubProposalModel 생성
      final newProposal = ClubProposalModel(
        id: '', // Firestore에서 자동 생성
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: widget.userModel.uid,
        location: parts?['kel'] ??
            parts?['kec'] ??
            parts?['kab'] ??
            parts?['kota'] ??
            parts?['prov'] ??
            'Unknown',
        locationParts: parts,
        geoPoint: widget.userModel.geoPoint,
        mainCategory: _mainCategory,
        interestTags: _interestTags,
        imageUrl: imageUrl ?? '',
        createdAt: Timestamp.now(),
        targetMemberCount: _targetMemberCount.toInt(), // 목표 인원
        currentMemberCount: 1,
        memberIds: [widget.userModel.uid],
      );

      // [수정] createClub -> createClubProposal 호출
      await _repository.createClubProposal(newProposal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.proposal.createSuccess'.tr()),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.proposal.createFail'
              .tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('clubs.proposal.createTitle'.tr()), // "모임 제안하기"
        actions: [
          // [수정] _isSaving 상태에 따라 버튼 활성화/비활성화
          if (!_isSaving)
            TextButton(
              onPressed: _createClub,
              child: Text('common.done'.tr()),
            )
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // V V V --- [추가] 대표 이미지 선택 UI --- V V V
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : null,
                        child: _image == null
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
                ListTile(
                  title: const Text('Location'),
                  subtitle: Text(
                    _selectedLocationParts?['kel'] ??
                        _selectedLocationParts?['kec'] ??
                        _selectedLocationParts?['kab'] ??
                        _selectedLocationParts?['kota'] ??
                        _selectedLocationParts?['prov'] ??
                        'Select location',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectLocation,
                ),
                const SizedBox(height: 24),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text("interests.title".tr(),
                //         style: const TextStyle(
                //             fontWeight: FontWeight.bold, fontSize: 16)),
                //     Text('${_selectedInterests.length}/3',
                //         style: const TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color: Colors.teal)), // 동호회는 최대 3개로 제한
                //   ],
                // ),
                // const SizedBox(height: 8),
                // ..._interestCategories.entries.map((entry) {
                //   final interestKeys = entry.value;
                //   return ExpansionTile(
                //     title: Text("interests.$categoryKey".tr(),
                //         style: const TextStyle(fontWeight: FontWeight.w500)),
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Wrap(
                //           spacing: 8.0,
                //           runSpacing: 4.0,
                //           children: interestKeys.map((interestKey) {
                //             final isSelected =
                //                 _selectedInterests.contains(interestKey);
                //             return FilterChip(
                //               label: Text("interests.items.$interestKey".tr()),
                //               selected: isSelected,
                //               onSelected: (selected) {
                //                 setState(() {
                //                   if (selected) {
                //                     if (_selectedInterests.length < 3) {
                //                       // 최대 3개 제한
                //                       _selectedInterests.add(interestKey);
                //                     } else {
                //                       ScaffoldMessenger.of(context)
                //                           .showSnackBar(
                //                         SnackBar(
                //                             content: Text(
                //                                 'clubs.createClub.maxInterests'
                //                                     .tr())),
                //                       );
                //                     }
                //                   } else {
                //                     _selectedInterests.remove(interestKey);
                //                   }
                //                 });
                //               },
                //             );
                //           }).toList(),
                //         ),
                //       )
                //     ],
                //   );
                // }),

                // ✅ 기존의 복잡한 관심사 선택 UI를 공용 태그 위젯으로 교체합니다.
                Text("interests.title".tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                CustomTagInputField(
                  hintText: 'clubs.proposal.tagsHint'.tr(),
                  onTagsChanged: (tags) {
                    setState(() {
                      _interestTags = tags;
                    });
                  },
                ),

                // [추가] 목표 인원 설정: 슬라이더 + 직접 입력
                const SizedBox(height: 24),
                Text(
                  'clubs.proposal.targetMembers'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 슬라이더
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
                            _targetCountController.text =
                                value.toInt().toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 숫자 직접 입력 필드
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _targetCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null) {
                            final clamped = parsed.clamp(3, 50);
                            if (clamped != parsed) {
                              // 범위 밖이면 즉시 보정
                              _targetCountController.text = clamped.toString();
                              _targetCountController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _targetCountController.text.length),
                              );
                            }
                            setState(() {
                              _targetMemberCount = clamped.toDouble();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  'clubs.proposal.targetMembersCount'.tr(namedArgs: {
                    'count': _targetMemberCount.toInt().toString()
                  }),
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
          // 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

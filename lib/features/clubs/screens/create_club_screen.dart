// lib/features/clubs/screens/create_club_screen.dart

import 'package:bling_app/core/models/club_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/clubs/data/club_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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

  final List<String> _selectedInterests = [];
  bool _isPrivate = false;
  bool _isSaving = false;

  final ClubRepository _repository = ClubRepository();

// [수정] find_friend와 동일한 전체 관심사 목록을 사용합니다.
  final Map<String, List<String>> _interestCategories = {
    'category_creative': [
      'drawing',
      'instrument',
      'photography',
      'writing',
      'crafting',
      'gardening'
    ],
    'category_sports': [
      'soccer',
      'hiking',
      'camping',
      'running',
      'biking',
      'golf',
      'workout'
    ],
    'category_food_drink': [
      'foodie',
      'cooking',
      'baking',
      'coffee',
      'wine',
      'tea'
    ],
    'category_entertainment': ['movies', 'music', 'concerts', 'gaming'],
    'category_growth': ['reading', 'investing', 'language', 'coding'],
    'category_lifestyle': ['travel', 'pets', 'volunteering', 'minimalism'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // [수정] 동호회 생성 로직 구현

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('clubs.createClub.selectAtLeastOneInterest'.tr())),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newClub = ClubModel(
        id: '', // ID는 Firestore에서 자동으로 생성됩니다.
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: widget.userModel.uid,
        location: widget.userModel.locationParts?['kec'] ??
            'Unknown', // 사용자의 Kecamatan 정보 활용
        // interests: _selectedInterests, // Removed or renamed as per ClubModel definition
        isPrivate: _isPrivate,
        createdAt: Timestamp.now(),
        membersCount: 1, // 개설자는 자동으로 멤버 1명이 됩니다.
        mainCategory: _selectedInterests.isNotEmpty
            ? _interestCategories.entries
                .firstWhere(
                  (entry) => entry.value.contains(_selectedInterests.first),
                  orElse: () => _interestCategories.entries.first,
                )
                .key
            : '', // 첫 번째 선택된 관심사의 카테고리, 없으면 빈 문자열
        interestTags: _selectedInterests, // 선택된 관심사 리스트
      );

      await _repository.createClub(newClub);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('clubs.createClub.success'.tr()),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'clubs.createClub.fail'.tr(namedArgs: {'error': e.toString()})),
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
        title: Text('clubs.createClub.title'.tr()),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("interests.title".tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_selectedInterests.length}/3',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)), // 동호회는 최대 3개로 제한
                  ],
                ),
                const SizedBox(height: 8),
                ..._interestCategories.entries.map((entry) {
                  final categoryKey = entry.key;
                  final interestKeys = entry.value;
                  return ExpansionTile(
                    title: Text("interests.$categoryKey".tr(),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: interestKeys.map((interestKey) {
                            final isSelected =
                                _selectedInterests.contains(interestKey);
                            return FilterChip(
                              label: Text("interests.items.$interestKey".tr()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    if (_selectedInterests.length < 3) {
                                      // 최대 3개 제한
                                      _selectedInterests.add(interestKey);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'clubs.createClub.maxInterests'
                                                    .tr())),
                                      );
                                    }
                                  } else {
                                    _selectedInterests.remove(interestKey);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  );
                }),
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

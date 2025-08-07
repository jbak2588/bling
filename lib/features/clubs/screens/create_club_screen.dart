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
  
  List<String> _selectedInterests = [];
  bool _isPrivate = false;
  bool _isSaving = false;
  
  final ClubRepository _repository = ClubRepository();

// [수정] find_friend와 동일한 전체 관심사 목록을 사용합니다.
  final Map<String, List<String>> _interestCategories = {
    'category_creative': ['drawing', 'instrument', 'photography', 'writing', 'crafting', 'gardening'],
    'category_sports': ['soccer', 'hiking', 'camping', 'running', 'biking', 'golf', 'workout'],
    'category_food_drink': ['foodie', 'cooking', 'baking', 'coffee', 'wine', 'tea'],
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
        SnackBar(content: Text('관심사를 1개 이상 선택해주세요.')), // TODO: 다국어
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
        location: widget.userModel.locationParts?['kec'] ?? 'Unknown', // 사용자의 Kecamatan 정보 활용
        interests: _selectedInterests,
        isPrivate: _isPrivate,
        createdAt: Timestamp.now(),
        membersCount: 1, // 개설자는 자동으로 멤버 1명이 됩니다.
      );

      await _repository.createClub(newClub);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동호회가 성공적으로 만들어졌습니다!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동호회 생성에 실패했습니다: $e'), backgroundColor: Colors.red),
        );
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
        title: Text('새 동호회 만들기'),
        actions: [
          // [수정] _isSaving 상태에 따라 버튼 활성화/비활성화
          if (!_isSaving)
            TextButton(
              onPressed: _createClub,
              child: Text('완료'),
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
                    labelText: '동호회 이름',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '동호회 이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '동호회 소개',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '동호회 소개를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("interests.title".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_selectedInterests.length}/3', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)), // 동호회는 최대 3개로 제한
                  ],
                ),
                const SizedBox(height: 8),
                ..._interestCategories.entries.map((entry) {
                  final categoryKey = entry.key;
                  final interestKeys = entry.value;
                  return ExpansionTile(
                    title: Text("interests.$categoryKey".tr(), style: const TextStyle(fontWeight: FontWeight.w500)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: interestKeys.map((interestKey) {
                            final isSelected = _selectedInterests.contains(interestKey);
                            return FilterChip(
                              label: Text("interests.items.$interestKey".tr()),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    if (_selectedInterests.length < 3) { // 최대 3개 제한
                                      _selectedInterests.add(interestKey);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('관심사는 최대 3개까지 선택할 수 있습니다.')), // TODO: 다국어
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
                  title: Text('비공개 동호회'),
                  subtitle: Text('초대를 통해서만 가입할 수 있습니다.'),
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
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
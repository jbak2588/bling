// lib/features/find_friends/screens/findfriend_form_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/controllers/find_friend_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindFriendFormScreen extends StatefulWidget {
  const FindFriendFormScreen({super.key});

  @override
  State<FindFriendFormScreen> createState() => _FindFriendFormScreenState();
}

class _FindFriendFormScreenState extends State<FindFriendFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 각 입력 필드를 위한 컨트롤러 선언
  late TextEditingController _bioController;
  late TextEditingController _ageController;
  String? _selectedGender;
  List<String> _selectedInterests = [];
  bool _isVisibleInList = true;

  // 유저 데이터 로딩 상태를 관리하는 변수
  bool _isUserDataLoading = true;

  @override
  void initState() {
    super.initState();
    // 컨트롤러들을 우선 빈 값으로 초기화
    _bioController = TextEditingController();
    _ageController = TextEditingController();
    // 화면이 시작될 때 Firestore에서 직접 유저 정보를 가져옵니다.
    _loadUserData();
  }

  // Firestore에서 직접 현재 로그인된 사용자의 데이터를 가져오는 함수
  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      if (mounted) {
        // 로그인 되어있지 않으면 로딩을 멈추고, 경고 후 이전 화면으로 이동
        setState(() => _isUserDataLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();

      if (mounted && userDoc.exists) {
        final user = UserModel.fromFirestore(userDoc);
        // 가져온 데이터로 각 컨트롤러의 값을 채웁니다.
        setState(() {
          _bioController.text = user.bio ?? '';
          _ageController.text = user.age?.toString() ?? '';
          _selectedGender = user.gender;
          _selectedInterests = user.interests ?? [];
          _isVisibleInList = user.isVisibleInList;
        });
      }
    } catch (e) {
      // 데이터 로딩 중 에러 발생 시 처리
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보를 불러오는데 실패했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 성공하든 실패하든 로딩 상태를 false로 변경
      if (mounted) {
        setState(() => _isUserDataLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // 저장 버튼을 눌렀을 때의 동작
  void _submitForm(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<FindFriendController>();
    // Controller에 모든 데이터를 넘겨줍니다.
    final success = await controller.saveProfile(
      bio: _bioController.text,
      interests: _selectedInterests,
      // 여기에 나이, 성별 등 다른 데이터를 추가할 수 있습니다.
      // 예시:
      // age: int.tryParse(_ageController.text),
      // gender: _selectedGender,
      // isVisible: _isVisibleInList,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 저장되었습니다!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? '알 수 없는 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 로딩 중일 때 로딩 화면 표시
    if (_isUserDataLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Consumer를 사용하여 Controller의 상태 변화를 감지
    return Consumer<FindFriendController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('친구 찾기 프로필 수정'),
            actions: [
              if (!controller.isLoading)
                TextButton(
                  onPressed: () => _submitForm(context),
                  child: const Text('저장'),
                ),
            ],
          ),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // --- 자기소개 ---
                    const Text('자기소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '자신을 다른 사람에게 소개해보세요.',
                      ),
                       validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '자기소개를 입력해주세요.';
                          }
                          return null;
                        },
                    ),
                    const SizedBox(height: 24),

                    // --- 나이 ---
                    const Text('나이', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '만 나이를 숫자로만 입력해주세요.',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 성별 ---
                    const Text('성별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: ['male', 'female']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label == 'male' ? '남성' : '여성'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '성별을 선택하세요',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 관심사 ---
                    const Text('관심사', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: ['운동', '영화', '여행', '게임', '요리', '음악', '독서', '패션']
                          .map((interest) => FilterChip(
                                label: Text(interest),
                                // ignore: deprecated_member_use
                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                selected: _selectedInterests.contains(interest),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedInterests.add(interest);
                                    } else {
                                      _selectedInterests.remove(interest);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // --- 프로필 공개 여부 ---
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('친구 찾기 리스트에 내 프로필 노출'),
                      subtitle: const Text('끄면 다른 사람이 나를 찾을 수 없습니다.'),
                      value: _isVisibleInList,
                      onChanged: (value) {
                        setState(() {
                          _isVisibleInList = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Controller가 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
              if (controller.isLoading)
                Container(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
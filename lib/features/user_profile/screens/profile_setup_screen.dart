import 'dart:io';

import 'package:bling_app/core/models/user_model.dart';
// import 'package:bling_app/core/utils/logging/logger.dart'; // [수정] Log 미사용 시 주석 처리 또는 삭제
// import 'package:bling_app/core/utils/upload_helpers.dart'; // [수정] 로컬 구현으로 대체하므로 제거 가능
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // [추가] 직접 업로드를 위해 추가
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // [추가] 확장자 추출용

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = true;
  File? _selectedImageFile;
  String? _currentProfileImageUrl;

  // 약관 동의 상태
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _marketingAgreed = false;

  // 개인정보 설정 상태
  bool _isVisibleInList = true;

  final List<String> _availableInterests = [
    'electronics',
    'fashion',
    'home_decor',
    'books',
    'sports',
    'beauty',
    'toys',
    'gaming',
    'cooking',
    'travel',
    'music',
    'art'
  ];
  final List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        // [수정 1] unused_local_variable 해결 (data 변수 제거)
        // final data = doc.data()!;
        final userModel = UserModel.fromFirestore(doc);

        setState(() {
          // [수정 2] dead_null_aware_expression 해결 (nickname은 String이므로 ?? '' 불필요)
          _nicknameController.text = userModel.nickname;

          if (userModel.interests != null) {
            _selectedInterests.addAll(userModel.interests!);
          }

          // [수정 3] undefined_getter 해결 (profileImage -> photoUrl)
          _currentProfileImageUrl = userModel.photoUrl;

          // [수정 4] invalid_assignment 해결 (bool? -> bool 변환)
          _isVisibleInList = userModel.isVisibleInList ?? true;

          _termsAgreed = userModel.termsAgreed ?? false;
          _privacyAgreed = userModel.privacyAgreed ?? false;
          _marketingAgreed = userModel.marketingAgreed ?? false;
        });
      }
    } catch (e) {
      // [수정 5] Undefined name 'Log' 해결 -> debugPrint 사용
      debugPrint('ProfileSetup: 데이터 로드 실패 - $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [추가] 프로필 이미지 업로드 로직 (UploadHelpers 의존성 제거)
  Future<String> _uploadProfileImage(File imageFile, String userId) async {
    final ext = p.extension(imageFile.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_profiles/$userId/profile$ext'); // 프로필 전용 경로
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAgreed || !_privacyAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? downloadUrl = _currentProfileImageUrl;

      if (_selectedImageFile != null) {
        // [수정 6] Undefined name 'UploadHelpers' 해결 -> 내부 메서드 사용
        downloadUrl = await _uploadProfileImage(_selectedImageFile!, user.uid);
      }

      // Firestore 업데이트 (User Model 필드명과 일치시킴)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'nickname': _nicknameController.text.trim(),
        'photoUrl': downloadUrl, // [중요] user_model.dart 필드명은 photoUrl
        'interests': _selectedInterests,
        'isVisibleInList': _isVisibleInList,
        'termsAgreed': _termsAgreed,
        'privacyAgreed': _privacyAgreed,
        'marketingAgreed': _marketingAgreed,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 성공 시 AuthGate가 감지 (자동 이동)
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 완성하기'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (이미지 선택 위젯 기존 동일) ...
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _selectedImageFile != null
                              ? FileImage(_selectedImageFile!)
                              : (_currentProfileImageUrl != null
                                  ? NetworkImage(_currentProfileImageUrl!)
                                  : null) as ImageProvider?,
                          child: (_selectedImageFile == null &&
                                  _currentProfileImageUrl == null)
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A66C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ... (닉네임 입력 필드 기존 동일) ...
                Text('닉네임 (필수)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: '닉네임 입력',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? '닉네임을 입력해주세요.'
                      : null,
                ),
                const SizedBox(height: 24),

                // ... (관심사 선택 기존 동일) ...
                Text('관심사 (선택)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _selectedInterests.add(interest)
                              : _selectedInterests.remove(interest);
                        });
                      },
                      selectedColor:
                          const Color(0xFF00A66C).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFF00A66C),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Divider(),
                Text('설정',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                SwitchListTile(
                  title: const Text('친구 찾기 리스트에 내 프로필 노출'),
                  value: _isVisibleInList,
                  // [수정 7] deprecated 'activeColor' -> 'activeColor' (최신 Flutter에서는 activeThumbColor 권장하나 호환성 위해 기존 속성 사용 또는 경고에 따라 수정)
                  // 권장: deprecated된 `activeColor` 대신 `activeThumbColor` 사용
                  activeThumbColor: const Color(0xFF00A66C),
                  // 트랙 색상도 함께 지정하면 더 나은 대비를 제공합니다.
                  activeTrackColor: const Color(0xFFBFEFDD),
                  onChanged: (val) => setState(() => _isVisibleInList = val),
                ),

                const SizedBox(height: 24),

                // ... (약관 동의 및 버튼 기존 동일) ...
                const Divider(),
                _buildCheckbox('이용약관 동의 (필수)', _termsAgreed,
                    (val) => setState(() => _termsAgreed = val!)),
                _buildCheckbox('개인정보 처리방침 동의 (필수)', _privacyAgreed,
                    (val) => setState(() => _privacyAgreed = val!)),
                _buildCheckbox('마케팅 정보 수신 동의 (선택)', _marketingAgreed,
                    (val) => setState(() => _marketingAgreed = val!)),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A66C),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('시작하기',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (_buildCheckbox 기존 동일) ...
  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF00A66C),
    );
  }
}

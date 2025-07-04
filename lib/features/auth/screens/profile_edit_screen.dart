import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  // final dynamic user; // 추후 사용자 정보를 받기 위한 변수
  const ProfileEditScreen({super.key/*, required this.user*/});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: const Center(
        child: Text('닉네임 등 프로필을 설정하는 화면입니다.'),
      ),
    );
  }
}
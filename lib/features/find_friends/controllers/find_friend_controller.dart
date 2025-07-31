// [설명] 사용자의 입력 처리, 상태 관리, Repository 호출 등 모든 비즈니스 로직을 담당합니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/find_friend_repository.dart';

class FindFriendController with ChangeNotifier {
  final FindFriendRepository _repository = FindFriendRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 프로필 저장 로직
  Future<bool> saveProfile({
    required String bio,
    required List<String> interests,
    // 필요 시 mbti 등 다른 필드 추가
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _errorMessage = "로그인이 필요합니다.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // UserModel의 기존 필드를 사용하여 데이터 맵 구성
    final dataToUpdate = {
      'bio': bio,
      'interests': interests,
      'isDatingProfile': true, // 친구 찾기 프로필 활성화
      'profileCompleted': true, // 프로필 작성을 완료했음으로 표시
      'updatedAt': FieldValue.serverTimestamp(), // 수정 시각 업데이트
    };

    try {
      await _repository.updateUserProfile(userId, dataToUpdate);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '프로필 저장에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
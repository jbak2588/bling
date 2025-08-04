// lib/features/find_friends/controllers/find_friend_controller.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // [수정] debugPrint를 사용하기 위해 임포트
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [수정] FieldValue를 사용하기 위해 임포트
import 'package:uuid/uuid.dart';
import '../data/find_friend_repository.dart';

class FindFriendController with ChangeNotifier {
  final FindFriendRepository _repository = FindFriendRepository();
  // final ImagePicker _picker = ImagePicker(); // [수정] 사용하지 않으므로 삭제

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 이미지 업로드 로직
  Future<List<String>> _uploadImages(String userId, List<File> images) async {
    final List<String> downloadUrls = [];
    for (var imageFile in images) {
      try {
        final fileName = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('find_friend_images')
            .child(userId)
            .child(fileName);

        final uploadTask = await ref.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        // [수정] print를 debugPrint로 변경
        debugPrint('이미지 업로드 실패: $e');
      }
    }
    return downloadUrls;
  }

  // 프로필 저장 로직 (전체 필드 포함)
  Future<bool> saveProfile({
    String? bio,
    List<String>? interests,
    int? age,
    String? gender,
    bool? isVisible,
    String? ageRange,
    String? genderPreference,
    List<File> newImages = const [],
    List<String> existingImageUrls = const [],
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

    try {
      final newImageUrls = await _uploadImages(userId, newImages);
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      final dataToUpdate = <String, dynamic>{
        'isDatingProfile': true,
        'updatedAt': FieldValue.serverTimestamp(), // [수정] FieldValue.serverTimestamp() 사용
      };
      
      // null이 아닌 값들만 업데이트 맵에 추가
      if (bio != null) dataToUpdate['bio'] = bio;
      if (interests != null) dataToUpdate['interests'] = interests;
      if (age != null) dataToUpdate['age'] = age;
      if (gender != null) dataToUpdate['gender'] = gender;
      if (isVisible != null) dataToUpdate['isVisibleInList'] = isVisible;
      if (ageRange != null) dataToUpdate['ageRange'] = ageRange;
      if (allImageUrls.isNotEmpty) dataToUpdate['findfriendProfileImages'] = allImageUrls;
      
      // privacySettings는 맵이므로 별도 처리
      if (genderPreference != null) {
        dataToUpdate['privacySettings'] = {
          'findFriendEnabled': true,
          'genderPreference': genderPreference,
        };
      }


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
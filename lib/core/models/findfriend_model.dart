// lib/core/models/findfriend_model.dart
// Model for FindFriend profile as described in FindFriend_Feature_Spec

import 'package:cloud_firestore/cloud_firestore.dart';

class FindFriend {
  final String userId;
  final String nickname;
  final List<String> profileImages;
  final String? location;
  final List<String>? interests;
  final String? ageRange;
  final String? gender;
  final String? bio;
  final bool isDatingProfile;
  final bool isNeighborVerified;
  final int trustLevel;

  FindFriend({
    required this.userId,
    required this.nickname,
    required this.profileImages,
    this.location,
    this.interests,
    this.ageRange,
    this.gender,
    this.bio,
    this.isDatingProfile = false,
    this.isNeighborVerified = false,
    this.trustLevel = 0,
  });

  factory FindFriend.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FindFriend.fromMap(data, doc.id);
  }

  factory FindFriend.fromMap(Map<String, dynamic> data, String id) {
    return FindFriend(
      userId: data['userId'] ?? id,
      nickname: data['nickname'] ?? '',
      profileImages: data['profileImages'] != null
          ? List<String>.from(data['profileImages'])
          : <String>[],
      location: data['location'],
      interests:
          data['interests'] != null ? List<String>.from(data['interests']) : null,
      ageRange: data['ageRange'],
      gender: data['gender'],
      bio: data['bio'],
      isDatingProfile: data['isDatingProfile'] ?? false,
      isNeighborVerified: data['isNeighborVerified'] ?? false,
      trustLevel: data['trustLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'profileImages': profileImages,
      'location': location,
      'interests': interests,
      'ageRange': ageRange,
      'gender': gender,
      'bio': bio,
      'isDatingProfile': isDatingProfile,
      'isNeighborVerified': isNeighborVerified,
      'trustLevel': trustLevel,
    };
  }
}
